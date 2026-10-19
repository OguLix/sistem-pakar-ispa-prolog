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
