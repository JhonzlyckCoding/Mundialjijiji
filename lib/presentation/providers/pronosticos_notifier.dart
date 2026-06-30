import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <--- IMPORTANTE
import '../../data/models/pronostico_model.dart';
import '../../data/models/form_pronostico_model.dart';
import '../../data/providers/dio_provider.dart';

class PronosticosNotifier extends StateNotifier<AsyncValue<List<PronosticoModel>>> {
  final Ref ref;
  final _storage = const FlutterSecureStorage(); // Instancia de la bóveda

  PronosticosNotifier(this.ref) : super(const AsyncValue.loading()) {
    getPronosticos();
  }

  Future<void> getPronosticos() async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      
      // Obtenemos el token de la bóveda
      final token = await _storage.read(key: 'token');
      
      // Hacemos la petición pasando el token en los headers
      final response = await dio.get(
        '/pronosticos',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      final List<dynamic> data = response.data;
      final listaPronosticos = data.map((json) => PronosticoModel.fromJson(json)).toList();
      
      state = AsyncValue.data(listaPronosticos);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<bool> registrarPronostico(FormPronosticoModel form) async {
    try {
      final dio = ref.read(dioProvider);
      final token = await _storage.read(key: 'token');
      
      await dio.post(
        '/pronosticos', 
        data: form.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      await getPronosticos();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final pronosticosProvider = StateNotifierProvider<PronosticosNotifier, AsyncValue<List<PronosticoModel>>>((ref) {
  return PronosticosNotifier(ref);
});