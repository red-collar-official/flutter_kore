class InstanceJsonModel {
  final String name;
  final bool isSingleton;
  final bool isLazy;
  final String inputType;
  final bool awaitInitialization;
  final int? initializationOrder;
  final bool isAsync;
  final bool isPart;

  InstanceJsonModel({
    required this.name,
    required this.isSingleton,
    required this.isLazy,
    required this.inputType,
    required this.awaitInitialization,
    required this.initializationOrder,
    required this.isAsync,
    required this.isPart,
  });

  factory InstanceJsonModel.fromJson(Map<dynamic, dynamic> json) {
    return InstanceJsonModel(
      name: json['name'],
      isAsync: json['isAsync'],
      isPart: json['isPart'],
      isSingleton: json['isSingleton'],
      isLazy: json['isLazy'],
      inputType: json['inputType'],
      awaitInitialization: json['awaitInitialization'],
      initializationOrder: json['initializationOrder'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'isSingleton': isSingleton,
        'isLazy': isLazy,
        'isPart': isPart,
        'isAsync': isAsync,
        'inputType': inputType,
        'awaitInitialization': awaitInitialization,
        'initializationOrder': initializationOrder,
      };
}
