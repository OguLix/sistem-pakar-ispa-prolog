# Sistem Pakar Diagnosis Awal ISPA Dewasa Menggunakan Prolog

Proyek akademik sistem pakar berbasis aturan IF-THEN menggunakan SWI-Prolog. Sistem menerima gejala dari pengguna dan menampilkan kondisi yang mungkin sesuai beserta alasan dan gejala pendukung. Sistem ini **bukan alat diagnosis medis**.

## Ruang lingkup

- P01 - Common cold / selesma
- P02 - Faringitis
- P03 - Sinusitis akut
- P04 - Bronkitis akut
- P05 - Asma (pembanding/diferensial noninfeksi)
- P06 - Pneumonia dewasa

## Prasyarat

[SWI-Prolog](https://www.swi-prolog.org/Download.html) versi stabil. Tidak ada pustaka tambahan yang perlu dipasang; seluruh kode memakai SWI-Prolog dan modul bawaannya.

## Menjalankan aplikasi

Dari folder root proyek:

```powershell
swipl -q -s src/main.pl
```

Aplikasi langsung berjalan dan menampilkan menu:

```
Menu:
  1) Mulai sesi konsultasi baru
  2) Keluar
```

Pilih `1` untuk memulai konsultasi. Alurnya secara ringkas:

1. Tujuh pertanyaan tanda bahaya ditanyakan terlebih dahulu. Jawaban "ya" pada salah satunya langsung memunculkan pesan untuk **segera mencari pertolongan medis**, dan pesan ini diulang di bagian paling atas hasil; sistem tidak mencoba mendiagnosis kondisi gawat dari tanda-tanda itu.
2. Wawancara gejala dengan pertanyaan ya/tidak. Jawaban yang tidak dipahami diulang; kosongkan (tekan Enter berulang sampai akhir masukan) juga mengakhiri program dengan aman.
3. Pertanyaan rincian mengikuti gejala tertentu: jenis batuk (kering/berdahak) beserta rincian dahak bila perlu, dan nilai suhu terukur bila demam benar-benar diukur. Nilai suhu >= 38 C dicatat sebagai demam terukur. Suhu bisa diketik dengan koma atau titik, misalnya `38,2` atau `38.2`.
4. Bagian opsional hasil pengukuran/pemeriksaan (frekuensi napas, temuan pemeriksaan) hanya ditanyakan bila pengguna menyatakan memilikinya, sehingga nilai yang dicatat selalu benar-benar terukur.
5. Hasil ditampilkan sebagai daftar kondisi yang mungkin sesuai, dikelompokkan per kondisi, beserta ID aturan, alasan, dan gejala pendukung. Ditutup dengan catatan batasan sistem.

Hasil yang kosong berarti tidak ada aturan yang cocok pada basis pengetahuan ini, **bukan** berarti tidak ada penyakit.

## Menjalankan pengujian

Dari folder root proyek:

```powershell
swipl -q -s tests/tests.pl -g run_tests -t halt
```

Suite memuat 96 tes PL-Unit yang mencakup kasus positif dan negatif untuk seluruh klausa aturan, guard gejala dan penolakan detail, reset antar sesi, pengelompokan hasil, pemunculan tanda bahaya di atas hasil, parser masukan, serta pemindaian frasa terlarang pada penjelasan aturan.

## Struktur proyek

```
src/
  basis_pengetahuan.pl    Fakta gejala, kondisi, dan detail (API sesi konsultasi)
  aturan_p01_p02.pl       Aturan selesma dan faringitis
  aturan_p03_p04.pl       Aturan sinusitis dan bronkitis
  aturan_p05_p06.pl       Aturan asma (pembanding) dan pneumonia
  mesin_inferensi.pl      Pencocokan aturan dan status hasil inferensi
  antarmuka.pl            Alur konsultasi dan tampilan hasil
  main.pl                 Titik masuk aplikasi dan urutan pemuatan file
tests/
  tests.pl                Suite pengujian PL-Unit
docs/
  arsitektur.md           Kontrak antarmuka kode
  matriks_basis_pengetahuan.md  Hubungan awal gejala-kondisi
  referensi.md            Tautan sumber dan catatan referensi
  rencana_pengujian.md    Rencana kasus uji
```

Urutan pemuatan file diatur oleh `src/main.pl`: basis pengetahuan dipuat lebih dulu karena deklarasi fakta sesi ada di sana, kemudian tiga file aturan, mesin inferensi, lalu antarmuka. Jalur pemuatan dihitung relatif terhadap lokasi `main.pl`, sehingga perintah di atas aman dijalankan dari folder mana pun.

Detail teknis antarmuka (daftar tanda bahaya, predikat murni untuk pengujian tanpa masukan keyboard, format detail seperti `suhu_X`) didokumentasikan di `docs/arsitektur.md`.

## Batasan

Hasil sistem merupakan kecocokan terhadap kumpulan aturan yang dibuat tim. Sistem tidak melakukan pemeriksaan fisik, tes laboratorium, pencitraan, atau validasi klinis. Hasilnya tidak boleh dianggap sebagai kepastian bahwa seseorang memiliki atau tidak memiliki penyakit, dan urutan tampilan hasil bukan tingkat keparahan atau peringkat kondisi. Sistem tidak memberi resep, dosis obat, atau rekomendasi obat. Jika gejala berat atau memburuk, pengguna harus diarahkan mencari pertolongan medis.
