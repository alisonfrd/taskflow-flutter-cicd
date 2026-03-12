class AppConfig {
  final String flavor;
  final String appName;

  const AppConfig({required this.flavor, required this.appName});

  bool get isDev => flavor == 'dev';
  bool get isProd => flavor == 'prod';
}
