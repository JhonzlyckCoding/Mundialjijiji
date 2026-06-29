import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../providers/pronosticos_notifier.dart';
import 'registrar_pronostico_screen.dart';

class ListPronosticosScreen extends ConsumerWidget {
  const ListPronosticosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pronosticosState = ref.watch(pronosticosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo
      appBar: AppBar(
        title: Text("MIS PRONÓSTICOS", style: GoogleFonts.oswald(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.red.shade800, //header
        elevation: 10,
        centerTitle: true,
      ),
      body: pronosticosState.when(
        data: (pronosticos) {
          if (pronosticos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 80, color: Colors.grey.shade800),
                  const SizedBox(height: 16),
                  Text(
                    "Cancha vacía. ¡Haz tu primer pronostico!",
                    style: GoogleFonts.roboto(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: pronosticos.length,
            itemBuilder: (context, index) {
              final pronostico = pronosticos[index];
              return Card(
                elevation: 8,
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PARTIDO",
                            style: GoogleFonts.oswald(color: Colors.red.shade400, fontSize: 16, letterSpacing: 1.2),
                          ),
                          Text(
                            "#${pronostico.idPartido}",
                            style: GoogleFonts.oswald(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade800, width: 2),
                        ),
                        child: Text(
                          "${pronostico.golesE1} - ${pronostico.golesE2}",
                          style: GoogleFonts.oswald(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
        loading: () => Center(child: CircularProgressIndicator(color: Colors.red.shade800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade800,
        elevation: 8,
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const RegistrarPronosticoScreen())
        ),
        icon: const Icon(Icons.add_chart, color: Colors.white),
        label: Text("NUEVO", style: GoogleFonts.oswald(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}