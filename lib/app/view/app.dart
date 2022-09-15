import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/app/app.dart';
import 'package:talk/pages/pages.dart';
import 'package:talk/pages/profile/view/profile_page.dart';
import 'package:talk/repos/repos.dart';
import 'package:talk/repos/user_repository/repository/friend_repository.dart';

class App extends StatelessWidget {
  final UserRepository userRepository;
  final FriendRepository friendRepository;
  final AuthRepository authRepository;
  final ChatRepository chatRepository;
  final ListenRepository listenRepository;

  const App({
    Key? key,
    required this.userRepository,
    required this.friendRepository,
    required this.authRepository,
    required this.chatRepository,
    required this.listenRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: userRepository,
        ),
        RepositoryProvider.value(
          value: friendRepository,
        ),
        RepositoryProvider.value(
          value: authRepository,
        ),
        RepositoryProvider.value(
          value: chatRepository,
        ),
        RepositoryProvider.value(
          value: listenRepository,
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
              return ProfilePage(
                username: state.params['username']!,
                user: state.extra as User?,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/new-chat',
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: ChatCreatePage(),
          );
        },
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
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: RegisterPage(),
          );
        },
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: VerifyEmailPage(),
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: ResetPasswordPage(),
          );
        },
      ),
    ],
    redirect: (state) {
      final bloc = context.read<AppBloc>();
      switch (bloc.state) {
        case AppState.unknown:
          if (state.subloc != '/splash') {
            return '/splash';
          }
          break;
        case AppState.authentication:
          if (state.subloc == '/login' ||
              state.subloc == '/splash' ||
              state.subloc == '/verify-email') {
            return '/home';
          }
          break;
        case AppState.unauthentication:
          if (state.subloc == '/register') return null;
          if (state.subloc == '/reset-password') return null;
          if (state.subloc != '/login') {
            return '/login';
          }
          break;
        case AppState.emailNotVerified:
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
