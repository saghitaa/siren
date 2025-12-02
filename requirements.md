# SIREN APPLICATION BRIEF
## TUJUAN

Menambahkan logika backend dan layanan aplikasi untuk:

* Forum (awareness sharing).
* Laporan (warga → responder) dengan alur notifikasi dan status.
* Tombol SOS (SMS ke kontak darurat + notifikasi suara real-time ke responder).
  Mempertahankan semua file UI tampilan tanpa perubahan tata letak.

---

## ATURAN

1. **JANGAN UBAH** file UI/layout unless needed:

   * `lib/screens/*dashboard*.dart`
   * `lib/screens/*profile*.dart`
   * `lib/widgets/*`
2. **HANYA BUAT / EDIT**:

   * `lib/services/*`
   * `lib/models/*`
   * `lib/providers/*` atau `lib/state/*`
   * `functions/*`
   * `assets/*`
   * `README_DEV.md`, unit tests, `cursor-config.json`
3. Ikuti penamaan dan gaya proyek yang ada.

---

## RINGKASAN FITUR

### FORUM

* Fungsi:

  * Warga dan Responder dapat membuat posting, membalas posting, dan membaca posting pengguna lain.
  * Setiap posting menyimpan: identitas pengguna, nama, peran, isi, dan timestamp.
  * Peran ditampilkan di UI sebagai label (Warga / Responder).
* Penyimpanan:

  * Gunakan koleksi `forumPosts` di Firestore.
  * Opsi: cache baca di SQLite untuk offline baca.
* UI behavior:

  * Setelah posting berhasil dikirim, kotak teks dikosongkan.
  * Balasan ditampilkan terstruktur (thread/reply count).

### LAPORAN

* Fungsi:

  1. Warga mengirim laporan lengkap berisi deskripsi, lokasi, jenis laporan, waktu.
  2. Setelah tombol kirim diklik, input teks dihapus/kosong di UI.
  3. Laporan tersimpan di koleksi `reports` di Firestore dengan status awal `Belum ditanggapi`.
  4. Sistem mengirim notifikasi ke responder yang sesuai (filter berdasarkan jenis/kategori atau role responder).
  5. Responder menerima notifikasi dengan judul `LAPORAN BARU` dan ringkasan; juga muncul di dashboard responder.
  6. Responder dapat menanggapi laporan melalui dashboard: menandai `Proses` atau `Sudah ditanggapi`, menambahkan pesan tanggapan, dan menyertakan `responderId` serta `responderName`.
  7. Warga dapat memantau status laporannya secara real-time: `Belum ditanggapi`, `Proses`, atau `Sudah ditanggapi`.
* Data lapor:

  * Simpan field: tipe laporan, userId, userName, description, lat/lng (jika ada), reportType/kategori, status, createdAt, respondedAt, responderId, responderName, responseMessage.

### SOS BUTTON

* Fungsi inti:

  1. Warga menekan tombol SOS.
  2. Sistem mengambil daftar kontak darurat dari profil user (`users/{userId}.contacts`) dan memvalidasi format nomor; jika ada nomor invalid, kembalikan error ke UI agar diperbaiki.
  3. Sistem membuat entri singkat di `reports` dengan tipe `SOS` dan status `SOS_SENT` (menyimpan lokasi & user info).
  4. Sistem memutar sirene lokal pada device warga (loop) hingga dibatalkan atau timeout.
  5. Sistem mengirim SMS ke setiap nomor valid di `contacts` dengan pesan yang jelas: nama user + teks bantuan + tautan lokasi Google Maps.
  6. Sistem mengirim notifikasi real-time (FCM) ke responder yang sesuai dengan payload tipe `SOS_ALERT` dan pesan: `[NAMA USER] BUTUH BANTUAN !!` beserta `reportId`, lokasi.
  7. Pada device responder: bermain suara sirene (asset yang sudah disediakan) dan menampilkan popup/alert real-time dengan opsi `Acknowledge` atau `Ignore`.
  8. Jika responder memilih `Acknowledge`, update `reports/{id}.status = Menanggapi`, tulis `responderId`, `responderName`, `respondedAt`, dan kirim FCM kepada reporter dengan payload berisi pesan persis:

     * `"LAPORAN ANDA DITERIMA. RESPONDER MENUJU LOKASI"`
       bersama detail responder (nama, nomor) sehingga reporter melihat modal/toast non-blocking dan tombol untuk tracking (buka navigasi).
  9. Jika reporter membatalkan SOS, stop sirene lokal, update report `status = cancelled`, dan kirim FCM `STOP_SIREN` ke responder terkait.

