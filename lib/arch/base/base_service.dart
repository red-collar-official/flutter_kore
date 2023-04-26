abstract class BaseService<T> {
  late T _instance;

  bool initialized = false;

  void initialize() {
    _instance = createService();
    initialized = true;
  }

  void dispose() {}

  T createService();

  T get instance => _instance;
}
