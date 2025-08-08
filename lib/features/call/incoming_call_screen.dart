import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/models/call_request.dart';
import 'package:demo_application/features/call/bloc/incoming_call_bloc.dart';
import 'package:demo_application/features/call/bloc/incoming_call_event.dart';
import 'package:demo_application/features/call/bloc/incoming_call_state.dart';
import 'package:demo_application/features/videoCall/videoCall/meeting_screen.dart';
import 'package:demo_application/core/constants.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallRequest callRequest;

  const IncomingCallScreen({
    super.key,
    required this.callRequest,
  });
  
  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Pulse animation for avatar
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Slide animation for buttons
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return BlocProvider(
      create: (_) => IncomingCallBloc()..add(InitializeIncomingCall(widget.callRequest)),
      child: BlocConsumer<IncomingCallBloc, IncomingCallState>(
        listener: (context, state) {
          if (state.callAccepted && state.callRequest?.meetingId != null) {
            // Navigate to meeting screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MeetingScreen(
                  meetingId: state.callRequest!.meetingId!,
                  token: videoCallSdkToken,
                  callId: state.callRequest!.id,
                ),
              ),
            );
          }
          
          if (state.callEnded) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: theme.colorScheme.inversePrimary.withOpacity(0.1),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.3),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Top spacer
                      SizedBox(height: isTablet ? 80 : 60),
                      
                      // Call type indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Incoming Video Call',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Caller avatar with pulse animation
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Multiple ripple rings
                                ...List.generate(3, (index) {
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(milliseconds: 2000 + (index * 400)),
                                    builder: (context, value, child) {
                                      return Container(
                                        width: 180 + (value * (60 + index * 20)),
                                        height: 180 + (value * (60 + index * 20)),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withOpacity((1 - value) * 0.3),
                                            width: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    onEnd: () {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  );
                                }),
                                
                                // Avatar with shadow
                                Container(
                                  width: isTablet ? 180 : 160,
                                  height: isTablet ? 180 : 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(0.1),
                                        theme.colorScheme.secondary.withOpacity(0.1),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.shadowColor.withOpacity(0.3),
                                        spreadRadius: 8,
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(90),
                                    child: Image.network(
                                      widget.callRequest.callerAvatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: isTablet ? 80 : 60,
                                            color: theme.colorScheme.primary,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Caller name with fade in animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Column(
                                children: [
                                  Text(
                                    widget.callRequest.callerName,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                      fontSize: isTablet ? 32 : 28,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  if (state.loading)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Connecting...',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Online',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const Spacer(),
                      
                      // Action buttons with slide animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 60 : 40,
                            vertical: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Decline button
                              _buildActionButton(
                                context: context,
                                theme: theme,
                                icon: Icons.call_end,
                                backgroundColor: theme.colorScheme.error,
                                label: 'Decline',
                                onTap: state.loading ? null : () {
                                  context.read<IncomingCallBloc>().add(DeclineCall());
                                },
                                isTablet: isTablet,
                              ),
                              
                              SizedBox(width: isTablet ? 60 : 40),
                              
                              // Accept button
                              _buildActionButton(
                                context: context,
                                theme: theme,
                                icon: Icons.videocam,
                                backgroundColor: Colors.green,
                                label: 'Accept',
                                onTap: state.loading ? null : () {
                                  context.read<IncomingCallBloc>().add(AcceptCall());
                                },
                                isTablet: isTablet,
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom spacer
                      SizedBox(height: isTablet ? 40 : 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required Color backgroundColor,
    required String label,
    required VoidCallback? onTap,
    required bool isTablet,
    bool isPrimary = false,
  }) {
    final size = isTablet ? 90.0 : 80.0;
    final iconSize = isTablet ? 36.0 : 32.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isPrimary ? size + 10 : size,
            height: isPrimary ? size + 10 : size,
            decoration: BoxDecoration(
              color: onTap != null ? backgroundColor : backgroundColor.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: onTap != null
                  ? [
                      BoxShadow(
                        color: backgroundColor.withOpacity(0.4),
                        spreadRadius: isPrimary ? 8 : 5,
                        blurRadius: isPrimary ? 20 : 15,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
              border: isPrimary
                  ? Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? iconSize + 4 : iconSize,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
