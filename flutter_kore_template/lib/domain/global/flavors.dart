enum Flavor {
  prod(
    name: prodName,
    baseUrl: String.fromEnvironment('BASE_URL_PROD'),
    enableLogs: false,
  ),
  prodTest(
    name: prodName,
    baseUrl: String.fromEnvironment('BASE_URL_PROD'),
    enableLogs: true,
  ),
  stage(
    name: stageName,
    baseUrl: String.fromEnvironment('BASE_URL_STAGE'),
    enableLogs: true,
  ),
  dev(
    name: devName,
    baseUrl: String.fromEnvironment('BASE_URL_DEV'),
    enableLogs: true,
  );

  final String baseUrl;
  final String name;
  final bool enableLogs;

  // TODO: add flavor settings here

  const Flavor({
    required this.name,
    required this.baseUrl,
    required this.enableLogs,
  });

  static const devName = 'devName';
  static const stageName = 'stageName';
  static const prodName = 'prodName';
  static const prodTestName = 'prodTestName';

  static Flavor fromName(String name) {
    switch (name) {
      case devName:
        return Flavor.dev;
      case stageName:
        return Flavor.stage;
      case prodName:
        return Flavor.prod;
      case prodTestName:
        return Flavor.prodTest;
      default:
        return Flavor.prod;
    }
  }
}

late Flavor currentFlavor;
