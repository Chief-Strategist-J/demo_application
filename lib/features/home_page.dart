import 'dart:async';

import 'package:demo_application/features/app_router.dart';
import 'package:demo_application/features/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final Uuid _uuid;
  String? _currentUuid;
  String textEvents = "";
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _uuid = const Uuid();
    _currentUuid = "";
    textEvents = "";

    // Initialize animation controller
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    initCurrentCall();
    listenerEvent(onEvent);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'CallKit Demo',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF0A0A0A)]
                : [Colors.white, const Color(0xFFF8F9FA)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Status Card
              _buildStatusCard(theme, isDark),

              const SizedBox(height: 24),

              // Control Buttons Grid
              _buildControlGrid(theme, isDark),

              const SizedBox(height: 24),

              // Events Section
              _buildEventsSection(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
              : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentUuid != null && _currentUuid!.isNotEmpty
                    ? _pulseAnimation.value
                    : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _currentUuid != null && _currentUuid!.isNotEmpty
                        ? Icons.phone_in_talk
                        : Icons.phone_disabled,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _currentUuid != null && _currentUuid!.isNotEmpty
                ? 'Call Active'
                : 'No Active Calls',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentUuid != null && _currentUuid!.isNotEmpty
                ? 'ID: ${_currentUuid!.substring(0, 8)}...'
                : 'Ready to make calls',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlGrid(ThemeData theme, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildControlButton(
          icon: Icons.call_received,
          label: 'Fake Incoming',
          color: const Color(0xFF48BB78),
          onPressed: makeFakeCallInComing,
          theme: theme,
          isDark: isDark,
        ),
        _buildControlButton(
          icon: Icons.call_end,
          label: 'End Call',
          color: const Color(0xFFE53E3E),
          onPressed: endCurrentCall,
          theme: theme,
          isDark: isDark,
        ),
        _buildControlButton(
          icon: Icons.call_made,
          label: 'Start Outgoing',
          color: const Color(0xFF4299E1),
          onPressed: startOutGoingCall,
          theme: theme,
          isDark: isDark,
        ),
        _buildControlButton(
          icon: Icons.list_alt,
          label: 'Active Calls',
          color: const Color(0xFF9F7AEA),
          onPressed: activeCalls,
          theme: theme,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection(ThemeData theme, bool isDark) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with End All Calls button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF4A5568)
                    : const Color(0xFFF7FAFC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Call Events',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2D3748),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: endAllCalls,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('End All'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE53E3E),
                      backgroundColor: const Color(0xFFE53E3E).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Events Content
            Expanded(
              child: textEvents.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A202C)
                                : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF4A5568)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            textEvents,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF4A5568),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFE2E8F0),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Events Yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF718096),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Call events will appear here',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFFA0AEC0),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // All the original logic methods remain unchanged
  Future<void> requestNotificationPermission() async {
    await FlutterCallkitIncoming.requestNotificationPermission({
      "title": "Notification Permission",
      "rationaleMessagePermission":
          "Notification permission is required, to show notification.",
      "postNotificationMessageRequired":
          "Notification permission is required, Please allow notification permission from setting.",
    });
  }

  Future<dynamic> initCurrentCall() async {
    await requestNotificationPermission();
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('DATA: $calls');
        _currentUuid = calls[0]['id'];
        return calls[0];
      } else {
        _currentUuid = "";
        return null;
      }
    }
  }

  Future<void> makeFakeCallInComing() async {
    await Future.delayed(const Duration(seconds: 10), () async {
      _currentUuid = _uuid.v4();

      final params = CallKitParams(
        id: _currentUuid,
        nameCaller: 'Hien Nguyen',
        appName: 'Callkit',
        avatar:
            'https://fastly.picsum.photos/id/773/200/300.jpg?hmac=nhH4e4UtqcS6I0hy7eCr9waIFzMYNaMkzety6PQnOHM',
        handle: '0123456789',
        type: 0,
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: true,
          subtitle: 'Missed call',
          callbackText: 'Call back',
        ),
        callingNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: true,
          subtitle: 'Calling...',
          callbackText: 'Hang Up',
        ),
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: true,
          isShowCallID: true,
          logoUrl: 'assets/test.png',
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl:
              'https://fastly.picsum.photos/id/773/200/300.jpg?hmac=nhH4e4UtqcS6I0hy7eCr9waIFzMYNaMkzety6PQnOHM',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: 'Incoming Call',
          missedCallNotificationChannelName: 'Missed Call',
          isImportant: true,
          isBot: false,
        ),
        ios: const IOSParams(
          iconName: 'CallKitLogo',
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    });
  }

  Future<void> endCurrentCall() async {
    initCurrentCall();
    await FlutterCallkitIncoming.endCall(_currentUuid!);
  }

  Future<void> startOutGoingCall() async {
    _currentUuid = _uuid.v4();
    final params = CallKitParams(
      id: _currentUuid,
      nameCaller: 'Hien Nguyen',
      handle: '0123456789',
      type: 1,
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      ios: const IOSParams(handleType: 'generic'),
      callingNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Calling...',
        callbackText: 'Hang Up',
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowCallID: true,
      ),
    );
    await FlutterCallkitIncoming.startCall(params);
  }

  Future<void> activeCalls() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    print(calls);
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  Future<void> getDevicePushTokenVoIP() async {
    var devicePushTokenVoIP =
        await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    print(devicePushTokenVoIP);
  }

  Future<void> listenerEvent(void Function(CallEvent) callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('HOME: $event');
        switch (event!.event) {
          case Event.actionCallIncoming:
            // TODO: received an incoming call
            break;
          case Event.actionCallStart:
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            NavigationService.instance.pushNamedIfNotCurrent(
              AppRoute.callingPage,
              args: event.body,
            );
            break;
          case Event.actionCallAccept:
            // TODO: accepted an incoming call
            // TODO: show screen calling in Flutter
            NavigationService.instance.pushNamedIfNotCurrent(
              AppRoute.callingPage,
              args: event.body,
            );
            break;
          case Event.actionCallDecline:
            // TODO: declined an incoming call
            await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
            break;
          case Event.actionCallEnded:
            // TODO: ended an incoming/outgoing call
            // TOTO: have check correct current call
            NavigationService.instance.popUntil(AppRoute.homePage);
            break;
          case Event.actionCallTimeout:
            // TODO: missed an incoming call
            break;
          case Event.actionCallCallback:
            // TODO: only Android - click action `Call back` from missed call notification
            break;
          case Event.actionCallToggleHold:
            // TODO: only iOS
            break;
          case Event.actionCallToggleMute:
            // TODO: only iOS
            break;
          case Event.actionCallToggleDmtf:
            // TODO: only iOS
            break;
          case Event.actionCallToggleGroup:
            // TODO: only iOS
            break;
          case Event.actionCallToggleAudioSession:
            // TODO: only iOS
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            // TODO: only iOS
            break;
          case Event.actionCallCustom:
            break;
          case Event.actionCallConnected:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
        callback(event);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  //check with https://events.hiennv.com
  Future<void> requestHttp(content) async {
    get(Uri.parse('https://events.hiennv.com/api/logs?data=$content'));
  }

  void onEvent(CallEvent event) {
    if (!mounted) return;
    setState(() {
      textEvents += '-----------------------\n${event.toString()}\n';
    });
  }
}
