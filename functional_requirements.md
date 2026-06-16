# Functional Requirements Spec (QuickTurn)

Dokumen ini mendokumentasikan seluruh **Kebutuhan Fungsional (Functional Requirements)** yang telah diimplementasikan dalam kode sumber (source code) platform **QuickTurn**, baik pada sisi **Java Backend (Spring Boot)** maupun **Frontend Mobile (Flutter)**. 

*(Catatan: Modul khusus Administrator/Admin Panel telah dikecualikan sesuai permintaan).*

---

## 1. AUTHENTICATION & USER MANAGEMENT (FR-01)

Sistem autentikasi mengelola akses pengguna berdasarkan peran (*role-based access control*), keamanan data akun, dan validasi kredensial.

*   **FR-01.1: Registrasi Akun Baru (Register)**
    *   Pengguna dapat mendaftar dengan menginput `nama`, `email`, `password` (dengan validasi kecocokan sandi), dan memilih peran akun: **MAHASISWA (Talent)** atau **UMKM (Client)**.
    *   Sistem memvalidasi agar email unik dan belum pernah terdaftar sebelumnya di database.
*   **FR-01.2: Masuk Akun (Login Kredensial)**
    *   Pengguna dapat masuk menggunakan email dan password terdaftar.
    *   Sistem memvalidasi kredensial menggunakan Spring Security dan mengembalikan JWT Access Token serta informasi `role` pengguna.
*   **FR-01.3: Autentikasi Pihak Ketiga (Google OAuth2)**
    *   Pengguna dapat masuk atau mendaftar menggunakan akun Google secara instan.
    *   Jika pengguna Google baru pertama kali login, sistem akan menahan dan mengarahkan ke halaman khusus pemilihan role (**Select Role**) terlebih dahulu sebelum akun aktif sepenuhnya.
*   **FR-01.4: Pemulihan Sandi (Lupa & Reset Password)**
    *   Pengguna dapat meminta reset password dengan menginput email terdaftar. Sistem akan mengirimkan 6-digit kode OTP verifikasi ke email pengguna.
    *   Pengguna memverifikasi kode OTP tersebut untuk mendapatkan `resetToken`.
    *   Pengguna menukar `resetToken` dengan password baru untuk mereset sandi akun.
*   **FR-01.5: Verifikasi Alamat Email (Email Verification)**
    *   Sistem mengirimkan email verifikasi otomatis berisi token tautan (*link* verifikasi) setelah registrasi.
    *   Pengguna wajib memverifikasi email terlebih dahulu sebelum diizinkan membuat proyek baru (UMKM) atau mengajukan lamaran proyek (Mahasiswa).

---

## 2. PROFILE MANAGEMENT (FR-02)

Setiap peran pengguna memiliki struktur dan pengelolaan data profil yang berbeda untuk mendukung fungsi mikro-magang.

### A. Pengguna Peran: Mahasiswa (Talent)
*   **FR-02.1: Pembaruan Profil Mandiri (Talent Profile)**
    *   Dapat memperbarui informasi diri: `Nama Lengkap`, `Headline`, `Bio/Deskripsi`, `Universitas`, `Tahun Pengalaman`, `Lokasi` (Kota & Negara), `Nomor Telepon`, dan `Status Ketersediaan` (*Full-time, Part-time, Freelance*).
*   **FR-02.2: Pengelolaan Keahlian & Tautan**
    *   Dapat menambahkan tag keahlian (*Skills* dalam bentuk format teks dipisah koma yang diterjemahkan menjadi list chip).
    *   Dapat mencantumkan tautan `Portfolio URL`, profil `LinkedIn`, dan profil `GitHub`.

### B. Pengguna Peran: UMKM (Client)
*   **FR-02.3: Pembaruan Profil Bisnis (Business Profile)**
    *   Dapat memperbarui profil usaha: `Nama Bisnis`, `Tagline`, `Tentang Usaha (Bio)`, `Nama Perusahaan/Organisasi`, `Alamat Fisik`, `Nomor Telepon`, dan `Website Bisnis`.
*   **FR-02.4: Jejaring Sosial Bisnis**
    *   Dapat mencantumkan tautan media sosial bisnis: `Instagram`, `YouTube`, dan `Facebook`.

### C. Fitur Profil Umum
*   **FR-02.5: Unggah Foto Profil (Profile Picture)**
    *   Pengguna dapat mengambil foto dari galeri/kamera, memotong foto (*crop* dengan rasio 1:1), dan mengunggahnya. Sistem menyimpan file gambar secara cloud di Azure Blob Storage dan memperbarui URL foto profil pengguna.
