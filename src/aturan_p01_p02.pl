% =====================================================================
% aturan_p01_p02.pl — Aturan P01 (Selesma) dan P02 (Faringitis)
% Pemilik file: Anggota 1 (lihat docs/pembagian_tugas.md)
%
% Kontrak integrasi (agent.md §6; docs/arsitektur.md):
%   aturan_p01_p02(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
%
% - Fakta sesi `gejala_terpilih/1` dibaca dari src/basis_pengetahuan.pl
%   (milik Anggota 4). File ini TIDAK mendefinisikan fakta tersebut.
% - `KodeKondisi` dan kode gejala memakai atom 'P01', 'G01', dst.
% - `Penjelasan` memakai teks (string) agar enak dibaca pengguna.
% - Setiap klausa dirancang mengembalikan tepat satu baris hasil
%   bila cocok, agar mesin inferensi tidak perlu membuang duplikat.
%
% Batas medis (agent.md §3): aturan hanya menyatakan kecocokan pola
% gejala ("kondisi yang mungkin sesuai"), bukan diagnosis final.
% File ini tidak memuat resep, dosis obat, atau rekomendasi antibiotik.
% Pesan keselamatan untuk keluhan berat adalah bagian dari antarmuka,
% bukan "diagnosis" oleh aturan di file ini.
% =====================================================================

% ---------------------------------------------------------------------
% Helper (prefiks p01p02_ agar tidak bentrok dengan file aturan lain).
%
% p01p02_satu_dari(+DaftarKandidat, -Kode)
% Mengembalikan kode PERTAMA dalam DaftarKandidat yang memang terpilih
% pengguna pada sesi ini. Bila tidak ada yang terpilih, predikat gagal
% sehingga aturan pemakainya juga tidak cocok.
%
% Predikat ini deterministik: untuk fakta sesi yang sama ia selalu
% mengembalikan satu jawaban yang sama, sehingga satu klausa aturan
% tidak menghasilkan beberapa baris hanya karena beberapa gejala
% kandidat terpilih sekaligus.
% ---------------------------------------------------------------------
p01p02_satu_dari([Kode|_], Kode) :-
    gejala_terpilih(Kode).
p01p02_satu_dari([Kode|Sisa], Pilihan) :-
    \+ gejala_terpilih(Kode),
    p01p02_satu_dari(Sisa, Pilihan).

% =====================================================================
% P01 — Common cold / selesma
% Sumber utama: CDC, "About Common Cold" — dokumen referensi no. 6
% (docs/referensi.md; tanggal akses 19 Oktober 2026). CDC
% mendeskripsikan gejala common cold dewasa: pilek, hidung tersumbat,
% bersin, nyeri tenggorokan, batuk, sakit kepala, pegal ringan, dan
% demam yang biasanya ringan.
%
% Pemetaan matriks (docs/matriks_basis_pengetahuan.md):
%   ●  G01 hidung tersumbat, G02 pilek, G03 bersin;
%   ○  G04, G05, G07, G09, G10, G11, G12, G28.
%
% Keterbatasan: gejala selesma banyak tumpang tindih dengan kondisi
% lain (misalnya alergi pada G01–G03); aturan tidak mengklaim diagnosis
% pasti dan tidak membedakan penyebab virus/nonvirus.
% G07 (demam ringan pada selesma) sengaja tidak dijadikan syarat:
% demam lebih menentukan pada P02–P04, dan hubungan G07/G08a (suhu
% sebagai detail) perlu disepakati dulu dengan pemilik basis pengetahuan
% (agent.md §6) agar tidak dihitung ganda.
% =====================================================================

% P01-R01 — ciri utama hidung: hidung tersumbat + pilek (dua simbol ●).
% Sumber: CDC "About Common Cold" (ref no. 6) — pilek dan hidung
% tersumbat tercantum sebagai gejala common cold dewasa.
aturan_p01_p02('P01', 'P01-R01',
    'Kombinasi hidung tersumbat dan pilek yang dipilih cocok dengan pola hidung utama selesma (common cold) menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G01','G02']) :-
    gejala_terpilih('G01'),
    gejala_terpilih('G02').

% P01-R02 — pola hidung + bersin-bersin.
% Sumber: CDC (ref no. 6) — bersin termasuk gejala yang dideskripsikan.
aturan_p01_p02('P01', 'P01-R02',
    'Gejala hidung yang dipilih disertai bersin-bersin cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G03']) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G03').

% P01-R03 — pola hidung + nyeri tenggorokan.
% Sumber: CDC (ref no. 6) — nyeri tenggorokan termasuk gejala yang
% dideskripsikan; tipologi matriks untuk G04 pada P01 adalah ○
% (pendukung).
aturan_p01_p02('P01', 'P01-R03',
    'Gejala hidung yang dipilih disertai nyeri tenggorokan cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G04']) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G04').

% P01-R04 — pola hidung + batuk.
% Sumber: CDC (ref no. 6) — batuk termasuk gejala yang dideskripsikan.
% Catatan (agent.md §6): jenis batuk (kering/berdahak) hanya detail
% dari G05, bukan gejala kedua yang independen; di sini cukup G05.
aturan_p01_p02('P01', 'P01-R04',
    'Gejala hidung yang dipilih disertai batuk cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G05']) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G05').

