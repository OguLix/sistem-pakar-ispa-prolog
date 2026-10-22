% =====================================================================
% antarmuka.pl - Alur konsultasi dan tampilan hasil
% File bersama tim (agent.md 5; docs/pembagian_tugas.md).
% Dikerjakan 21 Oktober 2026.
%
% Batas tanggung jawab:
% - File ini TIDAK berisi fakta sesi, aturan diagnosis, atau mesin
%   inferensi. Hanya memakai predikat yang sudah ada:
%   reset_sesi/0, tambah_gejala/1, tambah_detail/2, gejala_info/2,
%   gejala_tandai/2, gejala_catatan/2, kondisi_info/2,
%   kondisi_noninfeksi/1, inferensi/2 (agent.md 6).
% - Tidak ada assertz/retract fakta sesi di file ini; semua perubahan
%   data sesi lewat API basis_pengetahuan milik Anggota 4.
% - Tanda bahaya dikelola LOKAL di file ini (tanda_bahaya_info/2);
%   mereka BUKAN kode gejala baru dan tidak pernah menjadi syarat
%   aturan. Sistem tidak mendiagnosis kondisi gawat dari tanda itu.
% - Seluruh teks ASCII dan bahasa Indonesia. Hasil selalu dibingkai
%   "kondisi yang mungkin sesuai", bukan diagnosis medis.
% - Logika murni dipisah dari I/O agar mudah dites tanpa stdin
%   (docs/arsitektur.md, bagian Predikat antarmuka).
% =====================================================================

:- use_module(library(lists)).
:- use_module(library(readutil)).

% ---------------------------------------------------------------------
% BAGIAN 1: Predikat murni (tanpa I/O)
% ---------------------------------------------------------------------

% tanda_bahaya_info/2 - daftar 7 tanda darurat; urutan nomor = urutan
% pertanyaan. Lokal antarmuka, bukan kode gejala dari matriks.
tanda_bahaya_info(1, 'Sesak napas berat atau sulit bicara karena sesak').
tanda_bahaya_info(2, 'Napas makin cepat atau semakin berat').
tanda_bahaya_info(3, 'Nyeri dada berat atau menetap').
tanda_bahaya_info(4, 'Kebingungan atau penurunan kesadaran').
tanda_bahaya_info(5, 'Bibir atau ujung jari kebiruan').
tanda_bahaya_info(6, 'Batuk berdarah atau dahak berdarah').
tanda_bahaya_info(7, 'Kondisi cepat memburuk atau gejala berat datang tiba-tiba').

% pesan_tanda_bahaya/2 - dari daftar nomor tanda yang dijawab "ya"
% menjadi baris-baris peringatan yang mencolok.
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

% status_pesan/2 - mapping status inferensi ke pesan pengguna.
status_pesan(belum_ada_gejala,
             "Belum ada gejala yang dipilih untuk sesi ini.").
status_pesan(tidak_ada_aturan_cocok,
             "Tidak ada aturan yang cocok dengan kombinasi gejala yang dipilih.").
status_pesan(ada_hasil,
             "Kondisi berikut adalah kondisi yang mungkin sesuai dengan gejala yang dipilih.").

% pertanyaan_gejala/2 - teks pertanyaan untuk kode gejala.
% G05 dan G07 memakai pertanyaan khusus yang lebih ringkas agar nama
% tampilan kamus (yang menyertakan keterangan detail) tidak membingungkan.
pertanyaan_gejala('G05', 'Apakah Anda mengalami batuk?').
pertanyaan_gejala('G07', 'Apakah Anda mengalami demam?').
pertanyaan_gejala('G20b', 'Apakah napas Anda terdengar berbunyi tidak biasa?').
pertanyaan_gejala(Kode, Teks) :-
    \+ memberchk(Kode, ['G05', 'G07', 'G20b']),
    gejala_info(Kode, Nama),
    atomics_to_string(['Apakah Anda mengalami ', Nama, '?'], Teks).

