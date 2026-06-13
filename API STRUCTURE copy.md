# API Structure Spec (QuickTurn Backend)

Semua response REST API dibungkus oleh format standard `ApiResponse` dengan field berikut:
```json
{
    "success": true,
    "message": "Pesan sukses atau error",
    "data": {} // Isi data spesifik per-endpoint, bernilai null jika error
}
```

---

## 1. AUTHENTICATION & USER MANAGEMENT

### Register User
**REQUEST**
* **URL:** `POST /api/auth/register`
* **Headers:** `Content-Type: application/json`
* **Body:**
```json
{
    "nama": "Samuel Yohanes",
    "email": "samuel@example.com",
    "password": "P@ssw0rd123",
    "role": "MAHASISWA" // "MAHASISWA" atau "UMKM"
}
```

**RESPONSE SUCCESS (201 Created)**
```json
{
    "success": true,
    "message": "Register ok",
    "data": {
        "success": true,
        "message": "Registration successful",
        "accessToken": "eyJhbGciOiJIUzI1...",
        "tokenType": "Bearer",
        "expiresIn": 3600,
        "role": "MAHASISWA"
    }
}
```

**RESPONSE ERROR (400 Bad Request)**
```json
{
    "success": false,
    "message": "Email already registered",
    "data": null
}
```

---

### Login
**REQUEST**
* **URL:** `POST /api/auth/login`
* **Headers:** `Content-Type: application/json`
* **Body:**
```json
{
    "email": "samuel@example.com",
    "password": "P@ssw0rd123"
}
```

**RESPONSE SUCCESS (200 OK)**
```json
{
    "success": true,
    "message": "Login ok",
    "data": {
        "success": true,
        "message": "Login successful",
        "accessToken": "eyJhbGciOiJIUzI1...",
        "tokenType": "Bearer",
        "expiresIn": 3600,
        "role": "MAHASISWA"
    }
}
```

**RESPONSE ERROR (401 Unauthorized)**
```json
{
    "success": false,
    "message": "Invalid email or password",
    "data": null
}
```

---

### Get My Profile
**REQUEST**
* **URL:** `GET /api/users/profile`
* **Headers:** `Authorization: Bearer <token>`

**RESPONSE SUCCESS (200 OK)**
```json
{
    "success": true,
    "message": "Profile data",
    "data": {
        "id": 101,
        "nama": "Samuel Yohanes",
        "email": "samuel@example.com",
        "username": "samuel",
        "role": "MAHASISWA",
        "bio": "Suka koding",
        "skills": "Flutter, Spring Boot",
        "portfolioUrl": "http://github.com/...",
        "location": "Bandung",
        "phone": "08123456789",
        "bidang": "IT",
        "profilePictureUrl": "https://quickturn.blob.core.windows.net/...",
        "averageRating": "4.8",
        "totalReviews": 5,
        "headline": "Junior Dev",
        "university": "ITB",
        "yearsExperience": 1,
        "availability": "Part-Time",
        "address": "Bandung, Indonesia",
        "linkedinUrl": "https://linkedin.com/in/...",
        "githubUrl": "https://github.com/...",
        "youtubeUrl": null,
        "instagramUrl": null,
        "facebookUrl": null,
        "businessWebsite": null
    }
}
```

---

### Get Public Profile by ID
**REQUEST**
* **URL:** `GET /api/users/profile/{userId}`
* **Headers:** `Authorization: Bearer <token>`

**RESPONSE SUCCESS (200 OK)**
```json
{
    "success": true,
    "message": "Public profile",
    "data": {
        "id": 101,
        "nama": "Samuel Yohanes",
        "username": "samuel",
        "role": "MAHASISWA",
        "bio": "Suka koding",
        "skills": "Flutter, Spring Boot",
        "portfolioUrl": "http://github.com/...",
        "location": "Bandung",
        "bidang": "IT",
        "profilePictureUrl": "https://quickturn.blob.core.windows.net/...",
        "averageRating": "4.8",
        "totalReviews": 5,
        "headline": "Junior Dev",
        "university": "ITB",
        "yearsExperience": 1,
        "availability": "Part-Time",
        "linkedinUrl": "https://linkedin.com/in/...",
        "githubUrl": "https://github.com/...",
        "youtubeUrl": null,
        "instagramUrl": null,
        "facebookUrl": null,
        "businessWebsite": null
    }
}
```

