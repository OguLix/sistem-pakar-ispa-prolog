% =====================================================================
% aturan_p05_p06.pl — Aturan P05 (Asma) dan P06 (Pneumonia dewasa)
% Pemilik file: Anggota 3 (lihat docs/pembagian_tugas.md)
%
% Kontrak integrasi (agent.md §6; docs/arsitektur.md):
%   aturan_p05_p06(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
%
% - Fakta sesi `gejala_terpilih/1` dibaca dari src/basis_pengetahuan.pl
%   (milik Anggota 4). File ini TIDAK mendefinisikan fakta tersebut.
% - `KodeKondisi` dan kode gejala memakai atom 'P05', 'P06', 'G19', dst.
% - `Penjelasan` memakai teks (atom berkuota tunggal) agar enak dibaca.
% - Setiap klausa dirancang mengembalikan tepat satu baris hasil bila
%   cocok, agar mesin inferensi tidak perlu membuang duplikat.
%
% Batas medis (agent.md §3): aturan hanya menyatakan kecocokan pola
% gejala ("kondisi yang mungkin sesuai"), bukan diagnosis final.
% File ini tidak memuat resep, dosis obat, atau klaim sensitivitas/
% spesifisitas/akurasi. Pesan keselamatan untuk keluhan berat (sesak
% berat, nyeri dada berat, kebingungan, kondisi cepat memburuk) adalah
% bagian dari antarmuka, bukan kesimpulan aturan di sini.
%
% Catatan sumber: rujukan gejala mengikuti docs/referensi.md (tanggal
% akses 19 Oktober 2026). PNPK pneumonia dewasa Kemenkes (referensi
% no. 1) dicatat sebagai pedoman rujukan utama P06, tetapi halaman
% spesifik dokumen resminya belum dibaca per klausa; karena itu setiap
% aturan menautkan sumber gejala yang benar-benar tercatat (WHO, ref
% no. 8 dan no. 9) dan tidak mengklaim kriteria diagnosis mandiri
% (agent.md §7; docs/referensi.md, bagian cara mencatat referensi).
% =====================================================================

% ---------------------------------------------------------------------
% Helper (prefiks p05p06_ agar tidak bentrok dengan file aturan lain).
%
% p05p06_satu_dari(+DaftarKandidat, -Kode)
% Mengembalikan kode PERTAMA dalam DaftarKandidat yang memang terpilih
% pengguna pada sesi ini. Bila tidak ada yang terpilih, predikat gagal
% sehingga aturan pemakainya juga tidak cocok.
%
% Predikat ini deterministik: untuk fakta sesi yang sama ia selalu
% mengembalikan satu jawaban yang sama, sehingga satu klausa aturan
% tidak menghasilkan beberapa baris hanya karena beberapa gejala
% kandidat terpilih sekaligus.
% ---------------------------------------------------------------------
p05p06_satu_dari([Kode|_], Kode) :-
    gejala_terpilih(Kode).
p05p06_satu_dari([Kode|Sisa], Pilihan) :-
    \+ gejala_terpilih(Kode),
    p05p06_satu_dari(Sisa, Pilihan).

% =====================================================================
% P05 — Asma (pembanding noninfeksi)
% Sumber utama: WHO, "Asthma" — dokumen referensi no. 8
% (docs/referensi.md; tanggal akses 19 Oktober 2026). WHO
% mendeskripsikan gejala asma: mengi, sesak napas, dada terasa berat,
% batuk, gejala yang dapat memburuk pada malam/dini hari, dan yang
% dapat dipicu aktivitas atau pemicu tertentu.
%
% Pemetaan matriks (docs/matriks_basis_pengetahuan.md):
%   ●  G19 sesak napas, G20a mengi, G21 dada terasa berat,
%      G23 memburuk malam/dini hari, G24 dipicu alergen/olahraga/
%      perubahan cuaca;
%   ○  G05 batuk, G20b napas berbunyi secara umum.
%
% Penegasan status (agent.md §1; docs/matriks_basis_pengetahuan.md):
% P05 asma adalah PEMBANDING NONINFEKSI, bukan penyakit ISPA infeksi.
% Setiap penjelasan aturan di bagian ini menyatakan hal itu agar
% hasil tidak dibaca sebagai salah satu kemudian infeksi saluran
% pernapasan. Mengi atau sesak juga dapat muncul pada kondisi lain,
% sehingga tidak ada aturan yang mengklaim asma pasti dari gejala ini.
%
% Batuk (G05, ○) tidak pernah menjadi syarat tunggal pada aturan P05;
% selalu berpasangan dengan gejala ● lain (agent.md §7: satu gejala
% umum tidak cukup).
% =====================================================================

% P05-R01 — sesak napas + mengi (dua simbol ●).
% Sumber: WHO Asthma (ref no. 8) — mengi dan sesak disebut sebagai
% gejala asma.
aturan_p05_p06('P05', 'P05-R01',
    'Kombinasi sesak napas dan mengi yang dipilih cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi; gejala ini juga dapat muncul pada kondisi lain. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G19','G20a']) :-
    gejala_terpilih('G19'),
    gejala_terpilih('G20a').

