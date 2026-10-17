import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/user_role.dart';
import '../../auth/application/auth_session.dart';
import '../data/in_memory_booking_repository.dart';
import '../domain/booking.dart';

final bookingRepositoryProvider = Provider(
  (ref) => InMemoryBookingRepository(),
);
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final bookingsProvider = NotifierProvider<BookingController, List<Booking>>(
  BookingController.new,
);

class BookingController extends Notifier<List<Booking>> {
  @override
  List<Booking> build() => ref.watch(bookingRepositoryProvider).bookings;

  void _require(UserRole role) {
    if (ref.read(authSessionProvider).role != role) {
      throw const BookingException(
        'Peran ini tidak diizinkan melakukan tindakan tersebut.',
      );
    }
  }

  Future<Booking> submit(BookingDraft draft) async {
    _require(UserRole.customer);
    // An asynchronous boundary exposes loading and prevents repeated UI submits.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _require(UserRole.customer);
    final booking = ref
        .read(bookingRepositoryProvider)
        .create(
          ref.read(authSessionProvider).customerId,
          draft,
          now: ref.read(clockProvider)(),
        );
    state = ref.read(bookingRepositoryProvider).bookings;
    return booking;
  }

  void review(String id, {required bool accept, String? reason}) {
    _require(UserRole.admin);
    ref
        .read(bookingRepositoryProvider)
        .review(id, accept: accept, reason: reason);
    state = ref.read(bookingRepositoryProvider).bookings;
  }

  void cancel(String id) {
    _require(UserRole.customer);
    ref
        .read(bookingRepositoryProvider)
        .cancel(id, ref.read(authSessionProvider).customerId);
    state = ref.read(bookingRepositoryProvider).bookings;
  }
}

final visibleBookingsProvider = Provider<List<Booking>>((ref) {
  final session = ref.watch(authSessionProvider);
  final bookings = ref.watch(bookingsProvider);
  return switch (session.role) {
    UserRole.customer =>
      bookings.where((b) => b.customerId == session.customerId).toList(),
    UserRole.admin => bookings,
    UserRole.technician =>
      bookings.where((b) => b.status == BookingStatus.confirmed).toList(),
    null => [],
  };
});
