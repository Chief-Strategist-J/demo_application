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
            backgroundColor: theme.colorScheme.background,
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
                        _AnimatedAvatar(imageUrl: callKitParams.avatar),
                        const SizedBox(height: 24),
                        Text(
                          callKitParams.nameCaller ?? 'Unknown Caller',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.isConnected
                              ? _formatDuration(state.durationInSeconds)
                              : 'Ringing...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(
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
                          _ActionButton(
                            icon: Icons.call,
                            label: 'Connect',
                            color: theme.colorScheme.primary,
                            iconColor: theme.colorScheme.onPrimary,
                            textColor: theme.colorScheme.onBackground,
                            onPressed: state.isConnected
                                ? null
                                : () => bloc.add(ConnectCall()),
                          ),
                          _ActionButton(
                            icon: Icons.call_end,
                            label: 'End',
                            color: theme.colorScheme.error,
                            iconColor: theme.colorScheme.onError,
                            textColor: theme.colorScheme.onBackground,
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

class _AnimatedAvatar extends StatefulWidget {
  final String? imageUrl;

  const _AnimatedAvatar({this.imageUrl});

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: CircleAvatar(
        radius: 64,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: widget.imageUrl != null
            ? NetworkImage(widget.imageUrl!)
            : null,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: isDisabled ? Colors.grey : color,
          foregroundColor: iconColor,
          elevation: 4,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ],
    );
  }
}
