% =====================================================================
% tests/tests.pl - PL-Unit Sistem Pakar ISPA
% File bersama tim (agent.md 5). Jalankan dari root repo:
%   swipl -q -s tests/tests.pl -g run_tests -t halt
%
% File ini TIDAK memuat src/main.pl, agar aplikasi tidak berjalan
% saat pengujian; file src dimuat satu per satu dengan jalur relatif
% terhadap lokasi file tests ini.
%
% Cakupan (docs/rencana_pengujian.md):
% - T01-T12.
% - Kasus positif dan negatif untuk SELURUH 30 klausa aturan melalui
%   tabel kasus_aturan/7; setiap baris tabel dipecah menjadi satu tes
%   statis bernama memuat IdAturan (pos_P01_R01, neg_P01_R01, ...) agar
%   kegagalan selalu menyebut IdAturan spesifik.
% - Guard G08a tanpa G07, penolakan detail tanpa gejala induk, "detail
%   bukan gejala", reset antar sesi, beberapa kondisi cocok bersamaan,
%   P05 tampil sebagai pembanding noninfeksi, tanda bahaya muncul di
%   atas hasil, dan pemindaian frasa terlarang dengan pencocokan frasa
%   utuh per token ("dipastikan" tidak dianggap melanggar "pasti").
% - Tidak ada tes interaktif yang bergantung pada stdin sungguhan;
%   tes interaksi memakai predikat murni antarmuka.
% =====================================================================

:- use_module(library(plunit)).

% Muat file src satu per satu, jalur relatif terhadap file ini.
muat_src(DirRoot, Nama) :-
    atomics_to_string([DirRoot, '/src/', Nama], Jalur),
    consult(Jalur).

:- prolog_load_context(source, SumberTes),
   file_directory_name(SumberTes, DirTes),
   file_directory_name(DirTes, DirRoot),
   maplist(muat_src(DirRoot),
           ['basis_pengetahuan.pl',
            'aturan_p01_p02.pl',
            'aturan_p03_p04.pl',
            'aturan_p05_p06.pl',
            'mesin_inferensi.pl',
            'antarmuka.pl']).

% ---------------------------------------------------------------------
% Helper tes: isi fakta sesi lewat API resmi saja (tambah_gejala,
% tambah_detail, reset_sesi). Tidak ada assertz/retract langsung.
% ---------------------------------------------------------------------
isi_sesi(Gejala, Detail) :-
    reset_sesi,
    forall(member(Kode, Gejala), tambah_gejala(Kode)),
    isi_detail(Detail).

isi_detail(none) :- !.
isi_detail(Daftar) :-
    forall(member(Kode-Nilai, Daftar), tambah_detail(Kode, Nilai)).

% ---------------------------------------------------------------------
% Tabel kasus uji per klausa aturan: 30 klausa, masing-masing satu
% kasus positif dan satu kasus negatif (salah satu syarat dihilangkan).
% Kolom: sumber, kondisi, IdAturan, gejala pos, detail pos,
%        gejala neg, detail neg.
% ---------------------------------------------------------------------
kasus_aturan(aturan_p01_p02, 'P01', 'P01-R01', ['G01','G02'], none, ['G01'], none).
kasus_aturan(aturan_p01_p02, 'P01', 'P01-R02', ['G02','G03'], none, ['G03'], none).
kasus_aturan(aturan_p01_p02, 'P01', 'P01-R03', ['G01','G04'], none, ['G04'], none).
kasus_aturan(aturan_p01_p02, 'P01', 'P01-R04', ['G01','G05'], none, ['G05'], none).
kasus_aturan(aturan_p01_p02, 'P01', 'P01-R05', ['G02','G10'], none, ['G10'], none).
kasus_aturan(aturan_p01_p02, 'P02', 'P02-R01', ['G04','G07'], none, ['G07'], none).
kasus_aturan(aturan_p01_p02, 'P02', 'P02-R02', ['G04','G30b'], none, ['G30b'], none).
kasus_aturan(aturan_p01_p02, 'P02', 'P02-R03', ['G04','G27'], none, ['G27'], none).
kasus_aturan(aturan_p01_p02, 'P02', 'P02-R04', ['G04','G12'], none, ['G12'], none).
kasus_aturan(aturan_p03_p04, 'P03', 'P03-R01', ['G01','G15'], none, ['G15'], none).
kasus_aturan(aturan_p03_p04, 'P03', 'P03-R02', ['G01','G02','G14'], none, ['G14'], none).
kasus_aturan(aturan_p03_p04, 'P03', 'P03-R03', ['G02','G17'], none, ['G17'], none).
kasus_aturan(aturan_p03_p04, 'P03', 'P03-R04', ['G01','G09'], none, ['G09'], none).
kasus_aturan(aturan_p03_p04, 'P04', 'P04-R01', ['G05','G08b'], none, ['G08b'], none).
kasus_aturan(aturan_p03_p04, 'P04', 'P04-R02', ['G05','G20a'], none, ['G20a'], none).
kasus_aturan(aturan_p03_p04, 'P04', 'P04-R03', ['G05','G22'], none, ['G22'], none).
kasus_aturan(aturan_p03_p04, 'P04', 'P04-R04', ['G05','G12'], none, ['G12'], none).
kasus_aturan(aturan_p03_p04, 'P04', 'P04-R05',
             ['G05'], ['G05'-'berdahak', 'G25a'-'kuning_hijau'],
             ['G05'], ['G05'-'kering', 'G25a'-'kuning_hijau']).
