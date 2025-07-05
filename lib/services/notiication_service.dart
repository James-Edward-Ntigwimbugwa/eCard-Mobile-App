import 'dart:convert';
import 'package:ecard_app/services/app_urls.dart';
import 'package:ecard_app/services/requests/notification_requests.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_notification_model.dart';

class NotificationService {
  List<MessageNotification> _notifications = [];
  List<MessageNotification> get currentNotifications => _notifications;

  // initialize global user id
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  Future<List<MessageNotification>> loadNotifications(
      {required String? userId}) async {
    try {
      final response =
          await NotificationRequests.fetchNotifications(id: userId);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _notifications =
            jsonData.map((json) => MessageNotification.fromJson(json)).toList();
        // Sort by timestamp (newest first)
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return _notifications;
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading notifications: $e');
      throw e;
    }
  }

  Future<http.Response> sendNotification({
    required String cardId,
    required String message,
  }) async {
    try {
      final response = await NotificationRequests.sendNotificationToUsers(
          cardId: cardId, message: message);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearerToken = prefs.getString("accessToken");

    try {
      final response = await http.put(
        Uri.parse('${AppUrl.markAsRead}/$notificationId'),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
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
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final bearerToken = prefs.getString("accessToken");

    try {
      final response = await http.put(
        Uri.parse('${AppUrl.markAsRead}/$_currentUserId'),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Update local state
        _notifications = _notifications
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

        return true;
      }
      return false;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  void dispose() {
    // Clean up any resources if needed
    _notifications.clear();
  }
}