% gejala_ditanya_langsung/1 - gejala yang masuk wawancara umum.
% Di luar wawancara umum:
% - G25a-G25d : detail dahak (detail_dahak), keluar lewat alur detail G05.
% - G08a      : perlu pengukuran suhu (perlu_pengukuran), keluar lewat
%               alur G07 saat suhu benar-benar terukur.
% - G29/G31   : perlu pengukuran/pemeriksaan (perlu_pengukuran dan
%               perlu_pemeriksaan_ahli), keluar lewat pertanyaan opsional
%               hasil pengukuran/pemeriksaan tenaga kesehatan.
gejala_ditanya_langsung(Kode) :-
    gejala_info(Kode, _),
    \+ gejala_tandai(Kode, detail_dahak),
    \+ gejala_tandai(Kode, perlu_pengukuran),
    \+ gejala_tandai(Kode, perlu_pemeriksaan_ahli).

% kelompokkan_hasil/2 - mengelompokkan daftar hasil/5 per kondisi.
% keysort/2 sebelum group_pairs_by_key/2 agar urutan kelompok stabil
% berdasarkan kode kondisi. Urutan bukan tingkat kepastian.
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

% nama_tampil/2 - nama Ramah untuk layar hasil, digunakan teks_gejala/2.
% Nama kamus gejala_info/2 memuat keterangan teknis (mis. G05 "Batuk
% (jenis batuk menjadi detail)") yang pas untuk pengembang tetapi
% membingungkan orang awam pada blok hasil; kode-kode yang terdaftar
% di sini tampil versi pendeknya. Kode lain memakai nama kamus.
nama_tampil('G05', 'Batuk').
nama_tampil('G07', 'Demam').
nama_tampil(Kode, Nama) :-
    \+ memberchk(Kode, ['G05', 'G07']),
    gejala_info(Kode, Nama).

% teks_gejala/2 - kode gejala menjadi teks baca "KODE (nama)".
teks_gejala(Kode, Teks) :-
    nama_tampil(Kode, Nama),
    !,
    atomics_to_string([Kode, ' (', Nama, ')'], Teks).
teks_gejala(Kode, Kode).

% ---------------------------------------------------------------------
% potong_baris/3 - pemenggalan paragraf panjang per kata menjadi
% beberapa baris maksimal Lebar karakter, agar Penjelasan/Saran tidak
% tampil sebagai SATU baris panjang yang sulit dibaca di konsol
% sempit. Kata tunggal yang sangat panjang tetap diberi barisnya
% sendiri. Baris hasil berupa string.
% ---------------------------------------------------------------------
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

% awali/3 - menambahkan awalan (umumnya jarak indentasi) pada setiap
% baris hasil pemenggalan agar blok tetap tersusun rapi.
awali(Awalan, Baris, BarisAwalan) :-
    atomics_to_string([Awalan, Baris], BarisAwalan).

% poin_dukungan/2 - satu gejala pendukung menjadi poin daftar.
poin_dukungan(TeksGejala, Baris) :-
    atomics_to_string(['  - ', TeksGejala], Baris).

% garis_bingkai/1 - garis 64 karakter '=' untuk menonjolkan kepala
% tiap kelompok kondisi pada hasil. ASCII murni agar tampil sama di
% semua terminal Windows (tanpa bergantung dukungan warna ANSI).
garis_bingkai(Baris) :-
    length(Chars, 64),
    maplist(=(61), Chars),
    string_chars(Baris, Chars).

% baris_saran/2 - saran umum satu kondisi menjadi blok baris:
% baris pertama berawalan "Saran umum: ", baris lanjutan di-indent.
baris_saran(Saran, Baris) :-
    potong_baris(Saran, 64, Mentah),
    Mentah = [Pertama|Sisa],
    atomics_to_string(['  Saran umum: ', Pertama], BarisPertama),
    maplist(awali('    '), Sisa, SisaInden),
    append([[BarisPertama], SisaInden], Baris).

% jadikan_teks/2 - normalisasi atom/string menjadi string untuk tampilan
% (Penjelasan aturan antar file memakai campuran atom dan string).
jadikan_teks(Atom, Teks) :-
    atom(Atom),
    !,
    atom_string(Atom, Teks).
jadikan_teks(Teks, Teks).

% susun_keluaran/4 - rakit baris tampilan sesi:
%   1) blok tanda bahaya (bila ada) - paling atas agar tidak tertutup
%      daftar kecocokan;
%   2) blok hasil per kondisi / pesan status;
%   3) blok penutup (disclaimer + anjuran evaluasi tenaga kesehatan).
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

