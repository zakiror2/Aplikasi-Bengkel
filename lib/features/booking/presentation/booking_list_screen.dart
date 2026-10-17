import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/user_role.dart';
import '../../auth/application/auth_session.dart';
import '../application/booking_controller.dart';
import '../domain/booking.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authSessionProvider).role;
    if (role == null) return const SizedBox.shrink();
    final bookings = ref.watch(visibleBookingsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          role == UserRole.technician
              ? 'Simulasi antrean teknisi'
              : 'Daftar Booking',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (role == UserRole.technician)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Booking terkonfirmasi muncul sebagai antrean bersama. Penugasan dan progres teknisi belum tersedia.',
            ),
          ),
        if (role == UserRole.customer)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FilledButton.icon(
              onPressed: () => context.push('/customer/booking'),
              icon: const Icon(Icons.add),
              label: const Text('Booking Servis'),
            ),
          ),
        if (bookings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Belum ada booking.'),
          ),
        for (final booking in bookings.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push(
                  '/${role.name}/${role == UserRole.technician ? 'jobs' : 'bookings'}/${booking.id}',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.id} · ${booking.status.label}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(booking.vehicle.label),
                      Text(booking.service.name),
                      Text(
                        '${bookingDate(booking.draft.date!)} · ${booking.draft.slot}',
                      ),
                      const SizedBox(height: 8),
                      const Text('Lihat detail →'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
