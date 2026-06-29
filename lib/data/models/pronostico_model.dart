class PronosticoModel {
  final int idPronostico;
  final int idPartido;
  final int idUsuario;
  final int golesE1;
  final int golesE2;

  PronosticoModel({
    required this.idPronostico,
    required this.idPartido,
    required this.idUsuario,
    required this.golesE1,
    required this.golesE2,
  });

  factory PronosticoModel.fromJson(Map<String, dynamic> json) {
    return PronosticoModel(
      idPronostico: json['id_pronostico'] ?? 0,
      idPartido: json['id_partido'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      golesE1: json['goles_e1'] ?? 0,
      golesE2: json['goles_e2'] ?? 0,
    );
  }
}