import 'dart:async';

// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:mvvm_redux/annotations/api.dart';
import 'package:mvvm_redux/annotations/default_interactor.dart';
import 'package:mvvm_redux/annotations/service.dart';
import 'package:mvvm_redux/annotations/singleton_interactor.dart';
import 'package:mvvm_redux/annotations/singleton_service.dart';
import 'package:source_gen/source_gen.dart';

class InstancesCollectorGenerator extends Generator {
  static List<AnnotatedElement> singletonAnnotatedInteractors = [];
  static List<AnnotatedElement> defaultAnnotatedInteractors = [];

  static List<AnnotatedElement> singletonAnnotatedServices = [];
  static List<AnnotatedElement> defaultAnnotatedServices = [];

  static List<AnnotatedElement> apiAnnotated = [];

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    const singletonInteractorAnnotation =
        TypeChecker.fromRuntime(SingletonInteractor);
    const defaultInteractorAnnotation =
        TypeChecker.fromRuntime(DefaultInteractor);
    const defaultServiceAnnotation =
        TypeChecker.fromRuntime(DefaultService);
    const singletonServiceAnnotation =
        TypeChecker.fromRuntime(SingletonService);
    const apiAnnotation = TypeChecker.fromRuntime(ApiAnnotation);

    singletonAnnotatedInteractors
        .addAll(library.annotatedWith(singletonInteractorAnnotation));
    defaultAnnotatedInteractors
        .addAll(library.annotatedWith(defaultInteractorAnnotation));
    defaultAnnotatedServices
        .addAll(library.annotatedWith(defaultServiceAnnotation));
    singletonAnnotatedServices
        .addAll(library.annotatedWith(singletonServiceAnnotation));
    apiAnnotated.addAll(library.annotatedWith(apiAnnotation));

    return super.generate(library, buildStep);
  }
}
