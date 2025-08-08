import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/features/users/bloc/users_event.dart';
import 'package:demo_application/features/users/bloc/users_state.dart';
import 'package:demo_application/services/firebase_service.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _usersSubscription;

  UsersBloc() : super(const UsersState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<CreateDemoUsersEvent>(_onCreateDemoUsers);
    on<InitiateCallEvent>(_onInitiateCall);
    on<CancelCallEvent>(_onCancelCall);
    on<RefreshUsersEvent>(_onRefreshUsers);

    // Initialize Firebase service
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await _firebaseService.initialize();
      add(LoadUsersEvent());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to initialize: $e'));
    }
  }

  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Get current user
      final currentUser = _firebaseService.currentUser;
      
      // Listen to users stream
      await _usersSubscription?.cancel();
      _usersSubscription = _firebaseService.getUsers().listen(
        (users) {
          if (!isClosed) {
            emit(state.copyWith(
              users: users,
              currentUser: currentUser,
              loading: false,
            ));
          }
        },
        onError: (error) {
          emit(state.copyWith(
            loading: false,
            error: 'Error loading users: $error',
          ));
        },
      );

      // Initial emit with current user
      emit(state.copyWith(currentUser: currentUser, loading: false));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Failed to load users: $e',
      ));
    }
  }

  Future<void> _onCreateDemoUsers(CreateDemoUsersEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await _firebaseService.createDemoUsers();
      emit(state.copyWith(loading: false));
      
      // Refresh users list
      add(LoadUsersEvent());
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Failed to create demo users: $e',
      ));
    }
  }

  Future<void> _onInitiateCall(InitiateCallEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final callRequest = await _firebaseService.initiateCall(event.receiver);
      
      if (callRequest != null) {
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
        emit(state.copyWith(
          callInitiated: false,
          activeCall: null,
        ));
      } catch (e) {
        emit(state.copyWith(
          error: 'Failed to cancel call: $e',
        ));
      }
    }
  }

  void _onRefreshUsers(RefreshUsersEvent event, Emitter<UsersState> emit) {
    // This event is triggered by the stream listener
    // No additional logic needed here
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _firebaseService.dispose();
    return super.close();
  }
}
