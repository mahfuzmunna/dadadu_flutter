// lib/config/app_config.dart
class AppConfig {
  static const String wasabiAccessKey = String.fromEnvironment(
      'WASABI_ACCESS_KEY',
      defaultValue: 'FPZKMCLV8Q3AFHQ081CG');
  static const String wasabiSecretKey = String.fromEnvironment(
      'WASABI_SECRET_KEY',
      defaultValue: 'ABee0Nd94zjzVm2uNIoXQIoD4irPQtND9KhGlXBO');

  // Changed from wasabiRegion to wasabiEndpoint
  static const String wasabiEndpoint = String.fromEnvironment('WASABI_ENDPOINT',
      defaultValue: 's3.eu-central-2.wasabisys.com');
  static const String wasabiBucketName = String.fromEnvironment(
      'WASABI_BUCKET_NAME',
      defaultValue: 'dadadu-assets');
  static const String bunnyCdnHostname = String.fromEnvironment(
      'BUNNY_CDN_HOSTNAME',
      defaultValue: 'dadadu.b-cdn.net');

// If using flutter_dotenv:
// static final String wasabiAccessKey = dotenv.env['WASABI_ACCESS_KEY']!;
// static final String wasabiSecretKey = dotenv.env['WASABI_SECRET_KEY']!;
// static final String wasabiEndpoint = dotenv.env['WASABI_ENDPOINT']!;
// static final String wasabiBucketName = dotenv.env['WASABI_BUCKET_NAME']!;
// static final String bunnyCdnHostname = dotenv.env['BUNNY_CDN_HOSTNAME']!;
}
