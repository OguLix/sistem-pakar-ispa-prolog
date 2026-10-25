p03p04_satu_dari([Kode|_], Kode) :-
    gejala_terpilih(Kode).
p03p04_satu_dari([Kode|Sisa], Pilihan) :-
    \+ gejala_terpilih(Kode),
    p03p04_satu_dari(Sisa, Pilihan).

p03p04_detail_dari([Kode|_], Kode) :-
    detail_gejala(Kode, _).
p03p04_detail_dari([Kode|Sisa], Pilihan) :-
    \+ detail_gejala(Kode, _),
    p03p04_detail_dari(Sisa, Pilihan).

aturan_p03_p04('P03', 'P03-R01',
    'Kombinasi gejala hidung (pilek atau hidung tersumbat) yang dipilih disertai nyeri atau tekanan di wajah cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G15']) :-
    p03p04_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G15').

aturan_p03_p04('P03', 'P03-R02',
    'Kombinasi pilek dan hidung tersumbat yang dipilih disertai sekret hidung kekuningan/kehijauan cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis, dan warna sekret bukan bukti infeksi bakteri.',
    ['G01','G02','G14']) :-
    gejala_terpilih('G01'),
    gejala_terpilih('G02'),
    gejala_terpilih('G14').

aturan_p03_p04('P03', 'P03-R03',
    'Gejala hidung yang dipilih disertai salah satu keluhan khas sinus (penciuman menurun, nyeri gigi rahang atas, atau napas berbau) cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, Spesifik]) :-
    p03p04_satu_dari(['G01','G02'], Jangkar),
    p03p04_satu_dari(['G16','G17','G18'], Spesifik).

aturan_p03_p04('P03', 'P03-R04',
    'Gejala hidung yang dipilih disertai salah satu keluhan pendukung (demam, sakit kepala, atau lendir mengalir ke tenggorokan) cocok dengan pola sinusitis menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, Pendukung]) :-
    p03p04_satu_dari(['G01','G02'], Jangkar),
    p03p04_satu_dari(['G07','G09','G28'], Pendukung).

aturan_p03_p04('P04', 'P04-R01',
    'Batuk yang disertai demam atau menggigil cocok dengan gejala bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan tidak menentukan penyebab infeksi.',
    ['G05', Pdemam]) :-
    gejala_terpilih('G05'),
    p03p04_satu_dari(['G07','G08b'], Pdemam).

aturan_p03_p04('P04', 'P04-R02',
    'Batuk yang disertai sesak napas atau napas berbunyi cocok dengan gejala bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis, dan keluhan serupa juga dapat muncul pada kondisi lain.',
    ['G05', Pnapas]) :-
    gejala_terpilih('G05'),
    p03p04_satu_dari(['G19','G20a','G20b'], Pnapas).

aturan_p03_p04('P04', 'P04-R03',
    'Batuk yang disertai nyeri dada saat bernapas atau batuk cocok dengan gejala bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G05','G22']) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G22').

aturan_p03_p04('P04', 'P04-R04',
    'Batuk yang disertai salah satu keluhan pendukung (nyeri tenggorokan, sakit kepala, badan lemas, atau suara serak) cocok dengan pola bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G05', Pumum]) :-
    gejala_terpilih('G05'),
    p03p04_satu_dari(['G04','G09','G11','G12'], Pumum).

aturan_p03_p04('P04', 'P04-R05',
    'Batuk berdahak yang disertai rincian dahak (warna, bau, jumlah, atau kekentalan) cocok dengan pola bronkitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis, dan warna dahak bukan bukti infeksi bakteri.',
    ['G05', DetailDahak]) :-
    gejala_terpilih('G05'),
    detail_gejala('G05', 'berdahak'),
    p03p04_detail_dari(['G25a','G25b','G25c','G25d'], DetailDahak).
