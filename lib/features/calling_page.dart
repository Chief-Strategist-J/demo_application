import 'dart:convert';
import 'dart:async';

import 'package:demo_application/features/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:http/http.dart';

class CallingPage extends StatefulWidget {
  const CallingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return CallingPageState();
  }
}

class CallingPageState extends State<CallingPage>
    with TickerProviderStateMixin {
  late CallKitParams? calling;

  Timer? _timer;
  int _start = 0;
  bool isConnected = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Setup animations
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start animations
    _pulseController.repeat(reverse: true);
    _fadeController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _start++;
      });
    });
  }

  String intToTimeLeft(int value) {
    int h, m, s;
    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    s = value - (h * 3600) - (m * 60);
    String hourLeft = h.toString().length < 2 ? '0$h' : h.toString();
    String minuteLeft = m.toString().length < 2 ? '0$m' : m.toString();
    String secondsLeft = s.toString().length < 2 ? '0$s' : s.toString();
    String result = "$hourLeft:$minuteLeft:$secondsLeft";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final params = jsonDecode(
      jsonEncode(
        ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>,
      ),
    );
    print(ModalRoute.of(context)!.settings.arguments);
    calling = CallKitParams.fromJson(params);

    var timeDisplay = intToTimeLeft(_start);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isConnected
                ? [
                    const Color(0xFF667EEA).withOpacity(0.9),
                    const Color(0xFF764BA2).withOpacity(0.9),
                    const Color(0xFF1A1A2E),
                  ]
                : [
                    const Color(0xFF2C5364).withOpacity(0.9),
                    const Color(0xFF203A43).withOpacity(0.9),
                    const Color(0xFF0F2027),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with back button
              _buildTopSection(theme),

              // Main calling interface
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Caller info section
                    _buildCallerInfo(theme),

                    // Call status and timer
                    _buildCallStatus(timeDisplay, theme),

                    // Control buttons
                    _buildControlButtons(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => NavigationService.instance.goBack(),
            ),
          ),
          const Spacer(),
          Text(
            isConnected ? 'Connected' : 'Calling...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildCallerInfo(ThemeData theme) {
    return Column(
      children: [
        // Avatar with animated border
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                      Colors.white.withOpacity(0.2),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A1A2E),
                    ),
                    child: ClipOval(
                      child:
                          calling?.avatar != null && calling!.avatar!.isNotEmpty
                          ? Image.network(
                              calling!.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Caller name
        Text(
          calling?.nameCaller ?? 'Unknown Caller',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Phone number
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                calling?.handle ?? 'No number',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: const Icon(Icons.person, size: 80, color: Colors.white),
    );
  }

  Widget _buildCallStatus(String timeDisplay, ThemeData theme) {
    return Column(
      children: [
        // Timer display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Text(
            timeDisplay,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Status indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isConnected ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isConnected
                              ? Colors.green.withOpacity(0.5)
                              : Colors.orange.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              isConnected ? 'Connected' : 'Connecting...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Connect call button (only show if not connected)
          if (!isConnected)
            _buildActionButton(
              icon: Icons.call,
              label: 'Connect',
              color: const Color(0xFF4CAF50),
              onPressed: () async {
                if (calling != null) {
                  await makeFakeConnectedCall(calling!.id!);
                  setState(() {
                    isConnected = true;
                  });
                  startTimer();
                }
              },
            ),

          // Mute button (show when connected)
          if (isConnected)
            _buildActionButton(
              icon: Icons.mic_off,
              label: 'Mute',
              color: const Color(0xFF757575),
              onPressed: () {
                // Add mute functionality here
              },
            ),

          // Speaker button (show when connected)
          if (isConnected)
            _buildActionButton(
              icon: Icons.volume_up,
              label: 'Speaker',
              color: const Color(0xFF2196F3),
              onPressed: () {
                // Add speaker functionality here
              },
            ),

          // End call button
          _buildActionButton(
            icon: Icons.call_end,
            label: 'End Call',
            color: const Color(0xFFE53E3E),
            size: 72,
            iconSize: 32,
            onPressed: () async {
              if (calling != null) {
                await makeEndCall(calling!.id!);
                calling = null;
              }
              NavigationService.instance.goBack();
              await requestHttp('END_CALL');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    double size = 64,
    double iconSize = 24,
  }) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(size / 2),
              onTap: onPressed,
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // All original logic methods remain unchanged
  Future<void> makeFakeConnectedCall(id) async {
    await FlutterCallkitIncoming.setCallConnected(id);
  }

  Future<void> makeEndCall(id) async {
    await FlutterCallkitIncoming.endCall(id);
  }

  //check with https://webhook.site/#!/2748bc41-8599-4093-b8ad-93fd328f1cd2
  Future<void> requestHttp(content) async {
    get(
      Uri.parse(
        'https://webhook.site/2748bc41-8599-4093-b8ad-93fd328f1cd2?data=$content',
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _rotationController.dispose();
    _timer?.cancel();
    if (calling != null) FlutterCallkitIncoming.endCall(calling!.id!);
    super.dispose();
  }
}
