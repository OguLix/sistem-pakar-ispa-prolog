# Arsitektur dan Kontrak Kode

## Gambaran alur

```text
Pengguna
  ↓
Antarmuka (src/antarmuka.pl)
  ↓ menyimpan fakta gejala dan detail
Basis pengetahuan (src/basis_pengetahuan.pl)
  ↓ fakta terpilih dibaca oleh aturan
File aturan P01–P06
  ↓ semua aturan yang cocok
Mesin inferensi (src/mesin_inferensi.pl)
  ↓ gabungkan hasil dan alasan
Antarmuka menampilkan hasil + batasan + pesan keselamatan
```

## Tanggung jawab berkas

- `src/main.pl`: titik masuk program, memuat berkas yang dibutuhkan, lalu menjalankan aplikasi.
- `src/basis_pengetahuan.pl`: kamus kode gejala/kondisi, penyimpanan fakta sesi, detail gejala dan prosedur reset sesi.
- `src/mesin_inferensi.pl`: memanggil aturan, mengumpulkan seluruh hasil, mencegah duplikasi yang tidak disengaja, menangani hasil kosong.
- `src/aturan_p01_p02.pl`: aturan P01 dan P02.
- `src/aturan_p03_p04.pl`: aturan P03 dan P04.
- `src/aturan_p05_p06.pl`: aturan P05 dan P06.
- `src/antarmuka.pl`: pertanyaan gejala, validasi input, tampilan hasil dan informasi keselamatan.
- `tests/tests.pl`: tes unit dan integrasi dengan SWI-Prolog/PL-Unit.

## Kontrak predikat yang disarankan

Kontrak ini adalah rancangan awal. Jika implementasi mengharuskan perubahan, tim harus mengubah semua pemanggil secara konsisten dan memperbarui dokumen ini.

### Fakta sesi

```prolog
gejala_terpilih(KodeGejala).
detail_gejala(KodeGejala, NilaiDetail).
```

Gunakan deklarasi dinamis jika diperlukan dan implementasikan prosedur reset yang menghapus semua fakta sesi sebelum wawancara gejala yang baru. Kamus gejala sebaiknya memakai predikat terpisah agar tidak tercampur dengan fakta sesi.

Contoh data kamus (bukan seluruh implementasi):

```prolog
gejala_info('G01', 'Hidung tersumbat').
kondisi_info('P01', 'Common cold / selesma').
```

### Predikat aturan

```prolog
aturan_p01_p02(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
aturan_p03_p04(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
aturan_p05_p06(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
```

Predikat berhasil ketika syarat aturan yang bersangkutan terpenuhi. Daftar `GejalaPendukung` berisi kode gejala yang benar-benar menjadi bagian syarat aturan tersebut. Setiap klausa perlu memiliki ID aturan unik dan penjelasan yang dapat dimengerti pengguna.

### Hasil inferensi

Mesin inferensi mengumpulkan hasil dari ketiga predikat, mempertahankan semua kondisi yang cocok, dan menyajikan satu atau lebih penjelasan yang relevan. Tentukan representasi akhir hasil (misalnya `hasil(KodeKondisi, Nama, IdAturan, Penjelasan, GejalaPendukung)`) saat mulai implementasi, lalu pakai secara konsisten di antarmuka dan tes.

## Prinsip implementasi

- Jangan menyimpulkan satu kondisi hanya dari satu gejala umum.
- Jangan jadikan setiap gejala penunjang sebagai syarat wajib secara otomatis; aturan harus disusun dari kombinasi yang didukung referensi.
- Jangan menafsirkan jumlah gejala sebagai probabilitas medis.
- Hindari klausa yang saling tumpang-tindih sehingga hasil muncul berkali-kali tanpa penjelasan.
- Hasil yang kosong berarti “tidak ada aturan yang cocok pada basis pengetahuan ini”, bukan berarti orang tidak sakit.
- P05 asma adalah pembanding noninfeksi, sehingga tampilan harus membedakannya dari kondisi infeksi.
- Gejala darurat ditangani sebagai pesan keselamatan terpisah, tidak sebagai “diagnosis” oleh aturan.

