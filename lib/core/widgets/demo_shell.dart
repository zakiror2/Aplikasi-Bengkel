import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session.dart';
import '../constants/user_role.dart';

const demoNotice =
    'DEMO · Data hanya selama aplikasi berjalan dan hilang saat restart. Firebase belum terhubung.';

class DemoShell extends ConsumerWidget {
  const DemoShell({super.key, required this.role, required this.child});
  final UserRole role;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = switch (role) {
      UserRole.customer => 'bookings',
      UserRole.admin => 'bookings',
      UserRole.technician => 'jobs',
    };
    final paths = [
      '/${role.name}/home',
      '/${role.name}/$section',
      '/${role.name}/profile',
    ];
    final labels = [
      'Beranda',
      role == UserRole.technician ? 'Pekerjaan' : 'Booking',
      'Profil',
    ];
    const icons = [
      Icons.home_outlined,
      Icons.calendar_month_outlined,
      Icons.person_outline,
    ];
    final location = GoRouterState.of(context).uri.path;
    final selected = location.contains('/profile')
        ? 2
        : (location.contains('/book') || location.contains('/jobs'))
        ? 1
        : 0;
    void navigate(int index) => context.go(paths[index]);
    final content = Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(demoNotice, style: TextStyle(fontSize: 12)),
        ),
        Expanded(child: child),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('BengkelKu · ${role.label}'),
        leading: location == paths[0]
            ? null
            : BackButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(paths[0]);
                  }
                },
              ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => ref.read(authSessionProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 840) return content;
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: selected,
                  onDestinationSelected: navigate,
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(
                    3,
                    (i) => NavigationRailDestination(
                      icon: Icon(icons[i]),
                      label: Text(labels[i]),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: content,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 840
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: navigate,
              destinations: List.generate(
                3,
                (i) => NavigationDestination(
                  icon: Icon(icons[i]),
                  label: labels[i],
                ),
              ),
            ),
    );
  }
}

class DemoProfileScreen extends ConsumerWidget {
  const DemoProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authSessionProvider).role;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Profil ${role?.label ?? ''}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'Sesi peran demo tanpa password. Pelanggan menggunakan satu identitas tetap: Pelanggan Demo. Ini bukan autentikasi produksi.',
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => ref.read(authSessionProvider.notifier).signOut(),
          child: const Text('Keluar dari demo'),
        ),
      ],
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.feature});
  final String feature;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(feature, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      const Text('Segera Hadir. Fitur ini belum tersedia pada Phase 01.'),
    ],
  );
}
