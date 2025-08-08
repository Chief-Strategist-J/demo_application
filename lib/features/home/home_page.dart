import 'package:demo_application/features/home/bloc/home_bloc.dart';
import 'package:demo_application/features/home/component/call_button.dart';
import 'package:demo_application/features/users/users_list_screen.dart';
import 'package:demo_application/features/call/incoming_call_screen.dart';
import 'package:demo_application/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _incomingCallSubscription;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndListenForCalls();
  }

  Future<void> _initializeFirebaseAndListenForCalls() async {
    try {
      await _firebaseService.initialize();
      _listenForIncomingCalls();
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  void _listenForIncomingCalls() {
    _incomingCallSubscription = _firebaseService.listenForIncomingCalls().listen(
      (callRequest) {
        if (callRequest != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => IncomingCallScreen(callRequest: callRequest),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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

                  // Video Calling Section
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.videocam,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Video Calling',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CallButton(
                            icon: Icons.contacts,
                            label: 'View Contacts & Make Call',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const UsersListScreen(),
                                ),
                              );
                            },
                            color: theme.colorScheme.secondary,
                            textColor: theme.colorScheme.onSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Original Call Kit Section
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Call Kit Demo',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CallButton(
                            icon: Icons.phone_forwarded,
                            label: 'Start Outgoing Call',
                            onPressed: () => bloc.add(StartOutgoingCallEvent()),
                          ),
                          const SizedBox(height: 16),
                          CallButton(
                            icon: Icons.call_end,
                            label: 'End Current Call',
                            onPressed: () => bloc.add(EndCurrentCallEvent()),
                          ),
                          const SizedBox(height: 16),
                          CallButton(
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
