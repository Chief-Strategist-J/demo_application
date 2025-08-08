import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:demo_application/firebase_options.dart';
import 'package:demo_application/features/navigation_service.dart';
import 'package:demo_application/services/auth_service.dart';
import 'package:demo_application/features/auth/login_screen.dart';
import 'package:demo_application/features/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Background handler for call kit events
@pragma('vm:entry-point')
void backgroundCallHandler(CallEvent? callEvent) {
  if (callEvent == null) return;

  debugPrint('Background call event: $callEvent');

  switch (callEvent.event) {
    case Event.actionCallIncoming:
      debugPrint('Incoming call received in background');
      break;
    case Event.actionCallAccept:
      debugPrint('Call accepted in background');
      NavigationService.navigateToCallingPage(callEvent.body);
      break;
    case Event.actionCallDecline:
      debugPrint('Call declined in background');
      break;
    case Event.actionCallEnded:
      debugPrint('Call ended in background');
      break;
    default:
      break;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize CallKit with background handler
  try {
    FlutterCallkitIncoming.onEvent.listen(backgroundCallHandler);
  } catch (e) {
    debugPrint('CallKit initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      title: 'Video Call App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
