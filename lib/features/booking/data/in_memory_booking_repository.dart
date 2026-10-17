import '../domain/booking.dart';

class BookingException implements Exception {
  const BookingException(this.message);
  final String message;
  @override
  String toString() => message;
}

class InMemoryBookingRepository {
  final List<Booking> _bookings = [];
  int _sequence = 0;
  List<Booking> get bookings => List.unmodifiable(_bookings);

  Booking create(
    String customerId,
    BookingDraft draft, {
    required DateTime now,
  }) {
    final errors = draft.validate(now: now);
    if (errors.isNotEmpty) throw BookingException(errors.values.first);
    if (_bookings.any(
      (b) =>
          b.status.canCancel &&
          b.draft.date == draft.date &&
          b.draft.slot == draft.slot,
    )) {
      throw const BookingException(
        'Slot sudah dipesan. Pilih tanggal atau jam lain.',
      );
    }
    final booking = Booking(
      id: 'BKG-${(++_sequence).toString().padLeft(3, '0')}',
      customerId: customerId,
      draft: BookingDraft(
        vehicleId: draft.vehicleId,
        serviceId: draft.serviceId,
        date: draft.date,
        slot: draft.slot,
        complaint: draft.complaint.trim(),
      ),
    );
    _bookings.add(booking);
    return booking;
  }

  void review(String id, {required bool accept, String? reason}) {
    _update(id, (booking) {
      if (booking.status != BookingStatus.pending) {
        throw const BookingException(
          'Hanya booking menunggu yang bisa ditinjau.',
        );
      }
      if (!accept &&
          (reason == null ||
              reason.trim().length < 5 ||
              reason.trim().length > 500)) {
        throw const BookingException('Alasan penolakan wajib 5–500 karakter.');
      }
      return booking.withStatus(
        accept ? BookingStatus.confirmed : BookingStatus.rejected,
        reason: accept ? null : reason!.trim(),
      );
    });
  }

  void cancel(String id, String customerId) {
    _update(id, (booking) {
      if (booking.customerId != customerId || !booking.status.canCancel) {
        throw const BookingException('Booking ini tidak bisa dibatalkan.');
      }
      return booking.withStatus(BookingStatus.cancelled);
    });
  }

  void _update(String id, Booking Function(Booking) change) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index < 0) throw const BookingException('Booking tidak ditemukan.');
    _bookings[index] = change(_bookings[index]);
  }
}
