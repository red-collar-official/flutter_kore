// ignore_for_file: avoid_print

// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:umvvm/annotations/main_api.dart';
import 'package:umvvm/annotations/main_app.dart';
import 'package:umvvm/collectors/collectors.dart';
import 'package:source_gen/source_gen.dart';
import 'package:umvvm/generators/main_app_visitor.dart';

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
      InstancesCollectorGenerator.instances,
    );

    // ignore: cascade_invocations
    classBuffer.writeln('class Connectors {');

    generateConnectorCallsForInstanceType(
      classBuffer,
      InstancesCollectorGenerator.instances,
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
      ..writeln('List<Type> get singletonInstances => [');

    // ignore: prefer_foreach
    for (final element in InstancesCollectorGenerator.instances) {
      if ((element.annotation.peek('singleton')?.boolValue ?? false) &&
          element.element.name != null) {
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
      ..writeln('void registerInstances() {');
    if (InstancesCollectorGenerator.instances.isNotEmpty) {
      classBuffer.writeln('instances');
    }

    InstancesCollectorGenerator.instances.forEach((element) {
      classBuffer.writeln(
          '..addBuilder<${element.element.name}>(() => ${element.element.name}())');
    });

    if (InstancesCollectorGenerator.instances.isNotEmpty) {
      classBuffer.writeln(';');
    }

    classBuffer
      ..writeln('}')
      ..writeln('}');

    String printMessage = '';

    printMessage += 'Generated Mvvm app\n\n';

    printMessage +=
        'Instances count: ${InstancesCollectorGenerator.instances.length}\n';
    printMessage += 'Apis count: ${InstancesCollectorGenerator.api.length}';

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
    for (final element in InstancesCollectorGenerator.api) {
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
