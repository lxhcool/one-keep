import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/privacy_policy_page.dart';
import '../../features/auth/terms_of_service_page.dart';
import '../../features/home/home_page.dart';
import '../../features/stats/stats_page.dart';
import '../../features/bills/bills_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/profile/about_page.dart';
import '../../shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authProvider.select((state) => state.status));

  return GoRouter(
    redirect: (context, state) {
      final isAuth = authStatus == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isRootRoute = state.matchedLocation == '/';
      final isLegalRoute =
          state.matchedLocation == '/legal/privacy' ||
          state.matchedLocation == '/legal/terms' ||
          state.matchedLocation == '/about';

      if (isRootRoute) return '/home';
      if (authStatus == AuthStatus.unknown) return null;
      if (!isAuth && !isAuthRoute && !isLegalRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StatsPage()),
          ),
          GoRoute(
            path: '/bills',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BillsPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
    ],
  );
});
