import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> showApprovalNotification(String claimTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'expense_claims',
      'Expense Claims',
      channelDescription: 'Notifications for expense claim approvals',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Expense claim approved',
      '$claimTitle has been successfully approved for payment!',
      const NotificationDetails(android: androidDetails),
    );
  }
}
