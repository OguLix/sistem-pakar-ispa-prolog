% =====================================================================
% basis_pengetahuan.pl — Kamus kode gejala/kondisi dan fakta sesi
% Pemilik file: Anggota 4 (lihat docs/pembagian_tugas.md)
%
% Isi file:
%   A. Kamus kode gejala dan kode kondisi
%   B. Fakta sesi dinamis (gejala_terpilih/1, detail_gejala/2)
%   C. Prosedur sesi (tambah/hapus/reset)
%
% Batas tanggung jawab (agent.md §5):
%   - File ini TIDAK berisi aturan diagnosis. Aturan ada di
%     aturan_p01_p02.pl, aturan_p03_p04.pl, dan aturan_p05_p06.pl;
%     file aturan membaca fakta sesi yang dikelola di sini.
%   - File ini HARUS dimuat sebelum file aturan dan mesin inferensi,
%     karena deklarasi dynamic di sini harus ada lebih dulu.
%
% Aturan penamaan yang menjadi dasar (agent.md §3 dan §6):
%   - G05 batuk: jenis batuk adalah detail, bukan gejala kedua yang
%     independen (tidak dihitung dua kali).
%   - G07 demam dan G08a suhu >=38°C berkaitan: suhu adalah
%     penyempurnaan demam; G08a hanya boleh dicatat jika G07 terpilih.
%   - G25a-G25d adalah detail dahak, bukan gejala independen.
%   - G29 dan G31 memerlukan pengukuran/pemeriksaan oleh orang yang
%     kompeten; nilai tidak boleh ditebak pengguna awam.
%   - Tampilan sekret purulen (G14) bukan bukti pasti infeksi bakteri.
% Sumber kode: docs/matriks_basis_pengetahuan.md (status: draf awal
% yang perlu ditinjau; agent.md §2 prinsip 9).
% =====================================================================

% ---------------------------------------------------------------------
% A. Kamus gejala dan kondisi
%
% Kamus menggunakan predikat terpisah dari fakta sesi (docs/arsitektur.md,
% bagian "Fakta sesi") agar data statis tidak tercampur fakta wawancara.
% Teks disengaja tanpa karakter non-ASCII agar aman di konsol Windows.
% ---------------------------------------------------------------------

% --- Nama tampilan gejala (kode dari matriks; G06 tidak dipakai matriks) ---
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

% --- Penanda sifat khusus gejala (atom penanda, bukan teks bebas) ---
% detail_dahak            : masuk lewat tambah_detail/2, bukan tambah_gejala/1.
% perlu_pengukuran        : nilainya harus hasil pengukuran nyata.
% perlu_pemeriksaan_ahli  : nilainya dari pemeriksaan tenaga kesehatan.
gejala_tandai('G25a', detail_dahak).
gejala_tandai('G25b', detail_dahak).
gejala_tandai('G25c', detail_dahak).
gejala_tandai('G25d', detail_dahak).
gejala_tandai('G08a', perlu_pengukuran).
gejala_tandai('G29', perlu_pengukuran).
gejala_tandai('G31', perlu_pemeriksaan_ahli).

% --- Catatan penjelasan untuk antarmuka (teks, opsional dipakai) ---
% Tujuannya menjaga kepatuhan keselamatan agent.md §2 no. 7 dan §7 saat
% antarmuka menampilkan pertanyaan/penjelasan, tanpa mengubah aturan.
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

% --- Nama tampilan kondisi (docs/matriks_basis_pengetahuan.md) ---
kondisi_info('P01', 'Common cold / selesma').
kondisi_info('P02', 'Faringitis').
kondisi_info('P03', 'Sinusitis akut').
kondisi_info('P04', 'Bronkitis akut').
kondisi_info('P05', 'Asma (pembanding noninfeksi)').
kondisi_info('P06', 'Pneumonia dewasa').

% --- Penanda kondisi noninfeksi ---
% P05 asma adalah pembanding, BUKAN penyakit ISPA infeksi (agent.md §1).
% Antarmuka wajib menampilkannya sebagai kelompok pembanding.
kondisi_noninfeksi('P05').

% --- Validasi kode (kemudahan untuk antarmuka/tes) ---
kode_gejala_valid(Kode) :- gejala_info(Kode, _).
kode_kondisi_valid(Kode) :- kondisi_info(Kode, _).

