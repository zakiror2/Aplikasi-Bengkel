import 'package:bengkel_kendaraan/app/app.dart';
import 'package:bengkel_kendaraan/app/router/app_router.dart';
import 'package:bengkel_kendaraan/core/constants/user_role.dart';
import 'package:bengkel_kendaraan/features/booking/application/booking_controller.dart';
import 'package:bengkel_kendaraan/features/booking/domain/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> start(
  WidgetTester tester, {
  double width = 430,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  final container = ProviderContainer(
    overrides: [
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 17, 8)),
    ],
  );
  addTearDown(() {
    container.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const BengkelKuApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> tapText(WidgetTester tester, String label) async {
  final finder = find.text(label).last;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> scrollForm(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(
    find.byKey(key),
    150,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('booking-form')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

Future<void> fillForm(WidgetTester tester, {String slot = '09:00'}) async {
  await tester.tap(find.byKey(const Key('vehicle')));
  await tester.pumpAndSettle();
  await tapText(tester, 'Honda Brio RS · B 1234 XYZ');
  await tester.tap(find.byKey(const Key('service')));
  await tester.pumpAndSettle();
  await tapText(tester, 'Ganti Oli');
  await tester.tap(find.byKey(const Key('date')));
  await tester.pumpAndSettle();
  await tapText(tester, '18');
  await tapText(tester, 'OK');
  await scrollForm(tester, const Key('slot'));
  await tester.tap(find.byKey(const Key('slot')));
  await tester.pumpAndSettle();
  await tapText(tester, slot);
  await scrollForm(tester, const Key('complaint'));
  await tester.enterText(
    find.byKey(const Key('complaint')),
    'Mesin berbunyi keras',
  );
  await scrollForm(tester, const Key('submit-booking'));
  await tester.tap(find.byKey(const Key('submit-booking')));
  await tester.pumpAndSettle();
  expect(find.text('Konfirmasi Booking Demo'), findsOneWidget);
  await tapText(tester, 'Kirim Booking');
}

void main() {
  testWidgets(
    'customer form creates booking, admin confirms, customer cancels in same app',
    (tester) async {
      final container = await start(tester);
      await tapText(tester, 'Masuk sebagai Pelanggan');
      expect(find.text('Halo, Pelanggan'), findsOneWidget);
      await tapText(tester, 'Booking Servis');
      await fillForm(tester);
      expect(find.text('Detail BKG-001'), findsOneWidget);
      expect(find.text('Status: Menunggu'), findsOneWidget);
      expect(container.read(bookingsProvider), hasLength(1));
      await tester.tap(find.byTooltip('Keluar'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Masuk sebagai Admin');
      await tapText(tester, 'Lihat Daftar Booking');
      await tapText(tester, 'Lihat detail →');
      await tapText(tester, 'Konfirmasi Booking');
      await tapText(tester, 'Ya, lanjutkan');
      expect(find.text('Status: Dikonfirmasi'), findsOneWidget);
      await tester.tap(find.byTooltip('Keluar'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Masuk sebagai Pelanggan');
      await tapText(tester, 'Lihat Daftar Booking');
      await tapText(tester, 'Lihat detail →');
      expect(find.text('Status: Dikonfirmasi'), findsOneWidget);
      await tapText(tester, 'Batalkan Booking');
      await tapText(tester, 'Ya, lanjutkan');
      expect(find.text('Status: Dibatalkan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'invalid form stays open and conflicting slot shows recoverable error',
    (tester) async {
      final container = await start(tester);
      await tapText(tester, 'Masuk sebagai Pelanggan');
      await tapText(tester, 'Booking Servis');
      await scrollForm(tester, const Key('submit-booking'));
      await tester.tap(find.byKey(const Key('submit-booking')));
      await tester.pumpAndSettle();
      expect(container.read(bookingsProvider), isEmpty);
      expect(find.text('Konfirmasi Booking Demo'), findsNothing);
      expect(find.text('Isi keluhan 5–500 karakter.'), findsOneWidget);
      await scrollForm(tester, const Key('complaint'));
      await tester.enterText(
        find.byKey(const Key('complaint')),
        'Keluhan valid tanpa kendaraan',
      );
      await scrollForm(tester, const Key('submit-booking'));
      await tester.tap(find.byKey(const Key('submit-booking')));
      await tester.pumpAndSettle();
      expect(find.text('Pilih kendaraan demo.'), findsWidgets);
      expect(find.text('Konfirmasi Booking Demo'), findsNothing);
      expect(container.read(bookingsProvider), isEmpty);
      container.read(appRouterProvider).go('/customer/home');
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => container
            .read(bookingsProvider.notifier)
            .submit(
              BookingDraft(
                vehicleId: 'brio',
                serviceId: 'oil',
                date: DateTime(2026, 10, 18),
                slot: '09:00',
                complaint: 'Bunyi mesin keras',
              ),
            ),
      );
      await tapText(tester, 'Booking Servis');
      await fillForm(tester);
      expect(
        find.text('Slot sudah dipesan. Pilih tanggal atau jam lain.'),
        findsOneWidget,
      );
      expect(container.read(bookingsProvider), hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('admin rejection requires reason and customer sees it', (
    tester,
  ) async {
    final container = await start(tester);
    final auth = container.read(authSessionProvider.notifier);
    auth.signIn(UserRole.customer);
    final booking = (await tester.runAsync(
      () => container
          .read(bookingsProvider.notifier)
          .submit(
            BookingDraft(
              vehicleId: 'avanza',
              serviceId: 'periodic',
              date: DateTime(2026, 10, 18),
              slot: '11:00',
              complaint: 'Periksa rem kendaraan',
            ),
          ),
    ))!;
    auth.signIn(UserRole.admin);
    container.read(appRouterProvider).go('/admin/bookings/${booking.id}');
    await tester.pumpAndSettle();
    await tapText(tester, 'Tolak Booking');
    await tapText(tester, 'Ya, lanjutkan');
    expect(find.text('Isi alasan minimal 5 karakter.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Bengkel sedang tutup');
    await tapText(tester, 'Ya, lanjutkan');
    expect(find.text('Status: Ditolak'), findsOneWidget);
    auth.signIn(UserRole.customer);
    container.read(appRouterProvider).go('/customer/bookings/${booking.id}');
    await tester.pumpAndSettle();
    expect(find.text('Alasan penolakan: Bengkel sedang tutup'), findsOneWidget);
    expect(find.text('Batalkan Booking'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 360.0, 390.0, 430.0, 900.0]) {
    testWidgets('roles, tabs, guards and pages fit $width dp at text 1.3x', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = await start(tester, width: width);
      final router = container.read(appRouterProvider);
      expect(tester.takeException(), isNull);
      for (final role in UserRole.values) {
        await tapText(tester, 'Masuk sebagai ${role.label}');
        expect(router.routeInformationProvider.value.uri.path, roleHome(role));
        final listPath =
            '/${role.name}/${role == UserRole.technician ? 'jobs' : 'bookings'}';
        router.go(listPath);
        await tester.pumpAndSettle();
        final nav = find.byType(NavigationBar);
        if (width < 840) {
          expect(tester.widget<NavigationBar>(nav).selectedIndex, 1);
        } else {
          expect(
            tester
                .widget<NavigationRail>(find.byType(NavigationRail))
                .selectedIndex,
            1,
          );
        }
        router.go('/${role.name}/profile');
        await tester.pumpAndSettle();
        if (width < 840) {
          expect(tester.widget<NavigationBar>(nav).selectedIndex, 2);
        }
        router.go('/${role.name}/home');
        await tester.pumpAndSettle();
        router.push('/${role.name}/soon?feature=Riwayat');
        await tester.pumpAndSettle();
        expect(find.textContaining('Segera Hadir.'), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, roleHome(role));
        for (final other in UserRole.values.where((other) => other != role)) {
          router.go('/${other.name}/home');
          await tester.pumpAndSettle();
          expect(
            router.routeInformationProvider.value.uri.path,
            roleHome(role),
          );
        }
        if (role == UserRole.customer) {
          router.push('/customer/booking');
          await tester.pumpAndSettle();
          await scrollForm(tester, const Key('complaint'));
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await tester.tap(find.byKey(const Key('complaint')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          tester.view.resetViewInsets();
        }
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Keluar'));
        await tester.pumpAndSettle();
        router.go('/admin/bookings');
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/login');
      }
    });
  }
}
