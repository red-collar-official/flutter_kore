class InstanceJsonModel {
  final String name;
  final bool singleton;
  final bool lazy;
  final String inputType;
  final bool awaitInitialization;
  final int? initializationOrder;
  final bool async;
  final bool part;

  InstanceJsonModel({
    required this.name,
    required this.singleton,
    required this.lazy,
    required this.inputType,
    required this.awaitInitialization,
    required this.initializationOrder,
    required this.async,
    required this.part,
  });

  factory InstanceJsonModel.fromJson(Map<dynamic, dynamic> json) {
    return InstanceJsonModel(
      name: json['name'],
      async: json['async'],
      part: json['part'],
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
        'part': part,
        'async': async,
        'inputType': inputType,
        'awaitInitialization': awaitInitialization,
        'initializationOrder': initializationOrder,
      };
}
