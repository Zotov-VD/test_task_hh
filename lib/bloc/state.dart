import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState({this.error, this.isLoading = false});

  final String? error;
  final bool isLoading;

  bool get hasError => error != null;

  @override
  List<Object?> get props => [error, isLoading];
}

class PhoneInputState extends LoginState {
  const PhoneInputState({String? error}) : super(error: error);
}

class SmsRequestedState extends LoginState {
  const SmsRequestedState(this.phone, {String? error}) : super(error: error);

  final String phone;
}

class LoadingState extends LoginState {
  const LoadingState({String? error}) : super(error: error, isLoading: true);
}

class LoginSuccessState extends LoginState {
  const LoginSuccessState() : super();
}