% P05-R02 — sesak/mengi + dada terasa berat (G21 ●).
% Sumber: WHO Asthma (ref no. 8) — dada terasa berat termasuk gejala.
aturan_p05_p06('P05', 'P05-R02',
    'Sesak napas atau mengi yang disertai dada terasa berat/tertekan cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G21']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G21').

% P05-R03 — sesak/mengi + pola memburuk malam/dini hari (G23 ●).
% Sumber: WHO Asthma (ref no. 8) — gejala dapat memburuk pada malam
% atau dini hari.
aturan_p05_p06('P05', 'P05-R03',
    'Sesak napas atau mengi yang memburuk pada malam atau dini hari cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G23']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G23').

% P05-R04 — sesak/mengi + faktor pencetus (G24 ●).
% Sumber: WHO Asthma (ref no. 8) — gejala dapat dipicu aktivitas
% atau pemicu tertentu (matriks: alergen, olahraga, perubahan cuaca).
aturan_p05_p06('P05', 'P05-R04',
    'Sesak napas atau mengi yang dipicu alergen, olahraga, atau perubahan cuaca cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G24']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G24').

% P05-R05 — sesak/mengi + batuk (G05 ○).
% Sumber: WHO Asthma (ref no. 8) — batuk termasuk gejala asma.
% Keterbatasan: batuk bertipe ○ (tidak spesifik) dan menjadi syarat
% hanya bersama gejala ● lain; jenis batuk adalah detail G05, bukan
% gejala kedua yang dihitung terpisah (agent.md §6).
aturan_p05_p06('P05', 'P05-R05',
    'Sesak napas atau mengi yang disertai batuk cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi; batuk juga umum pada infeksi saluran pernapasan lain. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G05']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G05').

