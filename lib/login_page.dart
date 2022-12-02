import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:test_task/bloc/state.dart';
import 'package:test_task/repository/repository_implementation.dart';

import 'bloc/bloc.dart';
import 'bloc/event.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: BlocProvider<LoginBloc>(
              create: (_) => LoginBloc(MockLoginRepositoryImplementation()),
              child: const LoginForm()),
        ),
      );
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final phoneController = TextEditingController();
  final pinController = TextEditingController();

  static const pinLength = 4;

  late final LoginBloc bloc;

  @override
  void initState() {
    pinController.addListener(() {
      if (pinController.text.length == pinLength) {
        onPinEntered();
      }
    });
    bloc = BlocProvider.of(context);
    super.initState();
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void onPhoneSubmitted() {
    bloc.add(PhoneEnteredEvent(phoneController.text));
  }

  void onPinEntered() {
    bloc.add(CheckEnteredCode(pinController.text));
  }

  void reenterPhone() {
    pinController.clear();
    bloc.add(ReenterPhoneEvent());
  }

  @override
  Widget build(BuildContext context) {
    const pinPutDecoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.black, width: 2),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is PhoneInputState) ...[
                  const Text('Please enter your phone number'),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    child: TextField(
                      controller: phoneController,
                      onSubmitted: (_) => onPhoneSubmitted(),
                    ),
                  ),
                  if (state.hasError) ErrorText(text: state.error!),
                  ElevatedButton(
                    onPressed: onPhoneSubmitted,
                    child: const Text('Continue'),
                  ),
                ] else if (state is SmsRequestedState) ...[
                  Text('The code was sent to ${state.phone}'),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    child: PinPut(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      fieldsCount: pinLength,
                      pinAnimationType: PinAnimationType.fade,
                      textStyle:
                          const TextStyle(fontSize: 25.0, color: Colors.black),
                      fieldsAlignment: MainAxisAlignment.spaceEvenly,
                      separator: const SizedBox(width: 19),
                      separatorPositions: const [1, 2, 3],
                      withCursor: true,
                      submittedFieldDecoration: pinPutDecoration,
                      selectedFieldDecoration: pinPutDecoration,
                      followingFieldDecoration: pinPutDecoration,
                    ),
                  ),
                  if (state.hasError) ErrorText(text: state.error!),
                  ElevatedButton(
                    onPressed: onPinEntered,
                    child: const Text('Continue'),
                  ),
                  TextButton(
                      onPressed: reenterPhone,
                      child: const Text('Change phone')),
                ] else if (state is LoadingState) ...const [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ] else
                  const Text('Success')
              ],
            );
          }),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class ErrorText extends StatelessWidget {
  const ErrorText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
