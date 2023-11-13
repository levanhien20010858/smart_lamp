import 'package:bloc/bloc.dart';

class NDSmartBloc extends Bloc<Map<String, dynamic>, Map<String, dynamic>> {
  NDSmartBloc()
      : super({
          'temperature': 0.0,
          'humidity': 0.0,
        }) {
    on<Map<String, dynamic>>((event, emit) {
      emit(event);
    });
  }
}
