// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:build/src/builder/build_step.dart';
// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/element.dart';
import 'package:glob/glob.dart';
import 'package:umvvm/annotations/main_api.dart';
import 'package:umvvm/annotations/main_app.dart';
import 'package:source_gen/source_gen.dart';
import 'package:umvvm/collectors/models/api_json_model.dart';
import 'package:umvvm/collectors/models/instance_json_model.dart';
import 'package:umvvm/generators/main_app_visitor.dart';

class MainAppGenerator extends GeneratorForAnnotation<MainApp> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    final className = '${getClassName(element)}Gen';
    final classBuffer = StringBuffer();

    final instanceJsons = Glob('lib/**.mvvm.json');

    final jsonData = <Map>[];

    await for (final id in buildStep.findAssets(instanceJsons)) {
      final json = jsonDecode(await buildStep.readAsString(id));
      jsonData.addAll([...json]);
    }

    final instances = <InstanceJsonModel>[];

    for (final json in jsonData) {
      instances.add(InstanceJsonModel.fromJson(json));
    }

    // @override
    // List<Type> get singletons => [
    //     AutharizationInteractor,
    //     UserDefaultsInteractor,
    //     NavigationInteractor,
    //   ];

    generateConnectorsForInstanceType(
      classBuffer,
      instances,
    );

    // ignore: cascade_invocations
    classBuffer.writeln('class Connectors {');

    generateConnectorCallsForInstanceType(
      classBuffer,
      instances,
    );

    classBuffer
      ..writeln('}')
      ..writeln();

    if (annotation.peek('navigationInteractorType') == null) {
      classBuffer.writeln(
        'mixin $className on UMvvmApp {',
      );
    } else {
      classBuffer.writeln(
        'mixin $className on UMvvmApp<${annotation.peek('navigationInteractorType')!.typeValue.getDisplayString(withNullability: false)}> {',
      );
    }

    // ignore: cascade_invocations
    classBuffer
      ..writeln('final connectors = Connectors();')
      ..writeln()
      ..writeln('@override')
      ..writeln('List<Connector> get singletonInstances => [');

    // ignore: prefer_foreach
    for (final element in instances) {
      if (element.singleton && !element.lazy) {
        classBuffer.writeln(
          'connectors.${uncapitalize(element.name)}Connector(),',
        );
      }
    }

    // @override
    // void registerBuilders() {
    //   interactors
    //     ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
    //     ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
    //     ..addBuilder<PostsInteractor>(() => PostsInteractor())
    //     ..addBuilder<ShareInteractor>(() => ShareInteractor())
    //     ..addBuilder<PostInteractor>(() => PostInteractor())
    //     ..addBuilder<NavigationInteractor>(() => NavigationInteractor());
    // }

    classBuffer
      ..writeln('  ];')
      ..writeln()
      ..writeln('@override')
      ..writeln('void registerInstances() {');
    if (instances.isNotEmpty) {
      classBuffer.writeln('instances');
    }

    for (final element in instances) {
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    }

    if (instances.isNotEmpty) {
      classBuffer.writeln(';');
    }

    classBuffer
      ..writeln('}')
      ..writeln('}');

    String printMessage = '';

    printMessage += 'Generated Mvvm app\n\n';
    printMessage += 'Instances count: ${instances.length}';
    print(printMessage);

    return classBuffer.toString();
  }

  String getClassName(Element element) {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    return visitor.className ?? '';
  }

  void generateConnectorsForInstanceType(
    StringBuffer classBuffer,
    List<InstanceJsonModel> instances,
  ) {
    for (final element in instances) {
      final nameOfElementClass = element.name;
      final nameOfInputType = element.inputType;
      final asyncValue = element.async;
      final awaitInitializationValue = element.awaitInitialization;
      final orderValue = element.initializationOrder;

      String overridesString = '';

      if (orderValue != null) {
        overridesString += '''
  @override
  int? get order => $orderValue;
''';
      }

      if (awaitInitializationValue || orderValue != null) {
        overridesString += '''
  @override
  bool get awaitInitialization => $awaitInitializationValue;
''';
      }

      classBuffer
        ..writeln(
          'class ${nameOfElementClass}Connector extends ${asyncValue ? 'AsyncConnectorCall' : 'ConnectorCall'}<$nameOfElementClass, $nameOfInputType?> {$overridesString}',
        )
        ..writeln();
    }
  }

  void generateConnectorCallsForInstanceType(
    StringBuffer classBuffer,
    List<InstanceJsonModel> collection,
  ) {
    for (final element in collection) {
      generateConnectorCallForElement(classBuffer, element);
    }
  }

  void generateConnectorCallForElement(
    StringBuffer classBuffer,
    InstanceJsonModel element,
  ) {
    final nameOfElementClass = element.name;

    classBuffer.writeln(
      'late final ${uncapitalize(nameOfElementClass)}Connector = ${nameOfElementClass}Connector();',
    );
  }

  String uncapitalize(String input) {
    return '${input[0].toLowerCase()}${input.substring(1)}';
  }
}

class MainApiGenerator extends GeneratorForAnnotation<MainApiAnnotation> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    final className = '${visitor.className}Gen';
    final classBuffer = StringBuffer();

    // class Apis {
    //   static PostsApi? _posts;
    //   static PostsApi get posts => _posts ??= PostsApi();
    //   @visibleForTesting
    //   static set posts(value) => _posts = value;
    // }

    // ignore: cascade_invocations
    classBuffer.writeln('mixin $className {');

    final apisJsons = Glob('lib/**.api.json');

    final jsonData = <Map>[];

    await for (final id in buildStep.findAssets(apisJsons)) {
      final json = jsonDecode(await buildStep.readAsString(id));
      jsonData.addAll([...json]);
    }

    final apis = <ApiJsonModel>[];

    for (final json in jsonData) {
      apis.add(ApiJsonModel.fromJson(json));
    }

    // ignore: prefer_foreach
    for (final element in apis) {
      final elementName = element.name;
      final elementShortName = elementName.toLowerCase().split('api')[0];

      classBuffer
        ..writeln('$elementName? _$elementShortName;')
        ..writeln(
            '$elementName get $elementShortName => _$elementShortName ??= $elementName();')
        ..writeln('@visibleForTesting')
        ..writeln(
            'set $elementShortName(value) => _$elementShortName = value;');
    }

    classBuffer.writeln('}');

    String printMessage = '';

    printMessage += 'Generated Apis for app\n\n';
    printMessage += 'Apis count: ${apis.length}';

    print(printMessage);

    return classBuffer.toString();
  }
}
