% =====================================================================
% aturan_p03_p04.pl — Aturan P03 (Sinusitis akut) dan P04 (Bronkitis akut)
% Pemilik file: Anggota 2 (lihat docs/pembagian_tugas.md)
%
% Kontrak integrasi (agent.md paragraf 6; docs/arsitektur.md):
%   aturan_p03_p04(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
%
% - Fakta sesi `gejala_terpilih/1` dan `detail_gejala/2` dibaca dari
%   src/basis_pengetahuan.pl (milik Anggota 4). File ini TIDAK
%   mendefinisikan fakta tersebut dan TIDAK menambahkan fakta baru.
% - `KodeKondisi` dan kode gejala memakai atom berkutip 'P03', 'G01', dst.
%   (patokan keputusan Anggota 4 yang dicatat untuk semua file aturan).
% - `Penjelasan` memakai teks (string) agar enak dibaca pengguna.
% - Setiap klausa dirancang mengembalikan tepat satu baris hasil bila
%   cocok, agar mesin inferensi tidak perlu membuang duplikat.
% - Load order: basis_pengetahuan.pl -> file aturan -> mesin_inferensi.pl
%   (dekalarasi dynamic harus termuat lebih dulu, docs/arsitektur.md).
%
% Kesenjangan durasi P03 (docs/matriks_basis_pengetahuan.md, kesenjangan
% no. 1): variabel durasi/perjalanan gejala belum tersedia di fakta sesi.
% Semua aturan P03 di file ini ditulis TANPA syarat durasi. Usulan
% penambahan variabel durasi diteruskan ke pemilik basis pengetahuan
% (Anggota 4) agar dicatat di docs/arsitektur.md sesuai agent.md §6.
%
% Batas medis (agent.md §3): aturan hanya menyatakan kecocokan pola
% gejala ("kondisi yang mungkin sesuai"), bukan diagnosis final.
% File ini tidak memuat resep, dosis obat, atau rekomendasi antibiotik.
% Pesan keselamatan untuk keluhan berat adalah bagian dari antarmuka,
% bukan "diagnosis" oleh aturan di file ini.
% =====================================================================

% ---------------------------------------------------------------------
% Helper (prefiks p03p04_ agar tidak bentrok dengan file aturan lain).
%
% p03p04_satu_dari(+DaftarKandidat, -Kode)
% Mengembalikan kode PERTAMA dalam DaftarKandidat yang memang terpilih
% pengguna pada sesi ini (memeriksa gejala_terpilih/1). Bila tidak ada
% yang terpilih, predikat gagal sehingga aturan pemakainya juga tidak
% cocok. Predikat ini deterministik: untuk fakta sesi yang sama ia
% selalu mengembalikan satu jawaban yang sama, sehingga satu klausa
% aturan tidak menghasilkan beberapa baris hanya karena beberapa gejala
% kandidat terpilih sekaligus.
% ---------------------------------------------------------------------
p03p04_satu_dari([Kode|_], Kode) :-
    gejala_terpilih(Kode).
p03p04_satu_dari([Kode|Sisa], Pilihan) :-
    \+ gejala_terpilih(Kode),
    p03p04_satu_dari(Sisa, Pilihan).

% p03p04_detail_dari(+DaftarKandidat, -KodeDetail)
% Versi helper untuk DETAIL (bukan gejala): mengembalikan kode detail
% PERTAMA dalam DaftarKandidat yang nilainya benar-benar dicatat
% pengguna lewat detail_gejala/2 (mis. rincian dahak G25a-G25d).
% Detail TIDAK dihitung sebagai gejala kedua (agent.md §6); kode detail
% hanya dipakai untuk melengkapi daftar dukungan yang benar-benar
% dipakai klausa, tanpa menambah fakta gejala baru.
p03p04_detail_dari([Kode|_], Kode) :-
    detail_gejala(Kode, _).
p03p04_detail_dari([Kode|Sisa], Pilihan) :-
    \+ detail_gejala(Kode, _),
    p03p04_detail_dari(Sisa, Pilihan).

% =====================================================================
% P03 — Sinusitis akut
% Sumber utama: CDC, "Sinus Infection Basics" — dokumen referensi no. 7
% (docs/referensi.md; tanggal akses 19 Oktober 2026). CDC
% mendeskripsikan gejala sinusitis/sinus infection: pilek, hidung
% tersumbat, nyeri/tekanan wajah, sakit kepala, post-nasal drip,
% nyeri tenggorokan, batuk, dan bau napas.
%
% Pemetaan matriks (docs/matriks_basis_pengetahuan.md):
%   ●  G01 hidung tersumbat, G02 pilek, G15 nyeri/tekanan wajah;
%   ○  G04, G05, G09, G14, G16, G17, G18, G28;
%   ○* G07.
%
% Keterbatasan:
% - Gejala hidung banyak tumpang tindih dengan P01 (selesma) sehingga
%   beberapa kondisi dapat cocok bersamaan; ini perilaku yang diinginkan
%   (agent.md §2 no. 3), bukan kesalahan.
% - Tanpa syarat durasi (kesenjangan no. 1 matriks); aturan tidak
%   menilai perjalanan penyakit >=10 hari atau memburuk setelah membaik.
% - Sekret kuning-hijau (G14) hanyalah tampilan sekret, bukan bukti
%   infeksi bakteri (agent.md §7; docs/referensi.md catatan dahak).
% - G07 pada P03 bertipe ○* (konteks khusus); aturan yang memakainya
%   tidak menyatakan penyebab bakteri dari demam semata.
% =====================================================================

% P03-R01 — inti sinus: pola hidung + nyeri/tekanan wajah (G15 = ● utama).
% Sumber: CDC "Sinus Infection Basics" (ref no. 7) — nyeri/tekanan wajah
% dan pilek/hidung tersumbat tercantum sebagai gejala sinus infection.
% Keterbatasan: gejala hidung juga muncul pada P01, jadi kecocokan
% aturan ini tidak menutup kemungkinan kondisi lain cocok bersamaan.
aturan_p03_p04('P03', 'P03-R01',
    'Kombinasi gejala hidung (pilek atau hidung tersumbat) yang dipilih disertai nyeri atau tekanan di wajah cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G15']) :-
    p03p04_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G15').

