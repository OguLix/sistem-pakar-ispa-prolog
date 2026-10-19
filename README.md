# Sistem Pakar Diagnosis Awal ISPA Dewasa Menggunakan Prolog

Proyek akademik sistem pakar berbasis aturan IF–THEN menggunakan SWI-Prolog. Sistem menerima gejala dari pengguna dan menampilkan kondisi yang mungkin sesuai beserta alasan dan gejala pendukung. Sistem ini **bukan alat diagnosis medis**.

## Ruang lingkup

- P01 — Common cold / selesma
- P02 — Faringitis
- P03 — Sinusitis akut
- P04 — Bronkitis akut
- P05 — Asma (pembanding/diferensial noninfeksi)
- P06 — Pneumonia dewasa

## Prasyarat

1. SWI-Prolog versi stabil dari [halaman unduhan resmi](https://www.swi-prolog.org/Download.html).
2. Editor kode, misalnya [Visual Studio Code](https://code.visualstudio.com/Download).
3. Git untuk kolaborasi, dari [halaman unduhan resmi](https://git-scm.com/downloads).

## Menjalankan aplikasi

Setelah implementasi `src/main.pl` selesai:

```powershell
swipl --version
swipl -q -s src/main.pl
```

Jangan menganggap proyek siap demo hanya karena SWI-Prolog terpasang. Jalankan tes dari `tests/tests.pl` dan cek keluaran tiap skenario.

## Struktur proyek

Lihat struktur berkas di `agent.md`. Kontrak antarmuka kode berada di `docs/arsitektur.md`. Matriks hubungan awal gejala–kondisi ada di `docs/matriks_basis_pengetahuan.md`, sementara tautan sumber dan catatan referensi ada di `docs/referensi.md`.

## Kolaborasi

Setiap anggota hanya mengubah file sesuai tanggung jawab yang ditetapkan dalam `docs/pembagian_tugas.md`. Perubahan pada file milik anggota lain harus dilaporkan kepada pemiliknya, bukan diedit langsung. Perubahan file bersama dibahas dan diintegrasikan oleh tim.

## Batasan

Hasil sistem merupakan kecocokan terhadap kumpulan aturan yang dibuat tim. Sistem tidak melakukan pemeriksaan fisik, tes laboratorium, pencitraan, atau validasi klinis. Hasilnya tidak boleh dianggap sebagai kepastian bahwa seseorang memiliki atau tidak memiliki penyakit. Jika gejala berat atau memburuk, pengguna harus diarahkan mencari pertolongan medis.
