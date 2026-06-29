class FormPronosticoModel {
  final int idPartido;
  final int idUsuario;
  final int golesE1;
  final int golesE2;

  FormPronosticoModel({
    required this.idPartido,
    required this.idUsuario,
    required this.golesE1,
    required this.golesE2,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_partido': idPartido,
      'id_usuario': idUsuario,
      'goles_e1': golesE1,
      'goles_e2': golesE2,
    };
  }
}