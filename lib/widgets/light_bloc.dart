import 'package:bloc/bloc.dart';

class LightBloc extends Bloc<double, double> {
  LightBloc() : super(100.0) {
    on<double>((event, emit) {
      emit(event);
    });
  }

  // @override
  // Stream<double> mapEventToState(double event) async* {
  //   yield event;
  // }
}