kasus_aturan(aturan_p05_p06, 'P05', 'P05-R01', ['G19','G20a'], none, ['G20a'], none).
kasus_aturan(aturan_p05_p06, 'P05', 'P05-R02', ['G19','G21'], none, ['G21'], none).
kasus_aturan(aturan_p05_p06, 'P05', 'P05-R03', ['G19','G23'], none, ['G23'], none).
kasus_aturan(aturan_p05_p06, 'P05', 'P05-R04', ['G20a','G24'], none, ['G24'], none).
kasus_aturan(aturan_p05_p06, 'P05', 'P05-R05', ['G19','G05'], none, ['G05'], none).
kasus_aturan(aturan_p05_p06, 'P05', 'P05-R06', ['G20b','G21'], none, ['G21'], none).
kasus_aturan(aturan_p05_p06, 'P06', 'P06-R01', ['G05','G07','G19'], none, ['G05','G07'], none).
kasus_aturan(aturan_p05_p06, 'P06', 'P06-R02', ['G07','G11','G19'], none, ['G11','G19'], none).
kasus_aturan(aturan_p05_p06, 'P06', 'P06-R03', ['G19','G22','G05'], none, ['G19','G22'], none).
kasus_aturan(aturan_p05_p06, 'P06', 'P06-R04', ['G05','G07','G09'], none, ['G09'], none).
kasus_aturan(aturan_p05_p06, 'P06', 'P06-R05', ['G07','G08a','G08b','G19'], none, ['G07','G08a','G19'], none).
kasus_aturan(aturan_p05_p06, 'P06', 'P06-R06', ['G05','G19','G29'], none, ['G05','G19'], none).

% ---------------------------------------------------------------------
% Helper pemindaian frasa terlarang: frasa utuh per token (huruf kecil),
% bukan substring, sehingga "dipastikan" tidak dianggap "pasti".
% ---------------------------------------------------------------------
frasa_terlarang([['pasti', 'menderita'],
                 ['pasti', 'terkena'],
                 ['pasti', 'sehat'],
                 ['diagnosis', 'final'],
                 ['diagnosis', 'pasti'],
                 ['dipastikan', 'menderita'],
                 ['resep'],
                 ['dosis'],
                 ['antibiotik']]).

tokenisasi(TeksMasukan, Tok) :-
    ( atom(TeksMasukan)
    -> atom_string(TeksMasukan, Str)
    ;  Str = TeksMasukan
    ),
    split_string(Str, " .,;:()[]-/", "", Mentah),
    maplist(tok_kecil, Mentah, Tok).

tok_kecil(S, A) :-
    atom_string(A1, S),
    downcase_atom(A1, A).

frasa_am(Tok) :-
    frasa_terlarang(Daftar),
    forall(member(F, Daftar), \+ frasa_di(F, Tok)).

frasa_di(F, Tok) :-
    append(_, Sisa, Tok),
    append(F, _, Sisa).

% Kumpulkan seluruh Penjelasan dari tiga predikat aturan (tanpa
% mengevaluasi syarat aturan; clause/2 hanya mengambil kepala klausa).
aturan_penjelasan(P) :- clause(aturan_p01_p02(_, _, P, _), _).
aturan_penjelasan(P) :- clause(aturan_p03_p04(_, _, P, _), _).
aturan_penjelasan(P) :- clause(aturan_p05_p06(_, _, P, _), _).