% P03-R02 — pola hidung penuh (G01 + G02) + sekret hidung kuning-hijau.
% Sumber: CDC (ref no. 7) — gejala hidung dan sekret termasuk yang
% dideskripsikan; tipologi matriks G14 ○ (pendukung).
% Keterbatasan (agent.md §7): tampilan sekret kuning-hijau TIDAK
% dipakai untuk menyatakan bahwa infeksi adalah bakteri.
aturan_p03_p04('P03', 'P03-R02',
    'Kombinasi pilek dan hidung tersumbat yang dipilih disertai sekret hidung kekuningan/kehijauan cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis, dan warna sekret bukan bukti infeksi bakteri.',
    ['G01','G02','G14']) :-
    gejala_terpilih('G01'),
    gejala_terpilih('G02'),
    gejala_terpilih('G14').

% P03-R03 — pola hidung + keluhan spesifik sinus (satu dari: penciuman
% menurun G16, nyeri gigi rahang atas G17, napas berbau G18).
% Sumber: CDC (ref no. 7) — bau napas disebut sebagai gejala; G16/G17
% dipetakan ○ pada matriks sebagai pendukung spesifik sinus.
aturan_p03_p04('P03', 'P03-R03',
    'Gejala hidung yang dipilih disertai salah satu keluhan khas sinus (penciuman menurun, nyeri gigi rahang atas, atau napas berbau) cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, Spesifik]) :-
    p03p04_satu_dari(['G01','G02'], Jangkar),
    p03p04_satu_dari(['G16','G17','G18'], Spesifik).

% P03-R04 — pola hidung + satu pendukung umum (demam G07 ○*,
% sakit kepala G09, post-nasal drip G28).
% Sumber: CDC (ref no. 7) — sakit kepala, post-nasal drip, dan demam
% termasuk gejala yang dideskripsikan.
% Pengetatan (kabaran integrasi + pengujian atas perilaku lama; dikerjakan
% oleh pemilik file this sebagai Opsi 3): G04 nyeri tenggorokan dan G05
% batuk dikeluarkan dari daftar pendukung. Keduanya justru menyaratkan
% syarat/jangkar kondisi lain (G04: jangkar P02 dan syarat P01-R03;
% G05: syarat P01-R04 dan jangkar P04), sehingga presentasi
% selesma/faringitis generik tanpa satu pun sinyal sinus memicu
% kecocokan P03 (contoh terburuk G01+G05 → P01 dan P03 bersamaan).
% Ambang tetap satu pendukung; ciri khas sinus G14/G15/G16/G17/G18
% sudah dicakup R01–R03. Keterbatasan: G07 demam pada P03 tetap konteks
% (○*); aturan ini tidak menyatakan sinusitis bakteri dari demam;
% warna sekret dan jenis batuk hanyalah detail (agent.md §6, §7).
aturan_p03_p04('P03', 'P03-R04',
    'Gejala hidung yang dipilih disertai salah satu keluhan pendukung (demam, sakit kepala, atau lendir mengalir ke tenggorokan) cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, Pendukung]) :-
    p03p04_satu_dari(['G01','G02'], Jangkar),
    p03p04_satu_dari(['G07','G09','G28'], Pendukung).

% =====================================================================
% P04 — Bronkitis akut
% Sumber utama: Kementerian Kesehatan RI / RSUP dr. Soeradji
% Tirtonegoro, "Bronchitis" — dokumen referensi no. 3
% (docs/referensi.md; tanggal akses 19 Oktober 2026). Sumber tersebut
% menyebut batuk, dahak, demam, menggigil, lemas, sesak, napas
% berbunyi, dan nyeri dada saat batuk sebagai gejala terkait.
%
% Pemetaan matriks (docs/matriks_basis_pengetahuan.md):
%   ●  G05 batuk (keluhan utama);
%   ○  G04, G07, G08b, G09, G11, G12, G19, G20a, G20b, G22, G25a, G25c, G25d.
%
% Keterbatasan penting:
% - Batuk saja (G05) tidak dipakai sebagai aturan mandiri: satu gejala
%   umum tidak cukup menyatakan satu kondisi (agent.md §7; arsitektur).
% - Bronkitis tidak dapat dibedakan dari pneumonia atau penyakit
%   saluran napas lain hanya dari gejala; G29 (frekuensi napas) dan
%   G31 (ronki) memerlukan pengukuran/pemeriksaan, sehingga tidak
%   menjadi syarat aturan di file ini (docs/matriks_basis_pengetahuan.md).
% - G08a (suhu >=38 derajat) tidak ada pada kolom P04 matriks dan hanya
%   dicatat sebagai detail pengukuran; tidak dijadikan syarat.
% - Warna dahak (G25a) hanyalah tampilan, bukan bukti infeksi bakteri
%   (agent.md §7). Rincian dahak dipakai hanya sebagai detail yang
%   menyertai batuk berdahak, bukan gejala independen (agent.md §6).
% - Sesak berat/nyeri dada berat adalah keluhan darurat yang ditangani
%   antarmuka sebagai pesan keselamatan, bukan kesimpulan aturan.
% =====================================================================

% P04-R01 — batuk + demam atau menggigil.
% Sumber: artikel "Bronchitis" (ref no. 3) — demam dan menggigil
% disebut sebagai gejala terkait; tipologi matriks G07 ○, G08b ○.
aturan_p03_p04('P04', 'P04-R01',
    'Batuk yang disertai demam atau menggigil cocok dengan gejala bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan tidak menentukan penyebab infeksi.',
    ['G05', Pdemam]) :-
    gejala_terpilih('G05'),
    p03p04_satu_dari(['G07','G08b'], Pdemam).

% P04-R02 — batuk + keluhan pernapasan (sesak G19, mengi G20a, napas
% berbunyi umum G20b).
% Sumber: artikel "Bronchitis" (ref no. 3) — sesak dan napas berbunyi
% disebut sebagai gejala terkait; tipologi matriks G19/G20a/G20b ○.
% Keterbatasan: gejala ini juga utama pada P05 asma (pembanding
% noninfeksi), sehingga beberapa kondisi dapat cocok bersamaan — ini
% perilaku yang diinginkan, bukan kesalahan (agent.md §2 no. 3).
aturan_p03_p04('P04', 'P04-R02',
    'Batuk yang disertai sesak napas atau napas berbunyi cocok dengan gejala bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis, dan keluhan serupa juga dapat muncul pada kondisi lain.',
    ['G05', Pnapas]) :-
    gejala_terpilih('G05'),
    p03p04_satu_dari(['G19','G20a','G20b'], Pnapas).

% P04-R03 — batuk + nyeri dada saat bernapas atau batuk.
% Sumber: artikel "Bronchitis" (ref no. 3) — nyeri dada saat batuk
% disebut sebagai gejala terkait; tipologi matriks G22 ○.
% Keterbatasan: nyeri dada berat/sesak berat memicu pesan keselamatan
% di antarmuka, bukan kesimpulan aturan (agent.md §3).
aturan_p03_p04('P04', 'P04-R03',
    'Batuk yang disertai nyeri dada saat bernapas atau batuk cocok dengan gejala bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G05','G22']) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G22').

% P04-R04 — batuk + satu pendukung umum (nyeri tenggorokan G04, sakit
% kepala G09, badan lemas G11, suara serak G12).
% Sumber: artikel "Bronchitis" (ref no. 3) — nyeri tenggorokan dan
% lemas disebut sebagai gejala terkait; tipologi matriks G04/G09/G11/
% G12 ○ pada kolom P04.
aturan_p03_p04('P04', 'P04-R04',
    'Batuk yang disertai salah satu keluhan pendukung (nyeri tenggorokan, sakit kepala, badan lemas, atau suara serak) cocok dengan pola bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G05', Pumum]) :-
    gejala_terpilih('G05'),
    p03p04_satu_dari(['G04','G09','G11','G12'], Pumum).

