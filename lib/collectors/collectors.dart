import 'dart:async';

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:umvvm/annotations/api.dart';
import 'package:umvvm/annotations/mvvm_instance.dart';

class InstancesCollectorGenerator extends Generator {
  static List<AnnotatedElement> instances = [];
  static List<AnnotatedElement> api = [];

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    const instancesAnnotation = TypeChecker.fromRuntime(Instance);
    const apiAnnotation = TypeChecker.fromRuntime(ApiAnnotation);

    instances.addAll(library.annotatedWith(instancesAnnotation));
    api.addAll(library.annotatedWith(apiAnnotation));

    return super.generate(library, buildStep);
  }
}
