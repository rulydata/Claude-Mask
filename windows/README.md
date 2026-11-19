# Penyamaran di Windows (tanpa install, tanpa admin)

Simpan semua file ini dalam **satu folder** yang sama, misalnya `Documents\screen-mask`.

| File | Fungsi |
| --- | --- |
| `settings.ico` | Ikon roda gigi abu-abu pengganti ikon Claude |
| `mask.ps1` | Ganti ikon & judul jendela Claude jadi "Settings", plus tombol cepat minimize/sembunyi |
| `buat-shortcut.ps1` | Membuat shortcut "Settings" berikon roda gigi di Desktop, dan menjalankan `mask.ps1` otomatis saat Windows menyala |
| `mask.ahk` | Versi AutoHotkey (opsional, hanya kalau AutoHotkey terpasang) |

## Langkah

1. Klik kanan `buat-shortcut.ps1` > **Run with PowerShell**.
   Kalau diblokir, buka PowerShell di folder itu lalu jalankan:
   `powershell -ExecutionPolicy Bypass -File .\buat-shortcut.ps1`
2. Di taskbar: klik kanan ikon Claude lama > **Unpin from taskbar**.
3. Buka Claude dari shortcut **Settings** di Desktop, lalu klik kanan ikonnya di taskbar > **Pin to taskbar**.

## Tombol cepat

| Tombol | Hasil |
| --- | --- |
| `Ctrl+Shift+Spasi` | Minimize / munculkan lagi jendela Claude |
| `Ctrl+Shift+H` | Sembunyikan total (tidak ada di taskbar) / munculkan lagi |
| `Ctrl+Shift+Q` | Matikan helper (jendela yang disembunyikan muncul lagi) |

Aplikasi tetap berjalan, percakapan tidak hilang.
