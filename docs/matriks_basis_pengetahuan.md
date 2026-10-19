# Matriks Basis Pengetahuan — Draf Awal

**Status:** draf proyek untuk ditinjau. Matriks ini adalah alat dokumentasi hubungan gejala–kondisi, bukan kriteria diagnosis klinis yang tervalidasi. Setiap aturan implementasi tetap harus disusun dari kombinasi gejala dan sumber pendukung, bukan dari satu simbol saja.

## Kode kondisi

| Kode | Kondisi | Catatan |
|---|---|---|
| P01 | Common cold / selesma | Infeksi saluran pernapasan atas yang umumnya viral. |
| P02 | Faringitis | Peradangan faring; penyebab dan penilaian klinis dapat berbeda. |
| P03 | Sinusitis akut | Gejala hidung/sinus dan pola durasi/perjalanan penyakit perlu dipertimbangkan. |
| P04 | Bronkitis akut | Batuk merupakan keluhan utama; bronkitis tidak selalu dapat ditentukan hanya dari warna dahak. |
| P05 | Asma | **Pembanding noninfeksi**, bukan penyakit ISPA infeksi. |
| P06 | Pneumonia dewasa | Penilaian sesak, frekuensi napas, pemeriksaan fisik, dan konteks klinis penting. |

## Legenda

- `●` — gejala utama/umum yang relevan terhadap kondisi.
- `○` — gejala pendukung, tidak spesifik, atau dapat muncul pada sebagian kasus.
- `○*` — hubungan khusus konteks, misalnya pola viral/bakterial tertentu atau gejala yang perlu ditafsirkan bersama tanda lain.
- Sel kosong — hubungan **belum dimasukkan dalam matriks kerja** karena dukungan sumber yang ditinjau belum cukup atau hubungan tersebut tidak dipakai dalam rancangan awal. Sel kosong tidak berarti gejala mustahil muncul pada kondisi itu.

Simbol ini bukan angka, bobot statistik, probabilitas, atau tingkat kepastian diagnosis. Matriks perlu ditinjau bersama `docs/referensi.md` sebelum aturan final dibuat.

## Matriks hubungan gejala–kondisi

| Kode | Gejala / detail | P01 | P02 | P03 | P04 | P05 | P06 |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|
| G01 | Hidung tersumbat | ● | ○* | ● |  |  |  |
| G02 | Pilek / ingus encer | ● | ○* | ● |  |  |  |
| G03 | Bersin-bersin | ● | ○* |  |  |  |  |
| G04 | Nyeri tenggorokan | ○ | ● | ○ | ○ |  |  |
| G05 | Batuk (jenis batuk menjadi detail) | ○ | ○* | ○ | ● | ○ | ● |
| G07 | Demam (suhu sebagai detail) | ○ | ○ | ○* | ○ |  | ● |
| G08a | Demam dengan suhu ≥38°C |  | ○* |  |  |  | ○ |
| G08b | Menggigil |  | ○* |  | ○ |  | ○ |
| G09 | Sakit kepala | ○ | ○ | ○ | ○ |  | ○ |
| G10 | Nyeri otot / badan pegal | ○ | ○* |  |  |  | ○ |
| G11 | Badan lemas / lelah | ○ | ○ |  | ○ |  | ○ |
| G12 | Suara serak / berubah | ○ | ○* |  | ○ |  |  |
| G13 | Kelenjar leher nyeri / membesar |  | ○ |  |  |  |  |
| G14 | Sekret hidung purulen / kuning-hijau |  |  | ○ |  |  |  |
| G15 | Nyeri / tekanan di wajah |  |  | ● |  |  |  |
| G16 | Penciuman menurun |  |  | ○ |  |  |  |
| G17 | Nyeri gigi rahang atas |  |  | ○ |  |  |  |
| G18 | Napas berbau |  |  | ○ |  |  |  |
| G19 | Sesak napas |  |  |  | ○ | ● | ● |
| G20a | Mengi (wheezing) |  |  |  | ○ | ● |  |
| G20b | Napas berbunyi secara umum |  |  |  | ○ | ○ |  |
| G21 | Dada terasa berat / tertekan |  |  |  |  | ● |  |
| G22 | Nyeri dada saat bernapas atau batuk |  |  |  | ○ |  | ○ |
| G23 | Gejala memburuk malam / dini hari |  |  |  |  | ● |  |
| G24 | Dipicu alergen, olahraga, atau perubahan cuaca |  |  |  |  | ● |  |
| G25a | Detail dahak: warna |  |  |  | ○ |  | ○ |
| G25b | Detail dahak: bau |  |  |  |  |  |  |
| G25c | Detail dahak: jumlah |  |  |  | ○ |  | ○ |
| G25d | Detail dahak: kekentalan |  |  |  | ○ |  |  |
| G26 | Mual |  | ○* |  |  |  | ○* |
| G27 | Nyeri menelan hebat |  | ○ |  |  |  |  |
| G28 | Post-nasal drip / lendir mengalir ke tenggorokan | ○ |  | ○ |  |  |  |
| G29 | Frekuensi napas meningkat (diukur) |  |  |  |  |  | ● |
| G30a | Pembengkakan amandel |  | ○ |  |  |  |  |
| G30b | Eksudat / bercak putih amandel |  | ○* |  |  |  |  |
| G31 | Ronki / suara napas bronkial saat pemeriksaan |  |  |  |  |  | ○ |

