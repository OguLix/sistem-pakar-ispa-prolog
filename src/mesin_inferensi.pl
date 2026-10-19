% =====================================================================
% mesin_inferensi.pl — Pengumpulan dan penyajian hasil inferensi
% Pemilik file: Anggota 4 (lihat docs/pembagian_tugas.md)
%
% Kontrak terbuka yang dipanggil file ini (agent.md §6; docs/arsitektur.md):
%   aturan_p01_p02(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
%   aturan_p03_p04(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
%   aturan_p05_p06(KodeKondisi, IdAturan, Penjelasan, GejalaPendukung).
%
% Representasi hasil akhir (disepakati tim; dicatat di docs/arsitektur.md):
%   hasil(KodeKondisi, NamaKondisi, IdAturan, Penjelasan, GejalaPendukung)
%
% Persyaratan muat:
%   - Muat src/basis_pengetahuan.pl lebih dulu (status_inferensi membutuhkan
%     fakta dinamis gejala_terpilih/1 dan kondisi_info/2).
%   - File aturan sebaiknya dimuat sebelum file ini, tetapi memanggil
%     inferensi tetap aman bila sebagian file aturan belum selesai:
%     sumber yang belum bisa dipanggil dilewati dengan pesan peringatan
%     (integrasi bertahap antar anggota, docs/pembagian_tugas.md).
%
% Kepatuhan agent.md:
%   §2 no. 3 : semua kondisi yang cocok dikembalikan; beberapa kondisi
%              boleh muncul bersamaan; urutan hasil BUKAN probabilitas.
%   §2 no. 4 : hasil menyertakan kode/nama kondisi, ID aturan, penjelasan,
%              dan gejala pendukung.
%   §2 no. 5 : hasil kosong dibedakan dari "tidak memiliki penyakit";
%              tidak pernah disimpulkan pengguna sehat.
%   §3       : tidak ada teks diagnosis pasti, terapi, atau resep di sini;
%              pesan keselamatan keluhan darurat dikelola antarmuka.
% =====================================================================

% ---------------------------------------------------------------------
% Sumber aturan (kontrak integrasi; docs/arsitektur.md §Predikat aturan)
% --------------------------------------------------------------------
inferensi_sumber(aturan_p01_p02).
inferensi_sumber(aturan_p03_p04).
inferensi_sumber(aturan_p05_p06).

% ---------------------------------------------------------------------
% nama kondisi dari kamus; bila kondisi tidak dikenal, beri label jelas
% alih-alih gagal, agar baris hasil dari aturan tetap tampil.
% ---------------------------------------------------------------------
inferensi_nama_kondisi(Kode, Nama) :-
    kondisi_info(Kode, Nama), !.
inferensi_nama_kondisi(Kode, Label) :-
    atom_string(Kode, TeksKode),
    atomics_to_string(['Kondisi tidak dikenal di kamus (', TeksKode, ')'], Label).

% ---------------------------------------------------------------------
% inferensi_baris/1 — satu baris per kecocokan aturan sumber manapun.
%
% catch/3 menangkap kondisi "predikat aturan belum ada/belum selesai"
% (existence_error saat fase integrasi bertahap) sehingga sumber lain
% tetap diproses; peringatan dicetak agar tidak gagal senyap.
% ---------------------------------------------------------------------
inferensi_baris(hasil(Kode, Nama, IdAturan, Penjelasan, GejalaPendukung)) :-
    inferensi_sumber(Sumber),
    catch(call(Sumber, Kode, IdAturan, Penjelasan, GejalaPendukung),
          Error,
          ( inferensi_peringatan_sumber(Sumber, Error), fail )),
    inferensi_nama_kondisi(Kode, Nama).

inferensi_peringatan_sumber(Sumber, Error) :-
    format(user_error,
           'Peringatan: sumber aturan ~w belum bisa dipanggil (kalau ini masih tahap integrasi, itu wajar): ~w~n',
           [Sumber, Error]).

% ---------------------------------------------------------------------
% inferensi_jalankan/1 — kumpulkan seluruh baris dari tiga sumber, lalu
% sort/1 membuang duplikasi yang tidak disengaja (baris identik yang
% muncul lebih dari satu kali) sekaligus menstabilkan urutan. Kondisi
% dan aturan yang BERBEDA (ID berbeda, penjelasan berbeda, daftar
% pendukung berbeda) tetap tampil semua.
% ---------------------------------------------------------------------
inferensi_jalankan(Hasil) :-
    findall(Baris, inferensi_baris(Baris), BarisMentah),
    sort(BarisMentah, Hasil).

% ---------------------------------------------------------------------
% inferensi(Status, Hasil) — titik masuk utama untuk antarmuka dan tes.
%
% Status yang mungkin:
%   belum_ada_gejala        — sesi masih kosong (tidak ada masukan sama sekali)
%   ada_hasil               — minimal satu aturan cocok
%   tidak_ada_aturan_cocok  — ada masukan gejala tetapi tidak ada aturan
%                             yang cocok: sistem belum menemukan kecocokan
%                             dari aturan tersedia. Ini BUKAN berarti
%                             pengguna sehat atau tidak memiliki penyakit
%                             (agent.md §2 no. 5).
% ---------------------------------------------------------------------
inferensi(Status, Hasil) :-
    ( \+ gejala_terpilih(_)
    -> Status = belum_ada_gejala,
       Hasil = []
    ;  inferensi_jalankan(Hasil),
       ( Hasil == []
       -> Status = tidak_ada_aturan_cocok
       ;  Status = ada_hasil
       )
    ).
