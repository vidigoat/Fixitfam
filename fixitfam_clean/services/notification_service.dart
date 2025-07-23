import 'package:flutter/material.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  static NotificationService get instance => _instance;
  
  final List<AppNotification> _notifications = [];
  final StreamController<List<AppNotification>> _notificationController = 
      StreamController<List<AppNotification>>.broadcast();
  
  Stream<List<AppNotification>> get notificationStream => _notificationController.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notificationController.add(_notifications);
    
    // Auto-remove after delay if specified
    if (notification.autoRemove) {
      Timer(Duration(seconds: notification.duration), () {
        removeNotification(notification.id);
      });
    }
  }
  
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notificationController.add(_notifications);
  }
  
  void clearAll() {
    _notifications.clear();
    _notificationController.add(_notifications);
  }
  
  void dispose() {
    _notificationController.close();
  }
  
  // Quick notification methods
  void showSuccess(String message, {String? title}) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'Success',
      message: message,
      type: NotificationType.success,
    ));
  }
  
  void showError(String message, {String? title}) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'Error',
      message: message,
      type: NotificationType.error,
    ));
  }
  
  void showInfo(String message, {String? title}) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'Info',
      message: message,
      type: NotificationType.info,
    ));
  }
  
  void showReminder(String message, {String? title}) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'Reminder',
      message: message,
      type: NotificationType.reminder,
      autoRemove: false,
    ));
  }
}

enum NotificationType {
  success,
  error,
  info,
  reminder,
  expense,
  health,
  task,
  trip,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool autoRemove;
  final int duration; // seconds
  final VoidCallback? onTap;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    DateTime? timestamp,
    this.autoRemove = true,
    this.duration = 5,
    this.onTap,
  }) : timestamp = timestamp ?? DateTime.now();
  
  IconData get icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.expense:
        return Icons.attach_money;
      case NotificationType.health:
        return Icons.favorite;
      case NotificationType.task:
        return Icons.task_alt;
      case NotificationType.trip:
        return Icons.flight;
    }
  }
  
  Color get color {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF4CAF50);
      case NotificationType.error:
        return const Color(0xFFF44336);
      case NotificationType.info:
        return const Color(0xFF2196F3);
      case NotificationType.reminder:
        return const Color(0xFFFF9800);
      case NotificationType.expense:
        return const Color(0xFF4CAF50);
      case NotificationType.health:
        return const Color(0xFFE91E63);
      case NotificationType.task:
        return const Color(0xFF795548);
      case NotificationType.trip:
        return const Color(0xFF9C27B0);
    }
  }
}

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: NotificationService.instance.notificationStream,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        
        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.white54,
                ),
                SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationCard(notification: notification);
          },
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  
  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: notification.color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: notification.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notification.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.timestamp),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    NotificationService.instance.removeNotification(notification.id);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
