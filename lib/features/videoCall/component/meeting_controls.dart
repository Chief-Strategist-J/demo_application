import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final void Function() onToggleMicButtonPressed;
  final void Function() onToggleCameraButtonPressed;
  final void Function() onLeaveButtonPressed;
  final bool micEnabled;
  final bool cameraEnabled;

  const MeetingControls({
    super.key,
    required this.onToggleMicButtonPressed,
    required this.onToggleCameraButtonPressed,
    required this.onLeaveButtonPressed,
    this.micEnabled = true,
    this.cameraEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Microphone Control
            _buildControlButton(
              context: context,
              icon: micEnabled ? Icons.mic : Icons.mic_off,
              isActive: micEnabled,
              onPressed: onToggleMicButtonPressed,
              tooltip: micEnabled ? 'Mute microphone' : 'Unmute microphone',
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.error,
            ),
            
            // Camera Control
            _buildControlButton(
              context: context,
              icon: cameraEnabled ? Icons.videocam : Icons.videocam_off,
              isActive: cameraEnabled,
              onPressed: onToggleCameraButtonPressed,
              tooltip: cameraEnabled ? 'Turn off camera' : 'Turn on camera',
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.error,
            ),
            
            // Leave Call Control
            _buildControlButton(
              context: context,
              icon: Icons.call_end,
              isActive: false,
              onPressed: onLeaveButtonPressed,
              tooltip: 'End call',
              activeColor: theme.colorScheme.error,
              inactiveColor: theme.colorScheme.error,
              isEndCall: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
    required Color activeColor,
    required Color inactiveColor,
    bool isEndCall = false,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = isEndCall ? inactiveColor : (isActive ? activeColor : inactiveColor);
    final backgroundColor = isEndCall 
        ? inactiveColor
        : (isActive 
            ? activeColor.withOpacity(0.1)
            : inactiveColor.withOpacity(0.1));
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: isEndCall 
                  ? null
                  : Border.all(
                      color: effectiveColor.withOpacity(0.3),
                      width: 1,
                    ),
            ),
            child: Icon(
              icon,
              color: isEndCall ? Colors.white : effectiveColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
