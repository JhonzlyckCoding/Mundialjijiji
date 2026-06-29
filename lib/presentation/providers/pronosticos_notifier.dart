import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pronostico_model.dart';
import '../../data/models/form_pronostico_model.dart';
import '../../data/providers/dio_provider.dart';

class PronosticosNotifier extends StateNotifier<AsyncValue<List<PronosticoModel>>> {
  final Ref ref;

  PronosticosNotifier(this.ref) : super(const AsyncValue.loading()) {
    getPronosticos();
  }

  Future<void> getPronosticos() async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      // Peticion a la API
      final response = await dio.get('/pronosticos'); 
      
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
      // Peticion de guardado a la API
      await dio.post('/pronosticos', data: form.toJson());
      
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