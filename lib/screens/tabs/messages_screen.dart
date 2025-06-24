import 'package:ecard_app/components/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modals/message_notification.dart';
import '../../services/notiication_service.dart';
import '../../utils/resources/animes/lottie_animes.dart';
import '../../utils/theme/theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final NotificationService _notificationService = NotificationService();
  List<MessageNotification> notifications = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString("userId");

    if (userId != null) {
      _notificationService.initialize(userId);
      await _loadNotifications();
    } else {
      setState(() {
        error = 'User not authenticated';
        isLoading = false;
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedNotifications = await _notificationService.loadNotifications();

      if (mounted) {
        setState(() {
          notifications = loadedNotifications;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load notifications: $e';
          isLoading = false;
        });
      }
    }
  }

  void markAsRead(int id) async {
    final success = await _notificationService.markAsRead(id);
    if (success && mounted) {
      setState(() {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          notifications[index] = MessageNotification(
            id: notifications[index].id,
            companyName: notifications[index].companyName,
            cardHolderName: notifications[index].cardHolderName,
            companyLogo: notifications[index].companyLogo,
            timestamp: notifications[index].timestamp,
            isRead: true,
            message: notifications[index].message,
            type: notifications[index].type,
            cardTitle: notifications[index].cardTitle,
            organization: notifications[index].organization,
            email: notifications[index].email,
            phoneNumber: notifications[index].phoneNumber,
            address: notifications[index].address,
            actorFullName: notifications[index].actorFullName,
            recipientFullName: notifications[index].recipientFullName,
          );
        }
      });
    }
  }

  void markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success && mounted) {
      setState(() {
        notifications = notifications
            .map((n) => MessageNotification(
          id: n.id,
          companyName: n.companyName,
          cardHolderName: n.cardHolderName,
          companyLogo: n.companyLogo,
          timestamp: n.timestamp,
          isRead: true,
          message: n.message,
          type: n.type,
          cardTitle: n.cardTitle,
          organization: n.organization,
          email: n.email,
          phoneNumber: n.phoneNumber,
          address: n.address,
          actorFullName: n.actorFullName,
          recipientFullName: n.recipientFullName,
        ))
            .toList();
      });
    }
  }

  String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    }
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.45,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: HeaderBoldWidget(
                    text: "Messages",
                    color: Theme.of(context).highlightColor,
                    size: '20'),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppThemeColor.primaryColor,
                          AppThemeColor.greenBrighter,
                          AppThemeColor.greenLower,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lottie Animation
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset(LottieAnimes.messages, fit: BoxFit.cover)
                          ),
                          const SizedBox(height: 20),
                          if (isLoading)
                            Lottie.asset(LottieAnimes.loading,
                                width: 130, height: 130)
                          else if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppThemeColor.brightness,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$unreadCount new notifications',
                                style: TextStyle(
                                  color: AppThemeColor.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else if (notifications.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                  AppThemeColor.brightness.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'All caught up!',
                                  style: TextStyle(
                                    color: AppThemeColor.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                            Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Connection Error',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      error!,
                                      style: TextStyle(
                                        color: Colors.red.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _loadNotifications,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!isLoading && error == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            if (unreadCount > 0)
                              TextButton(
                                onPressed: markAllAsRead,
                                child: Text(
                                  'Mark all as read',
                                  style: TextStyle(
                                    color: AppThemeColor.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (isLoading && error == null)
              SliverToBoxAdapter(
                child: Center(
                    child: Lottie.asset(LottieAnimes.loading,
                        height: 130, width: 130)),
              )
            else if (notifications.isEmpty && !isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Theme.of(context).hintColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).hintColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Notifications will appear here when you receive them',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final notification = notifications[index];
                    return NotificationCard(
                      notification: notification,
                      onTap: () => markAsRead(notification.id),
                      formatTime: formatTime,
                    );
                  },
                  childCount: notifications.length,
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Bottom padding
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final MessageNotification notification;
  final VoidCallback onTap;
  final String Function(DateTime) formatTime;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Theme.of(context).cardColor.withOpacity(0.7)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead
            ? null
            : Border.all(
            color: AppThemeColor.primaryColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppThemeColor.shadows.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppThemeColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppThemeColor.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      notification.companyLogo,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company name and notification type
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.companyName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                              AppThemeColor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.type == 'CARD_SAVED'
                                  ? 'SAVED'
                                  : 'MESSAGE',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppThemeColor.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Card holder name
                      Text(
                        notification.cardHolderName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppThemeColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Time and read status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatTime(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                              Theme.of(context).hintColor.withOpacity(0.6),
                            ),
                          ),
                          Row(
                            children: [
                              if (!notification.isRead) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppThemeColor.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Icon(
                                notification.isRead
                                    ? Icons.mark_email_read_outlined
                                    : Icons.mark_email_unread_outlined,
                                size: 16,
                                color: notification.isRead
                                    ? Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.5)
                                    : AppThemeColor.primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}