% ---------------------------------------------------------------------
% saran_kondisi/2 - kamus saran umum edukasi per kondisi (P01-P06).
% Lokasi: antarmuka, karena hanya dipakai untuk TAMPILAN hasil; ini
% BUKAN syarat aturan, BUKAN kode gejala, dan tidak mengubah inferensi
% (agent.md 5, 6). Setiap kelompok kondisi yang muncul di hasil akan
% menambahkan satu blok "Saran umum" dari kamus ini.
%
% Teks bertumpu pada sumber docs/referensi.md (akses 21 Oktober 2026):
% - P01: CDC "About Common Cold" (umumnya pulih kurang dari seminggu)
%   dan CDC "Manage Common Cold" (istirahat, cairan; evaluasi bila
%   gejala lebih dari 10 hari tanpa membaik, demam lebih dari 4 hari,
%   sulit bernapas, atau membaik lalu memburuk).
% - P02: sumber yang dipakai (Kemenkes "Diagnosis Faringitis")
%   mendeskripsikan gejala, bukan pengelolaan; teks sengaja konservatif
%   tanpa klaim baru: anjuran evaluasi + batas keterbatasan penyebab
%   yang sama dengan catatan file aturan.
% - P03: CDC "Sinus Infection Basics", bagian When to seek medical
%   care (>10 hari tanpa membaik, memburuk setelah membaik, demam
%   3-4 hari lebih, nyeri wajah/sakit kepala berat) dan Treatment
%   (banyak kasus membaik dengan sendirinya).
% - P04: CDC "Chest Cold (Acute Bronchitis) Basics" (gejala kurang
%   dari 3 minggu; evaluasi bila lebih dari 3 minggu, demam lebih
%   dari 5 hari, dahak berdarah, sesak; umumnya membaik sendiri).
% - P05: WHO Asthma; asma pembanding noninfeksi (agent.md 1), jadi
%   saran hanya mengarah ke pengelolaan oleh tenaga kesehatan.
% - P06: WHO Pneumonia dan PNPK pneumonia dewasa Kemenkes; saran
%   berupa penilaian tenaga kesehatan, bukan pengobatan lingkap.
% Batas keselamatan (agent.md 3): teks tidak memuat nama obat, dosis,
% antibiotik, atau klaim kepastian; frasa tetap "evaluasi/segera cari
% pertolongan medis". Teks ASCII murni (aman konsol Windows).
% ---------------------------------------------------------------------
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

% kelompok_ke_baris/3 - satu blok tampilan per kelompok kondisi dengan
% nomor urut tampilan (bukan peringkat; disclaimer tetap dicetak di
% header hasil). Baris hasil berupa KUMPULAN blok (daftar daftar) yang
% diratakan oleh blok_hasil lewat append.
kelompok_ke_baris([], _, []).
kelompok_ke_baris([Kelompok|Sisa], Nomer, [BarisGrup|SisaBaris]) :-
    baris_kelompok(Nomer, Kelompok, BarisGrup),
    NomerBerikut is Nomer + 1,
    kelompok_ke_baris(Sisa, NomerBerikut, SisaBaris).

% baris_kelompok/3 - susun blok satu kondisi dengan bingkai agar
% kepala kondisi mudah dilihat:
%   baris kosong -> garis '=' -> "No. N." + judul kondisi -> garis '='
%   -> blok tiap aturan yang cocok -> Saran umum.
% Nomor urut tampilan bukan peringkat (disclaimer di header hasil).
% Kegagalan saran_kondisi sengaja tidak menggagalkan tampilan
% (kamus tidak lengkap tidak boleh menyembunyikan hasil).
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

% baris_aturan/2 - susun blok satu aturan yang cocok, urutan bacaan
% dari yang paling dekat dengan pengalaman pengguna:
%   gejala yang menyertai -> penjelasan (dipenggal) -> ID aturan.
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

% Parsing masukan murni (dipakai I/O dan bisa dites langsung).
% kata_pertama/2 - token pertama dari satu baris masukan, huruf kecil.
% Spasi/tab juga dipakai sebagai padding agar baris berawal/berakhir
% spasi tetap menghasilkan token pertama yang tidak kosong.
kata_pertama(Teks, Kata) :-
    split_string(Teks, " \t", " \t", [Pertama|_]),
    atom_string(KAwal, Pertama),
    downcase_atom(KAwal, Kata).