% P05-R06 — pola napas berbunyi (G20a/G20b) + dada berat, tanpa G19.
% Varian tanpa keluhan sesak yang eksplisit; menangkap pengguna yang
% mencatat bunyi napas dan rasa berat dada saja.
% Keterbatasan: G20b bertipe ○ (napas berbunyi secara umum tidak
% spesifik wheezing) sehingga aturan ini tetap hanya menyatakan
% kecocokan pola, bukan klaim asma.
aturan_p05_p06('P05', 'P05-R06',
    'Mengi atau napas berbunyi yang disertai dada terasa berat/tertekan cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi; bunyi napas juga dapat terjadi pada kondisi lain. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Bunyi,'G21']) :-
    p05p06_satu_dari(['G20a','G20b'], Bunyi),
    gejala_terpilih('G21').

% =====================================================================
% P06 — Pneumonia dewasa
% Sumber utama: WHO, "Pneumonia" — dokumen referensi no. 9
% (docs/referensi.md; tanggal akses 19 Oktober 2026): batuk, sesak
% napas, demam/menggigil, kelelahan, nyeri dada, dan kemungkinan
% gejala lain. Rujukan pedoman klinis Indonesia: PNPK pneumonia pada
% dewasa Kemenkes (referensi no. 1), yang perlu dibaca langsung
% sebelum mengklaim kriteria diagnosis lebih rinci (mis. ambang
% frekuensi napas atau temuan pemeriksaan fisik).
%
% Pemetaan matriks (docs/matriks_basis_pengetahuan.md):
%   ●  G05 batuk, G07 demam, G08a suhu >=38 derajat Celsius,
%      G08b menggigil, G19 sesak napas, G29 frekuensi napas meningkat;
%   ○  G09 sakit kepala, G10 nyeri otot/badan pegal, G11 badan lemas,
%      G22 nyeri dada saat bernapas/batuk, G25a detail dahak warna,
%      G25c detail dahak jumlah, G31 ronki/suara napas bronkial;
%   ○* G26 mual (konteks khusus).
%
% Catatan kepatuhan (agent.md §6; docs/matriks_basis_pengetahuan.md):
% - G07 dan G08a tidak dihitung ganda sebagai bukti independen:
%   G08a adalah penyempurnaan demam dan hanya dapat dicatat bila G07
%   sudah terpilih (dijamin basis_pengetahuan.pl).
% - G29 dan G31 memerlukan pengukuran/pemeriksaan oleh orang yang
%   kompeten. Keduanya hanya dipakai sebagai PENDUKUNG OPSIONAL pada
%   P06-R06: muncul dalam GejalaPendukung hanya bila pengguna benar-
%   benar mencatatnya, dan tidak pernah menjadi satu-satunya syarat.
%   Jangan minta pengguna awam menebak nilai ini.
% - G25a (warna dahak) TIDAK dijadikan syarat aturan mana pun: warna
%   dahak kuning/hijau bukan bukti pasti infeksi bakteri
%   (docs/referensi.md; agent.md §7).
% - Keluhan berat yang mungkin menyertai pneumonia adalah urusan pesan
%   keselamatan antarmuka, bukan kesimpulan aturan di sini.
% =====================================================================

% P06-R01 — batuk + demam + sesak napas (tiga simbol ●).
% Sumber: WHO Pneumonia (ref no. 9) — batuk, demam, dan sesak napas
% disebut sebagai gejala pneumonia.
aturan_p05_p06('P06', 'P06-R01',
    'Kombinasi batuk, demam, dan sesak napas yang dipilih cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan, termasuk pemeriksaan yang tidak dapat dilakukan dari keluhan saja.',
    ['G05','G07','G19']) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G07'),
    gejala_terpilih('G19').

% P06-R02 — demam/menggigil + badan lemas + sesak napas.
% Sumber: WHO Pneumonia (ref no. 9) — demam/menggigil, kelelahan,
% dan sesak napas termasuk gejala yang dideskripsikan.
% Keterbatasan: kombinasi ini juga dapat muncul pada infeksi lain;
% aturan tidak menyatakan berat-ringannya pneumonia.
aturan_p05_p06('P06', 'P06-R02',
    'Demam atau menggigil yang disertai badan lemas dan sesak napas cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    [Demam,'G11','G19']) :-
    p05p06_satu_dari(['G07','G08b'], Demam),
    gejala_terpilih('G11'),
    gejala_terpilih('G19').

% P06-R03 — sesak + nyeri dada saat bernapas/batuk + batuk atau demam.
% Sumber: WHO Pneumonia (ref no. 9) — nyeri dada termasuk gejala yang
% dideskripsikan; tipologi matriks G22 ○ pada P06.
% Keterbatasan: nyeri dada berat yang menetap termasuk keluhan yang
% harus memicu pesan keselamatan di antarmuka, bukan disimpulkan
% berat-ringannya di sini (agent.md §3).
aturan_p05_p06('P06', 'P06-R03',
    'Sesak napas yang disertai nyeri dada saat bernapas atau batuk, bersama batuk atau demam, cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    ['G19','G22',Pemicu]) :-
    gejala_terpilih('G19'),
    gejala_terpilih('G22'),
    p05p06_satu_dari(['G05','G07'], Pemicu).

% P06-R04 — batuk + demam + salah satu keluhan sistemik.
% Sumber: WHO Pneumonia (ref no. 9) — kelelahan termasuk gejala;
% tipologi matriks G09 ○, G10 ○, G26 ○* (konteks khusus).
% Keterbatasan: G26 (mual) bertipe konteks khusus pada matriks dan
% dipakai hanya sebagai pendukung bersama pola ●, bukan pembeda
% penyakit (agent.md §2, prinsip 9).
aturan_p05_p06('P06', 'P06-R04',
    'Batuk dan demam yang disertai salah satu keluhan umum (sakit kepala, nyeri otot/badan pegal, atau mual) cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan keluhan umum tersebut tidak spesifik untuk pneumonia.',
    ['G05','G07',Sistemik]) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G07'),
    p05p06_satu_dari(['G09','G10','G26'], Sistemik).

% P06-R05 — suhu terukur >=38 derajat Celsius + menggigil + sesak.
% Sumber: WHO Pneumonia (ref no. 9) — demam/menggigil dan sesak
% napas; tipologi matriks G08a ●, G08b ○ pada P06.
% Keterbatasan: G08a hanya bermakna bila suhu benar-benar diukur dan
% hanya dapat dicatat bersama G07 (dijamin basis_pengetahuan.pl);
% aturan ini tidak menghitung G07 dan G08a sebagai dua bukti
% independen dan tidak menyatakan penyebab bakteri maupun tingkat
% keparahan (agent.md §6).
aturan_p05_p06('P06', 'P06-R05',
    'Demam dengan suhu terukur 38 derajat Celsius atau lebih, disertai menggigil dan sesak napas, cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    ['G08a','G08b','G19']) :-
    gejala_terpilih('G08a'),
    gejala_terpilih('G08b'),
    gejala_terpilih('G19').

% P06-R06 — batuk + sesak + pendukung klinis opsional (G29/G31).
% Sumber: WHO Pneumonia (ref no. 9) — batuk dan sesak napas;
% tipologi matriks G29 ●, G31 ○ untuk pneumonia. Frekuensi napas
% dan temuan auskultasi sesungguhnya dinilai pemeriksaan klinis
% (PNPK Kemenkes, referensi no. 1); di sini keduanya HANYA dipakai
% sebagai pendukung opsional bila pengguna mencatat hasil
% pengukuran/pemeriksaan yang sebenarnya.
% Keterbatasan: pengguna awam tidak boleh menebak G29/G31; nilai
% tebakan membuat aturan ini tidak valid. Syarat inti tetap batuk
% dan sesak napas, bukan temuan klinis (agent.md §6, §7;
% docs/matriks_basis_pengetahuan.md, bagian definisi input).
aturan_p05_p06('P06', 'P06-R06',
    'Batuk dan sesak napas yang disertai temuan pengukuran atau pemeriksaan (frekuensi napas meningkat atau ronki/suara napas bronkial) cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Temuan tersebut hanya bermakna bila berasal dari pengukuran atau pemeriksaan, bukan perkiraan. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    ['G05','G19',PendukungKlinis]) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G19'),
    p05p06_satu_dari(['G29','G31'], PendukungKlinis).
