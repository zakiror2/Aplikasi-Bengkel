# BengkelKu

Aplikasi tugas akhir manajemen bengkel kendaraan milik dan dikembangkan oleh **Zaki**.
Repository asli: https://github.com/zakiror2/Aplikasi-Bengkel.
Phase 01 dikembangkan dari kode `origin/main` sendiri (baseline `b82057c`), pada branch `main`.

## Status Phase 01: fondasi mobile DEMO

Satu codebase Flutter untuk Android dan iOS, dengan Material 3, Riverpod, dan GoRouter.
Folder platform desktop existing dipertahankan. Prioritas verifikasi adalah mobile.

| Peran | Berfungsi dalam demo |
| --- | --- |
| Pelanggan | Pilih kendaraan/layanan demo, tanggal hingga 90 hari, slot jam, keluhan; konfirmasi, buat, lihat daftar/detail/status, batalkan booking menunggu atau terkonfirmasi |
| Admin | Dashboard berdasarkan data booking yang sama; konfirmasi atau tolak booking menunggu dengan alasan wajib |
| Teknisi | Dashboard dan simulasi antrean booking terkonfirmasi; belum ada penugasan atau pencatatan progres |

Login adalah pilihan peran **tanpa akun/password**, dengan satu identitas Pelanggan Demo.
Route dan tindakan dibatasi menurut peran. Admin tidak dapat membuka route teknisi.
Navigasi mobile dan navigation rail tablet/desktop mendukung pilihan tab, profil, logout dan kembali.

**DEMO: semua booking hanya disimpan dalam memori satu proses aplikasi.** Logout/ganti
peran mempertahankan data; restart atau hot restart menghapusnya. Tidak ada persistensi,
sinkronisasi antar perangkat, autentikasi produksi, atau jaminan kapasitas bengkel nyata.
Slot yang sama tidak bisa dipesan dua kali selama booking aktif. Tanggal/slot yang lewat,
isian kosong dan keluhan tidak valid ditolak. Kendaraan dan layanan adalah katalog contoh.

Riwayat servis, checklist/progres, stok/sparepart, pengelolaan customer/teknisi,
service order, pembayaran dan laporan membuka halaman **Segera Hadir**.
Tidak ada pembayaran sungguhan atau angka transaksi palsu.

## Menjalankan

Gunakan Flutter yang mendukung Dart `^3.13.5`, Android SDK, dan JDK yang kompatibel
dengan konfigurasi Gradle repo. Versi dependency terkunci pada `pubspec.lock`.

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
flutter build apk --debug
```

APK debug: `build/app/outputs/flutter-apk/app-debug.apk`. Signing rilis belum disiapkan;
konfigurasi release existing masih memakai debug key, bukan distribusi produksi.
Android namespace/applicationId dan iOS Runner bundle ID: `com.zakiror2.bengkelku`.
Nama aplikasi mobile: **BengkelKu**.

Untuk iOS, jalankan pada **macOS dengan Xcode**, pilih simulator atau perangkat dan
atur signing team untuk perangkat fisik:

```sh
flutter pub get
flutter run -d <ios-simulator-id>
flutter build ios --simulator
flutter build ios --no-codesign
```

**iOS build/run/signing: NOT VERIFIED di Windows.** Penggantian identifier dan display
name hanya persiapan struktur; bukan bukti aplikasi berjalan di iPhone.

## Pemeriksaan

```sh
dart format .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Pengujian mencakup session/guard tiga peran, router stabil, validasi draft, konflik slot,
transisi status, konfirmasi/penolakan admin, pembatalan pelanggan, form dan alur antar
peran. Widget diuji pada lebar 320/360/390/430 dp dan tablet 900 dp, teks 1,3× serta
keyboard inset. Ini tidak menggantikan uji manual perangkat nyata.

## Firebase dan batas biaya

Phase 01 tidak menginisialisasi Firebase. Semua fitur booking menggunakan repository
in-memory. Firebase Auth/Firestore belum menjadi backend demo ini; emulator tidak
diperlukan untuk phase ini. Tidak ada private key, token, password, atau signing key
yang boleh di-commit.

Phase berikutnya direncanakan **Spark saja**, Auth Email/Password dan Firestore Standard
(default), dengan pengujian rules/emulator sebelum akses data produksi. Tanpa Storage,
Cloud Functions, phone/SMS auth, payment gateway atau upgrade Blaze.

## Struktur dan rencana

`lib/features/auth` menangani session demo; `lib/features/booking` memisahkan domain,
repository, Riverpod controller dan presentasi; `lib/features/customer` berisi form.
`lib/app` menangani router/theme dan `lib/core` berisi komponen bersama.

Roadmap delapan phase dan bukti verifikasi dicatat di [docs/ROADMAP.md](docs/ROADMAP.md)
dan [docs/PHASE_STATUS.md](docs/PHASE_STATUS.md). Berhenti setelah Phase 01; setiap phase
berikutnya memerlukan instruksi Zaki. Kerja tetap pada `main`, tanpa fork, branch baru,
PR, cherry-pick kode pihak lain, perubahan remote, atau force push.
