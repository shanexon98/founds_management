import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:management_funds/core/config/env.dart';
import 'package:management_funds/core/services/aws_signer.dart';
import 'package:management_funds/core/services/notification_service.dart';

class AwsNotificationService implements NotificationService {
  final String region;
  final String accessKeyId;
  final String secretAccessKey;
  final String? sessionToken;
  final String? topicArn;
  final http.Client _client;

  AwsNotificationService({
    String? region,
    String? accessKeyId,
    String? secretAccessKey,
    String? sessionToken,
    String? topicArn,
    http.Client? client,
  })  : region = region ?? Env.awsRegion,
        accessKeyId = accessKeyId ?? Env.awsAccessKeyId,
        secretAccessKey = secretAccessKey ?? Env.awsSecretAccessKey,
        sessionToken = (Env.awsSessionToken.isEmpty ? null : Env.awsSessionToken),
        topicArn = (topicArn ?? (Env.snsTopicArn.isEmpty ? null : Env.snsTopicArn)),
        _client = client ?? http.Client();

  Uri _endpoint() => Uri.parse('https://sns.$region.amazonaws.com/');

  Future<http.Response> _signedPost(Map<String, String> form) async {
    final payload = form.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final signer = AwsSigV4(
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
      region: region,
      service: 'sns',
      sessionToken: sessionToken,
    );
    final headers = signer.sign(
      url: _endpoint(),
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      payload: payload,
    );
    return _client.post(_endpoint(), headers: headers, body: payload);
  }

  @override
  Future<void> sendSms({required String phone, required String message}) async {
    final form = <String, String>{
      'Action': 'Publish',
      'Version': '2010-03-31',
      'PhoneNumber': phone,
      'Message': message,
      'MessageAttributes.entry.1.Name': 'AWS.SNS.SMS.SMSType',
      'MessageAttributes.entry.1.Value.DataType': 'String',
      'MessageAttributes.entry.1.Value.StringValue': 'Transactional',
    };
    final res = await _signedPost(form);
    if (res.statusCode >= 300) {
      throw Exception('SNS SMS error: ${res.statusCode} ${res.body}');
    }
  }

  @override
  Future<void> subscribeEmailToTopic({required String email}) async {
    if (topicArn == null || topicArn!.isEmpty) {
      throw Exception('SNS Topic ARN requerido');
    }
    final form = <String, String>{
      'Action': 'Subscribe',
      'Version': '2010-03-31',
      'TopicArn': topicArn!,
      'Protocol': 'email',
      'Endpoint': email,
    };
    final res = await _signedPost(form);
    if (res.statusCode >= 300) {
      throw Exception('SNS Subscribe error: ${res.statusCode} ${res.body}');
    }
  }

  @override
  Future<void> publishEmailToTopic({
    required String subject,
    required String body,
  }) async {
    if (topicArn == null || topicArn!.isEmpty) {
      throw Exception('SNS Topic ARN requerido');
    }
    final form = <String, String>{
      'Action': 'Publish',
      'Version': '2010-03-31',
      'TopicArn': topicArn!,
      'Subject': subject,
      'Message': body,
    };
    final res = await _signedPost(form);
    if (res.statusCode >= 300) {
      throw Exception('SNS Publish error: ${res.statusCode} ${res.body}');
    }
  }
}
