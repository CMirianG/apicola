class UmbralModel {
  final String tipo;
  final double min;
  final double max;

  UmbralModel({required this.tipo, required this.min, required this.max});

  Map<String, dynamic> toMap() {
    return {'tipo': tipo, 'min': min, 'max': max};
  }

  factory UmbralModel.fromMap(Map<String, dynamic> map) {
    return UmbralModel(
      tipo: map['tipo'] ?? '',
      min: (map['min'] ?? 0).toDouble(),
      max: (map['max'] ?? 0).toDouble(),
    );
  }
}
