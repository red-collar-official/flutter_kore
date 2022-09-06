import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'main_app_generator.dart';

Builder generateMainApp(BuilderOptions options) => SharedPartBuilder([MainAppGenerator()], 'main_app_generator');
