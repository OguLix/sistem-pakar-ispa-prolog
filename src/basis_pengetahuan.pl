gejala_info('G01', 'Hidung tersumbat').
gejala_info('G02', 'Pilek / ingus encer').
gejala_info('G03', 'Bersin-bersin').
gejala_info('G04', 'Nyeri tenggorokan').
gejala_info('G05', 'Batuk (jenis batuk menjadi detail)').
gejala_info('G07', 'Demam (suhu sebagai detail)').
gejala_info('G08a', 'Demam dengan suhu terukur 38 derajat Celsius atau lebih').
gejala_info('G08b', 'Menggigil').
gejala_info('G09', 'Sakit kepala').
gejala_info('G10', 'Nyeri otot / badan pegal').
gejala_info('G11', 'Badan lemas / lelah').
gejala_info('G12', 'Suara serak / berubah').
gejala_info('G13', 'Kelenjar leher nyeri / membesar').
gejala_info('G14', 'Sekret hidung purulen / kuning-hijau').
gejala_info('G15', 'Nyeri / tekanan di wajah').
gejala_info('G16', 'Penciuman menurun').
gejala_info('G17', 'Nyeri gigi rahang atas').
gejala_info('G18', 'Napas berbau').
gejala_info('G19', 'Sesak napas').
gejala_info('G20a', 'Mengi (wheezing)').
gejala_info('G20b', 'Napas berbunyi secara umum').
gejala_info('G21', 'Dada terasa berat / tertekan').
gejala_info('G22', 'Nyeri dada saat bernapas atau batuk').
gejala_info('G23', 'Gejala memburuk malam / dini hari').
gejala_info('G24', 'Dipicu alergen, olahraga, atau perubahan cuaca').
gejala_info('G25a', 'Detail dahak: warna').
gejala_info('G25b', 'Detail dahak: bau').
gejala_info('G25c', 'Detail dahak: jumlah').
gejala_info('G25d', 'Detail dahak: kekentalan').
gejala_info('G26', 'Mual').
gejala_info('G27', 'Nyeri menelan hebat').
gejala_info('G28', 'Post-nasal drip / lendir mengalir ke tenggorokan').
gejala_info('G29', 'Frekuensi napas meningkat (diukur)').
gejala_info('G30a', 'Pembengkakan amandel').
gejala_info('G30b', 'Eksudat / bercak putih amandel').
gejala_info('G31', 'Ronki / suara napas bronkial saat pemeriksaan').

gejala_tandai('G25a', detail_dahak).
gejala_tandai('G25b', detail_dahak).
gejala_tandai('G25c', detail_dahak).
gejala_tandai('G25d', detail_dahak).
gejala_tandai('G08a', perlu_pengukuran).
gejala_tandai('G29', perlu_pengukuran).
gejala_tandai('G31', perlu_pemeriksaan_ahli).

gejala_catatan('G05', 'Jenis batuk (kering/berdahak) disimpan sebagai detail_gejala, bukan dihitung sebagai gejala kedua.').
gejala_catatan('G07', 'Jika suhu diukur, simpan sebagai detail_gejala; suhu bukan bukti independen kedua dari demam.').
gejala_catatan('G08a', 'Hanya bermakna bersama G07 (demam) dan hanya jika suhu benar-benar diukur.').
gejala_catatan('G14', 'Tampilan sekret kuning-hijau bukan bukti pasti infeksi bakteri.').
gejala_catatan('G25a', 'Rincian dahak bersifat opsional; hanya bermakna bila batuk berdahak dipilih.').
gejala_catatan('G25b', 'Rincian dahak bersifat opsional; hanya bermakna bila batuk berdahak dipilih.').
gejala_catatan('G25c', 'Rincian dahak bersifat opsional; hanya bermakna bila batuk berdahak dipilih.').
gejala_catatan('G25d', 'Rincian dahak bersifat opsional; hanya bermakna bila batuk berdahak dipilih.').
gejala_catatan('G29', 'Frekuensi napas harus diukur, bukan perkiraan pengguna.').
gejala_catatan('G31', 'Temuan auskultasi hanya dari pemeriksaan tenaga kesehatan; jangan minta awam menebak.').

kondisi_info('P01', 'Common cold / selesma').
kondisi_info('P02', 'Faringitis').
kondisi_info('P03', 'Sinusitis akut').
kondisi_info('P04', 'Bronkitis akut').
kondisi_info('P05', 'Asma (pembanding noninfeksi)').
kondisi_info('P06', 'Pneumonia dewasa').

kondisi_noninfeksi('P05').

kode_gejala_valid(Kode) :- gejala_info(Kode, _).
kode_kondisi_valid(Kode) :- kondisi_info(Kode, _).

:- dynamic gejala_terpilih/1.
:- dynamic detail_gejala/2.

tambah_gejala(Kode) :-
    \+ gejala_info(Kode, _), !,
    format(user_error, 'Kode gejala tidak dikenal: ~w (lihat gejala_info/2)~n', [Kode]),
    fail.
tambah_gejala(Kode) :-
    gejala_tandai(Kode, detail_dahak), !,
    format(user_error, 'Kode ~w adalah detail dahak; gunakan tambah_detail/2, bukan tambah_gejala/1.~n', [Kode]),
    fail.
tambah_gejala('G08a') :-
    \+ gejala_terpilih('G07'), !,
    format(user_error, 'G08a hanya dapat dicatat bersama G07 (demam). Tambahkan G07 dahulu.~n', []),
    fail.
tambah_gejala(Kode) :-
    ( gejala_terpilih(Kode)
    -> true
    ; assertz(gejala_terpilih(Kode))
    ).

kode_induk_detail(Kode, Kode) :-
    gejala_info(Kode, _),
    \+ gejala_tandai(Kode, detail_dahak).
kode_induk_detail('G25a', 'G05').
kode_induk_detail('G25b', 'G05').
kode_induk_detail('G25c', 'G05').
kode_induk_detail('G25d', 'G05').

tambah_detail(Kode, _Nilai) :-
    \+ gejala_info(Kode, _), !,
    format(user_error, 'Kode detail tidak dikenal: ~w (lihat gejala_info/2)~n', [Kode]),
    fail.
tambah_detail(Kode, _Nilai) :-
    kode_induk_detail(Kode, Induk),
    \+ gejala_terpilih(Induk), !,
    format(user_error, 'Detail ~w hanya dapat dicatat jika gejala induk ~w terpilih.~n', [Kode, Induk]),
    fail.
tambah_detail(Kode, Nilai) :-
    retractall(detail_gejala(Kode, _)),
    assertz(detail_gejala(Kode, Nilai)).

hapus_gejala(Kode) :-
    retractall(gejala_terpilih(Kode)),
    retractall(detail_gejala(Kode, _)),
    ( Kode == 'G05'
    -> forall(gejala_tandai(D, detail_dahak), retractall(detail_gejala(D, _)))
    ;  true
    ).

reset_sesi :-
    retractall(gejala_terpilih(_)),
    retractall(detail_gejala(_, _)).

daftar_gejala_terpilih(Daftar) :-
    findall(Kode, gejala_terpilih(Kode), KodeMentah),
    sort(KodeMentah, Daftar).

daftar_detail(Daftar) :-
    findall(detail_gejala(Kode, Nilai), detail_gejala(Kode, Nilai), Mentah),
    sort(Mentah, Daftar).
