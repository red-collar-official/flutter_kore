import 'package:umvvm/umvvm.dart';

abstract class BaseInstancePart<Input, T extends MvvmInstance>
    extends MvvmInstance<Input> with ApiCaller<Input> {
  late T parentInstance;

  @override
  void initialize(Input input) {
    super.initialize(input);

    initialized = true;
  }

  @override
  Future<void> initializeAsync(Input input) async {
    await super.initializeAsync(input);

    initialized = true;
  }
    
  /// Base method for lightweight instance initialization
  // coverage:ignore-start
  @override
  void initializeWithoutConnections(Input input) {
    initialized = true;
  }
  // coverage:ignore-end

  /// Base method for lightweight async instance initialization
  // coverage:ignore-start
  @override
  Future<void> initializeWithoutConnectionsAsync(Input input) async {
    initialized = true;
  }
  // coverage:ignore-end
}

abstract class UniversalInstancePart<Input>
    extends BaseInstancePart<Input, MvvmInstance> {}
