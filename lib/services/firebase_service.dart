import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:demo_application/models/user.dart' as app_user;
import 'package:demo_application/models/call_request.dart';
import 'package:demo_application/features/videoCall/services/video_call_service.dart';
import 'package:demo_application/services/auth_service.dart';
import 'package:demo_application/services/firebase_utils.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AuthService _authService = AuthService();

  StreamSubscription? _callRequestSubscription;
  StreamSubscription? _presenceSubscription;

  // Collections
  static const String usersCollection = 'users';
  static const String callRequestsCollection = 'call_requests';

  // Initialize Firebase service
  Future<void> initialize() async {
    if (!_authService.isLoggedIn) {
      throw Exception('User must be logged in to initialize Firebase service');
    }
    _setupPresenceSystem();
  }

  void _setupPresenceSystem() async {
    final userId = _authService.currentFirebaseUser?.uid;
    if (userId == null) return;

    // Set up real-time presence
    final presenceRef = _database.child('presence').child(userId);
    final isOnlineRef = _database.child('.info/connected');

    _presenceSubscription = isOnlineRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        presenceRef.onDisconnect().set({
          'isOnline': false,
          'lastSeen': ServerValue.timestamp,
        });
        presenceRef.set({'isOnline': true, 'lastSeen': ServerValue.timestamp});
      }
    });

    // Update Firestore user online status
    await _authService.updateOnlineStatus(true);
  }

  // Get all users except current user
  Stream<List<app_user.User>> getUsers() {
    final currentUserId = _authService.currentFirebaseUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection(usersCollection)
        .where('id', isNotEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => app_user.User.fromJson(doc.data()))
              .toList(),
        );
  }

  // Initiate a video call
  Future<CallRequest?> initiateCall(app_user.User receiver) async {
    final currentUser = await _authService.getCurrentUserData();
    if (currentUser == null || receiver.isInCall) return null;

    try {
      // Create meeting ID using video SDK
      final meetingId = await createMeeting();

      final callRequest = CallRequest(
        id: const Uuid().v4(),
        callerId: currentUser.id,
        callerName: currentUser.name,
        callerAvatar: currentUser.avatar,
        receiverId: receiver.id,
        receiverName: receiver.name,
        receiverAvatar: receiver.avatar,
        status: CallStatus.initiated,
        meetingId: meetingId,
        createdAt: DateTime.now(),
      );

      // Save call request to Firestore
      await _firestore
          .collection(callRequestsCollection)
          .doc(callRequest.id)
          .set(callRequest.toJson());

      // Update both users' call status using batch operation
      await FirebaseUtils.safeBatchUpdate([
        MapEntry(
          _firestore.collection(usersCollection).doc(currentUser.id),
          {
            'isInCall': true,
            'currentCallId': callRequest.id,
          },
        ),
        MapEntry(
          _firestore.collection(usersCollection).doc(receiver.id),
          {
            'isInCall': true,
            'currentCallId': callRequest.id,
          },
        ),
      ]);

      // Send notification to receiver (in a real app, this would use FCM)
      await _sendCallNotification(callRequest);

      return callRequest;
    } catch (e) {
      print('Error initiating call: $e');
      return null;
    }
  }

  // Listen for incoming calls
  Stream<CallRequest?> listenForIncomingCalls() {
    final currentUserId = _authService.currentFirebaseUser?.uid;
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection(callRequestsCollection)
        .where('receiverId', isEqualTo: currentUserId)
        .where(
          'status',
          whereIn: [CallStatus.initiated.name, CallStatus.ringing.name],
        )
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return CallRequest.fromJson(snapshot.docs.first.data());
        });
  }

  // Listen for outgoing call status changes (for caller)
  Stream<CallRequest?> listenForOutgoingCallUpdates(String callId) {
    return _firestore
        .collection(callRequestsCollection)
        .doc(callId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return null;
          return CallRequest.fromJson(snapshot.data()!);
        });
  }
  
  // Listen for call status changes for any participant (to handle when call ends for everyone)
  Stream<CallRequest?> listenForCallStatusUpdates(String callId) {
    return _firestore
        .collection(callRequestsCollection)
        .doc(callId)
        .snapshots()
        .where((snapshot) => snapshot.exists && snapshot.data() != null)
        .map((snapshot) => CallRequest.fromJson(snapshot.data()!))
        .where((callRequest) => 
            callRequest.status == CallStatus.ended || 
            callRequest.status == CallStatus.declined
        )
        .handleError((error) {
          print('Error in call status monitoring stream: $error');
        });
  }

  // Accept call
  Future<void> acceptCall(String callId) async {
    await FirebaseUtils.safeDocumentUpdate(
      _firestore.collection(callRequestsCollection).doc(callId),
      {
        'status': CallStatus.accepted.name,
        'answeredAt': Timestamp.now(),
      },
    );
  }

  // Decline call
  Future<void> declineCall(String callId) async {
    final callDoc = await FirebaseUtils.safeDocumentGet(
      _firestore.collection(callRequestsCollection).doc(callId)
    );
    if (callDoc == null) return;

    final callRequest = CallRequest.fromJson(callDoc.data()! as Map<String, dynamic>);

    await FirebaseUtils.safeBatchUpdate([
      MapEntry(
        _firestore.collection(callRequestsCollection).doc(callId),
        {
          'status': CallStatus.declined.name,
          'endedAt': Timestamp.now(),
        },
      ),
      MapEntry(
        _firestore.collection(usersCollection).doc(callRequest.callerId),
        {
          'isInCall': false,
          'currentCallId': null,
        },
      ),
      MapEntry(
        _firestore.collection(usersCollection).doc(callRequest.receiverId),
        {
          'isInCall': false,
          'currentCallId': null,
        },
      ),
    ]);
  }

  // End call
  Future<void> endCall(String callId) async {
    final callDoc = await FirebaseUtils.safeDocumentGet(
      _firestore.collection(callRequestsCollection).doc(callId)
    );
    if (callDoc == null) return;

    final callRequest = CallRequest.fromJson(callDoc.data()! as Map<String, dynamic>);

    await FirebaseUtils.safeBatchUpdate([
      MapEntry(
        _firestore.collection(callRequestsCollection).doc(callId),
        {
          'status': CallStatus.ended.name,
          'endedAt': Timestamp.now(),
        },
      ),
      MapEntry(
        _firestore.collection(usersCollection).doc(callRequest.callerId),
        {
          'isInCall': false,
          'currentCallId': null,
        },
      ),
      MapEntry(
        _firestore.collection(usersCollection).doc(callRequest.receiverId),
        {
          'isInCall': false,
          'currentCallId': null,
        },
      ),
    ]);
  }

  // Get call request by ID
  Future<CallRequest?> getCallRequest(String callId) async {
    final doc = await FirebaseUtils.safeDocumentGet(
      _firestore.collection(callRequestsCollection).doc(callId)
    );
    if (doc == null) return null;
    return CallRequest.fromJson(doc.data()! as Map<String, dynamic>);
  }
  
  // Get call request by meeting ID
  Future<CallRequest?> getCallRequestByMeetingId(String meetingId) async {
    try {
      final querySnapshot = await _firestore
          .collection(callRequestsCollection)
          .where('meetingId', isEqualTo: meetingId)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isEmpty) return null;
      
      return CallRequest.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      print('Error getting call request by meeting ID: $e');
      return null;
    }
  }

  // Send call notification (simulated - in real app would use FCM)
  Future<void> _sendCallNotification(CallRequest callRequest) async {
    // In a real implementation, this would send an FCM notification
    // For demo purposes, we'll just print the notification
    print('📞 Sending call notification to ${callRequest.receiverName}');
    print('   From: ${callRequest.callerName}');
    print('   Call ID: ${callRequest.id}');
    print('   Meeting ID: ${callRequest.meetingId}');
  }

  // Clean up resources
  void dispose() {
    _callRequestSubscription?.cancel();
    _presenceSubscription?.cancel();
    _authService.updateOnlineStatus(false);
  }
}