% jawaban_ya_tidak/2 - 'ya'/'y' -> ya; 'tidak'/'t' -> tidak; selain itu
% gagal (pemanggil I/O mengulang pertanyaan).
jawaban_ya_tidak(Teks, ya) :-
    kata_pertama(Teks, Kata),
    memberchk(Kata, [ya, y]).
jawaban_ya_tidak(Teks, tidak) :-
    kata_pertama(Teks, Kata),
    memberchk(Kata, [tidak, t]).

% pilihan_menu/2 - masukan menu: '1' atau '2'; selain itu gagal.
pilihan_menu(Teks, 1) :-
    kata_pertama(Teks, '1').
pilihan_menu(Teks, 2) :-
    kata_pertama(Teks, '2').

% parse_suhu/3 - baris masukan suhu menjadi (Nilai, TeksNormal).
% Menerima koma desimal (38,2) dan titik (38.2); gagal untuk bukan angka.
parse_suhu(Teks, Nilai, TeksSuhu) :-
    split_string(Teks, " \t", "", [Pertama|_]),
    split_string(Pertama, ",", "", Bagian),
    atomics_to_string(Bagian, '.', Bersih),
    number_string(Nilai, Bersih),
    Nilai > 30.0,
    Nilai < 50.0,
    TeksSuhu = Bersih.

% ---------------------------------------------------------------------
% BAGIAN 2: I/O konsultasi
% ---------------------------------------------------------------------

% tulis_baris/1, baca_baris/1 - pembantu I/O intensif.
% baca_baris melempar akhir_masukan ketika stream berakhir (EOF),
% sehingga tidak ada error yang tidak tertangani di wawancara.
tulis_baris(Teks) :-
    format('~s~n', [Teks]).

baca_baris(Teks) :-
    read_line_to_string(user_input, Bacaan),
    ( Bacaan == end_of_file
    -> throw(akhir_masukan)
    ;  Teks = Bacaan
    ).

% tanya_ya_tidak/2 - pertanyaan ya/tidak dengan pengulangan masukan
% tidak valid sampai jawaban dipahami.
tanya_ya_tidak(Pertanyaan, Jawaban) :-
    format('~s (ya/tidak): ', [Pertanyaan]),
    baca_baris(Teks),
    ( jawaban_ya_tidak(Teks, Jawaban)
    -> true
    ;  format('Jawaban tidak dipahami. Jawab "ya" atau "tidak".~n', []),
       tanya_ya_tidak(Pertanyaan, Jawaban)
    ).

% jalankan_aplikasi/0 - pembuka, menu (1 konsultasi baru, 2 keluar),
% penanganan EOF, dan keluar bersih dengan halt 0.
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

% konsultasi/0 - satu sesi penuh:
%   1) reset fakta sesi lama;
%   2) pembuka + peringatan;
%   3) 7 pertanyaan tanda bahaya terlebih dahulu; jika ada "ya", pesan
%      darurat muncul segera dan diulang di paling atas hasil;
%   4) wawancara gejala umum;
%   5) pertanyaan opsional hasil pengukuran/pemeriksaan (G29/G31);
%   6) inferensi dan tampilan hasil (tanda bahaya tetap paling atas).
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

% jawab_tanda_bahaya/2 - tanyakan 7 tanda secara berurutan; kumpulkan
% nomor yang dijawab "ya". Setiap "ya" langsung memunculkan pesan
% darurat yang mencolok (dan nanti diulang di bagian hasil).
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

% Wawancara gejala umum berdasarkan gejala_info/2 (urutan kamus).
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

% Alur detail G05: jenis batuk (kering/berdahak) sebagai detail; bila
% berdahak, rincian dahak G25a-G25d diberi pertanyaan opsional.
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

% Alur detail G07: bila suhu benar-benar diukur, simpan detail suhu;
% bila >= 38 C, catat G08a lewat tambah_gejala/1 (validasi induk tetap
% di basis pengetahuan). Nilai di bawah 38 C tidak dianggap G08a.
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

% Pertanyaan opsional G29/G31 (adjustment tim): tidak ditanya ke pengguna
% awam, kecuali pengguna menyatakan punya hasil pengukuran frekuensi
% napas atau pemeriksaan tenaga kesehatan yang sebenarnya, sehingga
% aturan P06-R06 tetap dapat tercapai dengan cara yang jujur.
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
