import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/bloc/state.dart';
import 'package:test_task/repository/repository.dart';

import 'event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this.repository) : super(const PhoneInputState());

  final LoginRepository repository;

  String _phone = "";

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is PhoneEnteredEvent) {
      yield const LoadingState();
      _phone = event.phone;
      try {
        await repository.requestSms(_phone);
        yield SmsRequestedState(_phone);
      } catch (_) {
        yield const PhoneInputState(error: "Failed SMS request");
      }
    } else if (event is CheckEnteredCode) {
      yield const LoadingState();
      try {
        await repository.checkCode(_phone, event.code);
        yield const LoginSuccessState();
      } catch (_) {
        yield SmsRequestedState(_phone, error: "Failed check code");
      }
    } else if (event is ReenterPhoneEvent) {
      yield const PhoneInputState();
    }
  }
}
