import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'generators.dart';

Builder generateMainApp(BuilderOptions options) => SharedPartBuilder([MainAppGenerator()], 'main_app_generator');
Builder generateMainApi(BuilderOptions options) => SharedPartBuilder([MainApiGenerator()], 'main_api_generator');
