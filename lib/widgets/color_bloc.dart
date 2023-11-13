import 'package:bloc/bloc.dart';

class ColorSmartBloc extends Bloc<int, int> {
  ColorSmartBloc() : super(0xff2196f3) {
    on<int>((event, emit) {
      emit(event);
    });
  }
}