% ---------------------------------------------------------------------
% B. Fakta sesi
%
% Fakta sesi SELALU kosong saat program dimuat; hanya diisi lewat
% prosedur di bagian C selama satu sesi wawancara. Elemen penting:
%   gejala_terpilih(KodeGejala).
%   detail_gejala(KodeDariMatriks, NilaiDetail).
% Kontrak bentuk detail_gejala/2 yang disepakati (rata-rata dipakai
% antarmuka dan file aturan):
%   detail_gejala('G05', 'kering')        % jenis batuk
%   detail_gejala('G05', 'berdahak')      % jenis batuk
%   detail_gejala('G07', 'suhu_38.2')     % suhu terukur, memengaruhi G08a
%   detail_gejala('G25a', 'kuning_hijau') % rincian dahak, opsional
% Nilai detail adalah atom deskriptif; antarmuka menentukan daftar
% pilihan yang ditawarkan. Detail tidak pernah dihitung sebagai gejala.
% ---------------------------------------------------------------------

:- dynamic gejala_terpilih/1.
:- dynamic detail_gejala/2.

% ---------------------------------------------------------------------
% C. Prosedur sesi
% ---------------------------------------------------------------------

% --- tambah_gejala/1 ---
% Aturan penerimaan:
%   1) kode harus dikenal kamus, jika tidak -> pesan + gagal;
%   2) kode detail dahak (G25a-G25d) ditolak di sini: gunakan
%      tambah_detail/2 agar tidak dihitung sebagai gejala;
%   3) 'G08a' hanya boleh dicat jika 'G07' sudah terpilih (agent.md §6);
%   4) menambah dua kali kode yang sama tidak membuat fakta ganda.
% Semua klausa penolakan diakhiri cut+fail agar tidak jatuh ke klausa
% assert setelah pesan kesalahan dicetak.
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

% --- kode_induk_detail/2 ---
% Detail dahak (G25a-G25d) milik G05; detail gejala lain milik
% gejalanya sendiri (mis. suhu milik G07). Dipakai validasi tambah_detail/2.
kode_induk_detail(Kode, Kode) :-
    gejala_info(Kode, _),
    \+ gejala_tandai(Kode, detail_dahak).
kode_induk_detail('G25a', 'G05').
kode_induk_detail('G25b', 'G05').
kode_induk_detail('G25c', 'G05').
kode_induk_detail('G25d', 'G05').

% --- tambah_detail/2 ---
% Syarat: kode dikenal dan gejala induknya sudah terpilih, agar tidak
% ada detail yatim tanpa gejalanya. Nilai terbaru menggantikan nilai
% lama untuk kode yang sama (satu nilai per kode, cukup untuk suhu dan
% rincian dahak dalam ruang lingkup proyek ini).
% Detail bersifat opsional dan TIDAK dihitung sebagai gejala kedua
% (agent.md §6; docs/matriks_basis_pengetahuan.md, bagian definisi input).
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

% --- hapus_gejala/1 ---
% Menghapus satu gejala beserta detail miliknya. Menghapus G05 (batuk)
% otomatis menghapus seluruh detail dahak karena detail dahak hanya
% bermakna bersama batuk berdahak (docs/matriks_basis_pengetahuan.md).
hapus_gejala(Kode) :-
    retractall(gejala_terpilih(Kode)),
    retractall(detail_gejala(Kode, _)),
    ( Kode == 'G05'
    -> forall(gejala_tandai(D, detail_dahak), retractall(detail_gejala(D, _)))
    ;  true
    ).

% --- reset_sesi/0 ---
% Wajib dipanggil sebelum sesi wawancara baru agar masukan sesi lama
% tidak terbawa (agent.md §6; docs/arsitektur.md).
reset_sesi :-
    retractall(gejala_terpilih(_)),
    retractall(detail_gejala(_, _)).

% --- Pembacaan fakta sesi (deterministik, terurut untuk kestabilan output) ---
daftar_gejala_terpilih(Daftar) :-
    findall(Kode, gejala_terpilih(Kode), KodeMentah),
    sort(KodeMentah, Daftar).

daftar_detail(Daftar) :-
    findall(detail_gejala(Kode, Nilai), detail_gejala(Kode, Nilai), Mentah),
    sort(Mentah, Daftar).

% Catatan gaya rapat: tidak ada aturan diagnosis, tidak ada teks terapi,
% dan tidak ada klaim probabilitas di file ini (agent.md §2, §3).
% Pesan keselamatan untuk keluhan darurat dipandu antarmuka; daftar
% penanda perlu_pengukuran/perlu_pemeriksaan_ahli hanya membantu antarmuka
% menyusun pertanyaan, bukan menggantikan pesan keselamatan itu.
