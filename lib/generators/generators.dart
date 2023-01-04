import 'dart:async';

// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:mvvm_redux/annotations/default_interactor.dart';
import 'package:mvvm_redux/annotations/main_api.dart';
import 'package:mvvm_redux/annotations/main_app.dart';
import 'package:mvvm_redux/annotations/api.dart';
import 'package:mvvm_redux/annotations/singleton_interactor.dart';
import 'package:source_gen/source_gen.dart';
import 'package:mvvm_redux/generators/main_app_visitor.dart';

class MainAppGenerator extends GeneratorForAnnotation<MainAppAnnotation> {
  List<Element> singletonAnnotated = [];
  List<Element> defaultAnnotated = [];

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    const singletonInteractorAnnotation =
        TypeChecker.fromRuntime(SingletonInteractorAnnotation);
    const defaultInteractorAnnotation =
        TypeChecker.fromRuntime(DefaultInteractorAnnotation);

    final annotatedSingletonFinder = [
      for (var member in library.annotatedWith(singletonInteractorAnnotation))
        member.element,
    ];

    final defaultAnnotatedFinder = [
      for (var member in library.annotatedWith(defaultInteractorAnnotation))
        member.element,
    ];

    if (annotatedSingletonFinder.isNotEmpty) {
      singletonAnnotated.addAll(annotatedSingletonFinder);
    }

    if (defaultAnnotatedFinder.isNotEmpty) {
      defaultAnnotated.addAll(defaultAnnotatedFinder);
    }

    return super.generate(library, buildStep);
  }

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
      ..writeln('List<Type> get singletons => [');

    // ignore: prefer_foreach
    for (final element in singletonAnnotated) {
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
      ..writeln('void registerBuilders() {');

    if (singletonAnnotated.isNotEmpty || defaultAnnotated.isNotEmpty) {
      classBuffer.writeln('interactors');
    }

    singletonAnnotated.forEach((element) {
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    });

    defaultAnnotated.forEach((element) {
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    });

    if (singletonAnnotated.isNotEmpty || defaultAnnotated.isNotEmpty) {
      classBuffer.writeln(';');
    }

    classBuffer
      ..writeln('}')
      ..writeln('}');

    return classBuffer.toString();
  }
}

class MainApiGenerator extends GeneratorForAnnotation<MainApiAnnotation> {
  List<Element> apiAnnotated = [];

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    const apiAnnotation = TypeChecker.fromRuntime(ApiAnnotation);

    final annotatedApiFinder = [
      for (var member in library.annotatedWith(apiAnnotation)) member.element,
    ];

    if (annotatedApiFinder.isNotEmpty) {
      apiAnnotated.addAll(annotatedApiFinder);
    }

    return super.generate(library, buildStep);
  }

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
    for (final element in apiAnnotated) {
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
