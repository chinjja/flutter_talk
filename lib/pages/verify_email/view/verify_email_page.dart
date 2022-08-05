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
            showError(context, state.error);
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
                _Header(),
                SizedBox(height: 32),
                _VerificationCodeTextField(),
                _CountDown(),
                _SendCodeButton(),
                SizedBox(height: 32),
                _VerifyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('인증코드 확인.', style: Theme.of(context).textTheme.headline2),
        const SizedBox(height: 12),
        Text(
          '이메일로 발송된 인증코드를 입력하세요.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
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
      keyboardType: TextInputType.number,
      onSubmitted: (_) {
        context.read<VerifyEmailBloc>().add(const VerifyEmailSubmitted());
      },
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
          return Text('유효시간이 ${state.seconds}초 남았습니다.');
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
              state.sendCode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('다시 받기'),
                        Icon(Icons.refresh),
                      ],
                    )
                  : const Text('코드 받기'),
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
              const Text('인증하기'),
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
