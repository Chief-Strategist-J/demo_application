import 'package:flutter/material.dart';
import 'package:demo_application/models/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback? onCallPressed;

  const UserTile({
    super.key,
    required this.user,
    required this.onCallPressed,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(user.avatar),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: user.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: user.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.isOnline 
                      ? 'Online' 
                      : 'Last seen ${_getTimeAgo(user.lastSeen)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            if (user.isInCall) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone_in_talk,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'In call',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video call button
            IconButton(
              onPressed: user.isInCall ? null : onCallPressed,
              icon: const Icon(Icons.videocam),
              tooltip: user.isInCall ? 'User is in call' : 'Start video call',
              style: IconButton.styleFrom(
                backgroundColor: user.isInCall 
                    ? theme.colorScheme.outline.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.1),
                foregroundColor: user.isInCall 
                    ? theme.colorScheme.outline
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            // Status indicator
            if (user.isOnline)
              Icon(
                Icons.circle,
                color: Colors.green,
                size: 12,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey,
                size: 12,
              ),
          ],
        ),
        onTap: user.isInCall ? null : onCallPressed,
      ),
    );
  }
}
