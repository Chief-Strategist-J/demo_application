import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/models/call_request.dart';
import 'package:demo_application/features/call/bloc/incoming_call_bloc.dart';
import 'package:demo_application/features/call/bloc/incoming_call_event.dart';
import 'package:demo_application/features/call/bloc/incoming_call_state.dart';
import 'package:demo_application/features/videoCall/videoCall/meeting_screen.dart';
import 'package:demo_application/core/constants.dart';

class IncomingCallScreen extends StatelessWidget {
  final CallRequest callRequest;

  const IncomingCallScreen({
    super.key,
    required this.callRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocProvider(
      create: (_) => IncomingCallBloc()..add(InitializeIncomingCall(callRequest)),
      child: BlocConsumer<IncomingCallBloc, IncomingCallState>(
        listener: (context, state) {
          if (state.callAccepted && state.callRequest?.meetingId != null) {
            // Navigate to meeting screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MeetingScreen(
                  meetingId: state.callRequest!.meetingId!,
                  token: videoCallSdkToken,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top section with call info
                      Column(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Incoming Video Call',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Caller avatar with ripple effect
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ripple effect
                              if (!state.callEnded) ...[
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(seconds: 2),
                                  builder: (context, value, child) {
                                    return Container(
                                      width: 200 + (value * 50),
                                      height: 200 + (value * 50),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.colorScheme.primary.withOpacity(1 - value),
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  },
                                  onEnd: () {
                                    // Animation ended - can add logic here if needed
                                  },
                                ),
                              ],
                              
                              // Avatar
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.surface,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 76,
                                  backgroundImage: NetworkImage(callRequest.callerAvatar),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Caller name
                          Text(
                            callRequest.callerName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Call status
                          Text(
                            state.loading ? 'Connecting...' : 'Video Call',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      
                      // Bottom section with call actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Decline button
                          GestureDetector(
                            onTap: state.loading ? null : () {
                              context.read<IncomingCallBloc>().add(DeclineCall());
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          
                          // Accept button
                          GestureDetector(
                            onTap: state.loading ? null : () {
                              context.read<IncomingCallBloc>().add(AcceptCall());
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
