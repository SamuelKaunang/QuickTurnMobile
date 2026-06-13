# API Structure

## General Response Structure
```json
{
    "success": true,
    "message": "Admin profile retrieved successfully",
    "data": {}
}
```

## 1. AUTHENTICATION & USER MANAGEMENT

### Register User
**REQUEST**
```json
{
    "nama": "Samuel Yohanes",
    "email": "samuel@example.com",
    "password": "P@ssw0rd123",
    "role": "MAHASISWA" // bisa "UMKM" atau "ADMIN"
}
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "User registered successfully",
    "data": {
        "id": 101,
        "nama": "Samuel Yohanes",
        "email": "samuel@example.com",
        "role": "MAHASISWA"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "Email is already registered",
    "data": {}
}
```

### Login
**REQUEST**
```json
{
    "email": "samuel@example.com",
    "password": "P@ssw0rd123"
}
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "accessToken": "eyJhbGciOiJIUzI1...",
        "tokenType": "Bearer",
        "expiresIn": 3600
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "Invalid email or password",
    "data": {}
}
```

### Get Profile
**REQUEST**
```text
GET /api/users/{id} → nggak butuh body
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "User profile retrieved successfully",
    "data": {
        "id": 101,
        "nama": "Samuel Yohanes",
        "email": "samuel@example.com",
        "role": "MAHASISWA",
        "skills": ["React", "Spring Boot"],
        "portfolio": ["link1", "link2"]
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "User not found",
    "data": {}
}
```

## 2. PROJECT MARKETPLACE

### Post Project (UMKM)
**REQUEST**
```json
{
    "judul": "Website Katalog Produk",
    "deskripsi": "Butuh website katalog max 20 item",
    "budget": 1000000,
    "deadline": "2025-10-15",
    "kategori": "Web Development"
}
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Project posted successfully",
    "data": {
        "id": 55,
        "judul": "Website Katalog Produk",
        "budget": 1000000,
        "status": "OPEN"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "Project title and budget are required",
    "data": {}
}
```

### Browse Projects
**REQUEST**
```text
GET /api/projects?status=OPEN&kategori=Web → query params
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Project list retrieved successfully",
    "data": [
        {
            "id": 55,
            "judul": "Website Katalog Produk",
            "budget": 1000000,
            "status": "OPEN"
        }
    ]
}
```

### Apply Project (Mahasiswa)
**REQUEST**
```json
{
    "studentId": 101,
    "proposal": "Saya bisa menyelesaikan dalam 2 minggu"
}
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Application submitted successfully",
    "data": {
        "applyId": 3001,
        "projectId": 55,
        "studentId": 101,
        "status": "PENDING"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "You have already applied for this project",
    "data": {}
}
```

## 3. MATCHING & CONTRACT

### Approve Application (UMKM pilih mahasiswa)
**REQUEST**
```text
PATCH /api/projects/{projectId}/approve/{applyId} → no body
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Application approved, contract created",
    "data": {
        "contractId": 501,
        "projectId": 55,
        "studentId": 101,
        "status": "ONGOING"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "Application not found",
    "data": {}
}
```

## 4. COMMUNICATION SYSTEM

### Send Chat
**REQUEST**
```json
{
    "fromUserId": 101,
    "toUserId": 201,
    "message": "Halo, apakah ada preferensi design?"
}
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Message sent successfully",
    "data": {
        "chatId": 7001,
        "fromUserId": 101,
        "toUserId": 201,
        "message": "Halo, apakah ada preferensi design?",
        "sentAt": "2025-09-25T10:00:00Z"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "Unauthorized to send message",
    "data": {}
}
```

## 5. PAYMENT & TRANSACTION

### Create Payment
**REQUEST**
```json
{
    "projectId": 55,
    "amount": 1000000,
    "paymentMethod": "GOPAY"
}
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Payment created successfully",
    "data": {
        "paymentId": "PMT-78901",
        "projectId": 55,
        "status": "PENDING",
        "paymentUrl": "https://sandbox.midtrans.com/pay/PMT-78901"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "Payment gateway error, please try again",
    "data": {}
}
```

## 6. REVIEW & RATING

### Submit Review
**REQUEST**
```json
{
    "projectId": 55,
    "reviewerId": 201,
    "rating": 5,
    "comment": "Pengerjaan cepat!"
}
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "Review submitted successfully",
    "data": {
        "reviewId": 901,
        "projectId": 55,
        "rating": 5,
        "comment": "Pengerjaan cepat!"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "You already submitted a review for this project",
    "data": {}
}
```

## 7. ADMIN PANEL

### Ban User
**REQUEST**
```text
PATCH /api/admin/users/{id}/ban → no body
```

**RESPONSE SUCCESS**
```json
{
    "success": true,
    "message": "User banned successfully",
    "data": {
        "userId": 101,
        "status": "BANNED"
    }
}
```

**RESPONSE ERROR**
```json
{
    "success": false,
    "message": "User not found",
    "data": {}
}
```
