import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/visitor2.dart';

class MainAppVisitor extends SimpleElementVisitor2<void> {
  String? className;

  @override
  void visitConstructorElement(ConstructorElement2 element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');

    if (elementReturnType.contains('<')) {
      className = className!.split('<')[0];
    }
  }
}
