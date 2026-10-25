muat_berkas(DirMain, Nama) :-
    atomics_to_string([DirMain, '/', Nama], Jalur),
    consult(Jalur).

:- prolog_load_context(source, SumberMain),
   file_directory_name(SumberMain, DirMain),
   maplist(muat_berkas(DirMain),
           ['basis_pengetahuan.pl',
            'aturan_p01_p02.pl',
            'aturan_p03_p04.pl',
            'aturan_p05_p06.pl',
            'mesin_inferensi.pl',
            'antarmuka.pl']).

:- initialization(jalankan_aplikasi, main).
