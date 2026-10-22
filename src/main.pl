% =====================================================================
% main.pl - Titik masuk aplikasi Sistem Pakar ISPA
% File bersama tim (agent.md 5; docs/pembagian_tugas.md).
%
% Urutan muat (agent.md 6; docs/arsitektur.md):
%   basis_pengetahuan -> aturan_p01_p02 -> aturan_p03_p04 ->
%   aturan_p05_p06 -> mesin_inferensi -> antarmuka
% Deklarasi dynamic fakta sesi ada di basis_pengetahuan, jadi file itu
% harus termuat paling dulu sebelum file aturan dipakai.
%
% Cara menjalankan:
%   swipl -q -s src/main.pl
% Aplikasi langsung berjalan dan keluar bersih (halt 0) ketika
% pengguna memilih menu keluar atau input berakhir (end of file).
%
% Jalur muat dihitung dari lokasi file ini, sehingga aman dipanggil
% baik dari root repo maupun dari direktori lain.
% =====================================================================

% muat_berkas/2 - memuat satu file src dengan jalur hasil penggabungan
% direktori file main ini dan nama file.
muat_berkas(DirMain, Nama) :-
    atomics_to_string([DirMain, '/', Nama], Jalur),
    consult(Jalur).

% Directive muat: menghitung direktori file ini lalu memuat enam file
% aplikasi secara berurutan. File aturan dimuat setelah kamus/fakta
% gejala; antarmuka dimuat setelah aturan dan mesin inferensi agar
% pertanyaan khusus seperti G20b selaras dengan aturan yang memakainya.
:- prolog_load_context(source, SumberMain),
   file_directory_name(SumberMain, DirMain),
   maplist(muat_berkas(DirMain),
           ['basis_pengetahuan.pl',
            'aturan_p01_p02.pl',
            'aturan_p03_p04.pl',
            'aturan_p05_p06.pl',
            'mesin_inferensi.pl',
            'antarmuka.pl']).

% Hook utama: berjalan setelah file ini dimuat sebagai program utama
% (swipl -s), sehingga aplikasi langsung berjalan tanpa perintah -g.
:- initialization(jalankan_aplikasi, main).
