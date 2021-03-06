import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk/app/app.dart';
import 'package:talk/common/common.dart';
import 'package:talk/pages/verify_email/verify_email.dart';
import 'package:talk/repos/auth_repository/auth_repository.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerifyEmailBloc(context.read<AuthRepository>()),
      child: const VerifyEmailView(),
    );
  }
}

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AppBloc>().add(const AppLogout());
          },
        ),
      ),
      body: BlocListener<VerifyEmailBloc, VerifyEmailState>(
        listenWhen: (previous, current) =>
            previous.submitStatus != current.submitStatus,
        listener: (context, state) {
          if (state.submitStatus == FetchStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  const SnackBar(content: Text('Cannot verify code')));
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 400,
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _VerificationCodeTextField(),
                _CountDown(),
                SizedBox(height: 8),
                _SendCodeButton(),
                SizedBox(height: 8),
                _VerifyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationCodeTextField extends StatelessWidget {
  const _VerificationCodeTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (code) {
        context.read<VerifyEmailBloc>().add(VerifyEmailCodeChanged(code));
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: const InputDecoration(
        hintText: 'Enter verification code',
        filled: true,
      ),
    );
  }
}

class _CountDown extends StatelessWidget {
  const _CountDown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<VerifyEmailBloc, VerifyEmailState>(
        builder: (context, state) {
          if (!state.sendCode) {
            return const SizedBox();
          }
          return Text('??????????????? ${state.seconds}??? ???????????????.');
        },
      ),
    );
  }
}

class _SendCodeButton extends StatelessWidget {
  const _SendCodeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerifyEmailBloc, VerifyEmailState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.sendStatus == FetchStatus.loading
              ? null
              : () {
                  context.read<VerifyEmailBloc>().add(const VerifyEmailSend());
                },
          child: Stack(
            children: [
              state.sendCode ? const Text('?????? ??????') : const Text('?????? ??????'),
              if (state.sendStatus == FetchStatus.loading)
                const _SamllIndicator(),
            ],
          ),
        );
      },
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerifyEmailBloc, VerifyEmailState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed:
              state.code.isEmpty || state.submitStatus == FetchStatus.loading
                  ? null
                  : () {
                      context
                          .read<VerifyEmailBloc>()
                          .add(const VerifyEmailSubmitted());
                    },
          child: Stack(
            children: [
              const Text('????????????'),
              if (state.submitStatus == FetchStatus.loading)
                const _SamllIndicator(),
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
