sealed class JoinEvent {}

class CreateMeetingEvent extends JoinEvent {}

class JoinMeetingEvent extends JoinEvent {
  final String meetingId;
  JoinMeetingEvent(this.meetingId);
}
