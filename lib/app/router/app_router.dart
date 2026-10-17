import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/user_role.dart';
import '../../core/widgets/demo_shell.dart';
import '../../features/auth/application/auth_session.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/booking/presentation/booking_detail_screen.dart';
import '../../features/booking/presentation/booking_list_screen.dart';
import '../../features/booking/presentation/demo_dashboard_screen.dart';
import '../../features/customer/presentation/customer_booking_screen.dart';

export '../../features/auth/application/auth_session.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionRefresh();
  ref.listen(authSessionProvider, (_, _) => refresh.changed());
  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) =>
        sessionRedirect(ref.read(authSessionProvider), state.uri.path),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      for (final role in UserRole.values) ...[
        GoRoute(
          path: '/${role.name}',
          redirect: (context, state) => roleHome(role),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              DemoShell(role: role, child: child),
          routes: [
            GoRoute(
              path: '/${role.name}/home',
              builder: (context, state) => const DemoDashboardScreen(),
            ),
            GoRoute(
              path: '/${role.name}/profile',
              builder: (context, state) => const DemoProfileScreen(),
            ),
            GoRoute(
              path: '/${role.name}/soon',
              builder: (context, state) => ComingSoonScreen(
                feature: state.uri.queryParameters['feature'] ?? 'Fitur',
              ),
            ),
            GoRoute(
              path:
                  '/${role.name}/${role == UserRole.technician ? 'jobs' : 'bookings'}',
              builder: (context, state) => const BookingListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      BookingDetailScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
            if (role == UserRole.customer)
              GoRoute(
                path: '/customer/booking',
                builder: (context, state) => const CustomerBookingScreen(),
              ),
          ],
        ),
      ],
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _SessionRefresh extends ChangeNotifier {
  void changed() => notifyListeners();
}
