# Penyamaran di Windows

Isi folder ini (simpan ketiganya dalam **satu folder** yang sama, misalnya `Documents\screen-mask`):

| File | Fungsi |
| --- | --- |
| `chat.ico` | Ikon balon chat hijau pengganti ikon Claude |
| `mask.ahk` | Ganti ikon & judul jendela Claude jadi "Chat", plus tombol cepat minimize/sembunyi |
| `buat-shortcut.ps1` | Membuat shortcut "Chat" berikon baru di Desktop, dan menjalankan `mask.ahk` otomatis saat Windows menyala |

## Langkah

1. Instal **AutoHotkey v2** dari autohotkey.com.
2. Klik dua kali `mask.ahk`. Ikon balon chat muncul di system tray.
3. Klik kanan `buat-shortcut.ps1` > **Run with PowerShell**.
   Kalau diblokir, buka PowerShell di folder itu lalu jalankan:
   `powershell -ExecutionPolicy Bypass -File .\buat-shortcut.ps1`
4. Di taskbar: klik kanan ikon Claude lama > **Unpin**, lalu buka shortcut **Chat** dari Desktop, klik kanan ikonnya di taskbar > **Pin to taskbar**.

## Tombol cepat

| Tombol | Hasil |
| --- | --- |
| `Ctrl+Shift+Spasi` | Minimize / munculkan lagi jendela Claude |
| `Ctrl+Shift+H` | Sembunyikan total (tidak ada di taskbar) / munculkan lagi |

Aplikasi tetap berjalan, percakapan tidak hilang. Kalau `mask.ahk` ditutup dari tray, jendela yang disembunyikan otomatis muncul lagi.

## Catatan

- Ikon di title bar, Alt+Tab, dan tombol taskbar diganti selama `mask.ahk` berjalan. Pada beberapa versi Windows, ikon taskbar yang di-pin tetap mengikuti ikon shortcut, karena itu langkah 4 perlu.
- Logo di **dalam** jendela aplikasi (misalnya di layar sambutan) tidak bisa diganti dari luar.
- Script mengenali Claude dari nama prosesnya, `claude.exe`. Kalau nama proses di komputer Anda berbeda (cek di Task Manager), ubah baris `TARGET` di `mask.ahk`.
