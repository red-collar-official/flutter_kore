import 'package:umvvm/umvvm.dart';

abstract class BaseInstancePart<T extends MvvmInstance>
    extends MvvmInstance<void> {
  late T parentInstance;
}
