import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'collectors.dart';

Builder generateInstanceCollector(BuilderOptions options) => PartBuilder(
      [InstancesCollectorGenerator()],
      '.temp.dart',
      allowSyntaxErrors: true,
    );