% P04-R05 — batuk berdahak + satu rincian dahak yang diisi (G25a-G25d).
% Sumber: artikel "Bronchitis" (ref no. 3) — dahak termasuk gejala
% terkait; tipologi matriks G25a/G25c/G25d ○ pada kolom P04.
% Keterbatasan (agent.md §7): warna dahak kuning/hijau TIDAK boleh
% dipakai sebagai bukti pasti infeksi bakteri. Rincian dahak adalah
% DETAIL dari batuk, bukan gejala kedua yang independen (agent.md §6);
% kode detail hanya dicantumkan pada daftar dukungan yang benar-benar
% dipakai klausa ini.
aturan_p03_p04('P04', 'P04-R05',
    'Batuk berdahak yang disertai rincian dahak (warna, bau, jumlah, atau kekentalan) cocok dengan pola bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis, dan warna dahak bukan bukti infeksi bakteri.',
    ['G05', DetailDahak]) :-
    gejala_terpilih('G05'),
    detail_gejala('G05', 'berdahak'),
    p03p04_detail_dari(['G25a','G25b','G25c','G25d'], DetailDahak).

% Catatan gaya rapat: tidak ada resep, dosis, rekomendasi antibiotik,
% atau klaim probabilitas/akurasi medis di file ini (agent.md §3, §7).
% Beberapa kondisi boleh cocok bersamaan bila syarat aturannya masing-
% masing terpenuhi; urutan hasil bukan tingkat kepastian.
