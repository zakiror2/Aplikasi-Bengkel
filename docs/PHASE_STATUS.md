# Tracking Phase — Zaki

Tanggal pengerjaan: 17 Oktober 2026 (Asia/Jakarta).
Repository asli: https://github.com/zakiror2/Aplikasi-Bengkel.
Baseline lokal dan remote main yang diperiksa: `b82057c43cb5eb966cc2f34e03346528581c4009`.

## Phase 01

Implementasi selesai; seluruh verifikasi yang tersedia pada host Windows PASS.

- Implementasi: session demo 3 peran, stable router, guard route/tindakan, navigasi,
  katalog kendaraan/layanan, booking draft/domain/status, in-memory repository,
  form validasi/konfirmasi/loading/error/success, daftar/detail/cancel, admin
  confirm/reject dengan alasan dan antrean simulasi teknisi.
- Data sama selama satu proses; hilang setelah restart. Label DEMO tampil pada login
  dan semua halaman sesi. Belum ada autentikasi produksi atau backend booking Firebase.
- Menu di luar lingkup membuka Segera Hadir. Tidak ada counter Flutter atau callback
  tombol fitur kosong.
- Identifier Android/iOS disiapkan ke `com.zakiror2.bengkelku` setelah audit awal tidak
  menemukan integrasi Firebase. Display name mobile BengkelKu.
- Perubahan lama `windows/runner/flutter_window.h` dan `.vscode/` tidak termasuk task.
- Working tree awal tidak bersih sehingga tidak menjalankan pull. Pemeriksaan remote
  dengan `git ls-remote origin refs/heads/main` menunjukkan baseline yang sama.

## Hasil verifikasi aktual

| Pemeriksaan | Status |
| --- | --- |
| dart format . | PASS — snapshot terformat, 0 file berubah |
| flutter pub get | PASS — dependency berhasil di-resolve |
| flutter analyze | PASS — No issues found |
| flutter test | PASS — 16 unit/widget tests |
| flutter build apk --debug | PASS — command langsung exit 0; APK debug berhasil dibuat |
| iOS build/run/signing | NOT VERIFIED — host Windows |
| Uji manual Android/iPhone | NOT VERIFIED — tidak ada perangkat mobile terhubung; widget test tidak menggantikan perangkat nyata |
| Firebase Emulator | Tidak diperlukan untuk in-memory Phase 01 |
| Audit diff/rahasia | PASS — index hanya berisi file Phase 01, tanpa private key/config Firebase/perubahan lama |
| Commit/push origin main | SHA dan hasil push dilaporkan pada laporan akhir sesi; hanya file Phase 01 yang disertakan |

Perubahan Firebase dari proses lain muncul saat implementasi berlangsung. Sesuai arahan
Zaki, perubahan tersebut dipertahankan di workspace dan dikecualikan dari commit Phase 01.
Verifikasi akhir dilakukan pada snapshot index Git agar yang diuji sesuai isi commit,
tanpa menyertakan dependency, plugin Gradle, registrant atau konfigurasi Firebase tersebut.
Hash source/test/konfigurasi mobile pada snapshot cocok dengan index; lockfile asli tetap
dipakai. Pemeriksaan source XML/identifier/display name Android dan iOS PASS.

Build awal gagal karena NDK `28.2.13676358` belum tersedia dan CLI Android tidak berhasil
memasangnya. Arsip Windows dari [rilis resmi NDK r28c](https://github.com/android/ndk/releases/tag/r28c)
diunduh dari Google dan SHA1-nya cocok `086bba43ff2f5eb0e387b15c8278bb4e0d89ba1d`
sebelum dipasang. Android SDK Platform 36 juga dipasang oleh Gradle. Ini adalah
perbaikan toolchain lokal; tidak menurunkan versi dependency atau mengubah source pihak lain.

APK diverifikasi dengan `aapt2 dump badging`: package `com.zakiror2.bengkelku`,
version `1.0.0+1`, application label `BengkelKu`. Salinan hasil snapshot tersedia lokal
di `build/phase01/app-debug.apk` (diabaikan Git). APK debug bukan artefak rilis produksi.
Flutter 3.47.6 / Dart 3.13.5 digunakan untuk verifikasi.

SHA commit dan hasil push akhir dilaporkan setelah Git selesai agar tidak menulis SHA
commit ke dalam commit itu sendiri. Phase 02–08 belum dikerjakan.