---

### Update Profile
**REQUEST**
* **URL:** `PUT /api/users/profile`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Body:** (Kirim field yang ingin diubah saja)
```json
{
    "nama": "Samuel Yohanes Edit",
    "bio": "Deskripsi bio baru",
    "skills": "React Native, Spring Boot",
    "portfolioUrl": "https://samuel.dev",
    "location": "Jakarta",
    "phone": "08987654321",
    "headline": "Mobile Dev",
    "university": "UI",
    "yearsExperience": 2,
    "availability": "Full-Time",
    "address": "Jakarta, Indonesia"
}
```

---

## 2. PROJECT MARKETPLACE

### Post Project (UMKM)
**REQUEST**
* **URL:** `POST /api/projects`
* **Headers:** `Authorization: Bearer <token_umkm>`, `Content-Type: application/json`
* **Body:**
```json
{
    "title": "Website Katalog Produk",
    "description": "Butuh website katalog max 20 item",
    "budget": 1000000,
    "deadline": "2026-10-15",
    "category": "Web Development"
}
```

**RESPONSE SUCCESS (201 Created)**
```json
{
    "success": true,
    "message": "Project berhasil dibuat",
    "data": {
        "id": 55,
        "title": "Website Katalog Produk",
        "description": "Butuh website katalog max 20 item",
        "budget": 1000000,
        "status": "OPEN",
        "category": "Web Development",
        "deadline": "2026-10-15T00:00:00"
    }
}
```

---

### Browse Projects (Status Aware)
**REQUEST**
* **URL:** `GET /api/projects`
* **Headers:** `Authorization: Bearer <token>`

**RESPONSE SUCCESS (200 OK)**
```json
{
    "success": true,
    "message": "All open projects retrieved",
    "data": [
        {
            "id": 55,
            "title": "Website Katalog Produk",
            "budget": 1000000,
            "category": "Web Development",
            "deadline": "2026-10-15",
            "status": "OPEN",
            "ownerName": "UMKM Maju",
            "ownerId": 10,
            "hasApplied": false
        }
    ]
}
```

---

### Apply Project (Mahasiswa)
**REQUEST**
* **URL:** `POST /api/projects/{projectId}/apply`
* **Headers:** `Authorization: Bearer <token_mahasiswa>`, `Content-Type: application/json`
* **Body:**
```json
{
    "proposal": "Saya sanggup membuat web ini dalam waktu 1 minggu menggunakan React.",
    "bidAmount": 950000
}
```

**RESPONSE SUCCESS (201 Created)**
```json
{
    "success": true,
    "message": "Application submitted successfully",
    "data": {
        "id": 3001,
        "projectId": 55,
        "studentId": 101,
        "proposal": "Saya sanggup membuat web ini dalam waktu 1 minggu menggunakan React.",
        "bidAmount": 950000,
        "status": "PENDING"
    }
}
```

---

### Get Applicants (UMKM Lihat Pelamar)
**REQUEST**
* **URL:** `GET /api/projects/{projectId}/applicants`
* **Headers:** `Authorization: Bearer <token_umkm>`

---

### Accept Applicant (UMKM Terima Pelamar)
**REQUEST**
* **URL:** `POST /api/projects/{projectId}/applicants/{appId}/accept`
* **Headers:** `Authorization: Bearer <token_umkm>`

**RESPONSE SUCCESS (200 OK)**
```json
{
    "success": true,
    "message": "Pelamar diterima, project dimulai!",
    "data": null
}
```

---

### Reject Applicant (UMKM Tolak Pelamar)
**REQUEST**
* **URL:** `POST /api/projects/{projectId}/applicants/{appId}/reject`
* **Headers:** `Authorization: Bearer <token_umkm>`

