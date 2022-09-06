import 'package:sample/domain/flavors/base/flavor.dart';

enum BackendUrls {
  main,
}

String getBaseUrl(BackendUrls api) {
  switch (api) {
    case BackendUrls.main:
      return currentFlavor.baseUrl;
  }
}