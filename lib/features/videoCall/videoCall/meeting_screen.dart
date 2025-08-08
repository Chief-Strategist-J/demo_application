import 'package:demo_application/features/videoCall/videoCall/bloc/meeting/meeting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/features/videoCall/component/meeting_controls.dart';
import 'package:demo_application/features/videoCall/component/participant_tile.dart';

class MeetingScreen extends StatelessWidget {
  final String meetingId;
  final String token;

  const MeetingScreen({
    super.key,
    required this.meetingId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) =>
          MeetingBloc()
            ..add(InitMeetingEvent(meetingId: meetingId, token: token)),
      child: BlocConsumer<MeetingBloc, MeetingState>(
        listenWhen: (prev, curr) =>
            prev.participants.length != curr.participants.length,
        listener: (context, state) {
          if (state.room == null && context.mounted) {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              context.read<MeetingBloc>().add(LeaveMeetingEvent());
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Meeting Room'),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              body: Column(
                children: [
                  // Meeting Info Header
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Meeting ID:",
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SelectableText(
                          meetingId,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Participant Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 280,
                        ),
                        itemCount: state.participants.length,
                        itemBuilder: (context, index) {
                          final participant = state.participants.values
                              .elementAt(index);
                          return ParticipantTile(
                            key: Key(participant.id),
                            participant: participant,
                          );
                        },
                      ),
                    ),
                  ),

                  // Meeting Controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                    child: MeetingControls(
                      onToggleMicButtonPressed: () {
                        context.read<MeetingBloc>().add(ToggleMicEvent());
                      },
                      onToggleCameraButtonPressed: () {
                        context.read<MeetingBloc>().add(ToggleCameraEvent());
                      },
                      onLeaveButtonPressed: () {
                        context.read<MeetingBloc>().add(LeaveMeetingEvent());
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
