import 'dart:async';

// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:mvvm_redux/annotations/default_interactor.dart';
import 'package:mvvm_redux/annotations/main_app.dart';
import 'package:mvvm_redux/annotations/singleton_interactor.dart';
import 'package:source_gen/source_gen.dart';

import 'main_app_visitor.dart';

class MainAppGenerator extends GeneratorForAnnotation<MainAppAnnotation> {
  List<Element> singletonAnnotated = [];
  List<Element> defaultAnnotated = [];

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    const singletonInteractorAnnotation = TypeChecker.fromRuntime(SingletonInteractorAnnotation);
    const defaultInteractorAnnotation = TypeChecker.fromRuntime(DefaultInteractorAnnotation);

    final annotatedSingletonFinder = [
      for (var member in library.annotatedWith(singletonInteractorAnnotation)) member.element,
    ];

    final defaultAnnotatedFinder = [
      for (var member in library.annotatedWith(defaultInteractorAnnotation)) member.element,
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
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
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
      classBuffer.writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    });

    defaultAnnotated.forEach((element) {
      classBuffer.writeln('..addBuilder<${element.name}>(() => ${element.name}())');
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
