# screen-mask

Menyamarkan tampilan sesi jadi seperti aplikasi chat (mode gelap), sehingga dari jauh terlihat seperti sedang chatting dengan kontak:
- Pesan Anda tampil sebagai balon hijau di kanan dengan centang dua; balasan sebagai balon gelap di kiri dengan nama kontak.
- Latar pola doodle tipis, warna hijau-kebiruan gelap.
- Animasi kerja diganti "mengetik…"; baris alat (Bash, Read, dll.) disamarkan jadi "📄 Dokumen".
- `/mask` menyalakan/mematikan penyamaran; `/mask nama <nama>` mengganti nama kontak (default: Rina).

Desain orisinal, tidak memakai logo, nama, atau aset aplikasi chat mana pun. Hanya berlaku di aplikasi desktop & mobile.

## Tirai

Tombol **Tutup tirai** di atas kotak ketik (atau `/tirai`) mengganti isi semua pesan jadi `• • • • • •`. Percakapan tidak dihapus; tekan **Buka tirai** untuk menampilkannya lagi.

## Instal

Di aplikasi desktop: klik **+** di samping kotak ketik > **Plugins** > **Add marketplace**, isi `rulydata/Claude-Mask`, lalu **Add plugin** > `screen-mask`.

Dari terminal Claude Code:

```
/plugin install screen-mask --marketplace rulydata/Claude-Mask
```
