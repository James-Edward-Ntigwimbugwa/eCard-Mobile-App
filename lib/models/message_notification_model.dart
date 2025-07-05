class MessageNotification {
  final int id;
  final String companyName;
  final String cardHolderName;
  final String companyLogo;
  final DateTime timestamp;
  final bool isRead;
  final String message;
  final String type;
  final String? cardTitle;
  final String? organization;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String actorFullName;
  final String recipientFullName;

  MessageNotification({
    required this.id,
    required this.companyName,
    required this.cardHolderName,
    required this.companyLogo,
    required this.timestamp,
    required this.isRead,
    required this.message,
    required this.type,
    this.cardTitle,
    this.organization,
    this.email,
    this.phoneNumber,
    this.address,
    required this.actorFullName,
    required this.recipientFullName,
  });

  factory MessageNotification.fromJson(Map<String, dynamic> json) {
    return MessageNotification(
      id: json['id'],
      companyName: json['card']?['organization'] ??
          json['actor']['companyName'] ??
          'Unknown Company',
      cardHolderName: json['actor']['fullName'] ?? 'Unknown',
      companyLogo: _getCompanyLogo(
          json['card']?['organization'] ?? json['actor']['companyName']),
      timestamp: DateTime.parse(json['createdAt']),
      isRead: json['read'] ?? false,
      message: _generateMessage(
          json['type'], json['message'], json['actor']['fullName']),
      type: json['type'],
      cardTitle: json['card']?['title'],
      organization: json['card']?['organization'],
      email: json['card']?['email'],
      phoneNumber: json['card']?['phoneNumber'],
      address: json['card']?['address'],
      actorFullName: json['actor']['fullName'] ?? 'Unknown',
      recipientFullName: json['recipient']['fullName'] ?? 'Unknown',
    );
  }

  static String _getCompanyLogo(String? companyName) {
    if (companyName == null) return '🏢';

    final name = companyName.toLowerCase();
    if (name.contains('fishing')) return '🐟';
    if (name.contains('tech')) return '💻';
    if (name.contains('holdings')) return '🏦';
    if (name.contains('trading') || name.contains('traders')) return '📈';
    if (name.contains('company')) return '🏢';
    return '💼';
  }

  static String _generateMessage(
      String type, String? messageContent, String actorName) {
    switch (type) {
      case 'CARD_SAVED':
        return '$actorName saved your business card';
      case 'CARDHOLDER_MESSAGE':
        if (messageContent != null && messageContent.isNotEmpty) {
          // Try to parse JSON message first
          try {
            final messageData = messageContent
                .replaceAll('"', '')
                .replaceAll('{', '')
                .replaceAll('}', '');
            if (messageData.contains('message')) {
              final actualMessage = messageData.split(':').last.trim();
              return '$actorName sent: $actualMessage';
            }
          } catch (e) {
            // If JSON parsing fails, use the message as is
            final cleanMessage = messageContent.replaceAll('"', '').trim();
            return '$actorName sent: $cleanMessage';
          }
        }
        return '$actorName sent you a message';
      default:
        return '$actorName performed an action';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'cardHolderName': cardHolderName,
      'companyLogo': companyLogo,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'message': message,
      'type': type,
      'cardTitle': cardTitle,
      'organization': organization,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'actorFullName': actorFullName,
      'recipientFullName': recipientFullName,
    };
  }
}
