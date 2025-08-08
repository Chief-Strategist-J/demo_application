import 'dart:async';
import 'package:demo_application/models/call_request.dart';
import 'package:demo_application/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/features/users/bloc/users_event.dart';
import 'package:demo_application/features/users/bloc/users_state.dart';
import 'package:demo_application/services/firebase_service.dart';
import 'package:demo_application/services/auth_service.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  StreamSubscription<CallRequest?>? _callStatusSubscription;

  UsersBloc() : super(const UsersState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<InitiateCallEvent>(_onInitiateCall);
    on<CancelCallEvent>(_onCancelCall);
    on<RefreshUsersEvent>(_onRefreshUsers);
    on<CallStatusChanged>(_onCallStatusChanged);

    // Load users immediately
    add(LoadUsersEvent());
  }

  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final currentUser = await _authService.getCurrentUserData();

      await emit.forEach<List<User>>(
        _firebaseService.getUsers(),
        onData: (users) {
          return state.copyWith(
            users: users,
            currentUser: currentUser,
            loading: false,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            loading: false,
            error: 'Error loading users: $error',
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Failed to load users: $e',
      ));
    }
  }

  Future<void> _onInitiateCall(InitiateCallEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final callRequest = await _firebaseService.initiateCall(event.receiver);

      if (callRequest != null) {
        // Start listening for call status changes
        _startListeningForCallStatus(callRequest.id);
        
        emit(state.copyWith(
          loading: false,
          callInitiated: true,
          activeCall: callRequest,
        ));
      } else {
        emit(state.copyWith(
          loading: false,
          error: 'Failed to initiate call. User may be busy.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Failed to initiate call: $e',
      ));
    }
  }

  Future<void> _onCancelCall(CancelCallEvent event, Emitter<UsersState> emit) async {
    if (state.activeCall != null) {
      try {
        await _firebaseService.endCall(state.activeCall!.id);
        _stopListeningForCallStatus();
        emit(state.copyWith(
          callInitiated: false,
          activeCall: null,
          callAccepted: false,
          callDeclined: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          error: 'Failed to cancel call: $e',
        ));
      }
    }
  }

  void _onRefreshUsers(RefreshUsersEvent event, Emitter<UsersState> emit) {
    add(LoadUsersEvent());
  }

  void _onCallStatusChanged(CallStatusChanged event, Emitter<UsersState> emit) {
    final updatedCall = event.callRequest;
    
    // Update the active call with new status
    emit(state.copyWith(activeCall: updatedCall));
    
    // Handle different call status changes
    switch (updatedCall.status) {
      case CallStatus.accepted:
        // Call was accepted, navigate to meeting should be handled by UI
        emit(state.copyWith(
          callAccepted: true,
          callInitiated: false,
        ));
        _stopListeningForCallStatus();
        break;
      case CallStatus.declined:
      case CallStatus.ended:
        // Call was declined or ended
        emit(state.copyWith(
          callInitiated: false,
          activeCall: null,
          callDeclined: updatedCall.status == CallStatus.declined,
        ));
        _stopListeningForCallStatus();
        break;
      default:
        // Keep waiting for other status changes
        break;
    }
  }

  void _startListeningForCallStatus(String callId) {
    _callStatusSubscription?.cancel();
    _callStatusSubscription = _firebaseService
        .listenForOutgoingCallUpdates(callId)
        .listen((callRequest) {
      if (callRequest != null) {
        add(CallStatusChanged(callRequest));
      }
    });
  }

  void _stopListeningForCallStatus() {
    _callStatusSubscription?.cancel();
    _callStatusSubscription = null;
  }

  @override
  Future<void> close() {
    _stopListeningForCallStatus();
    return super.close();
  }
}
