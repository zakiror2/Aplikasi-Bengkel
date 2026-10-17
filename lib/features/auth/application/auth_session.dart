import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/user_role.dart';

class AuthSession {
  const AuthSession({this.role});

  final UserRole? role;
  bool get isAuthenticated => role != null;
  // One fixed customer identity for the explicitly labelled demo.
  String get customerId => 'demo-customer';
}

class AuthSessionController extends Notifier<AuthSession> {
  @override
  AuthSession build() => const AuthSession();

  void signIn(UserRole role) => state = AuthSession(role: role);
  void signOut() => state = const AuthSession();
}

final authSessionProvider =
    NotifierProvider<AuthSessionController, AuthSession>(
      AuthSessionController.new,
    );

String roleHome(UserRole role) => '/${role.name}/home';

String? sessionRedirect(AuthSession session, String location) {
  if (!session.isAuthenticated) return location == '/login' ? null : '/login';
  final role = session.role!;
  final prefix = '/${role.name}';
  if (location == prefix) return roleHome(role);
  if (!location.startsWith('$prefix/')) return roleHome(role);
  return null;
}
