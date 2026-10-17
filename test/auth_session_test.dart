import 'package:bengkel_kendaraan/app/router/app_router.dart';
import 'package:bengkel_kendaraan/core/constants/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('all roles are restricted to their own route prefix', () {
    for (final role in UserRole.values) {
      final session = AuthSession(role: role);
      expect(sessionRedirect(session, '/login'), roleHome(role));
      expect(sessionRedirect(session, '/${role.name}/home'), isNull);
      for (final other in UserRole.values.where((r) => r != role)) {
        expect(sessionRedirect(session, '/${other.name}/home'), roleHome(role));
      }
      expect(
        sessionRedirect(session, '/${role.name}-fake/home'),
        roleHome(role),
      );
    }
    expect(sessionRedirect(const AuthSession(), '/admin/bookings'), '/login');
  });

  test('router instance remains stable across login and logout', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    final auth = container.read(authSessionProvider.notifier);
    for (final role in UserRole.values) {
      auth.signIn(role);
      expect(identical(container.read(appRouterProvider), router), isTrue);
      auth.signOut();
      expect(identical(container.read(appRouterProvider), router), isTrue);
    }
  });

  group('AuthSession', () {
    test('defaults to unauthenticated state', () {
      const session = AuthSession();

      expect(session.isAuthenticated, isFalse);
      expect(session.role, isNull);
    });

    test('customer role marks the user as authenticated', () {
      const session = AuthSession(role: UserRole.customer);

      expect(session.isAuthenticated, isTrue);
      expect(session.role, UserRole.customer);
    });
  });
}
