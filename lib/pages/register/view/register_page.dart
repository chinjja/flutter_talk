import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk/repos/repos.dart';

import '../register.dart';

class RegisterPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const RegisterPage());

  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(context.read<AuthRepository>()),
      child: BlocListener<RegisterBloc, RegisterState>(
        listenWhen: (previous, current) =>
            previous.submitStatus != current.submitStatus,
        listener: (context, state) {
          if (state.submitStatus == RegisterSubmitStatus.success) {
            Navigator.pop(context);
          }
        },
        child: const RegisterView(),
      ),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocListener<RegisterBloc, RegisterState>(
        listenWhen: (previous, current) =>
            current.submitStatus == RegisterSubmitStatus.failure,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text("Something went wrong!"),
              ),
            );
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _UsernameTextField(),
                _PasswordTextField(),
                _ConfirmPasswordTextField(),
                SizedBox(height: 8),
                _SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UsernameTextField extends StatelessWidget {
  const _UsernameTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return TextField(
          autofocus: true,
          onChanged: (username) {
            context.read<RegisterBloc>().add(RegisterUsernameChanged(username));
          },
          decoration: InputDecoration(
            hintText: 'Username',
            errorText: state.isValidUsername ? null : 'username invalid',
          ),
        );
      },
    );
  }
}

class _PasswordTextField extends StatelessWidget {
  const _PasswordTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return TextField(
          obscureText: true,
          onChanged: (password) {
            context.read<RegisterBloc>().add(RegisterPasswordChanged(password));
          },
          decoration: InputDecoration(
            hintText: 'Password',
            errorText: state.isValidPassword ? null : 'password invalid',
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordTextField extends StatelessWidget {
  const _ConfirmPasswordTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return TextField(
          obscureText: true,
          onChanged: (password) {
            context
                .read<RegisterBloc>()
                .add(RegisterConfirmPasswordChanged(password));
          },
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            errorText:
                state.isValidConfirmPassword ? null : 'password do not match',
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final inProgress =
            state.submitStatus == RegisterSubmitStatus.inProgress;
        return ElevatedButton(
          onPressed: inProgress
              ? null
              : () {
                  context.read<RegisterBloc>().add(const RegisterSubmitted());
                },
          child: inProgress
              ? const CircularProgressIndicator()
              : const Text('Submit'),
        );
      },
    );
  }
}
