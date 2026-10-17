import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/user_role.dart';
import '../../auth/application/auth_session.dart';
import '../application/booking_controller.dart';
import '../data/in_memory_booking_repository.dart';
import '../domain/booking.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  const BookingDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  String? error;
  Future<void> act({required bool cancel, bool accept = false}) async {
    var reason = '';
    final form = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          cancel
              ? 'Batalkan booking?'
              : accept
              ? 'Konfirmasi booking?'
              : 'Tolak booking?',
        ),
        content: SingleChildScrollView(
          child: cancel || accept
              ? const Text('Lanjutkan perubahan status booking demo ini?')
              : Form(
                  key: form,
                  child: TextFormField(
                    onChanged: (value) => reason = value,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alasan penolakan',
                    ),
                    validator: (value) => (value?.trim().length ?? 0) < 5
                        ? 'Isi alasan minimal 5 karakter.'
                        : null,
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () {
              if (cancel || accept || form.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Ya, lanjutkan'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      final controller = ref.read(bookingsProvider.notifier);
      if (cancel) {
        controller.cancel(widget.id);
      } else {
        controller.review(widget.id, accept: accept, reason: reason);
      }
      setState(() => error = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status booking diperbarui.')),
      );
    } on BookingException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref
        .watch(visibleBookingsProvider)
        .where((b) => b.id == widget.id);
    if (items.isEmpty) {
      return const Center(child: Text('Booking tidak ditemukan.'));
    }
    final booking = items.first;
    final role = ref.watch(authSessionProvider).role;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Detail ${booking.id}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Status: ${booking.status.label}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(booking.vehicle.label),
        Text(booking.service.name),
        Text('${bookingDate(booking.draft.date!)} · ${booking.draft.slot}'),
        const SizedBox(height: 16),
        Text('Keluhan: ${booking.draft.complaint}'),
        if (booking.reason != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Alasan penolakan: ${booking.reason}'),
          ),
        const SizedBox(height: 24),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (role == UserRole.customer && booking.status.canCancel)
          OutlinedButton(
            onPressed: () => act(cancel: true),
            child: const Text('Batalkan Booking'),
          ),
        if (role == UserRole.admin &&
            booking.status == BookingStatus.pending) ...[
          FilledButton(
            onPressed: () => act(cancel: false, accept: true),
            child: const Text('Konfirmasi Booking'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => act(cancel: false),
            child: const Text('Tolak Booking'),
          ),
        ],
      ],
    );
  }
}
