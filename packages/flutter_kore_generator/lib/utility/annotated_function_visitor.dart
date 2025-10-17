import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor2.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:flutter_kore/arch/navigation/annotations/link.dart';

class AnnotatedFunctionVisitor extends SimpleElementVisitor2<dynamic> {
  Map<String, ConstantReader> annotatedMethods = <String, ConstantReader>{};
  Map<String, MethodElement> annotatedMethodsData = <String, MethodElement>{};
  List<String> allMethods = <String>[];

  Map<String, List<FormalParameterElement>> parameters =
      <String, List<FormalParameterElement>>{};

  @override
  dynamic visitMethodElement(MethodElement element) {
    final annotation = methodHasAnnotation(Link, element);
    final name = element.name;

    if (name == null || name.isEmpty) {
      return;
    }

    if (annotation != null) {
      annotatedMethods[name] = ConstantReader(annotation);
      parameters[name] = element.formalParameters;
      annotatedMethodsData[name] = element;
    }

    allMethods.add(name);
  }

  DartObject? methodHasAnnotation(Type annotationType, MethodElement element) {
    final annotations = TypeChecker.typeNamed(annotationType).annotationsOf(
      element,
    );

    if (annotations.isEmpty) {
      return null;
    }

    return annotations.first;
  }
}
