final class AppConfig {
  const AppConfig({
    this.apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://rickandmortyapi.com/api',
    ),
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 15),
  });
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
}
