:- use_module(library(lists)).
:- use_module(library(readutil)).

tanda_bahaya_info(1, 'Sesak napas berat atau sulit bicara karena sesak').
tanda_bahaya_info(2, 'Napas makin cepat atau semakin berat').
tanda_bahaya_info(3, 'Nyeri dada berat atau menetap').
tanda_bahaya_info(4, 'Kebingungan atau penurunan kesadaran').
tanda_bahaya_info(5, 'Bibir atau ujung jari kebiruan').
tanda_bahaya_info(6, 'Batuk berdarah atau dahak berdarah').
tanda_bahaya_info(7, 'Kondisi cepat memburuk atau gejala berat datang tiba-tiba').

pesan_tanda_bahaya(NomorDaftar, Baris) :-
    maplist(baris_tanda_bahaya, NomorDaftar, BarisTanda),
    append([['!!! TANDA BAHAYA: SEGERA CARI PERTOLONGAN MEDIS !!!',
             'Tanda yang dilaporkan:'],
            BarisTanda,
            ['Kondisi ini tidak dinilai oleh aturan; sistem tidak mendiagnosis kondisi gawat.',
             'Segera hubungi pertolongan medis']],
           Baris).

baris_tanda_bahaya(Nomor, Teks) :-
    tanda_bahaya_info(Nomor, Deskripsi),
    atomics_to_string(['- ', Deskripsi], Teks).

status_pesan(belum_ada_gejala,
             "Belum ada gejala yang dipilih untuk sesi ini.").
status_pesan(tidak_ada_aturan_cocok,
             "Tidak ada aturan yang cocok dengan kombinasi gejala yang dipilih.").
status_pesan(ada_hasil,
             "Kondisi berikut adalah kondisi yang mungkin sesuai dengan gejala yang dipilih.").

pertanyaan_gejala('G05', 'Apakah Anda mengalami batuk?').
pertanyaan_gejala('G07', 'Apakah Anda mengalami demam?').
pertanyaan_gejala('G20b', 'Apakah napas Anda terdengar berbunyi tidak biasa?').
pertanyaan_gejala(Kode, Teks) :-
    \+ memberchk(Kode, ['G05', 'G07', 'G20b']),
    gejala_info(Kode, Nama),
    atomics_to_string(['Apakah Anda mengalami ', Nama, '?'], Teks).

gejala_ditanya_langsung(Kode) :-
    gejala_info(Kode, _),
    \+ gejala_tandai(Kode, detail_dahak),
    \+ gejala_tandai(Kode, perlu_pengukuran),
    \+ gejala_tandai(Kode, perlu_pemeriksaan_ahli).

kelompokkan_hasil(Hasil, Kelompok) :-
    maplist(hasil_ke_pasangan, Hasil, Pasangan),
    keysort(Pasangan, PasanganUrut),
    group_pairs_by_key(PasanganUrut, Digrup),
    maplist(bentuk_kelompok, Digrup, Kelompok).

hasil_ke_pasangan(hasil(Kode, Nama, Id, Penjelasan, Dukungan),
                  Kode-(Nama, Id, Penjelasan, Dukungan)).

bentuk_kelompok(Kode-DaftarNilai, kelompok(Kode, Nama, Noninfeksi, Baris)) :-
    DaftarNilai = [(Nama, _, _, _)|_],
    ( kondisi_noninfeksi(Kode)
    -> Noninfeksi = true
    ;  Noninfeksi = false
    ),
    maplist(buat_baris, DaftarNilai, Baris).

buat_baris((_, Id, Penjelasan, Dukungan), baris(Id, Penjelasan, Dukungan)).

nama_tampil('G05', 'Batuk').
nama_tampil('G07', 'Demam').
nama_tampil(Kode, Nama) :-
    \+ memberchk(Kode, ['G05', 'G07']),
    gejala_info(Kode, Nama).

teks_gejala(Kode, Teks) :-
    nama_tampil(Kode, Nama),
    !,
    atomics_to_string([Kode, ' (', Nama, ')'], Teks).
