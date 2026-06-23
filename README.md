# EasySell POS – Terminal Kasir Pintar (Flutter & Firebase)

EasySell POS adalah aplikasi Point of Sale (POS) modern, cepat, dan handal yang dirancang khusus untuk bisnis retail dan e-commerce. Aplikasi ini dibuat menggunakan **Flutter** untuk antarmuka pengguna yang responsif serta **Firebase Firestore & Authentication** untuk sinkronisasi data cloud secara langsung dan aman.

## Fitur Utama

-   **Sinkronisasi Real-Time**: Integrasi langsung dengan Firebase Firestore agar data penjualan dan inventaris selalu terbarui seketika.
-   **Offline/Guest Mode (Hive Cache)**: Dilengkapi dengan database offline lokal (Hive) sehingga transaksi tetap dapat berjalan dengan lancar saat koneksi internet terputus.
-   **Manajemen Inventaris (Stock Catalog)**: Manajemen stok barang lengkap dengan kode SKU, barcode, klasifikasi kategori, harga pokok (cost), harga jual (sell), dan level peringatan stok menipis (*low stock alert*).
-   **Terminal Kasir & Checkout**: Proses transaksi yang mudah dan intuitif dengan fitur penambahan diskon, perhitungan pajak otomatis, simulasi pemindaian barcode (*barcode scanning simulation*), kalkulator uang kembalian, serta integrasi multi-metode pembayaran (Cash, Card, QR, Mobile Pay).
-   **Riwayat Transaksi & Retur (Refund)**: Catatan riwayat transaksi penjualan yang detail disertai fitur pengembalian dana (*refund*) yang otomatis mengembalikan jumlah stok barang ke rak penyimpanan gudang.
-   **Analisis Dashboard Statis & Interaktif**: Visualisasi grafik porsi pendapatan per kategori dan performa penjualan outlet untuk memonitor kesehatan finansial bisnis.

---

## Prasyarat Setup Sistem Luar (System Requirements)

Pastikan lingkungan kerja (*development environment*) Anda telah terinstal tools berikut:

1.  **Flutter SDK**: Versi **3.19.0** atau yang lebih baru. ([Panduan instalasi Flutter](https://docs.flutter.dev/get-started/install))
2.  **Dart SDK**: Versi **3.0.0** atau yang lebih baru.
3.  **Android Studio / VS Code**: Lengkap dengan ekstensi Flutter & Dart terinstal.
4.  **Firebase Project**: Akun Firebase aktif dengan Firestore Database dan Email/Password Authentication yang sudah diaktifkan.

---

## Langkah Instalasi & Menjalankan Aplikasi

Ikuti langkah-langkah di bawah ini untuk mengunduh, mengonfigurasi, dan menjalankan aplikasi EasySell POS di laptop/komputer Anda:

### 1. Clone Repositori
Clone proyek ini dari repositori GitHub Anda:
```bash
git clone https://github.com/USERNAME-ANDA/NAMA-REPOSITORI.git
cd NAMA-REPOSITORI
```

### 2. Instalasi Dependensi
Jalankan perintah berikut pada terminal di folder root project untuk mengunduh seluruh dependensi paket Flutter yang dibutuhkan (seperti `provider`, `cloud_firestore`, `firebase_core`, `hive`, dll.):
```bash
flutter pub get
```

### 3. Konfigurasi Hubungan Firebase
Aplikasi ini dikonfigurasi menggunakan Firebase. Agar dapat berjalan dengan Firebase DB Anda sendiri, pasang konfigurasi platform khusus Anda:

-   **Untuk Android**:
    1. Buat aplikasi Android baru di Firebase Console Anda dengan nama paket (*package name*) yang sesuai (contoh: `com.example.easysell`).
    2. Unduh file `google-services.json`.
    3. Tempatkan file tersebut di direktori: `android/app/google-services.json`.

-   **Untuk iOS**:
    1. Buat aplikasi iOS baru di Firebase Console.
    2. Unduh file `GoogleService-Info.plist`.
    3. Tempatkan plist tersebut di direktori: `ios/Runner/GoogleService-Info.plist`.

-   **Menggunakan FlutterFire CLI (Direkomendasikan)**:
    Instal FlutterFire CLI di komputer Anda lalu jalankan perintah otomatis berikut untuk mengonfigurasi Firebase secara universal:
    ```bash
    flutterfire configure
    ```

### 4. Menjalankan Aplikasi di Perangkat / Emulator
Pastikan perangkat fisik (HP) atau emulator aktif telah terdeteksi oleh sistem dengan perintah:
```bash
flutter devices
```

Jalankan aplikasi menggunakan salah satu cara berikut:

-   **Via Terminal**:
    ```bash
    flutter run
    ```
-   **Via VS Code**: Tekan kunci `F5` atau klik tombol **Run and Debug** di editor Anda.

---

## Struktur Folder Proyek

Proyek ini dibangun menggunakan arsitektur modular Flutter yang rapi dan terstruktur:

```text
├── assets/                  # Aset statis seperti gambar atau font
├── lib/
│   ├── main.dart            # Titik masuk (entry point) aplikasi & inisialisasi modul
│   ├── models/              # Kelas data model bisnis
│   │   ├── business_profile.dart
│   │   ├── product.dart
│   │   └── sale.dart
│   ├── screens/             # Skema tampilan antarmuka (UI Pages)
│   │   ├── login_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── inventory_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── history_screen.dart
│   │   └── settings_screen.dart
│   └── services/            # Logika bisnis & integrasi Firebase (FirebaseService Provider)
│       └── firebase_service.dart
├── pubspec.yaml             # List dependensi eksternal proyek Flutter
└── README.md                # Dokumentasi petunjuk penggunaan aplikasi
```

---

## Cara Ekspor & Deploy ke GitHub dari AI Studio

Untuk meng-upload atau melakukan sinkronisasi project ini ke akun GitHub Anda secara langsung dari platform **Google AI Studio**, Anda bisa menggunakan fitur bawaan platform dengan cara berikut:

1.  **Ekspor Melalui Settings**:
    - Klik ikon gerigi / **Settings** di pojok kanan atas lingkungan kerja Google AI Studio Anda.
    - Pilih opsi **Export to GitHub** atau **Download ZIP**.
    - Jika memilih ekspor langsung ke GitHub, Anda akan diminta untuk menghubungkan (*authenticate*) akun GitHub Anda, lalu platform akan membuat repositori baru secara otomatis.

2.  **Mengunggah Secara Manual**:
    Apabila Anda mengunduh dalam bentuk file ZIP terlebih dahulu:
    - Ekstrak file ZIP di komputer Anda.
    - Jalankan serangkaian perintah Git berikut di terminal komputer Anda:
      ```bash
      git init
      git add .
      git commit -m "Inisialisasi EasySell POS Production Grade"
      git branch -M main
      git remote add origin https://github.com/username_github_anda/nama_repo.git
      git push -u origin main
      ```

---

*EasySell POS dibangun dengan kepatuhan tinggi terhadap performa, keamanan, dan keindahan pengalaman pengguna.*