% ---------------------------------------------------------------------
% Suite tes
% ---------------------------------------------------------------------
:- begin_tests(sistem_pakar_ispa).

% T01: file termuat dan predikat kunci tersedia.
test(t01_file_termuat) :-
    current_predicate(gejala_info/2),
    current_predicate(tambah_gejala/1),
    current_predicate(tambah_detail/2),
    current_predicate(reset_sesi/0),
    current_predicate(inferensi/2),
    current_predicate(kelompokkan_hasil/2),
    current_predicate(susun_keluaran/4).

% T02: tidak ada gejala dipilih; tidak menyimpulkan penyakit.
test(t02_tanpa_gejala) :-
    reset_sesi,
    inferensi(belum_ada_gejala, []).

% T03: hanya satu gejala umum tidak menyatakan kondisi.
test(t03_satu_gejala_umum) :-
    isi_sesi(['G05'], none),
    inferensi(tidak_ada_aturan_cocok, []).

% T04: aturan yang ditentukan muncul dengan ID dan alasan sesuai.
test(t04_satu_aturan_cocok_berserta_alasan) :-
    isi_sesi(['G01', 'G02'], none),
    inferensi(ada_hasil, Hasil),
    Hasil = [hasil('P01', 'Common cold / selesma', 'P01-R01', _, ['G01', 'G02'])].

% T05: dua aturan kondisi berbeda tampil bersamaan.
test(t05_banyak_kondisi_bersamaan) :-
    isi_sesi(['G01', 'G02', 'G04'], none),
    inferensi(ada_hasil, Hasil),
    findall(Kode, member(hasil(Kode, _, _, _, _), Hasil), Mentah),
    sort(Mentah, KodeUrut),
    % P03 tidak lagi ikut: sejak pengetatan P03-R04 (masukan integrasi +
    % pengujian, Opu 3; dikerjakan oleh pemilik aturan_p03_p04.pl),
    % G04/G05 tidak lagi menjadi pendukung R04, sehingga kombinasi hidung
    % + nyeri tenggorokan ini hanya cocok dengan P01 dan P02.
    KodeUrut == ['P01', 'P02'].

% T06: gejala tidak memenuhi syarat lengkap aturan manapun.
test(t06_syarat_tidak_lengkap) :-
    isi_sesi(['G01', 'G30a'], none),
    inferensi(tidak_ada_aturan_cocok, []).

% T07: reset menghapus sisa sesi sebelumnya.
test(t07_reset_antar_sesi) :-
    isi_sesi(['G01', 'G02'], none),
    reset_sesi,
    daftar_gejala_terpilih([]),
    inferensi(belum_ada_gejala, []).

% T08: detail batuk tersimpan sebagai detail G05, bukan gejala tambahan.
test(t08_detail_batuk_bukan_gejala_baru) :-
    isi_sesi(['G05'], ['G05'-'kering']),
    daftar_gejala_terpilih(['G05']),
    detail_gejala('G05', 'kering').

% T09: detail suhu bukan bukti independen kedua dari demam.
test(t09_detail_suhu_bukan_gejala_kedua) :-
    isi_sesi(['G07'], ['G07'-'suhu_38.2']),
    daftar_gejala_terpilih(['G07']),
    \+ daftar_gejala_terpilih(['G07', 'G08a']),
    detail_gejala('G07', 'suhu_38.2').

% T10: P05 cocok dan ditandai sebagai pembanding noninfeksi.
test(t10_p05_pembanding_noninfeksi) :-
    isi_sesi(['G19', 'G20a'], none),
    inferensi(ada_hasil, Hasil),
    kelompokkan_hasil(Hasil, Kelompok),
    member(kelompok('P05', 'Asma (pembanding noninfeksi)', true, _), Kelompok),
    kondisi_noninfeksi('P05').

% T11: tanda bahaya tampil sebelum daftar kecocokan (urutan baris).
test(t11_tanda_bahaya_di_atas_hasil) :-
    HasilUji = [hasil('P01', 'Common cold / selesma', 'P01-R01',
                      'Penjelasan untuk uji t11', ['G01'])],
    susun_keluaran([4], ada_hasil, HasilUji, Baris),
    atomics_to_string(Baris, ' ', Teks),
    sub_string(Teks, PosBahaya, _, _, 'SEGERA CARI PERTOLONGAN MEDIS'),
    !,
    sub_string(Teks, PosHasil, _, _, 'Common cold / selesma'),
    !,
    PosBahaya < PosHasil.