## Predikat antarmuka (ditambahkan 21 Oktober 2026)

Bagian ini mendokumentasikan predikat baru pada `src/main.pl` dan
`src/antarmuka.pl`. Kontrak fakta sesi, predikat aturan, dan hasil
inferensi yang sudah ada TIDAK berubah.

Titik masuk dan alur:

- `main.pl` memuat `basis_pengetahuan.pl`, tiga file aturan,
  `mesin_inferensi.pl`, `antarmuka.pl` dengan jalur relatif terhadap
  lokasi file; setelah termuat, hook `initialization(jalankan_aplikasi,
  main)` menjalankan aplikasi dan program keluar bersih dengan `halt/0`.
- `jalankan_aplikasi/0` menampilkan menu (1) konsultasi baru atau
  (2) keluar. Sesi baru selalu diawali `reset_sesi/0`. Masukan tidak
  valid diulang; `end_of_file` mengakhiri program dengan pesan, bukan
  error yang tidak tertangani. Tidak ada data pribadi yang diminta.
- `konsultasi/0` alurnya: pembuka + peringatan "bukan diagnosis medis;
  alat edukasi dan penyaringan awal"; 7 pertanyaan tanda bahaya terlebih
  dahulu (`tanda_bahaya_info/2`, lokal antarmuka, BUKAN kode gejala
  baru); bila dijawab "ya", pesan "segera cari pertolongan medis"
  muncul segera dan diulang di bagian paling atas hasil sehingga tidak
  tertutup daftar kecocokan; sistem tidak mendiagnosis kondisi gawat.
  Setelah itu wawancara gejala (ya/tidak) memakai `tambah_gejala/1` dan
  `tambah_detail/2`, lalu `inferensi/2`.

Aturan wawancara detail:

- G05: jenis batuk (kering/berdahak) lewat `tambah_detail('G05', ...)`;
  bila berdahak, rincian dahak G25a-G25d ditanya sebagai detail opsional.
- G07: bila suhu benar-benar diukur, detail `suhu_X` dicatat; suhu
  >= 38 C menambah `tambah_gejala('G08a')` (validasi induk tetap di
  `tambah_gejala/1` milik basis pengetahuan).
- G29/G31 tidak ditanya ke pengguna awam, kecuali pengguna menjawab
  "ya" pada pertanyaan opsional hasil pengukuran frekuensi napas atau
  pemeriksaan tenaga kesehatan; setelah itu barulah nilai sebenarnya
  ditanyakan, sehingga aturan P06-R06 tetap dapat tercapai dengan jujur.
- `gejala_catatan/2` ditampilkan pada pertanyaan yang relevan.

Predikat murni antarmuka (dapat dites tanpa stdin):

- `tanda_bahaya_info/2` - daftar 7 tanda bahaya (teks lokal).
- `pesan_tanda_bahaya/2` - nomor tanda yang dipilih -> baris peringatan.
- `status_pesan/2` - status `inferensi/2` -> pesan pengguna.
- `pertanyaan_gejala/2` - kode gejala -> teks pertanyaan.
- `gejala_ditanya_langsung/1` - gejala yang masuk wawancara umum
  (menyisihkan G25a-G25d, G08a, G29, G31).
- `kelompokkan_hasil/2` - daftar `hasil/5` -> kelompok per kondisi;
  memakai `keysort/2` sebelum `group_pairs_by_key/2`.
- `teks_gejala/2` dan `jadikan_teks/2` - konversi teks tampilan.
- `susun_keluaran/4` - rakit baris tampilan dengan urutan tetap:
  blok tanda bahaya, blok hasil, blok penutup (disclaimer).
- `jawaban_ya_tidak/2`, `pilihan_menu/2`, `parse_suhu/3` - parser masukan
  murni (ya/tidak; menu 1/2; suhu 38.2 atau 38,2), dipakai ulang oleh I/O.
