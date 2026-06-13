# Rencana Implementasi QuickTurn Mobile (React ke Flutter)

Dokumen ini menjelaskan rancangan arsitektur, spesifikasi layar (input/output data), sistem desain (theming), serta implementasi pemrograman mobile optimal untuk memindahkan web frontend React **QuickTurn** menjadi aplikasi mobile menggunakan **Flutter**.

---

## 1. Arsitektur & Tech Stack Mobile yang Optimal

Untuk menghasilkan aplikasi mobile berkinerja tinggi, aman, dan mudah dipelihara, kita akan menerapkan **Clean Architecture** dengan pendekatan **Feature-First** (fitur demi fitur).

### Tech Stack Utama:
*   **State Management:** `flutter_bloc` (Cubit). Mengapa? Prediktabilitas status yang sangat tinggi, pemisahan logika bisnis (BLoC) dari UI (Widgets) secara bersih, dan sangat efisien untuk pengujian unit.
*   **Networking:** `dio` untuk komunikasi HTTP/REST API. Mendukung interseptor otomatis (untuk menyisipkan header token `Bearer` dan menangani error `401 Unauthorized` / *token refresh* secara terpusat), unggah file dengan indikator progres, dan konfigurasi timeout.
*   **Real-time Chat:** `stomp_dart_client` untuk integrasi WebSocket dengan broker STOMP di backend (menyalin fungsionalitas SockJS + Stomp di React).
*   **Penyimpanan Lokal:** `flutter_secure_storage` untuk menyimpan JWT Access Token dan Refresh Token secara aman (terenkripsi di Keychain/Keystore).
*   **File & Gambar:** `image_cropper` untuk pemotongan foto profil secara langsung di aplikasi, dan `file_picker` untuk memilih file dokumen lamaran atau bukti laporan.

### Struktur Folder Proyek (Feature-First):
```
lib/
├── core/
│   ├── network/          # Dio client, interceptors, WebSocket manager
│   ├── theme/            # QuickTurn Design System, Colors, Styles
│   ├── storage/          # Secure storage wrapper
│   └── utils/            # Validators, formatters
├── features/
│   ├── auth/             # Login, register, OTP verification
│   ├── dashboard/        # Dashboard mahasiswa & UMKM, stats, project list
│   ├── projects/         # Post project, apply, detail, review, submissions
│   ├── chat/             # Chat page, WebSocket integration, attachments
│   ├── profile/          # Edit profile, report bug, delete account
│   └── search/           # Find users & freelancers
└── main.dart
```

---

## 2. Sistem Desain & Visual (Style)

QuickTurn web menggunakan kombinasi **Light Mode Base** dengan aksen **Premium Obsidian** dan efek **Glassmorphism**. Berikut adalah terjemahan token CSS ke dalam ekosistem styling Flutter.

### A. Palet Warna (Palette)
```dart
import 'package:flutter/material.dart';

class QTColors {
  // Base Colors
  static const Color bgPrimary = Color(0xFFF8FAFC);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgTertiary = Color(0xFFF1F5F9);
  
  // Brand Colors
  static const Color brandPrimary = Color(0xFFE11D48); // Rose Pink
  static const Color brandDark = Color(0xFFBE123C);
  static const Color brandLight = Color(0xFFFFF1F2);
  
  // Complexity Accents
  static const Color accentBeginner = Color(0xFF059669);   // Emerald Green
  static const Color accentIntermediate = Color(0xFFF59E0B); // Amber
  static const Color accentExpert = Color(0xFF2563EB);       // Blue
  
  // Dark Premium Accent (Obsidian)
  static const Color darkBase = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF151B28);
  static const Color darkElevated = Color(0xFF1E2433);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textContrast = Color(0xFFFFFFFF);
}
```

