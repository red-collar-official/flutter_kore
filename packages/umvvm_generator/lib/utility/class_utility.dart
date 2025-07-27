import 'package:analyzer/dart/element/element2.dart';
import 'package:umvvm_generator/utility/main_app_visitor.dart';

class ClassUtility {
  static String getClassName(Element2 element) {
    final visitor = MainAppVisitor();

    element.visitChildren2(visitor);

    return visitor.className ?? '';
  }
}
