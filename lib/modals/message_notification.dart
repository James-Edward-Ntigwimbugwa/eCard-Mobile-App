class MessageNotification {
  final String id;
  final String companyName;
  final String cardHolderName;
  final String companyLogo;
  final DateTime timestamp;
  final bool isRead;
  final String message;

  MessageNotification({
    required this.id,
    required this.companyName,
    required this.cardHolderName,
    required this.companyLogo,
    required this.timestamp,
    required this.isRead,
    required this.message,
  });
}