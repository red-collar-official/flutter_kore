import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/visitor2.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:umvvm/arch/navigation/annotations/link.dart';

class AnnotatedFunctionVisitor extends SimpleElementVisitor2<dynamic> {
  Map<String, ConstantReader> annotatedMethods = <String, ConstantReader>{};
  Map<String, MethodElement2> annotatedMethodsData = <String, MethodElement2>{};
  List<String> allMethods = <String>[];

  Map<String, List<FormalParameterElement>> parameters =
      <String, List<FormalParameterElement>>{};

  @override
  dynamic visitMethodElement(MethodElement2 element) {
    final annotation = methodHasAnnotation(Link, element);
    final name = element.name3;

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

  DartObject? methodHasAnnotation(Type annotationType, MethodElement2 element) {
    final annotations = TypeChecker.typeNamed(annotationType).annotationsOf(
      element,
    );

    if (annotations.isEmpty) {
      return null;
    }

    return annotations.first;
  }
}
