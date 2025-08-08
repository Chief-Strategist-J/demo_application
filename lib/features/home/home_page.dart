import 'package:demo_application/features/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => HomeBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phone Call Manager'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final bloc = context.read<HomeBloc>();

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Simulate Incoming Call Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: state.isAnimating ? 80 : 56,
                    curve: Curves.easeInOut,
                    child: ElevatedButton.icon(
                      onPressed: () => bloc.add(MakeFakeCallEvent()),
                      icon: const Icon(Icons.ring_volume),
                      label: const Text('Simulate Incoming Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        textStyle: theme.textTheme.labelLarge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Call Action Buttons in a Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _CallButton(
                            icon: Icons.phone_forwarded,
                            label: 'Start Outgoing Call',
                            onPressed: () => bloc.add(StartOutgoingCallEvent()),
                          ),
                          const SizedBox(height: 16),
                          _CallButton(
                            icon: Icons.call_end,
                            label: 'End Current Call',
                            onPressed: () => bloc.add(EndCurrentCallEvent()),
                          ),
                          const SizedBox(height: 16),
                          _CallButton(
                            icon: Icons.cancel,
                            label: 'End All Calls',
                            onPressed: () => bloc.add(EndAllCallsEvent()),
                            color: theme.colorScheme.error,
                            textColor: theme.colorScheme.onError,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const _CallButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? theme.colorScheme.secondaryContainer,
          foregroundColor: textColor ?? theme.colorScheme.onSecondaryContainer,
          textStyle: theme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
