class ApiJsonModel {
  final String name;

  ApiJsonModel({
    required this.name,
  });

  factory ApiJsonModel.fromJson(Map<dynamic, dynamic> json) {
    return ApiJsonModel(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
