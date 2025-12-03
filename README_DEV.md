# SIREN Application - Developer Guide

## Setup & Deployment

### 1. Firebase Project Setup

1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Enable services berikut:
   - **Firestore Database** (mode: Production atau Test)
   - **Cloud Functions**
   - **Cloud Messaging (FCM)**
   - **Authentication** (Email/Password atau Anonymous)

3. Download konfigurasi:
   - **Android**: Download `google-services.json`
     - Letakkan di: `android/app/google-services.json`
   - **iOS**: Download `GoogleService-Info.plist`
     - Letakkan di: `ios/Runner/GoogleService-Info.plist`

4. Update Android build files:
   - `android/build.gradle.kts`: Tambahkan classpath untuk Google Services
   - `android/app/build.gradle.kts`: Apply plugin `com.google.gms.google-services`

### 2. Cloud Functions Setup

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login ke Firebase:
   ```bash
   firebase login
   ```

3. Initialize Functions:
   ```bash
   firebase init functions
   ```
   - Pilih JavaScript
   - Pilih Node 18
   - Install dependencies: Yes

4. Set Twilio environment variables:
   ```bash
   firebase functions:config:set twilio.sid="YOUR_TWILIO_SID" twilio.token="YOUR_TWILIO_TOKEN" twilio.from="+1234567890"
   ```
   - Dapatkan credentials dari [Twilio Console](https://console.twilio.com/)
   - `from` harus nomor Twilio yang sudah diverifikasi

5. Deploy Functions:
   ```bash
   firebase deploy --only functions
   ```

### 3. Asset Files

1. **Logo Aplikasi**:
   - Letakkan `siren.png` di: `assets/images/siren.png`
   - Format: PNG dengan transparansi (disarankan)

2. **Suara Sirene**:
   - Letakkan `sos siren.mp3` di: `assets/sounds/sos siren.mp3`
   - Format: MP3, durasi disarankan 2-5 detik (akan di-loop)

3. Update `pubspec.yaml` (sudah dikonfigurasi):
   ```yaml
   flutter:
     assets:
       - assets/images/
       - assets/sounds/
   ```

4. Jalankan:
   ```bash
   flutter pub get
   ```

### 4. Flutter Dependencies

Semua dependencies sudah ditambahkan di `pubspec.yaml`:
- `firebase_core`, `cloud_firestore`, `firebase_messaging`, `cloud_functions`, `firebase_auth`
 (untuk cache offline opsional)

Jalankan:- `geolocator`, `audioplayers`, `url_launcher`
- `sqflite`, `path_provider`
```bash
flutter pub get
```

### 5. Android Configuration

1. Update `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
       id("com.google.gms.google-services") // Tambahkan ini
   }
   ```

2. Update `android/build.gradle.kts`:
   ```kotlin
   dependencies {
       classpath("com.google.gms:google-services:4.4.0") // Tambahkan ini
   }
   ```

3. Permissions sudah dikonfigurasi di `AndroidManifest.xml`:
   - `INTERNET`
   - `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
   - `CALL_PHONE`

### 6. iOS Configuration (jika deploy ke iOS)

1. Update `ios/Podfile` jika perlu
2. Jalankan:
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Testing

### Forum
1. Buka aplikasi sebagai Warga
2. Masuk ke Forum
3. Buat posting baru
4. Verifikasi posting muncul di Firestore collection `forumPosts`
5. Buka aplikasi sebagai Responder
6. Verifikasi posting Warga terlihat di Forum Responder

### Laporan
1. Buka aplikasi sebagai Warga
2. Masuk ke "Buat Laporan"
3. Isi form: jenis, lokasi, deskripsi
4. Klik "Buat Laporan"
5. Verifikasi:
   - Input fields dikosongkan setelah submit
   - Laporan muncul di Firestore collection `reports` dengan status `Belum ditanggapi`
   - Responder menerima FCM notification `NEW_REPORT`

### SOS Button
1. Buka aplikasi sebagai Warga
2. Pastikan profil memiliki kontak darurat (format E.164, contoh: `+6281234567890`)
3. Tekan tombol SOS merah di dashboard
4. Verifikasi:
   - Sirene lokal diputar (loop)
   - Laporan SOS dibuat di Firestore dengan status `SOS_SENT`
   - SMS terkirim ke kontak darurat (cek Twilio logs)
   - Responder menerima FCM `SOS_ALERT` dengan sirene
   - Dialog muncul dengan opsi "Batalkan SOS"

### Responder Acknowledge
1. Buka aplikasi sebagai Responder
2. Terima laporan SOS atau laporan biasa
3. Verifikasi:
   - Status laporan berubah ke `Menanggapi`
   - Reporter menerima FCM `SOS_ACK` dengan pesan: "LAPORAN ANDA DITERIMA. RESPONDER MENUJU LOKASI"
   - Sirene berhenti di semua device

### Testing FCM di Device Fisik

1. Build APK untuk device fisik:
   ```bash
   flutter build apk --debug
   ```

2. Install di device:
   ```bash
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

3. Verifikasi FCM token terdaftar:
   - Cek Firestore collection `responders` atau `users`
   - Field `fcmToken` harus terisi

4. Test notification:
   - Kirim test notification dari Firebase Console
   - Atau trigger SOS dari device lain

### Testing SMS (Twilio Sandbox)

1. Daftar di [Twilio Sandbox](https://www.twilio.com/docs/verify/sandbox)
2. Verifikasi nomor telepon Anda
3. Gunakan nomor sandbox sebagai `twilio.from`
4. Test SMS akan terkirim ke nomor terverifikasi

## Troubleshooting

### FCM Notifications Tidak Muncul
- Pastikan device memiliki Google Play Services (Android)
- Cek FCM token terdaftar di Firestore
- Cek permission notification di device settings
- Test dengan Firebase Console > Cloud Messaging > Send test message

### SMS Tidak Terkirim
- Verifikasi Twilio credentials di Firebase Functions config
- Cek Twilio logs di [Twilio Console](https://console.twilio.com/)
- Pastikan nomor `from` sudah diverifikasi di Twilio
- Untuk sandbox, pastikan nomor penerima sudah terverifikasi

### Sirene Tidak Berbunyi
- Pastikan file `assets/sounds/sos siren.mp3` ada
- Cek permission audio di device
- Test dengan `audioplayers` package langsung

### Logo Tidak Muncul (Red X)
- Pastikan file `assets/images/siren.png` ada
- Jalankan `flutter clean` lalu `flutter pub get`
- Rebuild aplikasi

### Firestore Permission Denied
- Update Firestore Security Rules di Firebase Console
- Untuk development, bisa gunakan rules sementara:
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if request.auth != null;
      }
    }
  }
  ```

## Architecture Notes

- **Services**: Semua business logic di `lib/services/`
- **Models**: Data models dengan `toFirestore()` dan `fromFirestore()`
- **Firestore Collections**:
  - `users/{userId}` - User profiles
  - `responders/{responderId}` - Responder profiles dengan FCM token
  - `reports/{reportId}` - Laporan dari warga
  - `forumPosts/{postId}` - Posting forum

- **Cloud Functions**:
  - `sendReportNotification` - Trigger onCreate untuk reports non-SOS
  - `sendSOS` - Callable untuk mengirim SMS + FCM SOS_ALERT
  - `acknowledgeReport` - Callable untuk responder acknowledge
  - `stopSiren` - Callable untuk stop sirene

## Next Steps

1. Implementasi reply di forum (subcollection `replies`)
2. Implementasi tracking responder location real-time
3. Implementasi ETA calculation
4. Implementasi offline caching dengan SQLite
5. Implementasi push notification untuk iOS

