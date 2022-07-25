import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
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
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => context
                .read<ResetPasswordBloc>()
                .add(ResetPasswordEamilChanged(value)),
            decoration: InputDecoration(
              hintText: 'Enter Email',
              errorText: state.email.invalid ? 'invalid email' : null,
            ),
          ),
          actions: [
            ElevatedButton(
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
                  if (state.status.isSubmissionInProgress)
                    const _SamllIndicator(),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isSubmissionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
                content: Text('Reset Password is sent to Email')));
          Navigator.pop(context);
        } else if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                const SnackBar(content: Text('Reset Password Failed')));
        }
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