10. Ketika satu responder menanggapi, kirim FCM `STOP_SIREN` ke device responder lain jika perlu.


* Validasi kontak:

  * Nomor harus dalam format yang valid (E.164 dianjurkan). Nomor invalid ditolak dan user diminta perbaikan.


# **Penegasan Asset Logo & Sirene (Siap Pakai)**

Aplikasi menggunakan dua asset lokal yang sudah tersedia di dalam folder `assets/`:

### **1. Logo Aplikasi**

* **Nama file:** `siren.png`
* **Lokasi:** `assets/images/siren.png`
* **Peran:**

  * Logo standar untuk splash screen, login, dashboard warga/responder, serta semua UI yang sebelumnya memakai `Image.network(...)`.
  * Logo harus dipanggil menggunakan referensi asset, bukan URL jaringan.
  * Jika terjadi error load, tampilkan placeholder di UI (Cursor akan membuat widget helper terpisah).

### **2. Suara Sirene**

* **Nama file:** `sos siren.mp3`
* **Lokasi:** `assets/sounds/sos siren.mp3`
* **Peran:**

  * Diputar pada **device warga** saat tombol SOS ditekan.
  * Diputar pada **device responder** ketika menerima `SOS_ALERT`.
  * Loop terus hingga:

    * responder melakukan **double-tap** pada popup, atau
    * responder menekan tombol **Tanggapi**, atau
    * reporter melakukan **Cancel SOS**, atau
    * backend mengirim FCM `STOP_SIREN`.
  * File wajib digunakan **langsung dari asset lokal**, bukan streaming.
 
## MODEL DATA (Firestore) — RINGKAS

### `users/{userId}`

* displayName, phone, role (`warga` atau `responder`), contacts (array nomor darurat), profileImageUrl, createdAt.

### `responders/{responderId}`

* userId, displayName, roleType (jenis responder), fcmToken, status (Tersedia/Tidak), createdAt.

### `reports/{reportId}`

* type (`regular` | `SOS`), userId, userName, description, lat, lng, reportType, status (`Belum ditanggapi` | `Proses` | `Sudah ditanggapi` | `SOS_SENT` | `cancelled` | `Menanggapi`), createdAt, respondedAt, responderId?, responderName?, responseMessage?.

### `forumPosts/{postId}`

* userId, name, role, content, createdAt, repliesCount.

---

## PAYLOAD NOTIFIKASI (format & tipe)

* **Laporan baru ke responder**

  * Tipe: `NEW_REPORT`
  * Judul: `LAPORAN BARU`
  * Isi data: `reportId`, ringkasan teks

* **SOS ke responder**

  * Tipe: `SOS_ALERT`
  * Pesan: `[NAMA USER] BUTUH BANTUAN !!`
  * Data: `reportId`, `lat`, `lng`

* **Reporter ACK (responder menanggapi)**

  * Tipe: `SOS_ACK`
  * Pesan: `LAPORAN ANDA DITERIMA. RESPONDER MENUJU LOKASI`
  * Data: `reportId`, `responderName`, `responderPhone`

* **Stop siren**

  * Tipe: `STOP_SIREN`
  * Data: `reportId`

---

## FILE YANG DITAMBAHKAN / DIUBAH (EKSPILISIT)

