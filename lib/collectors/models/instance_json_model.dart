class InstanceJsonModel {
  final String name;
  final bool singleton;
  final bool lazy;
  final String inputType;
  final bool awaitInitialization;
  final int? initializationOrder;
  final bool async;

  InstanceJsonModel({
    required this.name,
    required this.singleton,
    required this.lazy,
    required this.inputType,
    required this.awaitInitialization,
    required this.initializationOrder,
    required this.async,
  });

  factory InstanceJsonModel.fromJson(Map<dynamic, dynamic> json) {
    return InstanceJsonModel(
      name: json['name'],
      async: json['async'],
      singleton: json['singleton'],
      lazy: json['lazy'],
      inputType: json['inputType'],
      awaitInitialization: json['awaitInitialization'],
      initializationOrder: json['initializationOrder'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'singleton': singleton,
        'lazy': lazy,
        'async': async,
        'inputType': inputType,
        'awaitInitialization': awaitInitialization,
        'initializationOrder': initializationOrder,
      };
}
