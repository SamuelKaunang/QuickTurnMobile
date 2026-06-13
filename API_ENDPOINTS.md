# Daftar Lengkap API Endpoint Backend QuickTurn

Dokumen ini berisi daftar seluruh REST API endpoint dan WebSocket channel yang tersedia di backend Spring Boot untuk digunakan dalam integrasi aplikasi mobile Flutter.

---

## 1. Authentication & User Management (`/api/auth` & `/api/users`)

Mengatur registrasi, login, lupa password, verifikasi email, serta pengelolaan profil pengguna.

| Method | Endpoint | Fungsi |
| :--- | :--- | :--- |
| **POST** | `/api/auth/register` | Mendaftarkan akun baru (Mahasiswa / UMKM) |
| **POST** | `/api/auth/login` | Login pengguna untuk mendapatkan JWT Token |
| **POST** | `/api/auth/forgot-password` | Meminta kode reset password (Lupa Password) |
| **POST** | `/api/auth/verify-reset-code` | Memverifikasi kode reset password OTP |
| **POST** | `/api/auth/reset-password` | Mengatur ulang password dengan password baru |
| **POST** | `/api/auth/select-role` | Memilih/mengonfirmasi peran akun (Role) |
| **GET** | `/api/auth/verify-email` | Memverifikasi alamat email via token/link |
| **POST** | `/api/auth/send-verification` | Mengirim ulang email verifikasi |
| **GET** | `/api/auth/verification-status` | Mengecek status verifikasi email pengguna |
| **GET** | `/api/users/profile` | Mengambil detail profil user yang sedang login |
| **PUT** | `/api/users/profile` | Memperbarui informasi profil user yang login |
| **GET** | `/api/users/search` | Melakukan pencarian user/talent |
| **GET** | `/api/users/profile/{userId}` | Mengambil detail profil user tertentu berdasarkan ID |
| **GET** | `/api/users/profile/username/{username}` | Mengambil detail profil user berdasarkan username |
| **PUT** | `/api/users/username` | Mengubah username pengguna |
| **PUT** | `/api/users/bidang` | Memperbarui bidang keahlian/kategori user |
| **DELETE**| `/api/users/account` | Menghapus akun pengguna secara permanen |
| **GET** | `/api/users/account/delete-confirmation`| Mengambil teks konfirmasi penghapusan akun |

---

## 2. Project & Application Management (`/api/projects`)

Mengatur alur pembuatan proyek (oleh UMKM), pencarian proyek (oleh Mahasiswa), pendaftaran proyek, penerimaan lamaran, hingga proses penyelesaian kerja.

| Method | Endpoint | Fungsi |
| :--- | :--- | :--- |
| **POST** | `/api/projects` | Membuat proyek baru (Khusus UMKM) |
| **GET** | `/api/projects/my-projects` | Mengambil daftar proyek yang dibuat oleh UMKM tersebut |
| **GET** | `/api/projects` | Mengambil semua proyek aktif dengan filter/pencarian |
| **GET** | `/api/projects/recommendations` | Mengambil rekomendasi proyek yang cocok dengan skill |
| **GET** | `/api/projects/participating` | Mengambil proyek yang sedang diikuti mahasiswa |
| **GET** | `/api/projects/{projectId}/applicants` | Mengambil daftar pelamar pada suatu proyek |
| **POST** | `/api/projects/{projectId}/apply` | Mendaftar/melamar ke suatu proyek (Mahasiswa) |
| **POST** | `/api/projects/{projectId}/applicants/{appId}/accept` | Menerima lamaran mahasiswa untuk proyek |
| **POST** | `/api/projects/{projectId}/applicants/{appId}/reject` | Menolak lamaran mahasiswa untuk proyek |
| **POST** | `/api/projects/{projectId}/finish` | Mahasiswa menyatakan pengerjaan proyek selesai |
| **POST** | `/api/projects/{projectId}/finish/confirm` | UMKM menyetujui selesainya proyek |
| **GET** | `/api/projects/{projectId}/finish-status` | Mengecek status penyelesaian proyek |
| **GET** | `/api/projects/{projectId}/contract` | Mengambil detail kontrak digital proyek |
| **POST** | `/api/projects/{projectId}/review` | Memberikan review/rating dua arah setelah proyek selesai |
| **GET** | `/api/projects/{projectId}/my-review` | Mengambil review yang pernah diberikan |
| **GET** | `/api/projects/{projectId}/brief` | Mengambil instruksi pengerjaan (brief) proyek |

---

## 3. Communication System & File Manager (`/api/chat` & `/api/files`)

Menyediakan obrolan real-time via WebSocket, riwayat pesan, kontak, serta media penyimpanan berkas (foto profil, lampiran chat, berkas pengumpulan tugas).

### A. Obrolan Real-time (WebSocket STOMP)
*   **Connection Endpoint:** `ws://10.0.2.2:8080/ws` (Gunakan IP komputer atau domain jika deploy)
*   **Send Message (Publish):** `/app/chat.sendMessage` (Format body berupa JSON pesan)
*   **Receive Message (Subscribe):** `/user/queue/messages` (Untuk menerima pesan secara real-time)

