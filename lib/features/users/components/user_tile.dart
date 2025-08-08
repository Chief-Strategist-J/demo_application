import 'package:flutter/material.dart';
import 'package:demo_application/models/user.dart';

class UserTile extends StatefulWidget {
  final User user;
  final VoidCallback? onCallPressed;

  const UserTile({
    super.key,
    required this.user,
    required this.onCallPressed,
  });
  
  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
              vertical: 4,
            ),
            child: Material(
              elevation: widget.user.isOnline ? 2 : 1,
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface,
              shadowColor: theme.shadowColor.withOpacity(0.1),
              child: InkWell(
                onTap: widget.user.isInCall ? null : widget.onCallPressed,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: widget.user.isOnline
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primaryContainer.withOpacity(0.1),
                              theme.colorScheme.secondaryContainer.withOpacity(0.05),
                            ],
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Avatar with status indicator
                      _buildAvatar(theme, isCompact),
                      
                      SizedBox(width: isCompact ? 12 : 16),
                      
                      // User info
                      Expanded(
                        child: _buildUserInfo(theme, isCompact),
                      ),
                      
                      SizedBox(width: isCompact ? 8 : 12),
                      
                      // Call button
                      _buildCallButton(theme, isCompact),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAvatar(ThemeData theme, bool isCompact) {
    final avatarSize = isCompact ? 48.0 : 56.0;
    final statusSize = isCompact ? 14.0 : 16.0;
    
    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            boxShadow: widget.user.isOnline
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize / 2),
            child: Image.network(
              widget.user.avatar,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: avatarSize * 0.5,
                    color: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ),
        
        // Status indicator
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: statusSize,
            height: statusSize,
            decoration: BoxDecoration(
              color: widget.user.isOnline ? Colors.green : Colors.grey.shade400,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildUserInfo(ThemeData theme, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // User name
        Text(
          widget.user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isCompact ? 16 : 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Status row
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.user.isOnline ? Colors.green : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.user.isOnline 
                    ? 'Online' 
                    : 'Last seen ${_getTimeAgo(widget.user.lastSeen)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: isCompact ? 12 : 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        // In call indicator
        if (widget.user.isInCall) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_in_talk,
                  size: 12,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'In call',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildCallButton(ThemeData theme, bool isCompact) {
    final buttonSize = isCompact ? 44.0 : 52.0;
    final iconSize = isCompact ? 20.0 : 24.0;
    
    final isEnabled = !widget.user.isInCall && widget.onCallPressed != null;
    final backgroundColor = isEnabled 
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withOpacity(0.2);
    final iconColor = isEnabled 
        ? Colors.white
        : theme.colorScheme.outline;
    
    return Tooltip(
      message: widget.user.isInCall ? 'User is in call' : 'Start video call',
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: InkWell(
          onTap: isEnabled ? widget.onCallPressed : null,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(buttonSize / 2),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              Icons.videocam,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