teks_gejala(Kode, Kode).

potong_baris(Teks, Lebar, DaftarBaris) :-
    jadikan_teks(Teks, Str),
    split_string(Str, " ", " ", DaftarKata),
    gelar_baris(DaftarKata, Lebar, '', DaftarBaris).

gelar_baris([], _Lebar, BarisSekarang, [BarisSekarang]).
gelar_baris([Kata|Sisa], Lebar, BarisSekarang, Daftar) :-
    ( BarisSekarang == ''
    -> Kandidat = Kata
    ;  atomics_to_string([BarisSekarang, ' ', Kata], Kandidat)
    ),
    string_length(Kandidat, Panjang),
    ( Panjang =< Lebar
    -> gelar_baris(Sisa, Lebar, Kandidat, Daftar)
    ;  BarisSekarang == ''
    ->  ( Sisa == []
        -> Daftar = [Kandidat]
        ;  gelar_baris(Sisa, Lebar, '', SisaDaftar),
           Daftar = [Kandidat|SisaDaftar]
        )
    ;  gelar_baris([Kata|Sisa], Lebar, '', SisaDaftar),
       Daftar = [BarisSekarang|SisaDaftar]
    ).

awali(Awalan, Baris, BarisAwalan) :-
    atomics_to_string([Awalan, Baris], BarisAwalan).

poin_dukungan(TeksGejala, Baris) :-
    atomics_to_string(['  - ', TeksGejala], Baris).

garis_bingkai(Baris) :-
    length(Chars, 64),
    maplist(=(61), Chars),
    string_chars(Baris, Chars).

baris_saran(Saran, Baris) :-
    potong_baris(Saran, 64, Mentah),
    Mentah = [Pertama|Sisa],
    atomics_to_string(['  Saran umum: ', Pertama], BarisPertama),
    maplist(awali('    '), Sisa, SisaInden),
    append([[BarisPertama], SisaInden], Baris).

jadikan_teks(Atom, Teks) :-
    atom(Atom),
    !,
    atom_string(Atom, Teks).
jadikan_teks(Teks, Teks).

susun_keluaran(NomorBahaya, Status, Hasil, Baris) :-
    blok_bahaya(NomorBahaya, BarisBahaya),
    blok_hasil(Status, Hasil, BarisHasil),
    blok_penutup(BarisPenutup),
    append([BarisBahaya, BarisHasil, BarisPenutup], Baris).

blok_bahaya([], []).
blok_bahaya(NomorDaftar, Baris) :-
    NomorDaftar \= [],
    pesan_tanda_bahaya(NomorDaftar, Sementara),
    append(Sementara, [''], Baris).

saran_kondisi('P01',
    "Selesma biasanya membaik sendiri dalam waktu kurang dari seminggu. Istirahat cukup dan minum cairan membantu kenyamanan. Periksa ke tenaga kesehatan bila gejala tidak membaik setelah sekitar 10 hari, demam melewati 4 hari, muncul napas cepat atau sulit bernapas, atau keluhan memburuk kembali setelah membaik.").
saran_kondisi('P02',
    "Bila nyeri tenggorokan berat, nyeri menelan hebat, atau demam tinggi yang menetap, periksa ke tenaga kesehatan. Keluhan yang tidak membaik juga perlu ditilai. Penyebab faringitis tidak bisa ditentukan hanya dari gejala.").
saran_kondisi('P03',
    "Banyak sinusitis membaik sendiri. Periksa ke tenaga kesehatan bila gejala tidak membaik setelah lebih dari 10 hari, kembali memburuk setelah membaik, demam melewati 3-4 hari, atau nyeri wajah dan sakit kepala sampai berat.").
saran_kondisi('P04',
    "Bronkitis akut biasanya membaik sendiri dan gejalanya kurang dari 3 minggu. Istirahat cukup dan minum cairan membantu kenyamanan. Periksa ke tenaga kesehatan bila batuk melewati 3 minggu, demam melewati 5 hari, dahak bercampur darah, atau muncul sesak napas.").
