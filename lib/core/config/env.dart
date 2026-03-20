class Env {
  static const awsRegion = String.fromEnvironment('AWS_REGION', defaultValue: '');
  static const awsAccessKeyId =
      String.fromEnvironment('AWS_ACCESS_KEY_ID', defaultValue: '');
  static const awsSecretAccessKey =
      String.fromEnvironment('AWS_SECRET_ACCESS_KEY', defaultValue: '');
  static const awsSessionToken =
      String.fromEnvironment('AWS_SESSION_TOKEN', defaultValue: '');
  static const snsTopicArn =
      String.fromEnvironment('SNS_TOPIC_ARN', defaultValue: '');
}