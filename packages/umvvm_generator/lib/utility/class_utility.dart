import 'package:analyzer/dart/element/element.dart';
import 'package:umvvm_generator/utility/main_app_visitor.dart';

class ClassUtility {
  static String getClassName(Element element) {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    return visitor.className ?? '';
  }
}