saran_kondisi('P05',
    "Asma adalah pembanding noninfeksi, bukan ISPA infeksi. Pengelolaannya mengikuti anjuran tenaga kesehatan yang menangani Anda. Segera cari pertolongan medis bila sesak memburuk atau kondisi cepat memburuk.").
saran_kondisi('P06',
    "Pneumonia perlu ditilai dan ditangani tenaga kesehatan. Segera cari pertolongan medis bila sesak napas makin berat, nyeri dada berat, atau kondisi cepat memburuk.").

blok_hasil(ada_hasil, Hasil, Baris) :-
    status_pesan(ada_hasil, Judul),
    kelompokkan_hasil(Hasil, Kelompok),
    kelompok_ke_baris(Kelompok, 1, GrupBarisKelompok),
    append(GrupBarisKelompok, TeksKelompok),
    append([['== HASIL PENCOCOKAN ATURAN ==', Judul,
             'Urutan tampilan bukan peringkat tingkat keparahan.'],
            TeksKelompok], Baris).
blok_hasil(Status, _, Baris) :-
    Status \= ada_hasil,
    status_pesan(Status, Pesan),
    Baris = ['== HASIL PENCOCOKAN ATURAN ==',
             Pesan,
             'Sistem belum menemukan kecocokan dari aturan yang tersedia.',
             'Itu BUKAN berarti Anda bebas dari penyakit.',
             ''].

kelompok_ke_baris([], _, []).
kelompok_ke_baris([Kelompok|Sisa], Nomer, [BarisGrup|SisaBaris]) :-
    baris_kelompok(Nomer, Kelompok, BarisGrup),
    NomerBerikut is Nomer + 1,
    kelompok_ke_baris(Sisa, NomerBerikut, SisaBaris).

baris_kelompok(Nomer, kelompok(Kode, Nama, Noninfeksi, DaftarBaris), BarisKelompok) :-
    ( Noninfeksi == true
    -> atomics_to_string(['Pembanding noninfeksi (bukan ISPA infeksi): ',
                          Nama, ' (', Kode, ')'], JudulDasar)
    ;  atomics_to_string(['Kondisi yang mungkin sesuai: ',
                          Nama, ' (', Kode, ')'], JudulDasar)
    ),
    atomics_to_string(['No. ', Nomer, '. ', JudulDasar], Judul),
    garis_bingkai(Garis),
    maplist(baris_aturan, DaftarBaris, BarisAturan),
    append(BarisAturan, TeksAturan),
    ( saran_kondisi(Kode, Saran)
    -> baris_saran(Saran, BarisSaran)
    ;  BarisSaran = []
    ),
    append([['', Garis, Judul, Garis],
            TeksAturan,
            BarisSaran],
           BarisKelompok).

baris_aturan(baris(Id, Penjelasan, Dukungan), Baris) :-
    jadikan_teks(Penjelasan, P),
    maplist(teks_gejala, Dukungan, Dteks),
    ( Dteks == []
    -> BarisDukungan = ['  Gejala yang menyertai: tidak tercatat']
    ;  maplist(poin_dukungan, Dteks, PoinGejala),
       append([['  Gejala yang menyertai:'], PoinGejala], BarisDukungan)
    ),
    potong_baris(P, 64, BarisPenjelasanMentah),
    maplist(awali('    '), BarisPenjelasanMentah, BarisPenjelasan),
    atomics_to_string(['  Kecocokan aturan: ', Id], BarisAturanId),
    append([BarisDukungan,
            ['  Penjelasan:'],
            BarisPenjelasan,
            [BarisAturanId, '']],
           Baris).

blok_penutup(Baris) :-
    Baris = ['Catatan penting:',
             '- Sistem adalah alat edukasi dan penyaringan awal, bukan alat diagnosis medis.',
             '- Hasil berupa kecocokan aturan terhadap gejala yang dipilih, bukan diagnosis.',
             '- Urutan tampilan bukan tingkat kepastian atau probabilitas.',
             '- Saran umum pada hasil bersifat edukasi, bukan pengganti penilaian tenaga kesehatan.',
             '- Sistem tidak memberi resep, dosis obat, atau rekomendasi antibiotik.',
             '- Jika keluhan menetap atau memburuk, perlu evaluasi tenaga kesehatan.',
             '- Jika tanda bahaya muncul, segera cari pertolongan medis; jangan menunggu.',
             ''].

