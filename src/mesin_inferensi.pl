inferensi_sumber(aturan_p01_p02).
inferensi_sumber(aturan_p03_p04).
inferensi_sumber(aturan_p05_p06).

inferensi_nama_kondisi(Kode, Nama) :-
    kondisi_info(Kode, Nama), !.
inferensi_nama_kondisi(Kode, Label) :-
    atom_string(Kode, TeksKode),
    atomics_to_string(['Kondisi tidak dikenal di kamus (', TeksKode, ')'], Label).

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

inferensi_jalankan(Hasil) :-
    findall(Baris, inferensi_baris(Baris), BarisMentah),
    sort(BarisMentah, Hasil).

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