% T12: masukan tidak valid ditolak oleh parser murni (I/O mengulang).
test(t12_input_tidak_valid_ditolak) :-
    \+ jawaban_ya_tidak('makan', _),
    \+ jawaban_ya_tidak('', _),
    \+ pilihan_menu('3', _),
    \+ pilihan_menu('', _),
    \+ parse_suhu('dingin', _, _).

% Kelengkapan tabel kasus: 30 klausa, id unik, seluruh kondisi terwakili.
test(tabel_kasus_30_klausa) :-
    findall(Id, kasus_aturan(_, _, Id, _, _, _, _), Semua),
    length(Semua, 30),
    sort(Semua, Unik),
    length(Unik, 30),
    findall(Kondisi, kasus_aturan(_, Kondisi, _, _, _, _, _), KondisiMentah),
    sort(KondisiMentah, ['P01', 'P02', 'P03', 'P04', 'P05', 'P06']).

% Kasus positif dan negatif per klausa aturan. plunit menuntut nama tes
% atom, jadi setiap baris tabel dipecah menjadi deklarasi statis dengan
% nama yang memuat IdAturan (mis. pos_P01_R01), sehingga kegagalan tes
% selalu menyebut IdAturan spesifik. Isi pemanggilan tetap dari tabel.

uji_pos(Kondisi, Id) :-
    kasus_aturan(Sumber, Kondisi, Id, Pos, DetailPos, _, _),
    isi_sesi(Pos, DetailPos),
    call(Sumber, Kondisi, Id, _, Dukungan),
    !,
    Dukungan \= [].

uji_neg(Kondisi, Id) :-
    kasus_aturan(Sumber, Kondisi, Id, _, _, Neg, DetailNeg),
    isi_sesi(Neg, DetailNeg),
    \+ call(Sumber, Kondisi, Id, _, _).

% Kasus P01.
test(pos_P01_R01) :- uji_pos('P01', 'P01-R01').
test(pos_P01_R02) :- uji_pos('P01', 'P01-R02').
test(pos_P01_R03) :- uji_pos('P01', 'P01-R03').
test(pos_P01_R04) :- uji_pos('P01', 'P01-R04').
test(pos_P01_R05) :- uji_pos('P01', 'P01-R05').
% Kasus P02.
test(pos_P02_R01) :- uji_pos('P02', 'P02-R01').
test(pos_P02_R02) :- uji_pos('P02', 'P02-R02').
test(pos_P02_R03) :- uji_pos('P02', 'P02-R03').
test(pos_P02_R04) :- uji_pos('P02', 'P02-R04').
% Kasus P03.
test(pos_P03_R01) :- uji_pos('P03', 'P03-R01').
test(pos_P03_R02) :- uji_pos('P03', 'P03-R02').
test(pos_P03_R03) :- uji_pos('P03', 'P03-R03').
test(pos_P03_R04) :- uji_pos('P03', 'P03-R04').
% Kasus P04.
test(pos_P04_R01) :- uji_pos('P04', 'P04-R01').
test(pos_P04_R02) :- uji_pos('P04', 'P04-R02').
test(pos_P04_R03) :- uji_pos('P04', 'P04-R03').
test(pos_P04_R04) :- uji_pos('P04', 'P04-R04').
test(pos_P04_R05) :- uji_pos('P04', 'P04-R05').
% Kasus P05.
test(pos_P05_R01) :- uji_pos('P05', 'P05-R01').
test(pos_P05_R02) :- uji_pos('P05', 'P05-R02').
test(pos_P05_R03) :- uji_pos('P05', 'P05-R03').
test(pos_P05_R04) :- uji_pos('P05', 'P05-R04').
test(pos_P05_R05) :- uji_pos('P05', 'P05-R05').
test(pos_P05_R06) :- uji_pos('P05', 'P05-R06').
% Kasus P06.
test(pos_P06_R01) :- uji_pos('P06', 'P06-R01').
test(pos_P06_R02) :- uji_pos('P06', 'P06-R02').
test(pos_P06_R03) :- uji_pos('P06', 'P06-R03').
test(pos_P06_R04) :- uji_pos('P06', 'P06-R04').
test(pos_P06_R05) :- uji_pos('P06', 'P06-R05').
test(pos_P06_R06) :- uji_pos('P06', 'P06-R06').