kata_pertama(Teks, Kata) :-
    split_string(Teks, " \t", " \t", [Pertama|_]),
    atom_string(KAwal, Pertama),
    downcase_atom(KAwal, Kata).

jawaban_ya_tidak(Teks, ya) :-
    kata_pertama(Teks, Kata),
    memberchk(Kata, [ya, y]).
jawaban_ya_tidak(Teks, tidak) :-
    kata_pertama(Teks, Kata),
    memberchk(Kata, [tidak, t]).

pilihan_menu(Teks, 1) :-
    kata_pertama(Teks, '1').
pilihan_menu(Teks, 2) :-
    kata_pertama(Teks, '2').

parse_suhu(Teks, Nilai, TeksSuhu) :-
    split_string(Teks, " \t", "", [Pertama|_]),
    split_string(Pertama, ",", "", Bagian),
    atomics_to_string(Bagian, '.', Bersih),
    number_string(Nilai, Bersih),
    Nilai > 30.0,
    Nilai < 50.0,
    TeksSuhu = Bersih.

tulis_baris(Teks) :-
    format('~s~n', [Teks]).

baca_baris(Teks) :-
    read_line_to_string(user_input, Bacaan),
    ( Bacaan == end_of_file
    -> throw(akhir_masukan)
    ;  Teks = Bacaan
    ).

tanya_ya_tidak(Pertanyaan, Jawaban) :-
    format('~s (ya/tidak): ', [Pertanyaan]),
    baca_baris(Teks),
    ( jawaban_ya_tidak(Teks, Jawaban)
    -> true
    ;  format('Jawaban tidak dipahami. Jawab "ya" atau "tidak".~n', []),
       tanya_ya_tidak(Pertanyaan, Jawaban)
    ).

jalankan_aplikasi :-
    tampilkan_pembuka,
    catch(loop_menu,
          akhir_masukan,
          format('~nInput berakhir (end of file). Program diakhiri.~n', []
          )),
    tampilkan_penutup,
    halt(0).

tampilkan_pembuka :-
    format('==== Sistem Pakar ISPA - alat edukasi ====~n', []),
    format('Alat edukasi dan penyaringan awal. BUKAN alat diagnosis medis.~n', []),
    format('Hasil nanti berupa kondisi yang mungkin sesuai dengan gejala pilihan Anda.~n', []),
    format('Masukan hanya gejala; tidak ada data pribadi yang diminta.~n', []).

tampilkan_penutup :-
    format('Terima kasih. Ingat: hasil sistem bukan diagnosis medis dan perlu evaluasi tenaga kesehatan ketika keluhan menetap.~n', []).

loop_menu :-
    format('~nMenu:~n', []),
    format('  1) Mulai sesi konsultasi baru~n', []),
    format('  2) Keluar~n', []),
    baca_pilihan_menu(Pilihan),
    ( Pilihan == 1
    -> konsultasi,
       loop_menu
    ;  format('Menutup aplikasi.~n', [])
    ).

baca_pilihan_menu(Pilihan) :-
    format('Pilihan (1 atau 2): ', []),
    baca_baris(Teks),
    ( pilihan_menu(Teks, Pilihan)
    -> true
    ;  format('Pilihan tidak dipahami.~n', []),
       baca_pilihan_menu(Pilihan)
    ).

konsultasi :-
    reset_sesi,
    tampilkan_pembuka_konsultasi,
    jawab_tanda_bahaya(1, NomorBahaya),
    tanya_semua_gejala,
    tanya_opsi_pengukuran,
    inferensi(Status, Hasil),
    susun_keluaran(NomorBahaya, Status, Hasil, BarisTeks),
    forall(member(B, BarisTeks), tulis_baris(B)).

