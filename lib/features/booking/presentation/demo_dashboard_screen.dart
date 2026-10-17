import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/user_role.dart';
import '../../auth/application/auth_session.dart';
import '../application/booking_controller.dart';
import '../domain/booking.dart';

class DemoDashboardScreen extends ConsumerWidget {
  const DemoDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authSessionProvider).role;
    if (role == null) return const SizedBox.shrink();
    final bookings = ref.watch(visibleBookingsProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Halo, ${role.label}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('Kelola jadwal servis kendaraan dalam satu aplikasi.'),
        const SizedBox(height: 20),
        for (final status
            in role == UserRole.technician
                ? [BookingStatus.confirmed]
                : BookingStatus.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${status.label}: ${bookings.where((b) => b.status == status).length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (role == UserRole.customer) ...[
          FilledButton(
            onPressed: () => context.push('/customer/booking'),
            child: const Text('Booking Servis'),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton(
          onPressed: () => context.go(
            '/${role.name}/${role == UserRole.technician ? 'jobs' : 'bookings'}',
          ),
          child: Text(
            role == UserRole.technician
                ? 'Lihat Antrean Teknisi'
                : 'Lihat Daftar Booking',
          ),
        ),
        const SizedBox(height: 20),
        if (role == UserRole.customer) ...[
          Text('Kendaraan Demo', style: Theme.of(context).textTheme.titleLarge),
          for (final vehicle in demoVehicles)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(vehicle.label),
            ),
        ],
        if (role == UserRole.technician)
          const Text(
            'Simulasi antrean booking terkonfirmasi. Belum ada penugasan teknisi atau pencatatan progres.',
          ),
        const SizedBox(height: 20),
        for (final feature in switch (role) {
          UserRole.customer => ['Riwayat Servis', 'Pembayaran'],
          UserRole.admin => [
            'Teknisi',
            'Sparepart',
            'Customer',
            'Service Order',
            'Pembayaran',
            'Laporan',
          ],
          UserRole.technician => [
            'Checklist',
            'Progres',
            'Stok',
            'Riwayat Pekerjaan',
          ],
        })
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: () => context.push(
                '/${role.name}/soon?feature=${Uri.encodeComponent(feature)}',
              ),
              child: Text(feature),
            ),
          ),
      ],
    );
  }
}