% Kasus negatif: syarat dihilangkan, klausa dengan IdAturan itu tidak
% menghasilkan apa-apa.
test(neg_P01_R01) :- uji_neg('P01', 'P01-R01').
test(neg_P01_R02) :- uji_neg('P01', 'P01-R02').
test(neg_P01_R03) :- uji_neg('P01', 'P01-R03').
test(neg_P01_R04) :- uji_neg('P01', 'P01-R04').
test(neg_P01_R05) :- uji_neg('P01', 'P01-R05').
test(neg_P02_R01) :- uji_neg('P02', 'P02-R01').
test(neg_P02_R02) :- uji_neg('P02', 'P02-R02').
test(neg_P02_R03) :- uji_neg('P02', 'P02-R03').
test(neg_P02_R04) :- uji_neg('P02', 'P02-R04').
test(neg_P03_R01) :- uji_neg('P03', 'P03-R01').
test(neg_P03_R02) :- uji_neg('P03', 'P03-R02').
test(neg_P03_R03) :- uji_neg('P03', 'P03-R03').
test(neg_P03_R04) :- uji_neg('P03', 'P03-R04').
test(neg_P04_R01) :- uji_neg('P04', 'P04-R01').
test(neg_P04_R02) :- uji_neg('P04', 'P04-R02').
test(neg_P04_R03) :- uji_neg('P04', 'P04-R03').
test(neg_P04_R04) :- uji_neg('P04', 'P04-R04').
test(neg_P04_R05) :- uji_neg('P04', 'P04-R05').
test(neg_P05_R01) :- uji_neg('P05', 'P05-R01').
test(neg_P05_R02) :- uji_neg('P05', 'P05-R02').
test(neg_P05_R03) :- uji_neg('P05', 'P05-R03').
test(neg_P05_R04) :- uji_neg('P05', 'P05-R04').
test(neg_P05_R05) :- uji_neg('P05', 'P05-R05').
test(neg_P05_R06) :- uji_neg('P05', 'P05-R06').
test(neg_P06_R01) :- uji_neg('P06', 'P06-R01').
test(neg_P06_R02) :- uji_neg('P06', 'P06-R02').
test(neg_P06_R03) :- uji_neg('P06', 'P06-R03').
test(neg_P06_R04) :- uji_neg('P06', 'P06-R04').
test(neg_P06_R05) :- uji_neg('P06', 'P06-R05').
test(neg_P06_R06) :- uji_neg('P06', 'P06-R06').

% Guard G08a: ditolak tanpa G07, diterima setelah G07.
test(g08a_ditolak_tanpa_g07) :-
    reset_sesi,
    \+ tambah_gejala('G08a'),
    tambah_gejala('G07'),
    tambah_gejala('G08a').

% Detail dahak tidak boleh masuk lewat tambah_gejala/1.
test(detail_dahak_ditolak_di_tambah_gejala) :-
    reset_sesi,
    \+ tambah_gejala('G25a').

% Detail ditolak ketika gejala induknya belum terpilih.
test(detail_tanpa_induk_ditolak) :-
    reset_sesi,
    \+ tambah_detail('G25a', 'kuning_hijau'),
    \+ tambah_detail('G07', 'suhu_39').

% Detail tidak dihitung sebagai gejala kedua.
test(detail_bukan_gejala_kedua) :-
    isi_sesi(['G05'], ['G05'-'kering']),
    daftar_gejala_terpilih(['G05']),
    \+ daftar_gejala_terpilih(['G05', 'kering']).

% Beberapa kondisi berbeda bisa cocok bersamaan (mis. P01 dan P03).
test(banyak_kondisi_bersamaan_p01_p03) :-
    isi_sesi(['G01', 'G02', 'G15'], none),
    inferensi(ada_hasil, Hasil),
    findall(Kode, member(hasil(Kode, _, _, _, _), Hasil), Mentah),
    sort(Mentah, KodeUrut),
    KodeUrut == ['P01', 'P03'].