tampilkan_pembuka_konsultasi :-
    format('~n== Sesi konsultasi baru ==~n', []),
    format('Sistem adalah alat edukasi dan penyaringan awal, bukan alat diagnosis medis.~n', []),
    format('Hasil nanti berupa kondisi yang mungkin sesuai dengan gejala yang dipilih.~n', []),
    format('Data pribadi tidak diminta.~n', []),
    format('~nPertanyaan tanda bahaya terlebih dahulu:~n', []).

jawab_tanda_bahaya(8, []) :- !.
jawab_tanda_bahaya(Nomor, Pilihan) :-
    Nomor >= 1,
    Nomor =< 7,
    tanda_bahaya_info(Nomor, Deskripsi),
    atomics_to_string(['Tanda bahaya [', Nomor, '/7] ', Deskripsi], Pertanyaan),
    tanya_ya_tidak(Pertanyaan, Jawaban),
    ( Jawaban == ya
    -> format('!!! TANDA BAHAYA TERDETEKSI: SEGERA CARI PERTOLONGAN MEDIS.~n', []),
       format('Pesan ini diulang di bagian paling atas hasil.~n', []),
       ( Nomor == 7
       -> Pilihan = [Nomor]
       ;  NomorBerikut is Nomor + 1,
          jawab_tanda_bahaya(NomorBerikut, Sisa),
          Pilihan = [Nomor|Sisa]
       )
    ;  ( Nomor == 7
       -> Pilihan = []
       ;  NomorBerikut is Nomor + 1,
          jawab_tanda_bahaya(NomorBerikut, Pilihan)
       )
    ).

tanya_semua_gejala :-
    format('~nWawancara gejala:~n', []),
    findall(Kode, gejala_ditanya_langsung(Kode), Daftar),
    tanya_daftar_gejala(Daftar).

tanya_daftar_gejala([]).
tanya_daftar_gejala([Kode|Sisa]) :-
    pertanyaan_gejala(Kode, Pertanyaan),
    ( gejala_catatan(Kode, Catatan)
    -> format('Catatan: ~s~n', [Catatan])
    ;  true
    ),
    tanya_ya_tidak(Pertanyaan, Jawaban),
    ( Jawaban == ya
    -> tambah_gejala(Kode),
       ( Kode == 'G05' -> tanya_jenis_batuk ; true ),
       ( Kode == 'G07' -> tanya_suhu ; true )
    ;  true
    ),
    tanya_daftar_gejala(Sisa).

pilihan_opsi_batuk([op(1, 'kering'), op(2, 'berdahak'), op(3, 'lewati')]).

detail_kode('G25a').
detail_kode('G25b').
detail_kode('G25c').
detail_kode('G25d').

detail_pertanyaan('G25a', 'Warna dahak yang keluar?').
detail_pertanyaan('G25b', 'Bau dahak yang keluar?').
detail_pertanyaan('G25c', 'Jumlah dahak yang keluar?').
detail_pertanyaan('G25d', 'Kekentalan dahak yang keluar?').

detail_pilihan('G25a', [op(1, 'bening'), op(2, 'kuning_hijau'), op(3, 'lewati')]).
detail_pilihan('G25b', [op(1, 'tidak_berbau'), op(2, 'berbau'), op(3, 'lewati')]).
detail_pilihan('G25c', [op(1, 'sedikit'), op(2, 'banyak'), op(3, 'lewati')]).
detail_pilihan('G25d', [op(1, 'encer'), op(2, 'kental'), op(3, 'lewati')]).

tanya_jenis_batuk :-
    pilihan_opsi_batuk(Ops),
    tampilkan_opsi(Ops, 'Jenis batuk?'),
    baca_opsi(Ops, Nilai),
    ( Nilai == 'lewati'
    -> true
    ;  tambah_detail('G05', Nilai),
       ( Nilai == 'berdahak' -> tanya_detail_dahak ; true )
    ).

tanya_detail_dahak :-
    format('Rincian dahak (opsional; cukup yang diketahui):~n', []),
    findall(Kode, detail_kode(Kode), Daftar),
    tanya_daftar_detail(Daftar).

