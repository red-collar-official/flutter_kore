// ignore_for_file: avoid_print

// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:mvvm_redux/annotations/main_api.dart';
import 'package:mvvm_redux/annotations/main_app.dart';
import 'package:mvvm_redux/collectors/collectors.dart';
import 'package:source_gen/source_gen.dart';
import 'package:mvvm_redux/generators/main_app_visitor.dart';

class MainAppGenerator extends GeneratorForAnnotation<MainAppAnnotation> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    final className = '${visitor.className}Gen';
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

    // ignore: cascade_invocations
    classBuffer
      ..writeln('mixin $className on MvvmReduxApp {')
      ..writeln('@override')
      ..writeln('List<Type> get singletonInteractors => [');

    // ignore: prefer_foreach
    for (final element in InstancesCollectorGenerator.singletonAnnotated) {
      if (element.name != null) {
        classBuffer.writeln(element.name! + ', ');
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

    if (InstancesCollectorGenerator.singletonAnnotated.isNotEmpty ||
        InstancesCollectorGenerator.defaultAnnotated.isNotEmpty) {
      classBuffer.writeln('interactors');
    }

    InstancesCollectorGenerator.singletonAnnotated.forEach((element) {
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    });

    InstancesCollectorGenerator.defaultAnnotated.forEach((element) {
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    });

    if (InstancesCollectorGenerator.singletonAnnotated.isNotEmpty ||
        InstancesCollectorGenerator.defaultAnnotated.isNotEmpty) {
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
      if (element.name != null) {
        classBuffer.writeln(element.name! + ', ');
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
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    });

    InstancesCollectorGenerator.defaultAnnotatedServices.forEach((element) {
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    });

    if (InstancesCollectorGenerator.singletonAnnotatedServices.isNotEmpty ||
        InstancesCollectorGenerator.defaultAnnotatedServices.isNotEmpty) {
      classBuffer.writeln(';');
    }

    classBuffer
      ..writeln('}')
      ..writeln('}');

    print('Generated Mvvm app');
    
    print(
      'Singleton interactors count: ${InstancesCollectorGenerator.singletonAnnotated.length}',
    );
    print(
      'Default interactors count: ${InstancesCollectorGenerator.defaultAnnotated.length}',
    );
    print(
      'Singleton services count: ${InstancesCollectorGenerator.singletonAnnotatedServices.length}',
    );
    print(
      'Default services count: ${InstancesCollectorGenerator.defaultAnnotatedServices.length}',
    );
    print(
      'Apis count: ${InstancesCollectorGenerator.apiAnnotated.length}',
    );

    return classBuffer.toString();
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
      if (element.name != null) {
        final elementName = element.name!;
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