% Kelompok hasil menggabungkan beberapa aturan kondisi sama dan
% menandai P05 sebagai noninfeksi.
test(kelompokkan_hasil_menggabungkan_dan_menandai) :-
    HasilUji = [hasil('P01', 'Common cold / selesma', 'P01-R01', 'uji a', ['G01']),
                hasil('P01', 'Common cold / selesma', 'P01-R02', 'uji b', ['G02']),
                hasil('P05', 'Asma (pembanding noninfeksi)', 'P05-R01', 'uji c', ['G19'])],
    kelompokkan_hasil(HasilUji, Kelompok),
    length(Kelompok, 2),
    member(kelompok('P01', _, false, BarisP01), Kelompok),
    !,
    length(BarisP01, 2),
    member(kelompok('P05', _, true, _), Kelompok),
    !.

% Status pesan tersedia untuk ketiga status.
test(status_pesan_tersedia) :-
    forall(member(Status, [belum_ada_gejala, tidak_ada_aturan_cocok, ada_hasil]),
           ( status_pesan(Status, Pesan), string(Pesan) )).

% Hasil kosong dikata sebagai "belum menemukan kecocokan", bukan
% kesimpulan orang bebas dari penyakit.
test(blok_hasil_tanpa_kecocokan_bukan_berarti_sehat) :-
    blok_hasil(tidak_ada_aturan_cocok, _, Baris),
    atomics_to_string(Baris, ' ', Teks),
    sub_string(Teks, _, _, _, 'belum menemukan kecocokan'),
    !,
    sub_string(Teks, _, _, _, 'BUKAN berarti Anda bebas dari penyakit'),
    !.

% Tanpa tanda bahaya, tidak ada pesan darurat pada keluaran.
test(tanpa_bahaya_tanpa_pesan_darurat) :-
    susun_keluaran([], belum_ada_gejala, [], Baris),
    atomics_to_string(Baris, ' ', Teks),
    \+ sub_string(Teks, _, _, _, 'SEGERA CARI PERTOLONGAN MEDIS'),
    !.

% Kelompok P05 membawa label "bukan ISPA infeksi" pada tampilan.
test(tampilan_p05_bukan_ispa_infeksi) :-
    isi_sesi(['G01', 'G02', 'G19', 'G20a'], none),
    inferensi(ada_hasil, Hasil),
    susun_keluaran([], ada_hasil, Hasil, Baris),
    atomics_to_string(Baris, ' ', Teks),
    sub_string(Teks, _, _, _, 'Pembanding noninfeksi'),
    !,
    sub_string(Teks, _, _, _, 'bukan ISPA infeksi'),
    !.

% Parser murni antarmuka: jawaban ya/tidak, menu, suhu.
test(jawaban_ya_tidak_murni) :-
    jawaban_ya_tidak('Ya', ya),
    jawaban_ya_tidak('  y', ya),
    jawaban_ya_tidak('TIDAK', tidak),
    jawaban_ya_tidak(' tidak ', tidak),
    \+ jawaban_ya_tidak('belum tahu', _).

test(pilihan_menu_murni) :-
    pilihan_menu('1', 1),
    pilihan_menu('2', 2),
    \+ pilihan_menu('9', _).

test(parse_suhu_murni) :-
    parse_suhu('38,2', 38.2, "38.2"),
    parse_suhu('39.1 C', 39.1, "39.1"),
    \+ parse_suhu('dingin', _, _).

% Wawancara umum tidak menyertakan kode khusus.
test(wawancara_luar_kode_khusus) :-
    \+ gejala_ditanya_langsung('G25a'),
    \+ gejala_ditanya_langsung('G08a'),
    \+ gejala_ditanya_langsung('G29'),
    \+ gejala_ditanya_langsung('G31'),
    gejala_ditanya_langsung('G30b'),
    gejala_ditanya_langsung('G05').

% Kontrol tokenizer: "dipastikan" bukan token "pasti".
test(tokenisasi_dipastikan_bukan_pasti) :-
    tokenisasi('Penyebab tidak dapat dipastikan dari gejala', Tok),
    memberchk('dipastikan', Tok),
    frasa_am(Tok).

% Kontrol: frasa terlarang utuh memang dikenali (kemampuan detector).
test(kontrol_frasa_terlarang_dikenali) :-
    tokenisasi('Anda pasti menderita kondisi ini', Tok),
    frasa_di(['pasti', 'menderita'], Tok),
    !,
    \+ frasa_am(Tok).

% Pemindaian Seluruh Penjelasan aturan: bebas frasa terlarang.
test(penjelasan_bebas_frasa_terlarang) :-
    forall(aturan_penjelasan(P),
           ( tokenisasi(P, Tok), frasa_am(Tok) )).

:- end_tests(sistem_pakar_ispa).