% P01-R05 — pola hidung + satu keluhan sistemik/pendukung ringan.
% Sumber: CDC (ref no. 6) — sakit kepala, pegal ringan, lemas pada
% selesma; suara serak dan post-nasal drip dipetakan ○ pada matriks.
% Helper hanya mengambil satu pendukung yang terpilih (urutan daftar)
% agar satu klausa menghasilkan satu baris; tipologi matriks tetap ○.
aturan_p01_p02('P01', 'P01-R05',
    'Gejala hidung yang dipilih disertai salah satu keluhan umum selesma (sakit kepala, pegal/nyeri otot, badan lemas, suara serak, atau lendir mengalir ke tenggorokan) cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, Pendukung]) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    p01p02_satu_dari(['G09','G10','G11','G12','G28'], Pendukung).

% =====================================================================
% P02 — Faringitis
% Sumber utama: Kemenkes RI / RSUP dr. Soeradji Tirtonegoro,
% "Diagnosis Faringitis" — dokumen referensi no. 2
% (docs/referensi.md; tanggal akses 19 Oktober 2026).
%
% Pemetaan matriks (docs/matriks_basis_pengetahuan.md):
%   ●  G04 nyeri tenggorokan (utama);
%   ○  G07, G09, G11, G13, G27, G30a;
%   ○* G01, G02, G03, G05, G08a, G08b, G10, G12, G26, G30b.
%
% Keterbatasan penting (docs/matriks_basis_pengetahuan.md, kesenjangan
% no. 2 dan docs/referensi.md): gejala saja tidak membedakan penyebab
% virus dan bakteri. Demam (G07/G08a) maupun eksudat amandel (G30b)
% TIDAK dipakai oleh aturan mana pun di file ini untuk menyatakan
% faringitis bakteri. G26 mual dan G10 pegal (○*) tidak dijadikan
% syarat karena bertipe konteks khusus dan belum didukung sumber yang
% cukup (agent.md §3, prinsip 9).
% =====================================================================

% P02-R01 — nyeri tenggorokan + demam/menggigil.
% Sumber: artikel "Diagnosis Faringitis" (ref no. 2) — demam disebut
% sebagai gejala terkait faringitis; tipologi matriks: G07 ○,
% G08a/G08b ○* (konteks khusus).
% Keterbatasan: demam atau suhu ≥38°C tidak dipakai membuat klaim
% penyebab bakteri; G08a membutuhkan pengukuran suhu nyata.
aturan_p01_p02('P02', 'P02-R01',
    'Nyeri tenggorokan yang disertai demam atau menggigil cocok dengan gejala faringitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan tidak menyatakan penyebab virus maupun bakteri.',
    ['G04', Pendemam]) :-
    gejala_terpilih('G04'),
    p01p02_satu_dari(['G07','G08a','G08b'], Pendemam).

% P02-R02 — nyeri tenggorokan + temuan lokal tenggorokan/leher.
% Sumber: artikel "Diagnosis Faringitis" (ref no. 2) — pemeriksaan
% faring dan kelenjar terkait penilaian faringitis; tipologi matriks:
% G13 ○, G30a ○, G30b ○*.
% Keterbatasan: eksudat/bercak putih amandel (G30b) hanyalah temuan
% tampilan, bukan bukti infeksi bakteri (agent.md §3; referensi no. 2
% catatan warna dahak/sekret yang sama).
aturan_p01_p02('P02', 'P02-R02',
    'Nyeri tenggorokan yang disertai kelenjar leher nyeri/membesar atau temuan pada amandel cocok dengan gejala faringitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; temuan pada amandel bukan bukti infeksi bakteri.',
    ['G04', Lokal]) :-
    gejala_terpilih('G04'),
    p01p02_satu_dari(['G13','G30a','G30b'], Lokal).

% P02-R03 — nyeri tenggorokan + nyeri menelan hebat.
% Sumber: artikel "Diagnosis Faringitis" (ref no. 2) — nyeri menelan
% termasuk keluhan faringitis; tipologi matriks G27 ○.
% Keterbatasan: nyeri menelan yang sangat berat tidak dapat dipastikan
% penyebabnya hanya dari gejala; keluhan berat semacam ini harus
% memicu pesan keselamatan di antarmuka, bukan kesimpulan aturan.
aturan_p01_p02('P02', 'P02-R03',
    'Nyeri tenggorokan yang disertai nyeri menelan hebat cocok dengan gejala faringitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan penyebab keluhan tidak dapat dipastikan dari gejala saja.',
    ['G04','G27']) :-
    gejala_terpilih('G04'),
    gejala_terpilih('G27').

% P02-R04 — nyeri tenggorokan + pola pernapasan atas (konteks viral).
% Sumber: artikel "Diagnosis Faringitis" (ref no. 2) — faringitis dapat
% berirama dengan gejala pernapasan atas; tipologi matriks G01/G02/
% G03/G05/G12 pada P02 bertipe ○* (konteks khusus).
% Keterbatasan: kecocokan aturan ini tidak menyatakan penyebab pasti;
% gejala hidung juga muncul pada P01 dan P03 sehingga beberapa kondisi
% dapat cocok bersamaan (ini perilaku yang diinginkan, bukan kesalahan).
aturan_p01_p02('P02', 'P02-R04',
    'Nyeri tenggorokan yang disertai gejala hidung atau perubahan suara (pilek, hidung tersumbat, bersin, batuk, suara serak) cocok dengan pola faringitis yang berirama dengan keluhan pernapasan atas. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G04', PolaAtas]) :-
    gejala_terpilih('G04'),
    p01p02_satu_dari(['G01','G02','G03','G05','G12'], PolaAtas).
