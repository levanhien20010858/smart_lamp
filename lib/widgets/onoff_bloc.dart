import 'package:bloc/bloc.dart';

class OnoffSmartBloc extends Bloc<bool, bool> {
  OnoffSmartBloc() : super(false) {
    on<bool>((event, emit) {
      emit(event);
    });
  }

  // @override
  // Stream<bool> mapEventToState(bool event) async* {
  //   yield event;
  // }
}
