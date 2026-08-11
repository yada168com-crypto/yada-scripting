# Menyiapkan akses API Notion

## 1. Buat integrasi

1. Buka <https://www.notion.so/profile/integrations>
2. **New integration** → beri nama → pilih workspace yang dituju
3. Salin **Internal Integration Token** (diawali `ntn_`)
4. Simpan token itu ke sebuah file teks **di luar repositori mana pun**

## 2. Sambungkan halaman ke integrasi

Integrasi tidak otomatis bisa melihat apa pun. Tiap halaman induk harus disambungkan manual:

1. Buka halaman induk (mis. halaman teamspace yang memuat database)
2. Klik tombol `...` di kanan atas
3. Gulir ke bawah sampai menemukan **Connections**
4. Pilih nama integrasi Anda → **Add to page**

Menyambungkan halaman induk otomatis memberi akses ke semua halaman anaknya, termasuk database di dalamnya.

## 3. Cek koneksi

```powershell
$tok = (Get-Content 'D:\rahasia\notion-token.txt' -Raw).Trim()
$h = @{ 'Authorization' = "Bearer $tok"; 'Notion-Version' = '2022-06-28' }
Invoke-RestMethod -Uri 'https://api.notion.com/v1/users/me' -Headers $h -Method Get
```

Kalau berhasil, akan muncul nama bot dan nama workspace.

## 4. Cari ID database

```powershell
$h['Content-Type'] = 'application/json'
$body = '{"page_size":100,"filter":{"value":"database","property":"object"}}'
$r = Invoke-RestMethod -Uri 'https://api.notion.com/v1/search' -Headers $h -Method Post -Body $body
$r.results | ForEach-Object { ($_.title | ForEach-Object { $_.plain_text }) -join '' ; $_.id }
```

Kalau database yang baru disambungkan belum muncul, tunggu sebentar — indeks pencarian Notion kadang terlambat beberapa menit. Untuk memastikan aksesnya sudah ada, panggil langsung:

```
GET https://api.notion.com/v1/blocks/<page_id>/children
```

## 5. Lihat skema database

```powershell
$d = Invoke-RestMethod -Uri "https://api.notion.com/v1/databases/<database_id>" -Headers $h -Method Get
$d.properties.PSObject.Properties | ForEach-Object { $_.Name + '  (' + $_.Value.type + ')' }
```

## Hal-hal yang mudah bikin gagal

- **Nama properti harus persis sama**, termasuk spasi dan huruf besar-kecil. Nama seperti `" Links"` dengan spasi di depan itu sah dan sering terjadi kalau properti pernah diketik manual — dan API akan menolak kalau Anda menulisnya tanpa spasi.
- **Opsi `status` harus persis sama** dengan yang ada di database, termasuk salah ketiknya. Kalau opsinya tertulis `asking for apporve`, itu yang harus dikirim.
- Kalau database yang mirip dipakai di beberapa tempat, **opsi status bisa berbeda-beda** antar database sekalipun namanya sama. Periksa satu per satu.
- Satu potongan `rich_text` maksimal **2000 karakter**. Teks yang lebih panjang harus dipecah — skrip di repo ini sudah memecah otomatis di 1900 karakter.
- Kirim body sebagai **UTF-8 bytes**, bukan string biasa, kalau isinya memuat aksara non-Latin. Kalau tidak, aksaranya rusak.
- Menghapus halaman lewat API: `PATCH /v1/pages/<page_id>` dengan body `{"archived": true}`. Halaman masuk ke Trash dan masih bisa dipulihkan lewat tampilan web.
