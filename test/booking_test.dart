import 'package:bengkel_kendaraan/core/constants/user_role.dart';
import 'package:bengkel_kendaraan/features/auth/application/auth_session.dart';
import 'package:bengkel_kendaraan/features/booking/application/booking_controller.dart';
import 'package:bengkel_kendaraan/features/booking/data/in_memory_booking_repository.dart';
import 'package:bengkel_kendaraan/features/booking/domain/booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final now = DateTime(2026, 10, 17, 8);
BookingDraft validDraft({String slot = '09:00'}) => BookingDraft(
  vehicleId: 'brio',
  serviceId: 'oil',
  date: DateTime(2026, 10, 18),
  slot: slot,
  complaint: 'Mesin berbunyi keras',
);

void main() {
  test('draft validates all required fields, date range and elapsed slot', () {
    expect(
      const BookingDraft().validate(now: now).keys,
      containsAll(['vehicle', 'service', 'date', 'slot', 'complaint']),
    );
    expect(validDraft().validate(now: now), isEmpty);
    expect(
      BookingDraft(
        vehicleId: 'fake',
        serviceId: 'fake',
        date: now.subtract(const Duration(days: 1)),
        slot: '04:00',
        complaint: 'a',
      ).validate(now: now),
      hasLength(5),
    );
    expect(
      BookingDraft(date: now.add(const Duration(days: 91))).validate(now: now),
      contains('date'),
    );
    expect(
      BookingDraft(
        date: DateTime(2026, 10, 17),
        slot: '09:00',
      ).validate(now: DateTime(2026, 10, 17, 10)),
      contains('slot'),
    );
  });

  test('repository rejects duplicates and releases cancelled slot', () {
    final repository = InMemoryBookingRepository();
    expect(
      () => repository.create('customer', const BookingDraft(), now: now),
      throwsA(isA<BookingException>()),
    );
    final booking = repository.create('customer', validDraft(), now: now);
    expect(
      () => repository.create('customer', validDraft(), now: now),
      throwsA(isA<BookingException>()),
    );
    expect(
      () => repository.cancel(booking.id, 'other'),
      throwsA(isA<BookingException>()),
    );
    repository.cancel(booking.id, 'customer');
    expect(
      repository.create('customer', validDraft(), now: now).id,
      isNot(booking.id),
    );
    expect(() => repository.bookings.clear(), throwsUnsupportedError);
  });

  test(
    'shared bookings survive logout, admin confirms/rejects, customer cancels',
    () async {
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);
      final auth = container.read(authSessionProvider.notifier);
      final controller = container.read(bookingsProvider.notifier);
      expect(controller.submit(validDraft()), throwsA(isA<BookingException>()));
      auth.signIn(UserRole.customer);
      final first = await controller.submit(validDraft());
      final second = await controller.submit(validDraft(slot: '11:00'));
      expect(
        () => controller.review(first.id, accept: true),
        throwsA(isA<BookingException>()),
      );
      auth.signOut();
      expect(container.read(visibleBookingsProvider), isEmpty);
      auth.signIn(UserRole.admin);
      expect(container.read(visibleBookingsProvider), hasLength(2));
      expect(
        () => controller.cancel(first.id),
        throwsA(isA<BookingException>()),
      );
      controller.review(first.id, accept: true);
      expect(
        () =>
            controller.review(first.id, accept: false, reason: 'Ditolak ulang'),
        throwsA(isA<BookingException>()),
      );
      expect(
        () => controller.review(second.id, accept: false, reason: 'a'),
        throwsA(isA<BookingException>()),
      );
      controller.review(
        second.id,
        accept: false,
        reason: 'Bengkel sedang tutup',
      );
      auth.signIn(UserRole.technician);
      expect(container.read(visibleBookingsProvider).single.id, first.id);
      expect(
        () => controller.review(second.id, accept: true),
        throwsA(isA<BookingException>()),
      );
      auth.signIn(UserRole.customer);
      final items = container.read(visibleBookingsProvider);
      expect(items.first.status, BookingStatus.confirmed);
      expect(items.last.status, BookingStatus.rejected);
      expect(items.last.reason, 'Bengkel sedang tutup');
      expect(
        () => controller.cancel(second.id),
        throwsA(isA<BookingException>()),
      );
      controller.cancel(first.id);
      expect(
        container.read(bookingsProvider).first.status,
        BookingStatus.cancelled,
      );
      expect(
        () => controller.cancel(first.id),
        throwsA(isA<BookingException>()),
      );
      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      expect(restarted.read(bookingsProvider), isEmpty);
    },
  );
}
