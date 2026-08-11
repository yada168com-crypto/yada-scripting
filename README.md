# Notion Content-Calendar Automation

Perkakas kecil untuk membuat kartu naskah konten di database kalender Notion **langsung lewat API resmi Notion**, bukan lewat klik-klik di tampilan web.

Dipakai untuk alur kerja produksi konten harian: satu kartu = satu naskah video, lengkap dengan properti (tanggal tayang, pilar konten, penulis, sumber, status) dan isi badan halaman yang terbagi ke beberapa bagian tetap.

## Kenapa lewat API, bukan otomasi klik

Otomasi berbasis klik di Notion rapuh:

- halaman sering menggulir sendiri saat blok baru dibuat, sehingga klik berikutnya mendarat di elemen yang salah — paling sering di **judul halaman**, dan judulnya terpotong
- dropdown properti kadang tidak mau terbuka kalau jendela sedang kecil
- ekstensi peramban (mis. penerjemah) memunculkan popup setiap ada seleksi teks dan mencuri fokus

Lewat API, satu kartu lengkap selesai dalam satu panggilan, tanpa satu pun risiko di atas.

## Isi

```
tools/New-NotionCard.ps1      # bikin satu kartu dari satu file JSON
tools/cards/contoh-kartu.json # contoh isian
docs/setup-notion-api.md      # cara menyiapkan integrasi & menyambungkan halaman
```

## Cara pakai singkat

1. Ikuti `docs/setup-notion-api.md` untuk membuat integrasi dan menyambungkannya ke halaman.
2. Simpan token integrasi di sebuah file teks **di luar repositori ini**.
3. Tulis satu file JSON per kartu (lihat `tools/cards/contoh-kartu.json`).
4. Jalankan:

```powershell
powershell -ExecutionPolicy Bypass -File tools\New-NotionCard.ps1 -CardFile tools\cards\kartu-saya.json -TokenFile D:\rahasia\notion-token.txt
```

Keluarannya berupa konfirmasi dan URL halaman yang baru dibuat.

## Menyesuaikan untuk database lain

Skrip ini mengasumsikan database punya properti berikut. Ganti nama properti di bagian `$props` kalau database Anda berbeda:

| Properti | Tipe |
|---|---|
| `Name` | title |
| `content pillar` | multi_select |
| `author` | multi_select |
| `Date` | date |
| ` Links` | url |
| `Status` | status |

Susunan badan halaman yang dibuat: empat blok kutipan sebagai judul bagian, masing-masing diikuti isinya. Ubah bagian `$children` kalau susunan bagian Anda berbeda.

## Catatan keamanan

- **Jangan pernah menaruh token integrasi di dalam repositori.** File `.gitignore` di sini sudah memblokir pola nama yang umum, tapi cara paling aman tetap menyimpannya di folder lain sama sekali.
- Token integrasi Notion memberi akses **baca dan tulis** ke setiap halaman yang disambungkan ke integrasi tersebut. Perlakukan seperti kata sandi.
- Kalau token terlanjur ikut ter-*commit*, cabut integrasinya di pengaturan Notion lalu buat yang baru — menghapus filenya saja tidak cukup, karena riwayat commit masih menyimpannya.

## Lisensi

Bebas dipakai dan dimodifikasi.
