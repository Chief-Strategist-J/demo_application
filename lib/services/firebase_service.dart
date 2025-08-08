import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_application/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:demo_application/models/user.dart';
import 'package:demo_application/models/call_request.dart';
import 'package:demo_application/features/videoCall/services/video_call_service.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  String? _currentUserId;
  User? _currentUser;
  StreamSubscription? _callRequestSubscription;
  StreamSubscription? _usersSubscription;

  // Collections
  static const String usersCollection = 'users';
  static const String callRequestsCollection = 'call_requests';

  // Initialize Firebase service
  Future<void> initialize() async {
    // Anonymous auth for demo purposes
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    _currentUserId = _auth.currentUser!.uid;

    // Initialize current user if not exists
    await _initializeCurrentUser();

    // Set online status
    await setUserOnlineStatus(true);

    // Listen for app lifecycle changes
    _setupPresenceSystem();
  }

  Future<void> _initializeCurrentUser() async {
    if (_currentUserId == null) return;

    final userDoc = await _firestore
        .collection(usersCollection)
        .doc(_currentUserId)
        .get();

    if (!userDoc.exists) {
      // Create demo user
      final fcmToken = await _messaging.getToken() ?? '';
      final newUser = User(
        id: _currentUserId!,
        name: 'Demo User ${_currentUserId!.substring(0, 6)}',
        avatar: 'https://i.pravatar.cc/150?u=$_currentUserId',
        fcmToken: fcmToken,
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      await _firestore
          .collection(usersCollection)
          .doc(_currentUserId)
          .set(newUser.toJson());
      _currentUser = newUser;
    } else {
      _currentUser = User.fromJson(userDoc.data()!);
    }
  }

  void _setupPresenceSystem() {
    if (_currentUserId == null) return;

    // Set up real-time presence
    final presenceRef = _database.child('presence').child(_currentUserId!);
    final isOnlineRef = _database.child('.info/connected');

    isOnlineRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        presenceRef.onDisconnect().set({
          'isOnline': false,
          'lastSeen': ServerValue.timestamp,
        });
        presenceRef.set({'isOnline': true, 'lastSeen': ServerValue.timestamp});
      }
    });
  }

  // Create demo users
  Future<void> createDemoUsers() async {
    final demoUsers = [
      User(
        id: 'demo_user_1',
        name: 'Alice Johnson',
        avatar: 'https://i.pravatar.cc/150?u=alice',
        fcmToken: 'demo_token_1',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      User(
        id: 'demo_user_2',
        name: 'Bob Smith',
        avatar: 'https://i.pravatar.cc/150?u=bob',
        fcmToken: 'demo_token_2',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      User(
        id: 'demo_user_3',
        name: 'Carol Williams',
        avatar: 'https://i.pravatar.cc/150?u=carol',
        fcmToken: 'demo_token_3',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      User(
        id: 'demo_user_4',
        name: 'David Brown',
        avatar: 'https://i.pravatar.cc/150?u=david',
        fcmToken: 'demo_token_4',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
    ];

    final batch = _firestore.batch();
    for (final user in demoUsers) {
      if (user.id != _currentUserId) {
        batch.set(
          _firestore.collection(usersCollection).doc(user.id),
          user.toJson(),
        );
      }
    }
    await batch.commit();
  }

  // Get all users except current user
  Stream<List<User>> getUsers() {
    return _firestore
        .collection(usersCollection)
        .where('id', isNotEqualTo: _currentUserId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => User.fromJson(doc.data())).toList(),
        );
  }

  // Get current user
  User? get currentUser => _currentUser;

  // Set user online status
  Future<void> setUserOnlineStatus(bool isOnline) async {
    if (_currentUserId == null) return;

    await _firestore.collection(usersCollection).doc(_currentUserId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  // Initiate a video call
  Future<CallRequest?> initiateCall(User receiver) async {
    if (_currentUser == null || receiver.isInCall) return null;

    try {
      // Create meeting ID using video SDK
      final meetingId = await createMeeting();

      final callRequest = CallRequest(
        id: const Uuid().v4(),
        callerId: _currentUser!.id,
        callerName: _currentUser!.name,
        callerAvatar: _currentUser!.avatar,
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

      // Update both users' call status
      await Future.wait([
        _firestore.collection(usersCollection).doc(_currentUser!.id).update({
          'isInCall': true,
          'currentCallId': callRequest.id,
        }),
        _firestore.collection(usersCollection).doc(receiver.id).update({
          'isInCall': true,
          'currentCallId': callRequest.id,
        }),
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
    if (_currentUserId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection(callRequestsCollection)
        .where('receiverId', isEqualTo: _currentUserId)
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

  // Accept call
  Future<void> acceptCall(String callId) async {
    await _firestore.collection(callRequestsCollection).doc(callId).update({
      'status': CallStatus.accepted.name,
      'answeredAt': Timestamp.now(),
    });
  }

  // Decline call
  Future<void> declineCall(String callId) async {
    final callDoc = await _firestore
        .collection(callRequestsCollection)
        .doc(callId)
        .get();
    if (!callDoc.exists) return;

    final callRequest = CallRequest.fromJson(callDoc.data()!);

    await Future.wait([
      _firestore.collection(callRequestsCollection).doc(callId).update({
        'status': CallStatus.declined.name,
        'endedAt': Timestamp.now(),
      }),
      _firestore.collection(usersCollection).doc(callRequest.callerId).update({
        'isInCall': false,
        'currentCallId': null,
      }),
      _firestore.collection(usersCollection).doc(callRequest.receiverId).update(
        {'isInCall': false, 'currentCallId': null},
      ),
    ]);
  }

  // End call
  Future<void> endCall(String callId) async {
    final callDoc = await _firestore
        .collection(callRequestsCollection)
        .doc(callId)
        .get();
    if (!callDoc.exists) return;

    final callRequest = CallRequest.fromJson(callDoc.data()!);

    await Future.wait([
      _firestore.collection(callRequestsCollection).doc(callId).update({
        'status': CallStatus.ended.name,
        'endedAt': Timestamp.now(),
      }),
      _firestore.collection(usersCollection).doc(callRequest.callerId).update({
        'isInCall': false,
        'currentCallId': null,
      }),
      _firestore.collection(usersCollection).doc(callRequest.receiverId).update(
        {'isInCall': false, 'currentCallId': null},
      ),
    ]);
  }

  // Get call request by ID
  Future<CallRequest?> getCallRequest(String callId) async {
    final doc = await _firestore
        .collection(callRequestsCollection)
        .doc(callId)
        .get();
    if (!doc.exists) return null;
    return CallRequest.fromJson(doc.data()!);
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
    _usersSubscription?.cancel();
    setUserOnlineStatus(false);
  }
}