*   **FR-02.6: Pengubahan Nama Pengguna (Username)**
    *   Pengguna dapat menyetel atau mengubah username unik (dengan validasi format alfanumerik & underscore sepanjang 3-30 karakter).
*   **FR-02.7: Melihat Profil Publik (Public Profile)**
    *   Pengguna dapat mencari dan membuka halaman profil publik pengguna lain untuk melihat rating rata-rata, statistik proyek selesai, bio, skill, portofolio, dan riwayat ulasan yang pernah diterima.
*   **FR-02.8: Penghapusan Akun Secara Mandiri (Delete Account)**
    *   Pengguna dapat menghapus akunnya secara permanen.
    *   Sistem mewajibkan pengguna mengetik frasa konfirmasi yang didapatkan secara dinamis dari API (*"Saya mengerti bahwa akun saya akan dihapus permanen..."*) sebelum tombol hapus aktif guna mencegah kecelakaan klik.
    *   Proses hapus akun akan: menghapus foto profil dari Azure Storage, menganonimkan pesan chat, dan mengubah status akun menjadi tidak aktif (terhapus).

---

## 3. PROJECT MARKETPLACE & MANAGEMENT (FR-03)

Modul utama yang menjembatani kebutuhan proyek digital UMKM dengan keahlian pengerjaan Mahasiswa.

