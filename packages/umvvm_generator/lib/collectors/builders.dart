// ignore: depend_on_referenced_packages
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'collectors.dart';

Builder generateInstanceCollector(BuilderOptions options) => LibraryBuilder(
      InstancesCollectorGenerator(),
      generatedExtension: '.mvvm.json',
      allowSyntaxErrors: true,
      formatOutput: (generated) => generated.replaceAll(RegExp(r'//.*|\s'), ''),
    );

Builder generateApiCollector(BuilderOptions options) => LibraryBuilder(
      ApisCollectorGenerator(),
      generatedExtension: '.api.json',
      allowSyntaxErrors: true,
      formatOutput: (generated) => generated.replaceAll(RegExp(r'//.*|\s'), ''),
    );
