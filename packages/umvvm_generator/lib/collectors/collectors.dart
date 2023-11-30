import 'dart:async';
import 'dart:convert';

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:umvvm/annotations/api.dart';
import 'package:umvvm/annotations/mvvm_instance.dart';

// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/element.dart';
import 'package:umvvm_generator/collectors/models/api_json_model.dart';
import 'package:umvvm_generator/collectors/models/instance_json_model.dart';

import 'main_app_visitor.dart';

class InstancesCollectorGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    const instancesAnnotation = TypeChecker.fromRuntime(Instance);
    final instances = library.annotatedWith(instancesAnnotation);
    final instancesJsonModels = <InstanceJsonModel>[];

    for (final element in instances) {
      final name = getClassName(element.element);
      final inputType = element.annotation
          .peek('inputType')
          ?.typeValue
          .getDisplayString(withNullability: false);
      final asyncValue = element.annotation.peek('async')?.boolValue ?? false;
      final partValue = element.annotation.peek('part')?.boolValue ?? false;
      final awaitInitialization =
          element.annotation.peek('awaitInitialization')?.boolValue ?? false;
      final order = element.annotation
          .peek(
            'initializationOrder',
          )
          ?.intValue;
      final singleton =
          element.annotation.peek('singleton')?.boolValue ?? false;
      final lazy = element.annotation.peek('lazy')?.boolValue ?? false;

      instancesJsonModels.add(InstanceJsonModel(
        name: name,
        singleton: singleton,
        lazy: lazy,
        inputType: inputType ?? '',
        awaitInitialization: awaitInitialization,
        initializationOrder: order,
        async: asyncValue,
        part: partValue,
      ));
    }

    if (instancesJsonModels.isNotEmpty) {
      return jsonEncode(instancesJsonModels);
    }

    return null;
  }

  String getClassName(Element element) {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    return visitor.className ?? '';
  }
}

class ApisCollectorGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    const apiAnnotation = TypeChecker.fromRuntime(ApiAnnotation);
    final apis = library.annotatedWith(apiAnnotation);
    final apisJsonModels = <ApiJsonModel>[];

    for (final element in apis) {
      final name = getClassName(element.element);

      apisJsonModels.add(ApiJsonModel(
        name: name,
      ));
    }

    if (apisJsonModels.isNotEmpty) {
      return jsonEncode(apisJsonModels);
    }

    return null;
  }

  String getClassName(Element element) {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    return visitor.className ?? '';
  }
}
