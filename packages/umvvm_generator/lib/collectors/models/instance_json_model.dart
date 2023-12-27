class InstanceJsonModel {
  final String name;
  final bool singleton;
  final bool isLazy;
  final String inputType;
  final bool awaitInitialization;
  final int? initializationOrder;
  final bool isAsync;
  final bool part;

  InstanceJsonModel({
    required this.name,
    required this.singleton,
    required this.isLazy,
    required this.inputType,
    required this.awaitInitialization,
    required this.initializationOrder,
    required this.isAsync,
    required this.part,
  });

  factory InstanceJsonModel.fromJson(Map<dynamic, dynamic> json) {
    return InstanceJsonModel(
      name: json['name'],
      isAsync: json['isAsync'],
      part: json['part'],
      singleton: json['singleton'],
      isLazy: json['isLazy'],
      inputType: json['inputType'],
      awaitInitialization: json['awaitInitialization'],
      initializationOrder: json['initializationOrder'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'singleton': singleton,
        'isLazy': isLazy,
        'part': part,
        'isAsync': isAsync,
        'inputType': inputType,
        'awaitInitialization': awaitInitialization,
        'initializationOrder': initializationOrder,
      };
}
