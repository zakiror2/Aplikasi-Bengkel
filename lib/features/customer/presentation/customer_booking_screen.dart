import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../booking/application/booking_controller.dart';
import '../../booking/data/in_memory_booking_repository.dart';
import '../../booking/domain/booking.dart';

class CustomerBookingScreen extends ConsumerStatefulWidget {
  const CustomerBookingScreen({super.key});
  @override
  ConsumerState<CustomerBookingScreen> createState() =>
      _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends ConsumerState<CustomerBookingScreen> {
  final form = GlobalKey<FormState>();
  final complaint = TextEditingController();
  final dateText = TextEditingController();
  String? vehicleId, serviceId, slot, error;
  DateTime? date;
  bool busy = false;
  bool sending = false;

  BookingDraft get draft => BookingDraft(
    vehicleId: vehicleId,
    serviceId: serviceId,
    date: date,
    slot: slot,
    complaint: complaint.text,
  );
  String? validation(String field) =>
      draft.validate(now: ref.read(clockProvider)())[field];

  @override
  void dispose() {
    complaint.dispose();
    dateText.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: date ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (selected != null && mounted) {
      setState(() {
        date = selected;
        dateText.text = bookingDate(selected);
      });
    }
  }

  Future<void> submit() async {
    if (busy) return;
    final value = draft;
    final errors = value.validate(now: ref.read(clockProvider)());
    final visibleFieldsValid = form.currentState!.validate();
    if (errors.isNotEmpty || !visibleFieldsValid) {
      setState(() => error = errors.isEmpty ? null : errors.values.first);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Booking Demo'),
          content: SingleChildScrollView(
            child: Text(
              '${demoVehicles.firstWhere((v) => v.id == value.vehicleId).label}\n'
              '${demoServices.firstWhere((s) => s.id == value.serviceId).name}\n'
              '${bookingDate(value.date!)} · ${value.slot}\n\n${value.complaint.trim()}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Periksa lagi'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Kirim Booking'),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      setState(() => sending = true);
      final booking = await ref.read(bookingsProvider.notifier).submit(value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking demo berhasil dibuat.')),
      );
      context.replace('/customer/bookings/${booking.id}');
    } on BookingException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Booking gagal dibuat. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: ListView(
      key: const Key('booking-form'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Booking Servis',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          key: const Key('vehicle'),
          initialValue: vehicleId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Kendaraan Demo',
            border: OutlineInputBorder(),
          ),
          items: demoVehicles
              .map(
                (v) => DropdownMenuItem(
                  value: v.id,
                  child: Text(
                    v.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: busy ? null : (value) => setState(() => vehicleId = value),
          validator: (_) => validation('vehicle'),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          key: const Key('service'),
          initialValue: serviceId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Layanan',
            border: OutlineInputBorder(),
          ),
          items: demoServices
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(
                    s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: busy ? null : (value) => setState(() => serviceId = value),
          validator: (_) => validation('service'),
        ),
        const SizedBox(height: 20),
        TextFormField(
          key: const Key('date'),
          controller: dateText,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Tanggal',
            hintText: 'Pilih tanggal',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_month),
          ),
          onTap: busy ? null : pickDate,
          validator: (_) => validation('date'),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          key: const Key('slot'),
          initialValue: slot,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Slot Jam',
            border: OutlineInputBorder(),
          ),
          items: demoSlots
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: busy ? null : (value) => setState(() => slot = value),
          validator: (_) => validation('slot'),
        ),
        const SizedBox(height: 20),
        TextFormField(
          key: const Key('complaint'),
          controller: complaint,
          enabled: !busy,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Keluhan',
            helperText: 'Minimal 5 karakter',
            border: OutlineInputBorder(),
          ),
          validator: (_) => validation('complaint'),
        ),
        const SizedBox(height: 16),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (sending)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          ),
        FilledButton(
          key: const Key('submit-booking'),
          onPressed: busy ? null : submit,
          child: Text(busy ? 'Memproses…' : 'Konfirmasi Booking'),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}
