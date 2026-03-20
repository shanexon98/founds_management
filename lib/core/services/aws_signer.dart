import 'dart:convert';
import 'package:crypto/crypto.dart';

class AwsSigV4 {
  final String accessKeyId;
  final String secretAccessKey;
  final String? sessionToken;
  final String region;
  final String service;

  AwsSigV4({
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.region,
    required this.service,
    this.sessionToken,
  });

  Map<String, String> sign({
    required Uri url,
    required String method,
    required Map<String, String> headers,
    required String payload,
    DateTime? now,
  }) {
    now ??= DateTime.now().toUtc();
    final amzDate = _formatAmzDate(now);
    final dateStamp = _formatDate(now);
    final host = url.host;

    final signedHeaders = [
      'content-type',
      'host',
      'x-amz-date',
      if (sessionToken != null) 'x-amz-security-token',
    ].join(';');

    final canonicalHeaders = StringBuffer()
      ..write('content-type:${headers['Content-Type']?.toLowerCase() ?? 'application/x-www-form-urlencoded'}\n')
      ..write('host:$host\n')
      ..write('x-amz-date:$amzDate\n');
    if (sessionToken != null) {
      canonicalHeaders.write('x-amz-security-token:$sessionToken\n');
    }

    final canonicalRequest = [
      method,
      url.path.isEmpty ? '/' : url.path,
      '',
      canonicalHeaders.toString(),
      signedHeaders,
      sha256.convert(utf8.encode(payload)).toString(),
    ].join('\n');

    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    final signingKey = _getSignatureKey(secretAccessKey, dateStamp, region, service);
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    final authorization = 'AWS4-HMAC-SHA256 Credential=$accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    final signed = <String, String>{
      'Authorization': authorization,
      'x-amz-date': amzDate,
      'Host': host,
      'Content-Type': headers['Content-Type'] ?? 'application/x-www-form-urlencoded',
    };
    if (sessionToken != null) {
      signed['x-amz-security-token'] = sessionToken!;
    }
    return signed;
  }

  static String _formatAmzDate(DateTime dt) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    final y = dt.year.toString().padLeft(4, '0');
    final m = two(dt.month);
    final d = two(dt.day);
    final h = two(dt.hour);
    final min = two(dt.minute);
    final s = two(dt.second);
    return '$y$m$d' 'T' '$h$min$s' 'Z';
  }

  static String _formatDate(DateTime dt) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    final y = dt.year.toString().padLeft(4, '0');
    final m = two(dt.month);
    final d = two(dt.day);
    return '$y$m$d';
  }

  static List<int> _getSignatureKey(String key, String dateStamp, String regionName, String serviceName) {
    List<int> kDate = Hmac(sha256, utf8.encode('AWS4$key')).convert(utf8.encode(dateStamp)).bytes;
    List<int> kRegion = Hmac(sha256, kDate).convert(utf8.encode(regionName)).bytes;
    List<int> kService = Hmac(sha256, kRegion).convert(utf8.encode(serviceName)).bytes;
    List<int> kSigning = Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;
    return kSigning;
  }
}
