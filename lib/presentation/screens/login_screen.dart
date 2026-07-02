import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// Ajusta estas rutas a como tengas tus carpetas
import '../../data/providers/dio_provider.dart';
import '../../core/constants.dart';
import 'list_pronosticos_screen.dart'; // Tu pantalla actual

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = ref.read(dioProvider);

      final response = await dio.post(
        '/auth/login',
        data: {
          'nombre': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final token = response.data['token'];

      if (token != null) {
        await _storage.write(key: 'token', value: token);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Login exitoso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ListPronosticosScreen(),
          ),
        );
      }
    } on DioException catch (e) {
      // Construimos un mensaje detallado según el tipo de error de Dio,
      // para saber si es problema de red, servidor caído, o credenciales.
      String mensaje;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        mensaje =
            'Tiempo de espera agotado. ¿El servidor está corriendo '
            'y es accesible en ${Constants.baseUrl}?';
      } else if (e.type == DioExceptionType.connectionError) {
        mensaje =
            'No se pudo conectar al servidor (${Constants.baseUrl}). '
            'Revisa tu conexión o si el backend está caído.\n${e.message ?? ''}';
      } else if (e.response != null) {
        // El servidor respondió con un error (400, 401, 500, etc.)
        final status = e.response?.statusCode;
        final data = e.response?.data;
        final serverError = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : data.toString();
        mensaje = 'Error $status del servidor: $serverError';
      } else {
        mensaje = 'Error inesperado: ${e.message}';
      }

      debugPrint(
        'LOGIN ERROR -> type: ${e.type}, '
        'status: ${e.response?.statusCode}, '
        'data: ${e.response?.data}, '
        'message: ${e.message}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      debugPrint('LOGIN ERROR (no-Dio) -> $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'INICIAR SESIÓN',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[800],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                prefixIcon: Icon(Icons.email, color: Colors.grey),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 40),

            _isLoading
                ? const CircularProgressIndicator(color: Colors.red)
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        'ENTRAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
