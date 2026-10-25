p01p02_satu_dari([Kode|_], Kode) :-
    gejala_terpilih(Kode).
p01p02_satu_dari([Kode|Sisa], Pilihan) :-
    \+ gejala_terpilih(Kode),
    p01p02_satu_dari(Sisa, Pilihan).

aturan_p01_p02('P01', 'P01-R01',
    'Kombinasi hidung tersumbat dan pilek yang dipilih cocok dengan pola hidung utama selesma (common cold) menurut CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G01','G02']) :-
    gejala_terpilih('G01'),
    gejala_terpilih('G02').

aturan_p01_p02('P01', 'P01-R02',
    'Gejala hidung yang dipilih disertai bersin-bersin cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G03']) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G03').

aturan_p01_p02('P01', 'P01-R03',
    'Gejala hidung yang dipilih disertai nyeri tenggorokan cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G04']) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G04').

aturan_p01_p02('P01', 'P01-R04',
    'Gejala hidung yang dipilih disertai batuk cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, 'G05']) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    gejala_terpilih('G05').

aturan_p01_p02('P01', 'P01-R05',
    'Gejala hidung yang dipilih disertai salah satu keluhan umum selesma (sakit kepala, pegal/nyeri otot, badan lemas, suara serak, atau lendir mengalir ke tenggorokan) cocok dengan pola selesma yang dideskripsikan CDC. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar, Pendukung]) :-
    p01p02_satu_dari(['G01','G02'], Jangkar),
    p01p02_satu_dari(['G09','G10','G11','G12','G28'], Pendukung).

aturan_p01_p02('P02', 'P02-R01',
    'Nyeri tenggorokan yang disertai demam atau menggigil cocok dengan gejala faringitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan tidak menyatakan penyebab virus maupun bakteri.',
    ['G04', Pendemam]) :-
    gejala_terpilih('G04'),
    p01p02_satu_dari(['G07','G08a','G08b'], Pendemam).

aturan_p01_p02('P02', 'P02-R02',
    'Nyeri tenggorokan yang disertai kelenjar leher nyeri/membesar atau temuan pada amandel cocok dengan gejala faringitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; temuan pada amandel bukan bukti infeksi bakteri.',
    ['G04', Lokal]) :-
    gejala_terpilih('G04'),
    p01p02_satu_dari(['G13','G30a','G30b'], Lokal).

aturan_p01_p02('P02', 'P02-R03',
    'Nyeri tenggorokan yang disertai nyeri menelan hebat cocok dengan gejala faringitis yang dirujuk sumber Kemenkes. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan penyebab keluhan tidak dapat dipastikan dari gejala saja.',
    ['G04','G27']) :-
    gejala_terpilih('G04'),
    gejala_terpilih('G27').

aturan_p01_p02('P02', 'P02-R04',
    'Nyeri tenggorokan yang disertai gejala hidung atau perubahan suara (pilek, hidung tersumbat, bersin, batuk, suara serak) cocok dengan pola faringitis yang berirama dengan keluhan pernapasan atas. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G04', PolaAtas]) :-
    gejala_terpilih('G04'),
    p01p02_satu_dari(['G01','G02','G03','G05','G12'], PolaAtas).
