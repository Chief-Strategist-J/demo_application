import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/core/constants.dart';
import 'package:demo_application/features/videoCall/videoCall/meeting_screen.dart';
import 'package:demo_application/features/videoCall/videoCall/bloc/video/video_call_bloc.dart';
import 'package:demo_application/features/videoCall/videoCall/bloc/video/video_call_event.dart';
import 'package:demo_application/features/videoCall/videoCall/bloc/video/video_call_state.dart';

class JoinScreen extends StatelessWidget {
  const JoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController meetingIdController = TextEditingController();
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => JoinBloc(),
      child: BlocListener<JoinBloc, JoinState>(
        listener: (context, state) {
          if (state.meetingId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MeetingScreen(
                  meetingId: state.meetingId!,
                  token: videoCallSdkToken,
                ),
              ),
            );
          }

          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App/Brand Title
                    Text(
                      'Join a Video Call',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter a meeting ID or create a new one to begin.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Create Meeting Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create New Meeting'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        textStyle: theme.textTheme.labelLarge,
                      ),
                      onPressed: () {
                        context.read<JoinBloc>().add(CreateMeetingEvent());
                      },
                    ),
                    const SizedBox(height: 24),

                    // Join by Meeting ID
                    TextField(
                      controller: meetingIdController,
                      decoration: InputDecoration(
                        labelText: 'Meeting ID',
                        hintText: 'Enter meeting ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.videocam),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Join Meeting'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        textStyle: theme.textTheme.labelLarge,
                      ),
                      onPressed: () {
                        final meetingId = meetingIdController.text.trim();
                        if (meetingId.isNotEmpty) {
                          context.read<JoinBloc>().add(JoinMeetingEvent(meetingId));
                          meetingIdController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid Meeting ID')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
