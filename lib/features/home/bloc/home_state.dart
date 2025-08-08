// home_state.dart
part of 'home_bloc.dart';

class HomeState {
  final String currentUuid;
  final String textEvents;
  final bool isAnimating;

  const HomeState({
    required this.currentUuid,
    required this.textEvents,
    required this.isAnimating,
  });

  HomeState copyWith({
    String? currentUuid,
    String? textEvents,
    bool? isAnimating,
  }) {
    return HomeState(
      currentUuid: currentUuid ?? this.currentUuid,
      textEvents: textEvents ?? this.textEvents,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  factory HomeState.initial() {
    return const HomeState(currentUuid: '', textEvents: '', isAnimating: false);
  }
}