## Definisi dan catatan input

- `G05` adalah satu gejala batuk. Jenis batuk (kering/berdahak) disimpan sebagai detail, bukan gejala terpisah yang dihitung lagi.
- `G07` adalah demam. `G08a` mencatat detail bahwa suhu terukur ≥38°C; keduanya tidak boleh dihitung sebagai bukti independen ganda. Jika suhu tidak diukur, jangan menyatakan ambang suhu terpenuhi.
- `G25a` sampai `G25d` adalah detail dahak jika batuk berdahak dipilih; semuanya tidak wajib diisi.
- `G29` dan `G31` memerlukan pengukuran atau pemeriksaan oleh orang yang kompeten. Jangan meminta pengguna awam menebak ronki atau suara napas bronkial.
- Istilah `sekret purulen/kuning-hijau` mendeskripsikan tampilan sekret, bukan bukti pasti infeksi bakteri.
- Sel kosong tidak membuktikan gejala tidak pernah muncul. Sel tersebut hanya tidak digunakan dalam hubungan awal ini.

## Kesenjangan yang harus ditinjau sebelum aturan final

1. **Perjalanan waktu sinusitis:** matriks belum punya variabel durasi gejala, tidak membaik, atau memburuk lagi setelah sempat membaik. Tambahkan pertanyaan konteks/waktu hanya setelah sumber yang sesuai ditinjau, lalu dokumentasikan sebagai variabel terpisah bila tim setuju.
2. **Kriteria faringitis:** gejala saja tidak selalu membedakan penyebab virus dan bakteri. Jangan menyatakan faringitis bakterial berdasarkan demam atau eksudat saja.
3. **Pneumonia:** gejala pengguna saja bukan pengganti pemeriksaan klinis. Frekuensi napas dan temuan auskultasi harus diberi sumber data yang jelas.
4. **Asma:** gejala dapat bervariasi dan membutuhkan konteks riwayat/pemeriksaan; asma ditampilkan sebagai pembanding noninfeksi.
5. **Validasi matriks:** pemilik aturan perlu mencocokkan hubungan yang dipakai dengan bagian sumber yang benar-benar dibaca; ubah simbol hanya dengan mencatat alasan dan referensi.

## Catatan status

Matriks ini dibangun sebagai titik awal pengembangan perangkat lunak dari daftar gejala dan referensi edukasi/klinis yang dicatat. Matriks ini belum melalui tinjauan klinis formal. Jangan menggunakannya untuk menentukan terapi atau membuat klaim akurasi medis.
