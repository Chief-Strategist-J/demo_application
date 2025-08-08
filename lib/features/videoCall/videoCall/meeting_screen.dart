import 'package:demo_application/features/videoCall/videoCall/bloc/meeting/meeting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/features/videoCall/component/meeting_controls.dart';
import 'package:demo_application/features/videoCall/component/participant_tile.dart';

class MeetingScreen extends StatelessWidget {
  final String meetingId;
  final String token;
  final String? callId;

  const MeetingScreen({
    super.key,
    required this.meetingId,
    required this.token,
    this.callId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isPhone = screenSize.width < 600;

    return BlocProvider(
      create: (_) =>
          MeetingBloc()
            ..add(InitMeetingEvent(
              meetingId: meetingId, 
              token: token,
              callId: callId,
            )),
      child: BlocConsumer<MeetingBloc, MeetingState>(
        listener: (context, state) {
          if (state.callEnded && context.mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              _showLeaveConfirmation(context);
              return false; // Prevent default back behavior
            },
            child: Scaffold(
              backgroundColor: theme.colorScheme.surface,
              body: SafeArea(
                child: Column(
                  children: [
                    // Custom App Bar
                    _buildCustomAppBar(context, theme, isPhone),

                    // Meeting Info Header
                    _buildMeetingHeader(theme, isPhone,context),

                    // Participants Count
                    _buildParticipantsCount(theme, state, isPhone),

                    // Participant Grid
                    Expanded(
                      child: _buildParticipantGrid(
                        context,
                        state,
                        theme,
                        isTablet,
                        isPhone,
                      ),
                    ),

                    // Meeting Controls
                    MeetingControls(
                      micEnabled: state.micEnabled,
                      cameraEnabled: state.camEnabled,
                      onToggleMicButtonPressed: () {
                        context.read<MeetingBloc>().add(ToggleMicEvent());
                      },
                      onToggleCameraButtonPressed: () {
                        context.read<MeetingBloc>().add(ToggleCameraEvent());
                      },
                      onLeaveButtonPressed: () {
                        _showLeaveConfirmation(context);
                      },
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

  Widget _buildCustomAppBar(
    BuildContext context,
    ThemeData theme,
    bool isPhone,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showLeaveConfirmation(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.colorScheme.onSurface,
            ),
            tooltip: 'Leave meeting',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Video Call',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Tap to share meeting ID',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMeetingInfo(context),
            icon: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            tooltip: 'Meeting info',
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingHeader(ThemeData theme, bool isPhone, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isPhone ? 16 : 24, vertical: 8),
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 16 : 20,
        vertical: isPhone ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam,
              color: theme.colorScheme.primary,
              size: isPhone ? 20 : 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Meeting ID",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(
                      0.8,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  meetingId,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: isPhone ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyMeetingId(context),
            icon: Icon(
              Icons.copy,
              color: theme.colorScheme.primary,
              size: isPhone ? 20 : 24,
            ),
            tooltip: 'Copy meeting ID',
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsCount(
    ThemeData theme,
    MeetingState state,
    bool isPhone,
  ) {
    final participantCount = state.participants.length;

    if (participantCount == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isPhone ? 16 : 24, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.people,
            size: isPhone ? 16 : 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$participantCount participant${participantCount == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantGrid(
    BuildContext context,
    MeetingState state,
    ThemeData theme,
    bool isTablet,
    bool isPhone,
  ) {
    final participantCount = state.participants.length;

    if (participantCount == 0) {
      return _buildEmptyState(theme);
    }

    // Determine grid layout based on participant count and screen size
    int crossAxisCount;
    if (isTablet) {
      crossAxisCount = participantCount == 1
          ? 1
          : (participantCount <= 4 ? 2 : 3);
    } else {
      crossAxisCount = participantCount == 1 ? 1 : 2;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 12 : 16, vertical: 8),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isPhone ? 8 : 12,
          mainAxisSpacing: isPhone ? 8 : 12,
          childAspectRatio: participantCount == 1 ? 16 / 10 : 4 / 3,
        ),
        itemCount: participantCount,
        itemBuilder: (context, index) {
          final participant = state.participants.values.elementAt(index);
          return ParticipantTile(
            key: Key(participant.id),
            participant: participant,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Waiting for participants...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share the meeting ID to invite others',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final meetingBloc = context.read<MeetingBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            const Text('Leave Meeting'),
          ],
        ),
        content: const Text(
          'Are you sure you want to leave this meeting? You can rejoin anytime using the meeting ID.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              meetingBloc.add(LeaveMeetingEvent());
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showMeetingInfo(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Meeting Info'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting ID:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              meetingId,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share this ID with others to invite them to the meeting.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _copyMeetingId(context),
            child: const Text('Copy ID'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _copyMeetingId(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Meeting ID copied: $meetingId'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
