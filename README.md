<p align="center">
  <img src="https://i.imgur.com/your_logo_url.png" alt="Logo Inni Dawet" width="120" />
</p>

<h1 align="center">Inni Dawet POS</h1>

<p align="center">
  Aplikasi Point of Sale (POS) modern berbasis Flutter & GetX.<br>
  Dibuat untuk kecepatan transaksi, efisiensi kasir, dan pengalaman pengguna yang menyenangkan.
</p>

<p align="center">
  <a href="#✨-fitur-utama"><strong>Fitur</strong></a> ·
  <a href="#🛠️-stack-teknologi"><strong>Teknologi</strong></a> ·
  <a href="#🚀-memulai"><strong>Instalasi</strong></a> ·
  <a href="#📂-struktur-proyek"><strong>Struktur</strong></a>
</p>

<p align="center">
  <img alt="Flutter Version" src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img alt="State Management" src="https://img.shields.io/badge/State%20Management-GetX-purple?logo=getx" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green" />
</p>

---

## ✨ Fitur Utama

| 💡 | Fitur | Deskripsi |
|:--:|-------|-----------|
| 📱 | **Halaman Kasir Intuitif** | UI kasir yang bersih dan cepat, meminimalisir kesalahan saat transaksi. |
| 🔍 | **Pencarian Real-time** | Cari produk secara instan dengan pencarian yang responsif dan efisien. |
| 🗂️ | **Filter Kategori Dinamis** | Navigasi kategori yang interaktif menggunakan tab horizontal. |
| 🛒 | **Manajemen Keranjang Cerdas** | Keranjang pesanan dengan fitur tambah/kurang produk dalam `BottomSheet`. |
| 🎨 | **Antarmuka Modern & Interaktif** | Dilengkapi *Shimmer*, *Staggered Animation*, dan *Haptic Feedback*. |
| 🧱 | **Struktur GetX Pattern** | Arsitektur scalable & maintainable dengan dependency injection. |

---

## 🛠️ Stack Teknologi

| Kategori | Paket / Teknologi | Fungsi |
|---------|-------------------|--------|
| **Framework** | `Flutter` | Basis pengembangan aplikasi multiplatform. |
| **State Management** | `GetX` | Mengelola state, route, dan dependency injection. |
| **Font & Aset** | `google_fonts`, `flutter_gen_runner` | Tipografi dan manajemen aset otomatis. |
| **Animasi & UI** | `shimmer`, `flutter_staggered_animations` | Efek loading modern dan transisi UI yang halus. |
| **Utility** | `intl`, `equatable` | Format angka & perbandingan objek. |

---

## 🚀 Memulai

### ✅ Prasyarat

- Flutter SDK **3.x** atau terbaru
- IDE seperti **VS Code** atau **Android Studio**
- Emulator atau perangkat fisik

### 📦 Instalasi

1. Clone proyek ini:
    ```bash
    git clone https://github.com/username/pos_app.git
    cd pos_app
    ```

2. Install dependency:
    ```bash
    flutter pub get
    ```

3. Generate file aset:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4. Jalankan aplikasi:
    ```bash
    flutter run
    ```

---

## 📂 Struktur Proyek

```
lib/
├── app/
│   ├── core/           # Konfigurasi umum (tema, warna, style)
│   ├── data/           # Model, provider, repository
│   ├── modules/        # Modularisasi fitur per halaman
│   │   └── home/
│   │       ├── bindings/
│   │       ├── controllers/
│   │       ├── views/
│   │       └── widgets/
│   └── routes/         # Konfigurasi routing GetX
├── gen/                # File auto-generated (flutter_gen)
└── main.dart           # Titik awal aplikasi
```

---

## 📜 Lisensi

Aplikasi ini dilisensikan di bawah [MIT License](LICENSE).

---

<p align="center">
  Dibuat dengan ❤️ oleh tim Inni Dawet menggunakan Flutter.
</p>
