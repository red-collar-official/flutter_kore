// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/visitor.dart';
// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/constant/value.dart';
import 'package:umvvm/arch/navigation/annotations/link.dart';

class AnnotatedFunctionVisitor extends SimpleElementVisitor<dynamic> {
  Map<String, ConstantReader> annotatedMethods = <String, ConstantReader>{};
  Map<String, MethodElement> annotatedMethodsData = <String, MethodElement>{};
  List<String> allMethods = <String>[];

  Map<String, List<ParameterElement>> parameters = <String, List<ParameterElement>>{};

  @override
  dynamic visitMethodElement(MethodElement element) {
    final annotation = methodHasAnnotation(Link, element);

    if (annotation != null) {
      annotatedMethods[element.name] = ConstantReader(annotation);
      parameters[element.name] = element.parameters;
      annotatedMethodsData[element.name] = element;
    }

    allMethods.add(element.name);
  }

  DartObject? methodHasAnnotation(Type annotationType, MethodElement element) {
    final annotations = TypeChecker.fromRuntime(annotationType).annotationsOf(
      element,
    );

    if (annotations.isEmpty) {
      return null;
    }

    return annotations.first;
  }
}
