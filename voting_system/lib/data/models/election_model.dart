class ElectionModel {
  final int id;
  final String name;
  final int phase;

  ElectionModel({
    required this.id,
    required this.name,
    required this.phase,
  });

  factory ElectionModel.fromJson(Map<String, dynamic> json) {
    return ElectionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      phase: json['phase'] ?? 0,
    );
  }
}