### A. Alur Pembuatan Proyek (UMKM)
*   **FR-03.1: Posting Proyek Baru**
    *   Dapat memposting proyek dengan rincian: `Judul`, `Kategori` (Web Dev, Design, dll), `Budget (Rp)`, `Tenggat Waktu (Deadline)`, `Estimasi Durasi`, `Tingkat Kompleksitas` (*Beginner/Intermediate/Expert*), `Keahlian yang Dibutuhkan` (*Required Skills*), `Deskripsi Proyek`, dan `Instruksi Kerja (Brief)*.
*   **FR-03.2: Unggah Lampiran Proyek**
    *   Dapat mengunggah berkas/dokumen pendukung pengerjaan proyek ke Azure Blob Storage saat pembuatan proyek.

### B. Alur Pencarian & Pengajuan Lamaran (Mahasiswa)
*   **FR-03.3: Jelajah Proyek (Browse Projects)**
    *   Dapat melihat daftar proyek berstatus `OPEN` lengkap dengan estimasi budget, deadline, nama UMKM pemilik, tag keahlian, dan jumlah pelamar saat ini.
*   **FR-03.4: Sistem Rekomendasi Berbasis AI (Recommendation)**
    *   Dashboard mahasiswa menampilkan proyek yang direkomendasikan secara cerdas berdasarkan kecocokan bidang keahlian di profil mahasiswa dengan keahlian yang dibutuhkan proyek.
*   **FR-03.5: Melamar Proyek (Apply Project)**
    *   Dapat mengajukan lamaran ke proyek aktif dengan menginput pesan proposal penawaran serta nilai harga tawaran pengerjaan (*bidAmount*). Pengguna tidak dapat melamar proyek yang sama dua kali.

### C. Alur Kontrak & Pengerjaan Proyek (Ongoing)
*   **FR-03.6: Seleksi Pelamar & Kontrak Digital**
    *   UMKM dapat melihat daftar mahasiswa yang melamar proyeknya (proposal dan nominal bid-nya).
    *   UMKM dapat memutuskan untuk **Menerima (Accept)** pelamar terpilih. Penerimaan otomatis memicu pembuatan kontrak digital sederhana, mengubah status proyek menjadi `ONGOING`, menetapkan mahasiswa tersebut sebagai pekerja, dan menolak pelamar lainnya.
    *   UMKM dapat **Menolak (Reject)** pelamar secara manual sebelum memilih pemenang.
*   **FR-03.7: Lihat Brief Proyek Terkunci**
    *   Mahasiswa yang diterima dapat mengakses instruksi kerja detail (*Brief*) dan lampiran berkas proyek yang diunggah oleh UMKM (akses ini ditutup untuk pelamar lain).

### D. Alur Pengumpulan & Penutupan Proyek (Done/Closed)
*   **FR-03.8: Pengumpulan Hasil Kerja (Submit Work)**
    *   Mahasiswa dapat mengumpulkan hasil pekerjaan dengan menuliskan deskripsi, mencantumkan tautan hasil kerja (*finishingLink* seperti URL GitHub/Figma), serta mengunggah file hasil kerja ke sistem storage. Status proyek berubah menjadi `DONE`.
*   **FR-03.9: Konfirmasi Penyelesaian Proyek (Close Project)**
    *   UMKM dapat meninjau kiriman hasil kerja mahasiswa dan melakukan konfirmasi penyelesaian. Konfirmasi ini akan mengakhiri masa kontrak dan memindahkan status proyek menjadi `CLOSED` (selesai).

---

## 4. COMMUNICATION / CHAT SYSTEM (FR-04)

Sistem komunikasi real-time terintegrasi untuk mendukung kolaborasi selama proyek berjalan.

*   **FR-04.1: Obrolan Real-time (WebSocket Chatting)**
    *   Mahasiswa dan UMKM yang memiliki proyek aktif (`ONGOING` / `APPROVED` application) dapat bertukar pesan teks secara real-time menggunakan koneksi WebSocket (STOMP).
*   **FR-04.2: Unggah Berkas Obrolan (Chat Attachment)**
    *   Pengguna dapat mengirimkan lampiran file (foto/dokumen kerja) di dalam chat room. File diunggah terlebih dahulu ke Azure Storage, kemudian URL dan metadatanya dikirimkan via pesan WebSocket.
*   **FR-04.3: Daftar Kontak & Riwayat Chat**
    *   Sistem mengurutkan kontak chat aktif berdasarkan waktu pesan terbaru dan jumlah pesan belum dibaca.
    *   Riwayat chat disimpan secara persisten di database MongoDB dan dapat dimuat ulang (mendukung paginasi / *paged history*).
*   **FR-04.4: Penghitung Pesan Belum Dibaca (Unread Count)**
    *   Sistem menghitung dan menampilkan lencana merah (*unread badge count*) untuk setiap pesan yang masuk dari lawan bicara saat ruang chat ditutup. Pengguna dapat menandai pesan sebagai telah dibaca secara manual atau otomatis saat ruang chat dibuka.

---

## 5. REVIEW & RATING SYSTEM (FR-05)

Ulasan timbal balik untuk memastikan kualitas dan transparansi platform.

*   **FR-05.1: Ulasan Dua Arah (Two-Way Review)**
    *   Setelah proyek ditutup (`CLOSED`), UMKM wajib memberikan penilaian berupa rating bintang (1-5) dan testimoni ulasan kepada mahasiswa.
    *   Mahasiswa juga dapat mengirimkan ulasan penilai kepada UMKM.
*   **FR-05.2: Kalkulasi Skor Reputasi**
    *   Sistem secara otomatis menghitung ulang nilai rata-rata rating (*Average Rating*) dan jumlah review (*Total Reviews*) pengguna yang langsung disinkronkan ke profil publik mereka.

---

## 6. NOTIFICATION & ANNOUNCEMENT (FR-06)

*   **FR-06.1: Notifikasi Aktivitas Proyek (Internal Notifications)**
    *   Pengguna mendapatkan pemberitahuan real-time (ikon lonceng) saat terjadi perubahan status proyek (lamaran diterima/ditolak, hasil kerja diserahkan, review baru masuk).
    *   Mendukung penandaan notifikasi sebagai terbaca (*mark as read* per item atau *read-all* sekaligus).
*   **FR-06.2: Pengumuman Global (Announcements)**
    *   Pengguna dapat melihat daftar pengumuman penting/global yang diterbitkan oleh administrator di halaman utama dashboard.

---

## 7. REPORT & COMPLAINT SYSTEM (FR-07)

*   **FR-07.1: Pengaduan Masalah (Submit Report)**
    *   Pengguna dapat mengirimkan laporan pengaduan masalah langsung dari menu pengaturan profil.
    *   Pengaduan dikategorikan berdasarkan tipe: `BUG`, `CONTRACT_ISSUE`, `USER_COMPLAINT`, `PAYMENT_ISSUE`, atau `OTHER`, dengan menyertakan subjek dan deskripsi aduan.
*   **FR-07.2: Unggah Screenshot Bukti (Evidence Upload)**
    *   Pengguna dapat melampirkan screenshot gambar bukti permasalahan (maksimal ukuran 10MB) yang disimpan di cloud Azure untuk mendukung proses investigasi aduan.
*   **FR-07.3: Riwayat Pengaduan Saya (My Reports)**
    *   Pengguna dapat memantau status penanganan aduan mereka (Pending, Investigating, Resolved, Rejected) beserta catatan balasan dari pihak admin.