---

### Submit Finishing (Mahasiswa Menyelesaikan Pekerjaan)
**REQUEST**
* **URL:** `POST /api/projects/{projectId}/finish`
* **Headers:** `Authorization: Bearer <token_mahasiswa>`
* **Body:**
```json
{
    "finishingLink": "https://github.com/samuel/katalog-produk"
}
```

---

### Confirm Finishing (UMKM Konfirmasi & Tutup Project)
**REQUEST**
* **URL:** `POST /api/projects/{projectId}/finish/confirm`
* **Headers:** `Authorization: Bearer <token_umkm>`

---

## 3. COMMUNICATION SYSTEM (CHAT)

Sistem komunikasi utama menggunakan **WebSocket** (STOMP) untuk realtime chat, didukung REST API untuk history & upload attachment.

### WebSocket Connection
* **Endpoint Connection:** `/ws-chat`
* **Topic Berlangganan (Incoming):** `/topic/public/{myUserId}`
* **Kirim Message (Outgoing):** `/app/chat.sendMessage`
* **Format Payload:**
```json
{
    "senderId": 101,
    "recipientId": 201,
    "content": "Halo, apakah ada preferensi design?",
    "attachmentUrl": null, // Diisi jika mengirim file
    "attachmentType": null, // "IMAGE" atau "DOCUMENT"
    "originalFilename": null,
    "fileSize": null
}
```

### Get Chat History
* **URL:** `GET /api/chat/history?otherUserId={otherUserId}`
* **Headers:** `Authorization: Bearer <token>`
* **Response Success:** `ApiResponse` berisi list message percakapan antara kedua user.

### Upload Chat Attachment
* **URL:** `POST /api/chat/upload`
* **Headers:** `Authorization: Bearer <token>`
* **Request Params (Multipart):** `file` (MultipartFile), `recipientId` (Long)
* **Response Success:** Mengembalikan URL file dan metadata attachment yang nantinya dikirim via WebSocket payload.

---

## 4. FILE UPLOADS & SUBMISSIONS

### Profile Picture Upload
* **URL:** `POST /api/files/profile-picture`
* **Request (Multipart):** `file` (MultipartFile)
* **Response Success:**
```json
{
    "success": true,
    "message": "Profile picture uploaded successfully",
    "data": {
        "url": "https://quickturn.blob.core.windows.net/profile-pictures/..."
    }
}
```

### Work Submission (Mahasiswa Unggah File Kerja Tambahan)
* **URL:** `POST /api/files/submission/{projectId}`
* **Request Params (Multipart):**
  - `description` (String, optional)
  - `links` (String, optional)
  - `files` (List of MultipartFile, optional)

---

## 5. REVIEW & RATING

### Submit Review
* **URL:** `POST /api/projects/{projectId}/review`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Body:**
```json
{
    "rating": 5,
    "comment": "Pengerjaan cepat!"
}
```

**RESPONSE SUCCESS (200 OK)**
```json
{
    "success": true,
    "message": "Review submitted successfully",
    "data": null
}
```

---

## 6. ADMIN PANEL

### Ban User
* **URL:** `PUT /api/admin/users/{id}/ban`
* **Headers:** `Authorization: Bearer <token_admin>`

### Unban User
* **URL:** `PUT /api/admin/users/{id}/unban`

### Toggle Ban User
* **URL:** `PUT /api/admin/users/{id}/toggle-ban`

### Get All Projects (Admin Audit)
* **URL:** `GET /api/admin/projects`

### Get Project Activity Logs (Admin Audit)
* **URL:** `GET /api/admin/projects/{projectId}/logs`

---

> [!NOTE]
> **PAYMENT GATEWAY (MIDTRANS / GOPAY)**
> Integrasi Payment Gateway Midtrans (GOPAY, Virtual Account, dll.) saat ini **belum diimplementasikan** di sisi Java Backend. Alur transaksi saat ini langsung dari approve pelamar menuju ongoing dan dikonfirmasi manual saat penutupan project.
