import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

import '../register.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(context.read<AuthRepository>()),
      child: BlocListener<RegisterBloc, RegisterState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status.isSubmissionSuccess) {
            context.pop();
          } else if (state.status.isSubmissionFailure) {
            showError(context, state.error);
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
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (!state.status.isSubmissionFailure) return;

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
          key: const Key('registerPage_username_textField'),
          autofocus: true,
          onChanged: (username) {
            context.read<RegisterBloc>().add(RegisterUsernameChanged(username));
          },
          decoration: InputDecoration(
            hintText: 'Username (Email)',
            errorText: state.username.invalid
                ? 'enter username formatted email'
                : null,
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
          key: const Key('registerPage_password_textField'),
          obscureText: true,
          onChanged: (password) {
            context.read<RegisterBloc>().add(RegisterPasswordChanged(password));
          },
          decoration: InputDecoration(
            hintText: 'Password',
            errorText: state.password.invalid ? 'password invalid' : null,
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
          key: const Key('registerPage_confirmPassword_textField'),
          obscureText: true,
          onChanged: (password) {
            context
                .read<RegisterBloc>()
                .add(RegisterConfirmPasswordChanged(password));
          },
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            errorText:
                state.confirmPassword.invalid ? 'password do not match' : null,
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
        return ElevatedButton(
          key: const Key('registerPage_submit_button'),
          onPressed: state.status.isSubmissionInProgress || !state.isValid
              ? null
              : () {
                  context.read<RegisterBloc>().add(const RegisterSubmitted());
                },
          child: state.status.isSubmissionInProgress
              ? const CircularProgressIndicator()
              : const Text('Register'),
        );
      },
    );
  }
}
