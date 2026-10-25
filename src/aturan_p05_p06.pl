p05p06_satu_dari([Kode|_], Kode) :-
    gejala_terpilih(Kode).
p05p06_satu_dari([Kode|Sisa], Pilihan) :-
    \+ gejala_terpilih(Kode),
    p05p06_satu_dari(Sisa, Pilihan).

aturan_p05_p06('P05', 'P05-R01',
    'Kombinasi sesak napas dan mengi yang dipilih cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi; gejala ini juga dapat muncul pada kondisi lain. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G19','G20a']) :-
    gejala_terpilih('G19'),
    gejala_terpilih('G20a').

aturan_p05_p06('P05', 'P05-R02',
    'Sesak napas atau mengi yang disertai dada terasa berat/tertekan cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G21']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G21').

aturan_p05_p06('P05', 'P05-R03',
    'Sesak napas atau mengi yang memburuk pada malam atau dini hari cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G23']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G23').

aturan_p05_p06('P05', 'P05-R04',
    'Sesak napas atau mengi yang dipicu alergen, olahraga, atau perubahan cuaca cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G24']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G24').

aturan_p05_p06('P05', 'P05-R05',
    'Sesak napas atau mengi yang disertai batuk cocok dengan pola gejala asma yang dideskripsikan WHO. Asma adalah pembanding noninfeksi, bukan ISPA infeksi; batuk juga umum pada infeksi saluran pernapasan lain. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    [Jangkar,'G05']) :-
    p05p06_satu_dari(['G19','G20a'], Jangkar),
    gejala_terpilih('G05').

aturan_p05_p06('P05', 'P05-R06',
    'Napas berbunyi secara umum yang disertai dada terasa berat/tertekan cocok dengan pola gejala yang dapat ditemukan pada asma. Asma adalah pembanding noninfeksi, bukan ISPA infeksi; bunyi napas juga dapat terjadi pada kondisi lain. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis.',
    ['G20b','G21']) :-
    gejala_terpilih('G20b'),
    gejala_terpilih('G21').

aturan_p05_p06('P06', 'P06-R01',
    'Kombinasi batuk, demam, dan sesak napas yang dipilih cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan, termasuk pemeriksaan yang tidak dapat dilakukan dari keluhan saja.',
    ['G05','G07','G19']) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G07'),
    gejala_terpilih('G19').

aturan_p05_p06('P06', 'P06-R02',
    'Demam atau menggigil yang disertai badan lemas dan sesak napas cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    [Demam,'G11','G19']) :-
    p05p06_satu_dari(['G07','G08b'], Demam),
    gejala_terpilih('G11'),
    gejala_terpilih('G19').

aturan_p05_p06('P06', 'P06-R03',
    'Sesak napas yang disertai nyeri dada saat bernapas atau batuk, bersama batuk atau demam, cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    ['G19','G22',Pemicu]) :-
    gejala_terpilih('G19'),
    gejala_terpilih('G22'),
    p05p06_satu_dari(['G05','G07'], Pemicu).

aturan_p05_p06('P06', 'P06-R04',
    'Batuk dan demam yang disertai salah satu keluhan umum (sakit kepala, nyeri otot/badan pegal, atau mual) cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan keluhan umum tersebut tidak spesifik untuk pneumonia.',
    ['G05','G07',Sistemik]) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G07'),
    p05p06_satu_dari(['G09','G10','G26'], Sistemik).

aturan_p05_p06('P06', 'P06-R05',
    'Demam dengan suhu terukur 38 derajat Celsius atau lebih, disertai menggigil dan sesak napas, cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    ['G08a','G08b','G19']) :-
    gejala_terpilih('G08a'),
    gejala_terpilih('G08b'),
    gejala_terpilih('G19').

aturan_p05_p06('P06', 'P06-R06',
    'Batuk dan sesak napas yang disertai temuan pengukuran atau pemeriksaan (frekuensi napas meningkat atau ronki/suara napas bronkial) cocok dengan pola gejala pneumonia yang dideskripsikan WHO. Temuan tersebut hanya bermakna bila berasal dari pengukuran atau pemeriksaan, bukan perkiraan. Aturan ini cocok dengan gejala yang dipilih; hasil bukan diagnosis medis dan perlu evaluasi tenaga kesehatan.',
    ['G05','G19',PendukungKlinis]) :-
    gejala_terpilih('G05'),
    gejala_terpilih('G19'),
    p05p06_satu_dari(['G29','G31'], PendukungKlinis).
