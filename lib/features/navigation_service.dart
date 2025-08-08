import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:demo_application/features/call/calling_page.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  // Static navigator key for main app
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get appContext => navigationKey.currentContext;

  RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

  static final NavigationService _instance = NavigationService._private();
  factory NavigationService() {
    return _instance;
  }
  NavigationService._private();

  static NavigationService get instance => _instance;

  // Static method to navigate to calling page from background
  static Future<void> navigateToCallingPage(dynamic callData) async {
    final context = navigatorKey.currentContext;
    if (context != null && callData is Map<String, dynamic>) {
      // Convert call data to CallKitParams if needed
      final callParams = CallKitParams(
        id: callData['id'] ?? '',
        nameCaller: callData['nameCaller'] ?? 'Unknown',
        appName: callData['appName'] ?? 'Video Call',
        avatar: callData['avatar'],
        handle: callData['handle'] ?? '',
        type: callData['type'] ?? 0,
        duration: callData['duration'] ?? 30000,
        textAccept: callData['textAccept'] ?? 'Accept',
        textDecline: callData['textDecline'] ?? 'Decline',
        extra: callData['extra'] ?? <String, dynamic>{},
        headers: callData['headers'] ?? <String, dynamic>{},
        android: callData['android'],
        ios: callData['ios'],
      );
      
      await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => CallingPage(callKitParams: callParams),
        ),
      );
    }
  }

  Future<T?> pushNamed<T extends Object>(
    String routeName, {
    Object? args,
  }) async {
    return navigationKey.currentState?.pushNamed<T>(routeName, arguments: args);
  }

  Future<T?> pushNamedIfNotCurrent<T extends Object>(
    String routeName, {
    Object? args,
  }) async {
    if (!isCurrent(routeName)) {
      return pushNamed(routeName, args: args);
    }
    return null;
  }

  bool isCurrent(String routeName) {
    bool isCurrent = false;
    navigationKey.currentState!.popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }

  Future<T?> push<T extends Object>(Route<T> route) async {
    return navigationKey.currentState?.push<T>(route);
  }

  Future<T?> pushReplacementNamed<T extends Object, TO extends Object>(
    String routeName, {
    Object? args,
  }) async {
    return navigationKey.currentState?.pushReplacementNamed<T, TO>(
      routeName,
      arguments: args,
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object>(
    String routeName, {
    Object? args,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return navigationKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (_) => false,
      arguments: args,
    );
  }

  Future<T?> pushAndRemoveUntil<T extends Object>(
    Route<T> route, {
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return navigationKey.currentState?.pushAndRemoveUntil<T>(
      route,
      predicate ?? (_) => false,
    );
  }

  Future<bool> maybePop<T extends Object>([Object? args]) async {
    return navigationKey.currentState!.maybePop<T>(args as T);
  }

  bool canPop() => navigationKey.currentState!.canPop();

  void goBack<T extends Object>({T? result}) {
    navigationKey.currentState?.pop<T>(result);
  }

  void popUntil(String route) {
    navigationKey.currentState!.popUntil(ModalRoute.withName(route));
  }
}
