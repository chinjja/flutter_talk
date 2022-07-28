import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/app/app.dart';
import 'package:talk/pages/pages.dart';
import 'package:talk/pages/profile/view/profile_page.dart';
import 'package:talk/repos/repos.dart';

class App extends StatelessWidget {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final ChatRepository chatRepository;
  final StorageRepository storageRepository;

  const App({
    Key? key,
    required this.userRepository,
    required this.authRepository,
    required this.chatRepository,
    required this.storageRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: storageRepository,
        ),
        RepositoryProvider.value(
          value: userRepository,
        ),
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

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final _router = GoRouter(
    urlPathStrategy: UrlPathStrategy.path,
    initialLocation: '/home',
    routes: [
      GoRoute(
        name: 'home',
        path: '/:tab(home|chat|settings)',
        builder: (context, state) {
          final tab = state.params['tab'];
          final idx = tab == 'home'
              ? 0
              : tab == 'chat'
                  ? 1
                  : 2;
          return HomePage(tab: idx);
        },
        routes: [
          GoRoute(
            name: 'new-chat',
            path: 'new-chat',
            builder: (context, state) => const ChatCreatePage(),
          ),
          GoRoute(
            name: 'chats',
            path: 'chats/:chatId',
            builder: (context, state) {
              return ChatPage(chatId: int.parse(state.params['chatId']!));
            },
          ),
          GoRoute(
            name: 'profile',
            path: 'profile/:username',
            builder: (context, state) {
              return ProfilePage(username: state.params['username']!);
            },
          ),
        ],
      ),
      GoRoute(
        name: 'profile-edit',
        path: '/profile-edit',
        pageBuilder: (context, state) {
          return MaterialPage(
            fullscreenDialog: true,
            child: ProfileEditPage(user: state.extra as User),
          );
        },
      ),
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            name: 'register',
            path: 'register',
            builder: (context, state) => const RegisterPage(),
          )
        ],
      ),
      GoRoute(
        name: 'verify-email',
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailPage(),
      ),
    ],
    redirect: (state) {
      final bloc = context.read<AppBloc>();
      switch (bloc.state.status) {
        case AppStatus.unknown:
          if (state.subloc != '/splash') {
            return '/splash';
          }
          break;
        case AppStatus.authentication:
          if (state.subloc == '/login' ||
              state.subloc == '/splash' ||
              state.subloc == '/verify-email') {
            return '/';
          }
          break;
        case AppStatus.unauthentication:
          if (state.subloc == '/login/register') return null;
          if (state.subloc != '/login') {
            return '/login';
          }
          break;
        case AppStatus.emailNotVerified:
          if (state.subloc != '/verify-email') {
            return '/verify-email';
          }
          break;
      }
      if (state.subloc == '/') {
        return '/home';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(context.read<AppBloc>().stream),
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      title: 'Talk',
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
