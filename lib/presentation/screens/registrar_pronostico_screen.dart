import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/form_pronostico_model.dart';
import '../providers/pronosticos_notifier.dart';

class RegistrarPronosticoScreen extends ConsumerStatefulWidget {
  const RegistrarPronosticoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegistrarPronosticoScreen> createState() => _RegistrarPronosticoScreenState();
}

class _RegistrarPronosticoScreenState extends ConsumerState<RegistrarPronosticoScreen> {
  final _idPartidoController = TextEditingController();
  final _golesE1Controller = TextEditingController();
  final _golesE2Controller = TextEditingController();
  bool _isSubmitting = false;

  // Widget helper para crear inputs hermosos sin repetir código
  Widget _buildInput(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.red.shade400),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red.shade600, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("NUEVO PRONÓSTICO", style: GoogleFonts.oswald(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Icon(Icons.stadium, size: 90, color: Colors.red.shade800),
              ),
              const SizedBox(height: 30),
              
              _buildInput("ID del Partido (Ej: 1, 2...)", _idPartidoController, Icons.tag),
              
              // Fila para los goles, se ve mucho más limpio
              Row(
                children: [
                  Expanded(child: _buildInput("Goles Local", _golesE1Controller, Icons.sports_soccer)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput("Goles Visita", _golesE2Controller, Icons.sports_soccer)),
                ],
              ),
              
              const SizedBox(height: 30),
              
              _isSubmitting
                  ? Center(child: CircularProgressIndicator(color: Colors.red.shade800))
                  : SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade800,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        onPressed: () async {
                          setState(() => _isSubmitting = true);

                          final form = FormPronosticoModel(
                            idPartido: int.tryParse(_idPartidoController.text) ?? 0,
                            golesE1: int.tryParse(_golesE1Controller.text) ?? 0,
                            golesE2: int.tryParse(_golesE2Controller.text) ?? 0,
                            idUsuario: 1, 
                          );

                          final exito = await ref.read(pronosticosProvider.notifier).registrarPronostico(form);

                          setState(() => _isSubmitting = false);

                          if (exito) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("¡Golazo! Pronóstico registrado ⚽", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              )
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Error al guardar en el servidor", style: TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.red.shade900,
                                behavior: SnackBarBehavior.floating,
                              )
                            );
                          }
                        },
                        child: Text(
                          "GUARDAR PRONÓSTICO",
                          style: GoogleFonts.oswald(fontSize: 22, color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}