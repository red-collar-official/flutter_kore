enum Flavor {
  prod(
    name: prodName,
    baseUrl: .fromEnvironment('BASE_URL_PROD'),
    enableLogs: false,
  ),
  prodTest(
    name: prodName,
    baseUrl: .fromEnvironment('BASE_URL_PROD'),
    enableLogs: true,
  ),
  stage(
    name: stageName,
    baseUrl: .fromEnvironment('BASE_URL_STAGE'),
    enableLogs: true,
  ),
  dev(
    name: devName,
    baseUrl: .fromEnvironment('BASE_URL_DEV'),
    enableLogs: true,
  );

  const Flavor({
    required this.name,
    required this.baseUrl,
    required this.enableLogs,
  });

  final String baseUrl;
  final String name;
  final bool enableLogs;

  // TODO: add flavor settings here

  static const devName = 'devName';
  static const stageName = 'stageName';
  static const prodName = 'prodName';
  static const prodTestName = 'prodTestName';

  static Flavor fromName(String name) {
    switch (name) {
      case devName:
        return .dev;
      case stageName:
        return .stage;
      case prodName:
        return .prod;
      case prodTestName:
        return .prodTest;
      default:
        return .prod;
    }
  }
}

late Flavor currentFlavor;
