import 'dart:async';

// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:mvvm_redux/annotations/api.dart';
import 'package:mvvm_redux/annotations/default_interactor.dart';
import 'package:mvvm_redux/annotations/service.dart';
import 'package:mvvm_redux/annotations/singleton_interactor.dart';
import 'package:mvvm_redux/annotations/singleton_service.dart';
import 'package:source_gen/source_gen.dart';

class InstancesCollectorGenerator extends Generator {
  static List<Element> singletonAnnotated = [];
  static List<Element> defaultAnnotated = [];

  static List<Element> singletonAnnotatedServices = [];
  static List<Element> defaultAnnotatedServices = [];

  static List<Element> apiAnnotated = [];

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    const singletonInteractorAnnotation =
        TypeChecker.fromRuntime(SingletonInteractorAnnotation);
    const defaultInteractorAnnotation =
        TypeChecker.fromRuntime(DefaultInteractorAnnotation);
    const defaultServiceAnnotation =
        TypeChecker.fromRuntime(DefaultServiceAnnotation);
    const singletonServiceAnnotation =
        TypeChecker.fromRuntime(SingletonServiceAnnotation);
        const apiAnnotation = TypeChecker.fromRuntime(ApiAnnotation);

    final annotatedSingletonFinder = [
      for (var member in library.annotatedWith(singletonInteractorAnnotation))
        member.element,
    ];

    final defaultAnnotatedFinder = [
      for (var member in library.annotatedWith(defaultInteractorAnnotation))
        member.element,
    ];

    final defaultServiceAnnotationFinder = [
      for (var member in library.annotatedWith(defaultServiceAnnotation))
        member.element,
    ];

    final singletonServiceAnnotationFinder = [
      for (var member in library.annotatedWith(singletonServiceAnnotation))
        member.element,
    ];

    final annotatedApiFinder = [
      for (var member in library.annotatedWith(apiAnnotation)) member.element,
    ];

    if (annotatedSingletonFinder.isNotEmpty) {
      singletonAnnotated.addAll(annotatedSingletonFinder);
    }

    if (defaultAnnotatedFinder.isNotEmpty) {
      defaultAnnotated.addAll(defaultAnnotatedFinder);
    }

    if (defaultServiceAnnotationFinder.isNotEmpty) {
      defaultAnnotatedServices.addAll(defaultServiceAnnotationFinder);
    }

    if (singletonServiceAnnotationFinder.isNotEmpty) {
      singletonAnnotatedServices.addAll(singletonServiceAnnotationFinder);
    }

    if (annotatedApiFinder.isNotEmpty) {
      apiAnnotated.addAll(annotatedApiFinder);
    }

    return super.generate(library, buildStep);
  }
}