### B. Glassmorphism Card Widget Custom
Implementasi Glassmorphism di Flutter dapat dibuat menggunakan widget `BackdropFilter` dikombinasikan dengan border gradasi tipis:
```dart
class QTGlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;

  const QTGlassCard({
    Key? key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.85,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

---

## 3. Spesifikasi Layar (Input Fields & Displayed Data)

Berikut deskripsi lengkap untuk setiap layar utama aplikasi mobile QuickTurn.

### A. Landing / Welcome Screen
Layar penyambung yang memperkenalkan proposisi nilai QuickTurn.
*   **Data yang Ditampilkan:**
    *   Logo QuickTurn (Animasi transisi).
    *   Headline: *"Empowering your digital future."*
    *   Deskripsi singkat micro-internship platform.
    *   Grid Fitur: *Quick Start, Verified Talents, Real Impact, Grow Together*.
*   **Input & Aksi:**
    *   Tombol *"Mulai Sekarang"* -> Navigasi ke **Select Role Screen**.
    *   Tombol *"Sudah punya akun? Masuk"* -> Navigasi ke **Login Screen**.
*   **Style:** Background gradasi dari `darkBase` ke `darkSurface` dengan sentuhan glow neon kemerahan (`brandPrimary`).

### B. Login Screen
Layar autentikasi masuk dengan integrasi pemulihan akun (Lupa Password).
*   **Input Fields (Form):**
    *   `Email` (Teks, keyboard tipe email, ikon amplop di sebelah kiri).
    *   `Password` (Teks tersamar/obscured, tombol ikon mata untuk menampilkan/menyembunyikan).
*   **Input & Aksi:**
    *   Tombol *"Login"* (Merah, dengan animasi loading spinner saat mengirim permintaan).
    *   Tombol *"Forgot password?"* -> Mengaktifkan *Forgot Password Modal/State*.
    *   Tombol *"Masuk dengan Google"* (Integrasi OAuth2 webview atau Google Sign-In SDK).
*   **Alur Lupa Password (Forgot Password):**
    1.  *Input Email:* User memasukkan email tujuan pemulihan.
    2.  *Input OTP:* Memasukkan 6 digit kode verifikasi (Auto-focus otomatis ke kotak berikutnya).
    3.  *Reset Password:* Input `Password Baru` dan konfirmasi sandi baru.
*   **Style:** Desain premium gelap di bagian atas dan form glassmorphism bersih di bagian bawah.

### C. Select Role & Registration Screen
Layar pemilihan akun pendaftaran sebelum masuk ke halaman registrasi data.
*   **Select Role:**
    *   Pilihan Kartu Visual:
        *   **Mahasiswa (Talent):** Ikon Sparkles/Graduation, deskripsi *"Temukan proyek magang terbaik untuk portofoliomu"*.
        *   **UMKM (Client):** Ikon Toko/Building, deskripsi *"Temukan talenta mahasiswa unggulan untuk membantu bisnismu"*.
*   **Form Registrasi (Sama untuk Mahasiswa & UMKM, membedakan tipe Role di API payload):**
    *   `Nama Lengkap / Nama Bisnis` (Teks, validator minimal 3 karakter).
    *   `Alamat Email` (Teks, validator struktur email).
    *   `Password` (Teks tersamar, memiliki indikator kekuatan sandi real-time: Lemah/Sedang/Kuat).
    *   `Konfirmasi Password` (Teks tersamar, validator kecocokan dengan field Password).
    *   `Persetujuan T&C` (Checkbox).
*   **Aksi:** Tombol *"Daftar Akun"* -> Mengirim data ke `/api/auth/register` dan mengarahkan ke halaman login.

### D. Email Verification Screen (OTP)
Diaktifkan jika user belum memverifikasi email saat ingin melamar proyek atau membuat proyek baru.
*   **Data yang Ditampilkan:**
    *   Informasi bahwa email verifikasi telah terkirim.
    *   Email target: `name@example.com`.
    *   Instruksi cara membuka kotak masuk email.
*   **Input & Aksi:**
    *   Tombol *"Kirim Ulang Email Verifikasi"* (Dengan cooldown timer 60 detik sebelum bisa diklik kembali).
    *   Tombol *"Kembali ke Dashboard"* (Batal).

---

### E. Dashboard Mahasiswa (Talent Portal)
Layar utama mahasiswa setelah login untuk mencari proyek dan memantau status lamaran.

| Komponen Dashboard | Data yang Ditampilkan | Input & Aksi | Style |
| :--- | :--- | :--- | :--- |
| **Header** | Foto profil mahasiswa, Nama panggilan, Notifikasi lonceng (menampilkan unread badge). | Ketuk profil -> Navigasi ke **Edit Profile**. | Glassmorphism bar di atas. |
| **Kategori Proyek** | Dropdown pilihan: *All, IT/Web, Desain, Marketing, Video, Writing*. | Mengubah pilihan untuk memfilter proyek secara real-time. | Horizontal chip scrollbar. |
| **Rekomendasi Proyek** | Daftar proyek yang cocok (skor rating pemilik tinggi). | Swipe ke kiri-kanan untuk melihat kartu proyek kompak. | Horizontal list, kartu gradasi modern. |
| **Daftar Cari Proyek** | Daftar semua proyek terbuka yang disortir berdasarkan pelamar terbanyak. | Kolom teks pencarian. Ketuk kartu -> Membuka **Detail Proyek**. | Kartu vertikal (Landscape web model) dengan logo owner, budget, tenggat waktu, complexity chip, dan jumlah pelamar saat ini. |

#### 1. Detail Proyek Modal (Dialog)
*   **Data yang Ditampilkan:**
    *   Judul proyek, Kategori, Status (OPEN, CLOSED).
    *   Budget (Format: `Rp 1.500.000`), Deadline proyek.
    *   Complexity level (`BEGINNER`, `INTERMEDIATE`, `EXPERT`) dengan warna badge yang sesuai.
    *   Durasi estimasi proyek (contoh: 2 minggu).
    *   Deskripsi lengkap proyek dan keahlian yang dibutuhkan (Required Skills sebagai tag-chip).
    *   Informasi UMKM Pemilik (Nama, rating bintang, link menuju profil publik).
*   **Input & Aksi:**
    *   Tombol *"Apply Now"* (jika belum melamar).
    *   Indikator status lamaran: *"Application Pending"* (kuning), *"Rejected"* (merah), atau *"Accepted"* (hijau).

#### 2. Form Lamaran Proyek (Apply Modal)
*   **Input Fields (Form):**
    *   `Your Proposal` (Teks paragraf panjang, penjelasan kesiapan bekerja).
    *   `Your Bid Amount (Rp)` (Angka, placeholder nilai budget default proyek).
*   **Aksi:** Tombol *"Submit Application"* -> API call POST `/api/projects/{id}/apply`.

---

### F. Dashboard UMKM (Client Portal)
Layar utama bagi pelaku usaha untuk mengelola pekerjaan yang mereka buat.

| Komponen Dashboard | Data yang Ditampilkan | Input & Aksi | Style |
| :--- | :--- | :--- | :--- |
| **Welcome Banner** | Nama UMKM, jumlah proyek aktif, jumlah pelamar menunggu. | Tombol merah *"Post Project"* -> Navigasi ke layar pembuatan proyek. | Banner premium dengan background melingkar glowing. |
| **Stats Grid** | 3 Kartu Ringkasan: 1) Total Projects, 2) Completed Projects, 3) Total Applicants. | - | Grid 3 kolom, Glassmorphism card dengan ikon lucu. |
| **My Projects List** | Daftar proyek buatan sendiri dengan status: `OPEN`, `ONGOING`, `DONE`, `CLOSED`, `OVERDUE`. | Ketuk kartu -> Sesuai status proyek untuk melakukan aksi manajemen. | Horizontal scrolling cards (memudahkan navigasi satu baris). |

#### Alur Manajemen Proyek Berdasarkan Status di Aplikasi Mobile:
1.  **Status OPEN (Membuka Lowongan):**
    *   *Aksi:* Menampilkan tombol *"View Applicants"*. Membuka list pelamar.
    *   *Layar Kelola Pelamar:* Menampilkan nama mahasiswa, rating bintang, isi proposal, dan harga penawaran (`bidAmount`).
    *   *Input Aksi:* Tombol hijau *"Accept"* (Terima lamaran) atau tombol abu *"Reject"*.
2.  **Status ONGOING (Pengerjaan):**
    *   *Status:* Menampilkan teks *"Waiting for Submission"* (Menunggu mahasiswa mengumpulkan file).
    *   *Aksi tambahan:* Tombol *"View Contract"* untuk melihat berkas kesepakatan pengerjaan.
3.  **Status DONE (Telah Dikumpulkan):**
    *   *Aksi:* Tombol *"View Submissions"* (Membuka dialog untuk mengunduh tautan file pekerjaan mahasiswa) dan tombol *"Approve and Complete"* untuk menyelesaikan proyek.
4.  **Status CLOSED (Selesai):**
    *   *Aksi:* Jika belum diulas, tampilkan tombol *"Rate Talent"*. Membuka dialog rating bintang (1-5) dan kolom teks komentar/review, lalu panggil API `/api/projects/{id}/review`. Jika sudah diulas, tampilkan rating bintang yang diberikan.
5.  **Status OVERDUE (Terlambat):**
    *   *Aksi:* Kartu dapat diketuk untuk melihat detail pengerjaan, namun tidak ada aksi interaktif (read-only) dengan penanda peringatan keterlambatan merah.

---

### G. Layar Post Project (Khusus UMKM)
Layar pembuatan proyek baru dengan alur multi-step wizard.
*   **Step 1: Informasi Dasar**
    *   `Judul Proyek` (Input teks).
    *   `Kategori` (Pilihan dropdown: *IT / Web, Desain, Marketing, Video, Writing*).
*   **Step 2: Budget & Waktu**
    *   `Budget (Rp)` (Input angka).
    *   `Deadline` (Input pemilih tanggal / *DatePicker*).
    *   `Estimasi Durasi` (Dropdown: *1-3 hari, 1 minggu, 2 minggu, 3-4 minggu, 1-2 bulan, 3+ bulan*).
    *   `Complexity` (Radio button: *Beginner, Intermediate, Expert*).
*   **Step 3: Keahlian & Deskripsi**
    *   `Required Skills` (Input teks keahlian + tombol "Add". Menampilkan tag-chip yang bisa dihapus menggunakan tanda silang).
    *   `Deskripsi Proyek` (Input teks paragraf).
    *   `Instruksi Kerja (Brief Text)` (Teks detail petunjuk bagi pelamar terpilih).
    *   `Attachment` (Tombol unggah file opsional, terintegrasi dengan `file_picker`).
*   **Aksi:** Tombol *"Post Project"* -> POST ke `/api/projects` kemudian unggah lampiran jika ada.

---

### H. Chat / Messaging Screen
Layar pengerjaan real-time komunikasi antara UMKM dan Mahasiswa.
*   **Layar Utama Chat List (Inbox):**
    *   Daftar kontak chat aktif. Menampilkan foto profil lawan bicara, nama kontak, pesan terakhir, unread badge (jumlah pesan belum dibaca), dan informasi judul proyek relasi.
*   **Layar Percakapan (Chat Room):**
    *   *Header:* Foto profil, nama kontak (bisa diketuk untuk membuka Profil Publik), dan sub-header judul proyek pengerjaan.
    *   *Daftar Pesan:* Bubble chat bergaya percakapan. Pesan pengirim di sebelah kanan (warna merah rose), pesan penerima di kiri (warna abu-abu/tertiary).
    *   *Dukungan Lampiran (Attachment):*
        *   Jika pesan memiliki gambar, tampilkan preview gambar langsung yang bisa diketuk untuk fullscreen.
        *   Jika file dokumen (PDF/ZIP), tampilkan ikon berkas, nama file, ukuran berkas, dan tombol unduh.
    *   *Input Area:* Kolom teks pesan, tombol klip kertas (pilih file/gambar via picker), tombol kirim (ikon pesawat kertas).
*   **Implementasi Mobile Optimal:**
    *   Menggunakan WebSocket STOMP client untuk mendengarkan pesan masuk baru secara background selama layar terbuka.
    *   State diatur menggunakan BLoC dengan event `MessageReceived` untuk memperbarui list percakapan secara instan tanpa memuat ulang API riwayat.

---

### I. Profile & Settings Screen
Layar pengaturan data profil pengguna.
*   **Aparatus Unggah Foto Profil:**
    *   Menampilkan avatar lingkaran besar. Saat diketuk, membuka opsi kamera/galeri, lalu dialihkan ke plugin crop dengan rasio 1:1 sebelum dikirim ke API `/api/files/profile-picture` secara asinkron.
*   **Form Data Profil (Mahasiswa):**
    *   `Full Name`, `Headline`, `Bio`, `University`, `Years of Experience`, `Availability` (Dropdown status), `Skills` (Kombinasi teks chip), `Location` (Kota, Negara), `Phone Number`, `Portfolio URL`, `LinkedIn Profile`, `GitHub Profile`.
*   **Form Data Profil (UMKM):**
    *   `Business Name`, `Headline/Tagline`, `About Your Business`, `Company/Organization`, `Location`, `Phone Number`, `Business Address`, `Business Website`, `Social Media Links` (Instagram, YouTube, Facebook).
*   **Layanan Laporkan Masalah (Report Issue Modal):**
    *   `Jenis Laporan` (Dropdown: *BUG, CONTRACT_ISSUE, USER_COMPLAINT, PAYMENT_ISSUE, OTHER*).
    *   `Subjek` & `Deskripsi Permasalahan`.
    *   `Bukti Gambar` (Pilih gambar screenshot dari galeri).
*   **Fitur Hapus Akun (Delete Account):**
    *   Memanggil API GET `/api/users/account/delete-confirmation` untuk mengambil teks frasa konfirmasi unik backend.
    *   User harus mengetikkan frasa tersebut persis sebelum tombol *"Hapus Akun Saya"* menjadi aktif untuk menghindari tindakan tidak sengaja.

---

## 4. Rekomendasi Alur UX Mobile yang Mulus

1.  **Autentikasi Biometrik:** Manfaatkan `local_auth` di Flutter agar pengguna yang sudah login dapat masuk ke dashboard menggunakan FaceID atau pemindai sidik jari tanpa mengetik sandi berulang kali.
2.  **Pull-to-Refresh:** Gunakan widget `RefreshIndicator` di setiap daftar proyek dan chat list untuk penyegaran data instan secara alami di platform mobile.
3.  **Caching Gambar:** Gunakan package `cached_network_image` untuk merender gambar avatar profil dan attachment chat guna menghemat kuota internet pengguna dan mempercepat pemuatan halaman.
4.  **Local Notification:** Jika ada pesan chat masuk atau status proyek berubah saat aplikasi tidak aktif, kirimkan pemberitahuan lokal terintegrasi dengan Firebase Cloud Messaging (FCM).
