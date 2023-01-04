import 'package:sample_database/domain/flavors/base/flavor.dart';

class TestFlavor extends Flavor {
  @override
  String get baseUrl => 'http://jsonplaceholder.typicode.com';
}
