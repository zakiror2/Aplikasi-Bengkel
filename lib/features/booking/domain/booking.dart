enum BookingStatus {
  pending('Menunggu'),
  confirmed('Dikonfirmasi'),
  rejected('Ditolak'),
  cancelled('Dibatalkan');

  const BookingStatus(this.label);
  final String label;
  bool get canCancel => this == pending || this == confirmed;
}

class Vehicle {
  const Vehicle(this.id, this.name, this.plate);
  final String id;
  final String name;
  final String plate;
  String get label => '$name · $plate';
}

class WorkshopService {
  const WorkshopService(this.id, this.name);
  final String id;
  final String name;
}

class BookingDraft {
  const BookingDraft({
    this.vehicleId,
    this.serviceId,
    this.date,
    this.slot,
    this.complaint = '',
  });
  final String? vehicleId;
  final String? serviceId;
  final DateTime? date;
  final String? slot;
  final String complaint;

  Map<String, String> validate({required DateTime now}) {
    final errors = <String, String>{};
    if (!demoVehicles.any((v) => v.id == vehicleId)) {
      errors['vehicle'] = 'Pilih kendaraan demo.';
    }
    if (!demoServices.any((s) => s.id == serviceId)) {
      errors['service'] = 'Pilih layanan.';
    }
    final today = DateTime(now.year, now.month, now.day);
    if (date == null ||
        date!.isBefore(today) ||
        date!.isAfter(today.add(const Duration(days: 90)))) {
      errors['date'] = 'Pilih tanggal hari ini hingga 90 hari ke depan.';
    }
    if (!demoSlots.contains(slot)) {
      errors['slot'] = 'Pilih slot jam.';
    } else if (date != null) {
      final hour = int.parse(slot!.split(':').first);
      final appointment = DateTime(date!.year, date!.month, date!.day, hour);
      if (!appointment.isAfter(now)) errors['slot'] = 'Slot sudah berlalu.';
    }
    if (complaint.trim().length < 5 || complaint.trim().length > 500) {
      errors['complaint'] = 'Isi keluhan 5–500 karakter.';
    }
    return errors;
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.customerId,
    required this.draft,
    this.status = BookingStatus.pending,
    this.reason,
  });
  final String id;
  final String customerId;
  final BookingDraft draft;
  final BookingStatus status;
  final String? reason;
  Vehicle get vehicle =>
      demoVehicles.firstWhere((v) => v.id == draft.vehicleId);
  WorkshopService get service =>
      demoServices.firstWhere((s) => s.id == draft.serviceId);
  Booking withStatus(BookingStatus value, {String? reason}) => Booking(
    id: id,
    customerId: customerId,
    draft: draft,
    status: value,
    reason: reason,
  );
}

const demoVehicles = [
  Vehicle('brio', 'Honda Brio RS', 'B 1234 XYZ'),
  Vehicle('avanza', 'Toyota Avanza', 'N 1234 AB'),
];
const demoServices = [
  WorkshopService('periodic', 'Servis Berkala'),
  WorkshopService('oil', 'Ganti Oli'),
  WorkshopService('inspection', 'Pemeriksaan Kendaraan'),
];
const demoSlots = ['09:00', '11:00', '13:00', '15:00'];

String bookingDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
