# Rencana Pengujian

## Tujuan

Memastikan aturan Prolog berjalan sesuai kontrak, menghasilkan penjelasan yang konsisten, dapat menampilkan beberapa kecocokan, dan menangani input yang tidak cukup tanpa klaim medis berlebihan.

## Tingkat pengujian

1. **Pemuatan/sintaks:** semua file dapat dimuat SWI-Prolog tanpa error sintaks.
2. **Unit aturan:** aturan terpenuhi hanya saat seluruh syarat aturan tersebut benar.
3. **Mesin inferensi:** hasil dari tiga file aturan dikumpulkan dengan benar, tanpa duplikasi tak disengaja.
4. **Reset sesi:** gejala dari sesi sebelumnya tidak memengaruhi konsultasi baru.
5. **Antarmuka:** pilihan gejala dan detail tervalidasi, hasil serta penjelasan ditampilkan dengan jelas.
6. **Keselamatan:** hasil bukan diagnosis pasti; kondisi darurat memunculkan anjuran mencari pertolongan medis.

## Skenario minimum

| ID | Skenario | Yang harus diperiksa |
|---|---|---|
| T01 | Program dimulai | Semua file berhasil dimuat dan aplikasi menampilkan pembuka. |
| T02 | Tidak ada gejala dipilih | Tidak menyimpulkan penyakit; menyebutkan data belum cukup/tidak ada aturan cocok. |
| T03 | Hanya satu gejala umum, misalnya batuk | Tidak langsung menyatakan kondisi tertentu secara pasti. |
| T04 | Gejala memenuhi satu aturan yang ditentukan | Kondisi dan ID aturan muncul dengan alasan yang sesuai. |
| T05 | Gejala memenuhi dua aturan dari kondisi berbeda | Kedua kecocokan dapat ditampilkan. |
| T06 | Gejala tidak memenuhi syarat lengkap suatu aturan | Aturan itu tidak menghasilkan hasil. |
| T07 | Reset lalu konsultasi ulang tanpa gejala | Gejala sesi pertama tidak tersisa. |
| T08 | Detail batuk diisi | Jenis batuk tampil sebagai detail G05, bukan gejala independen tambahan. |
| T09 | Suhu demam ≥38°C | Detail suhu tidak dihitung sebagai bukti independen ganda dengan G07. |
| T10 | P05 asma cocok | Hasil ditandai sebagai kondisi pembanding noninfeksi, bukan infeksi. |
| T11 | Pengguna melaporkan kesulitan bernapas berat atau gejala serius | Pesan keselamatan terlihat dan tidak tertutupi oleh daftar kecocokan. |
| T12 | Input tidak valid | Aplikasi meminta input yang benar tanpa error yang tidak ditangani. |
| T13 | Kondisi cocok tampil dengan saran | Setiap kode kondisi memiliki teks saran umum edukasi; teks saran bebas frasa terlarang; blok "Saran umum" muncul pada tampilan hasil. |
| T14 | Tampilan hasil mudah dibaca | Gejala pendukung tampil berpoin dengan nama ramah (G05 tampil "Batuk", tanpa keterangan teknis kamus) dan paragraf panjang dipenggal per kata dengan lebar kolom terbatas. |

## Kerangka PL-Unit (contoh)

```prolog
:- begin_tests(sistem_pakar).

% Tambahkan pengujian setelah nama predikat dan kontrak integrasi final disepakati.
% Contoh pola:
% test(program_loaded) :- current_predicate(gejala_info/2).

:- end_tests(sistem_pakar).
```

Jalankan dari direktori root setelah `run_tests/0` tersedia:

```powershell
swipl -q -s tests/tests.pl -g run_tests -t halt
```

## Pencatatan hasil

Untuk setiap pengujian, catat: ID skenario, fakta gejala yang dimasukkan, hasil yang diharapkan, hasil aktual, status lulus/gagal, dan catatan. Tes medis pada tahap ini adalah tes konsistensi aturan dan perangkat lunak, bukan bukti bahwa sistem tervalidasi secara klinis.
