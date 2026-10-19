# Pembagian Tugas Tim

## Tujuan

Pembagian ini membagi basis aturan per kondisi agar pekerjaan paralel tidak menyebabkan anggota atau AI coding agent mengubah file anggota lain. Antarmuka, pengujian, dokumentasi, dan integrasi dikerjakan bersama.

## Pemilik file

| Anggota | File kode utama | Tanggung jawab |
|---|---|---|
| Anggota 1 | `src/aturan_p01_p02.pl` | Menyusun aturan untuk P01 selesma dan P02 faringitis, dengan penjelasan dan kode gejala pendukung. |
| Anggota 2 | `src/aturan_p03_p04.pl` | Menyusun aturan untuk P03 sinusitis akut dan P04 bronkitis akut. |
| Anggota 3 | `src/aturan_p05_p06.pl` | Menyusun aturan untuk P05 asma sebagai pembanding dan P06 pneumonia dewasa. |
| Anggota 4 | `src/basis_pengetahuan.pl`, `src/mesin_inferensi.pl` | Kamus gejala/kondisi, fakta masukan, pengumpulan hasil, deduplikasi, penanganan hasil kosong/informasi kurang, serta reset sesi. |
| Seluruh anggota | `src/main.pl`, `src/antarmuka.pl`, `tests/tests.pl`, `docs/*`, `README.md` | Menyetujui rancangan, menyiapkan demo, menguji integrasi, meninjau teks keselamatan, dan menggabungkan perubahan. |

## Aturan kolaborasi

1. Jangan mengedit file aturan yang bukan milikmu.
2. Jika menemukan kekurangan pada file anggota lain, tulis issue/komentar yang menyebutkan file, perilaku yang salah, kasus untuk mereproduksi masalah, dan saran perbaikan.
3. Perubahan antarmuka predikat harus disepakati dan dicatat di `docs/arsitektur.md` sebelum diintegrasikan.
4. File bersama tidak boleh ditimpa dengan hasil agent tanpa meninjau perubahan yang sudah ada.
5. Sebelum integrasi, pemilik file menjelaskan aturan yang ditambahkan dan kasus uji yang digunakan.
6. Semua anggota bersama-sama memeriksa bahwa keluaran tidak menyebut diagnosis pasti atau memberi terapi/obat.

## Urutan kerja yang disarankan

1. Sepakati kontrak kode dan daftar kode gejala.
2. Masing-masing pemilik menyusun aturan kondisi miliknya beserta referensi.
3. Anggota 4 menyiapkan basis pengetahuan dan mesin inferensi terhadap kontrak yang sama.
4. Tim membuat antarmuka dan tes bersama.
5. Jalankan tes unit, integrasi, dan skenario demo.
6. Tinjau ulang matriks, referensi, teks keselamatan, dan keterbatasan sistem sebelum presentasi.

## Catatan

Nomor anggota adalah label kerja dan bisa diganti dengan nama anggota tim. Jangan mengubah lingkup file tanpa kesepakatan tim.