* `lib/services/forum_service.dart` — CRUD forum post & reply; optional caching.
* `lib/services/report_service.dart` — create report, clear input setelah kirim, listen update status.
* `lib/services/sos_service.dart` — alur SOS: create report SOS, validasi kontak, kirim SMS, kirim FCM, mainkan sirene lokal, cancel flow.
* `lib/services/fcm_service.dart` — register token, handle incoming messages (`NEW_REPORT`, `SOS_ALERT`, `SOS_ACK`, `STOP_SIREN`), tampilkan popup/alert.
* `lib/models/report_model.dart`
* `lib/models/forum_post_model.dart`
* `lib/providers/app_state_provider.dart` — injeksi service ke UI (Provider/Riverpod).
* `functions/index.js` — cloud functions: `sendReportNotification` (onCreate atau callable), `sendSOS` (callable), `acknowledgeReport` (callable).
* `assets/sounds/siren.mp3` — pastikan file disimpan di path ini.
* `README_DEV.md`, `cursor-config.json`, unit tests untuk `report_service.createReport()` dan `sos_service.sendSOS()`.

---

## DEPENDENSI & PUBSPEC (DITAMBAHKAN JIKA PERLU)

* cloud_firestore
* firebase_messaging
* cloud_functions
* firebase_core
* geolocator
* audioplayers
* url_launcher
* sqflite (opsional)
* path_provider

Tambahkan asset:

* `assets/sounds/siren.mp3`

---

## CLOUD FUNCTIONS (RINGKAS)

* `sendReportNotification` (trigger onCreate reports non-SOS): cari responder sesuai kategori → kirim FCM `NEW_REPORT` → set `reports.status = Belum ditanggapi` jika perlu.
* `sendSOS` (callable): baca report SOS → kirim SMS ke kontak (Twilio) → kirim FCM `SOS_ALERT` ke responder → update `reports.status = SOS_SENT`.
* `acknowledgeReport` (callable): transaksi safety untuk menandai report ditanggapi oleh responder → update report & notify reporter (`SOS_ACK`).

---

## PERILAKU AUDIO & NOTIFIKASI

* Pada `SOS_ALERT`, responder memutar file `assets/sounds/siren.mp3` dalam mode loop sampai `STOP_SIREN` diterima atau responder acknowledge.
* Reporter memutar sirene lokal setelah menekan SOS sampai cancel/timeout/acknowledge.
* Semua stop flows (cancel/acknowledge/resolve) harus mengirim FCM `STOP_SIREN` ke pihak lain jika relevan.

---

## VALIDASI NOMOR DARURAT

* Validasi pola nomor sebelum mengirim SMS.
* Jika nomor tidak valid, tolak pengiriman dan laporkan kesalahan ke UI agar user memperbarui kontak.

---

## UI WIRING (MINIMAL, TANPA UBAHAN LAYOUT)

* Sediakan `Provider`/`ServiceLocator` di `main.dart` untuk injeksi services.
* Forum screen: panggil `forumService.createPost()` dan clear input setelah sukses.
* Report screen: panggil `reportService.createReport()` dan clear input area setelah sukses.
* SOS button: panggil `sosService.sendSOS()`.

---

## CHECKLIST PENGUJIAN

* [ ] Forum: buat posting, balas, baca lintas device.
* [ ] Laporan: kirim → FCM ke responder; input di-clear setelah kirim.
* [ ] Responder dashboard menampilkan laporan masuk dan dapat menanggapi → update status di Firestore.
* [ ] Warga dapat melihat status laporan real-time.
* [ ] SOS: tekan SOS → SMS ke kontak darurat terkirim; FCM ke responder; reporter memutar sirene lokal; responder mendengar sirene.
* [ ] Responder acknowledge → update status dan reporter menerima `LAPORAN ANDA DITERIMA. RESPONDER MENUJU LOKASI`.
* [ ] Cancel/Resolve mengirim `STOP_SIREN` dan menghentikan audio.
* [ ] Validasi nomor darurat berfungsi.
* [ ] `flutter pub get` sukses dan asset sirene dimuat.

---

## README_DEV (yang harus ada)

* Cara deploy Cloud Functions (env vars Twilio, service account).
* Cara menaruh `assets/sounds/siren.mp3` ke project.
* Cara menjalankan tes: forum, laporan, SOS.
* Cara menguji SMS di Twilio sandbox dan FCM di device.

