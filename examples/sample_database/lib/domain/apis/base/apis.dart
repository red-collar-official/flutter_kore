import 'package:sample_database/domain/flavors/base/flavor.dart';

/// Enum to list all backend api services
enum BackendUrls {
  main,
}

/// Returns backend base url based on current flavor
String getBaseUrl(BackendUrls api) {
  switch (api) {
    case BackendUrls.main:
      return currentFlavor.baseUrl;
  }
}