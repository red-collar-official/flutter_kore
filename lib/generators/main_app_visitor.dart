// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/visitor.dart';
// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/element.dart';

class MainAppVisitor extends SimpleElementVisitor<void> {
  String? className;

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');
  }
}
