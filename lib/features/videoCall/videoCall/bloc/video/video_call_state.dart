class JoinState {
  final String? meetingId;
  final String? error;

  const JoinState({this.meetingId, this.error});

  factory JoinState.initial() => const JoinState();

  JoinState copyWith({String? meetingId, String? error}) {
    return JoinState(
      meetingId: meetingId ?? this.meetingId,
      error: error,
    );
  }
}