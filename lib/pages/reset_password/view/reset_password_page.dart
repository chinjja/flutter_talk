import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/common/common.dart';
import 'package:talk/pages/reset_password/bloc/reset_password_bloc.dart';
import 'package:talk/repos/auth_repository/auth_repository.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordBloc(context.read<AuthRepository>()),
      child: const ResetPasswordView(),
    );
  }
}

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Reset Password')),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: const [
                _EmailField(),
                SizedBox(height: 10),
                _SubmitButton(),
              ],
            ),
          ),
        );
      },
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isSubmissionSuccess) {
          showSnackbar(context, 'Reset Password is sent to Email');
          context.pop();
        } else if (state.status.isSubmissionFailure) {
          showError(context, state.error);
        }
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      builder: (context, state) {
        return TextField(
          autofocus: true,
          onChanged: (value) => context
              .read<ResetPasswordBloc>()
              .add(ResetPasswordEamilChanged(value)),
          decoration: InputDecoration(
            labelText: 'Enter Email',
            errorText: state.email.invalid ? 'invalid email' : null,
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
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.status.isSubmissionInProgress || !state.isValid
              ? null
              : () {
                  context
                      .read<ResetPasswordBloc>()
                      .add(const ResetPasswordSubmitted());
                },
          child: Stack(
            children: [
              const Text('Send to Email'),
              if (state.status.isSubmissionInProgress) const _SamllIndicator(),
            ],
          ),
        );
      },
    );
  }
}

class _SamllIndicator extends StatelessWidget {
  const _SamllIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child:
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
      ),
    );
  }
}
