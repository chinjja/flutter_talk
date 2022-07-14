import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk/app/app.dart';
import 'package:talk/pages/home/home.dart';
import 'package:talk/pages/login/login.dart';
import 'package:talk/repos/repos.dart';

class App extends StatelessWidget {
  final AuthRepository authRepository;
  final ChatRepository chatRepository;

  const App({
    Key? key,
    required this.authRepository,
    required this.chatRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: authRepository,
        ),
        RepositoryProvider.value(
          value: chatRepository,
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            AppBloc(authRepository: context.read<AuthRepository>())
              ..add(const AppInited()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talk',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          switch (state.status) {
            case AppStatus.authentication:
              return const HomePage();
            case AppStatus.unauthentication:
              return const LoginPage();
            default:
              return const SplashView();
          }
        },
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
