import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:umvvm/annotations/api.dart';
import 'package:umvvm/annotations/mvvm_instance.dart';

import 'package:umvvm_generator/collectors/models/api_json_model.dart';
import 'package:umvvm_generator/collectors/models/instance_json_model.dart';
import 'package:umvvm_generator/utility/class_utility.dart';

class InstancesCollectorGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    const instancesAnnotation = TypeChecker.typeNamed(Instance);
    final instances = library.annotatedWith(instancesAnnotation);
    final instancesJsonModels = <InstanceJsonModel>[];

    for (final element in instances) {
      final name = ClassUtility.getClassName(element.element);
      final inputType =
          element.annotation.peek('inputType')?.typeValue.getDisplayString();
      final asyncValue = element.annotation.peek('isAsync')?.boolValue ?? false;
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
      final lazy = element.annotation.peek('isLazy')?.boolValue ?? false;

      instancesJsonModels.add(InstanceJsonModel(
        name: name,
        singleton: singleton,
        isLazy: lazy,
        inputType: inputType ?? '',
        awaitInitialization: awaitInitialization,
        initializationOrder: order,
        isAsync: asyncValue,
        part: partValue,
      ));
    }

    if (instancesJsonModels.isNotEmpty) {
      return jsonEncode(instancesJsonModels);
    }

    return null;
  }
}

class ApisCollectorGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    const apiAnnotation = TypeChecker.typeNamed(ApiAnnotation);
    final apis = library.annotatedWith(apiAnnotation);
    final apisJsonModels = <ApiJsonModel>[];

    for (final element in apis) {
      final name = ClassUtility.getClassName(element.element);

      apisJsonModels.add(ApiJsonModel(
        name: name,
      ));
    }

    if (apisJsonModels.isNotEmpty) {
      return jsonEncode(apisJsonModels);
    }

    return null;
  }
}
