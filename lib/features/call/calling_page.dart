import 'package:demo_application/features/call/component/action_button.dart';
import 'package:demo_application/features/call/component/animated_avatar.dart';
import 'package:demo_application/features/call/bloc/call_bloc.dart';
import 'package:demo_application/features/call/bloc/call_event.dart';
import 'package:demo_application/features/call/bloc/call_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';

class CallingPage extends StatelessWidget {
  final CallKitParams callKitParams;

  const CallingPage({super.key, required this.callKitParams});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => CallingBloc()..add(InitializeCalling(callKitParams)),
      child: BlocBuilder<CallingBloc, CallingState>(
        builder: (context, state) {
          final bloc = context.read<CallingBloc>();

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 40),

                    /// Caller Info
                    Column(
                      children: [
                        AnimatedAvatar(imageUrl: callKitParams.avatar),
                        const SizedBox(height: 24),
                        Text(
                          callKitParams.nameCaller ?? 'Unknown Caller',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.isConnected
                              ? _formatDuration(state.durationInSeconds)
                              : 'Ringing...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// Action Buttons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icons.call,
                            label: 'Connect',
                            color: theme.colorScheme.primary,
                            iconColor: theme.colorScheme.onPrimary,
                            textColor: theme.colorScheme.onSurface,
                            onPressed: state.isConnected
                                ? null
                                : () => bloc.add(ConnectCall()),
                          ),
                          ActionButton(
                            icon: Icons.call_end,
                            label: 'End',
                            color: theme.colorScheme.error,
                            iconColor: theme.colorScheme.onError,
                            textColor: theme.colorScheme.onSurface,
                            onPressed: () => bloc.add(EndCall()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
