# Roadmap BengkelKu — Zaki

Repository: https://github.com/zakiror2/Aplikasi-Bengkel. Semua phase dikerjakan pada
`main`, dengan verifikasi aktual dan commit relevan. Tidak otomatis lanjut phase.

| Phase | Lingkup | Kriteria keluar |
| --- | --- | --- |
| 01 | Fondasi mobile orisinal; session 3 peran; booking in-memory | Alur pelanggan/admin bekerja satu proses; guard, layout, test, dokumentasi dan APK debug diverifikasi |
| 02 | Firebase Spark: Email/Password dan Firestore Standard default | Identitas project konsisten; akun/peran aman; rules dan emulator diuji, termasuk penolakan eskalasi peran |
| 03 | Kendaraan, layanan, booking persisten dan kapasitas jadwal | Ownership, validasi dan konflik transaksi diuji; bukan hanya guard UI |
| 04 | Service order dan penugasan teknisi | Admin menugaskan; teknisi hanya mengakses pekerjaan berwenang |
| 05 | Checklist, progres dan riwayat servis | Transisi valid dan riwayat konsisten, tanpa Cloud Functions/Storage |
| 06 | Inventaris dan pemakaian sparepart | Perubahan stok dan referensi servis aman serta tervalidasi |
| 07 | Pencatatan pembayaran manual dan laporan | Tidak ada payment gateway; laporan sesuai data nyata dan pembatasan peran |
| 08 | UAT, aksesibilitas, keamanan dan persiapan rilis TA | Uji perangkat Android/iPhone, signing milik Zaki di luar Git, bukti build dan dokumentasi akhir |

Seluruh rencana tetap Spark: tidak memakai Storage, Cloud Functions, SMS/phone auth,
payment gateway, atau upgrade Blaze. Perubahan biaya/lingkup memerlukan instruksi Zaki.
Rencana adalah target pengembangan, bukan klaim bahwa fitur sudah tersedia.
