import 'package:flutter/foundation.dart';

abstract class NotificationService {
  Future<void> sendSms({required String phone, required String message});
  Future<void> subscribeEmailToTopic({required String email});
  Future<void> publishEmailToTopic({
    required String subject,
    required String body,
  });
}

class DummyNotificationService implements NotificationService {
  @override
  Future<void> publishEmailToTopic({required String subject, required String body}) async {}
  @override
  Future<void> sendSms({required String phone, required String message}) async {}
  @override
  Future<void> subscribeEmailToTopic({required String email}) async {}
}