tanya_daftar_detail([]).
tanya_daftar_detail([Kode|Sisa]) :-
    detail_pertanyaan(Kode, Pertanyaan),
    detail_pilihan(Kode, Ops),
    tampilkan_opsi(Ops, Pertanyaan),
    ( gejala_catatan(Kode, Catatan)
    -> format('Catatan: ~s~n', [Catatan])
    ;  true
    ),
    baca_opsi(Ops, Nilai),
    ( Nilai == 'lewati'
    -> true
    ;  tambah_detail(Kode, Nilai)
    ),
    tanya_daftar_detail(Sisa).

tampilkan_opsi(Ops, Pertanyaan) :-
    format('~s (pilih nomor):~n', [Pertanyaan]),
    forall(member(op(Nomor, Nilai), Ops),
           format('  ~w) ~w~n', [Nomor, Nilai])).

baca_opsi(Ops, Nilai) :-
    baca_baris(Teks),
    ( pilih_opsi(Ops, Teks, Nilai)
    -> true
    ;  format('Pilihan tidak dipahami.~n', []),
       tampilkan_opsi(Ops, 'Masukan ulang'),
       baca_opsi(Ops, Nilai)
    ).

pilih_opsi([op(Nomor, Nilai)|_], Teks, Nilai) :-
    kata_pertama(Teks, Kata),
    term_to_atom(Nomor, KA),
    Kata == KA,
    !.
pilih_opsi([_|Sisa], Teks, Nilai) :-
    pilih_opsi(Sisa, Teks, Nilai).

tanya_suhu :-
    tanya_ya_tidak('Apakah suhu benar-benar diukur dengan termometer?', Jawaban),
    ( Jawaban == ya
    -> tanya_nilai_suhu(3)
    ;  format('Detail suhu dilewati; hanya G07 yang dicatat.~n', [])
    ).

tanya_nilai_suhu(0) :-
    format('Detail suhu dilewati karena nilai tidak dapat dibaca.~n', []).
tanya_nilai_suhu(Sisa) :-
    format('Nilai suhu terukur (derajat Celsius, contoh: 38.2): ', []),
    baca_baris(Teks),
    ( parse_suhu(Teks, Nilai, TeksSuhu)
    -> atomics_to_string(['suhu_', TeksSuhu], Str),
       atom_string(Detail, Str),
       tambah_detail('G07', Detail),
       ( Nilai >= 38.0
       -> tambah_gejala('G08a'),
          ( gejala_catatan('G08a', Catatan)
          -> format('Catatan: ~s~n', [Catatan])
          ;  true
          )
       ;  format('Suhu di bawah 38 C tidak dicatat sebagai G08a.~n', [])
       )
    ;  Sisa1 is Sisa - 1,
       format('Nilai tidak dapat dibaca. Contoh yang benar: 38.2~n', []),
       tanya_nilai_suhu(Sisa1)
    ).

tanya_opsi_pengukuran :-
    format('~nBagian opsional: hasil pengukuran atau pemeriksaan.~n', []),
    tanya_ya_tidak('Apakah Anda memiliki hasil pengukuran frekuensi napas atau pemeriksaan tenaga kesehatan yang ingin dicatat?', Jawaban),
    ( Jawaban == ya
    -> tanya_daftar_pengukuran(['G29', 'G31'])
    ;  format('Bagian ini dilewati. G29/G31 hanya dipakai aturan jika nilainya benar-benar tercatat.~n', [])
    ).

tanya_daftar_pengukuran([]).
tanya_daftar_pengukuran([Kode|Sisa]) :-
    pertanyaan_gejala(Kode, Pertanyaan),
    ( gejala_catatan(Kode, Catatan)
    -> format('Catatan: ~s~n', [Catatan])
    ;  true
    ),
    tanya_ya_tidak(Pertanyaan, Jawaban),
    ( Jawaban == ya -> tambah_gejala(Kode) ; true ),
    tanya_daftar_pengukuran(Sisa).
