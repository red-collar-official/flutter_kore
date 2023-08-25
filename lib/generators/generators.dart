// ignore_for_file: avoid_print

// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:mvvm_redux/annotations/main_api.dart';
import 'package:mvvm_redux/annotations/main_app.dart';
import 'package:mvvm_redux/collectors/collectors.dart';
import 'package:source_gen/source_gen.dart';
import 'package:mvvm_redux/generators/main_app_visitor.dart';

class MainAppGenerator extends GeneratorForAnnotation<MainApp> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    final className = '${getClassName(element)}Gen';
    final classBuffer = StringBuffer();

    // @override
    // List<Type> get singletons => [
    //     AutharizationInteractor,
    //     UserDefaultsInteractor,
    //     NavigationInteractor,
    //   ];

    // for (final element in singletonAnnotated) {
    //   if (element.source != null) {
    //     classBuffer.writeln("import '${element.source!.uri.toString()}';");
    //   }
    // }

    generateConnectorsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.singletonAnnotatedInteractors,
    );

    generateConnectorsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.defaultAnnotatedInteractors,
    );

    generateConnectorsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.singletonAnnotatedServices,
    );

    generateConnectorsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.defaultAnnotatedServices,
    );

    classBuffer.writeln('class Connectors {');

    generateConnectorCallsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.singletonAnnotatedInteractors,
    );

    generateConnectorCallsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.defaultAnnotatedInteractors,
    );

    generateConnectorCallsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.singletonAnnotatedServices,
    );

    generateConnectorCallsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.defaultAnnotatedServices,
    );

    classBuffer
      ..writeln('}')
      ..writeln();

    // ignore: cascade_invocations
    classBuffer
      ..writeln(
          'mixin $className on MvvmReduxApp<${annotation.peek('navigationInteractorType')!.typeValue.getDisplayString(withNullability: false)}> {')
      ..writeln('final connectors = Connectors();')
      ..writeln()
      ..writeln('@override')
      ..writeln('List<Type> get singletonInteractors => [');

    // ignore: prefer_foreach
    for (final element
        in InstancesCollectorGenerator.singletonAnnotatedInteractors) {
      if (element.element.name != null) {
        classBuffer.writeln(element.element.name! + ', ');
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
      ..writeln('void registerInteractors() {');

    if (InstancesCollectorGenerator.singletonAnnotatedInteractors.isNotEmpty ||
        InstancesCollectorGenerator.defaultAnnotatedInteractors.isNotEmpty) {
      classBuffer.writeln('interactors');
    }

    InstancesCollectorGenerator.singletonAnnotatedInteractors
        .forEach((element) {
      classBuffer.writeln(
          '..addBuilder<${element.element.name}>(() => ${element.element.name}())');
    });

    InstancesCollectorGenerator.defaultAnnotatedInteractors.forEach((element) {
      classBuffer.writeln(
          '..addBuilder<${element.element.name}>(() => ${element.element.name}())');
    });

    if (InstancesCollectorGenerator.singletonAnnotatedInteractors.isNotEmpty ||
        InstancesCollectorGenerator.defaultAnnotatedInteractors.isNotEmpty) {
      classBuffer.writeln(';');
    }

    classBuffer
      ..writeln('}')
      ..writeln();

    // ignore: cascade_invocations
    classBuffer
      ..writeln('@override')
      ..writeln('List<Type> get singletonServices => [');

    // ignore: prefer_foreach
    for (final element
        in InstancesCollectorGenerator.singletonAnnotatedServices) {
      if (element.element.name != null) {
        classBuffer.writeln(element.element.name! + ', ');
      }
    }

    classBuffer
      ..writeln('  ];')
      ..writeln()
      ..writeln('@override')
      ..writeln('void registerServices() {');

    if (InstancesCollectorGenerator.singletonAnnotatedServices.isNotEmpty ||
        InstancesCollectorGenerator.defaultAnnotatedServices.isNotEmpty) {
      classBuffer.writeln('services');
    }

    InstancesCollectorGenerator.singletonAnnotatedServices.forEach((element) {
      classBuffer.writeln(
          '..addBuilder<${element.element.name}>(() => ${element.element.name}())');
    });

    InstancesCollectorGenerator.defaultAnnotatedServices.forEach((element) {
      classBuffer.writeln(
          '..addBuilder<${element.element.name}>(() => ${element.element.name}())');
    });

    if (InstancesCollectorGenerator.singletonAnnotatedServices.isNotEmpty ||
        InstancesCollectorGenerator.defaultAnnotatedServices.isNotEmpty) {
      classBuffer.writeln(';');
    }

    classBuffer
      ..writeln('}')
      ..writeln('}');

    String printMessage = '';

    printMessage += 'Generated Mvvm app\n\n';

    printMessage +=
        'Singleton interactors count: ${InstancesCollectorGenerator.singletonAnnotatedInteractors.length}\n';
    printMessage +=
        'Default interactors count: ${InstancesCollectorGenerator.defaultAnnotatedInteractors.length}\n';
    printMessage +=
        'Singleton services count: ${InstancesCollectorGenerator.singletonAnnotatedServices.length}\n';
    printMessage +=
        'Default services count: ${InstancesCollectorGenerator.defaultAnnotatedServices.length}\n';
    printMessage +=
        'Apis count: ${InstancesCollectorGenerator.apiAnnotated.length}';

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
    List<AnnotatedElement> collection,
  ) {
    for (final element in collection) {
      final nameOfElementClass = getClassName(element.element);
      final nameOfInputType = element.annotation
          .peek('inputType')
          ?.typeValue
          .getDisplayString(withNullability: false);

      classBuffer
        ..writeln(
          'class ${nameOfElementClass}Connector extends ConnectorCall<$nameOfElementClass, $nameOfInputType?> {}',
        )
        ..writeln();
    }
  }

  void generateConnectorCallsForInstanceType(
    StringBuffer classBuffer,
    List<AnnotatedElement> collection,
  ) {
    for (final element in collection) {
      generateConnectorCallForElement(classBuffer, element);
    }
  }

  void generateConnectorCallForElement(
    StringBuffer classBuffer,
    AnnotatedElement element,
  ) {
    final nameOfElementClass = getClassName(element.element);

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
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
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

    // ignore: prefer_foreach
    for (final element in InstancesCollectorGenerator.apiAnnotated) {
      if (element.element.name != null) {
        final elementName = element.element.name!;
        final elementShortName = elementName.toLowerCase().split('api')[0];

        classBuffer
          ..writeln('$elementName? _$elementShortName;')
          ..writeln(
              '$elementName get $elementShortName => _$elementShortName ??= $elementName();')
          ..writeln('@visibleForTesting')
          ..writeln(
              'set $elementShortName(value) => _$elementShortName = value;');
      }
    }

    classBuffer.writeln('}');

    return classBuffer.toString();
  }
}
