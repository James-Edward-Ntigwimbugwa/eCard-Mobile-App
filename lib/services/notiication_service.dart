import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../modals/message_notification.dart';

class NotificationService {
  static const String baseUrl = 'http://192.168.1.150:8080/api';
  static const String wsUrl = 'ws://192.168.1.150:8080/api';

  WebSocketChannel? _channel;
  StreamController<List<MessageNotification>>? _notificationsController;
  StreamController<MessageNotification>? _newNotificationController;

  List<MessageNotification> _notifications = [];
  String? _currentUserId;
  String? _token; // Store token for WebSocket usage

  // Getters for streams
  Stream<List<MessageNotification>> get notificationsStream =>
      _notificationsController?.stream ?? Stream.empty();

  Stream<MessageNotification> get newNotificationStream =>
      _newNotificationController?.stream ?? Stream.empty();

  List<MessageNotification> get currentNotifications => _notifications;

  void initialize(String userId) async {
    _currentUserId = userId;

    // Get the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("acessToken");

    _notificationsController = StreamController<List<MessageNotification>>.broadcast();
    _newNotificationController = StreamController<MessageNotification>.broadcast();

    // Load initial notifications
    loadNotifications();
    // Connect to WebSocket
    _connectWebSocket();
  }

  Future<void> loadNotifications() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("acessToken");

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/user/$_currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          "Accept" : "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _notifications = jsonData
            .map((json) => MessageNotification.fromJson(json))
            .toList();

        // Sort by timestamp (newest first)
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        _notificationsController?.add(_notifications);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _notificationsController?.addError(e);
    }
  }

  void _connectWebSocket() async {
    if (_currentUserId == null) return;

    // Ensure we have a fresh token
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("acessToken");

    if (_token == null) {
      print('No authentication token available for WebSocket connection');
      return;
    }

    try {
      // For WebSocket authentication, you have a few options:

      // Option 1: Add token as a query parameter
      final wsUrlWithAuth = '$wsUrl/notifications/user/$_currentUserId?token=$_token';

      _channel = IOWebSocketChannel.connect(
        wsUrlWithAuth,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      _channel!.stream.listen(
            (data) {
          try {
            final jsonData = json.decode(data);
            final notification = MessageNotification.fromJson(jsonData);

            // Add to the beginning of the list
            _notifications.insert(0, notification);

            // Emit the new notification
            _newNotificationController?.add(notification);

            // Emit the updated list
            _notificationsController?.add(_notifications);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          // Try to reconnect after a delay
          Timer(const Duration(seconds: 5), () {
            _connectWebSocket();
          });
        },
        onDone: () {
          print('WebSocket connection closed');
          // Try to reconnect after a delay
          Timer(const Duration(seconds: 5), () {
            _connectWebSocket();
          });
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      // Retry connection after delay
      Timer(const Duration(seconds: 10), () {
        _connectWebSocket();
      });
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("acessToken");

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add authentication
        },
      );

      if (response.statusCode == 200) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = MessageNotification(
            id: _notifications[index].id,
            companyName: _notifications[index].companyName,
            cardHolderName: _notifications[index].cardHolderName,
            companyLogo: _notifications[index].companyLogo,
            timestamp: _notifications[index].timestamp,
            isRead: true,
            message: _notifications[index].message,
            type: _notifications[index].type,
            cardTitle: _notifications[index].cardTitle,
            organization: _notifications[index].organization,
            email: _notifications[index].email,
            phoneNumber: _notifications[index].phoneNumber,
            address: _notifications[index].address,
            actorFullName: _notifications[index].actorFullName,
            recipientFullName: _notifications[index].recipientFullName,
          );

          _notificationsController?.add(_notifications);
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("acessToken");

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/user/$_currentUserId/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add authentication
        },
      );

      if (response.statusCode == 200) {
        // Update local state
        _notifications = _notifications.map((n) => MessageNotification(
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
        )).toList();

        _notificationsController?.add(_notifications);
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void dispose() {
    _channel?.sink.close();
    _notificationsController?.close();
    _newNotificationController?.close();
  }

  // Reconnect method for manual reconnection
  void reconnect() {
    _channel?.sink.close();
    _connectWebSocket();
  }
}