### B. HTTP Chat & File REST API
| Method | Endpoint | Fungsi |
| :--- | :--- | :--- |
| **GET** | `/api/chat/history` | Mengambil riwayat percakapan |
| **GET** | `/api/chat/history/paged` | Mengambil riwayat percakapan dengan sistem halaman (page) |
| **GET** | `/api/chat/unread` | Mengambil jumlah total pesan yang belum dibaca |
| **GET** | `/api/chat/unread/{senderId}` | Mengambil pesan belum dibaca dari pengirim tertentu |
| **POST** | `/api/chat/mark-read` | Menandai pesan chat telah dibaca |
| **POST** | `/api/chat/upload` | Mengunggah file attachment di dalam chat |
| **GET** | `/api/chat/contacts` | Mengambil daftar kontak percakapan aktif |
| **POST** | `/api/chat/start` | Mulai inisiasi percakapan baru dengan pengguna lain |
| **POST** | `/api/files/profile-picture` | Mengunggah/memperbarui foto profil user |
| **POST** | `/api/files/submission/{projectId}` | Mahasiswa mengunggah file bukti pengumpulan proyek |
| **GET** | `/api/files/submissions/{projectId}` | UMKM mengambil daftar file pengumpulan proyek tertentu |
| **GET** | `/api/files/submission/{submissionId}`| Mengambil berkas/download submission berdasarkan ID |
| **POST** | `/api/files/submission/{submissionId}/review`| UMKM menilai/mereview berkas pengumpulan mahasiswa |
| **GET** | `/api/files/my-submissions` | Mahasiswa melihat daftar riwayat pengumpulan berkasnya |
| **DELETE**| `/api/files/{fileId}` | Menghapus file yang pernah diunggah berdasarkan ID |
| **POST** | `/api/files/project-attachment/{projectId}`| UMKM mengunggah file pelengkap brief proyek |

---

## 4. Notifications & User Activity (`/api/notifications` & `/api/activities`)

Mengelola notifikasi sistem kepada user dan mencatat log aktivitas penting.

| Method | Endpoint | Fungsi |
| :--- | :--- | :--- |
| **GET** | `/api/notifications` | Mengambil seluruh daftar notifikasi user |
| **GET** | `/api/notifications/unread` | Mengambil notifikasi yang belum dibaca |
| **GET** | `/api/notifications/count` | Mengambil jumlah notifikasi belum dibaca |
| **PATCH**| `/api/notifications/{id}/read` | Menandai satu notifikasi tertentu sebagai telah dibaca |
| **PATCH**| `/api/notifications/read-all` | Menandai semua notifikasi sebagai telah dibaca |
| **GET** | `/api/activities/recent` | Mengambil log aktivitas terbaru milik user yang login |
| **GET** | `/api/activities` | Mengambil seluruh log aktivitas milik user yang login |

---

## 5. Administration & Moderation (`/api/admin` & `/api/announcements` & `/api/reports`)

Digunakan oleh Administrator untuk memantau sistem, memoderasi user/proyek, dan mengelola pengaduan masalah/isu.

| Method | Endpoint | Fungsi |
| :--- | :--- | :--- |
| **GET** | `/api/admin/users` | Mengambil daftar semua user terdaftar di sistem |
| **DELETE**| `/api/admin/users/{id}` | Menghapus user berdasarkan ID |
| **GET** | `/api/admin/projects` | Mengambil daftar seluruh proyek |
| **GET** | `/api/admin/projects/{projectId}/logs` | Melihat riwayat perubahan/log pada suatu proyek |
| **PUT** | `/api/admin/users/{id}/ban` | Melakukan blokir (ban) pada user tertentu |
| **PUT** | `/api/admin/users/{id}/unban` | Membuka blokir (unban) pada user tertentu |
| **PUT** | `/api/admin/users/{id}/toggle-ban` | Toggle status blokir user |
| **GET** | `/api/announcements` | Mengambil pengumuman sistem yang aktif |
| **POST** | `/api/announcements` | Membuat pengumuman sistem baru |
| **DELETE**| `/api/announcements/{id}` | Menghapus pengumuman berdasarkan ID |
| **POST** | `/api/reports` | Melaporkan masalah/kendala baru |
| **POST** | `/api/reports/{reportId}/evidence` | Mengunggah screenshot/file bukti pelaporan |
| **GET** | `/api/reports/my-reports` | Melihat daftar laporan yang pernah dibuat user |
| **GET** | `/api/reports/{reportId}` | Melihat detail status laporan tertentu |
| **GET** | `/api/reports/admin/all` | Admin: Mengambil seluruh laporan dari semua user |
| **GET** | `/api/reports/admin/status/{status}` | Admin: Mengambil laporan berdasarkan status filter |
| **PUT** | `/api/reports/admin/{reportId}/status`| Admin: Mengubah status penanganan laporan |
| **GET** | `/api/reports/admin/pending-count` | Admin: Mengambil jumlah laporan yang belum ditangani |
