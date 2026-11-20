%% ARES - Pruebas de persistencia de perfiles

:- use_module('../ui/persistencia.pl').

:- begin_tests(persistencia).

%% ---------------------------------------------------------------------------
%% Utilidades
%% ---------------------------------------------------------------------------

persistencia_test_archivo(Archivo) :-
    (   getenv('TEMP', Directorio)
    ->  true
    ;   getenv('TMP', Directorio)
    ),
    atomic_list_concat([Directorio, 'ares_perfil_prueba.pl'], '/', Archivo).

persistencia_test_crear :-
    assertz(perfiles:estudiante(prueba)),
    assertz(perfiles:anio_actual(prueba, 3)),
    assertz(perfiles:cuatrimestre_actual(prueba, 1)),
    assertz(perfiles:promedio(prueba, 7.5)),
    assertz(perfiles:max_creditos(prueba, 20)),
    assertz(perfiles:objetivo(prueba, graduarse)),
    assertz(perfiles:interes(prueba, sistemas)),
    assertz(perfiles:aprobo(prueba, aed1)),
    assertz(perfiles:recursa(prueba, aed2)).

persistencia_test_borrar_hechos :-
    retractall(perfiles:estudiante(prueba)),
    retractall(perfiles:anio_actual(prueba, _)),
    retractall(perfiles:cuatrimestre_actual(prueba, _)),
    retractall(perfiles:promedio(prueba, _)),
    retractall(perfiles:max_creditos(prueba, _)),
    retractall(perfiles:objetivo(prueba, _)),
    retractall(perfiles:interes(prueba, _)),
    retractall(perfiles:aprobo(prueba, _)),
    retractall(perfiles:cursa(prueba, _)),
    retractall(perfiles:recursa(prueba, _)).

persistencia_test_limpiar :-
    persistencia_test_borrar_hechos,
    persistencia_test_archivo(Archivo),
    persistencia:eliminar(_, Archivo).

%% ---------------------------------------------------------------------------
%% Hechos
%% ---------------------------------------------------------------------------

test(hechos_de_ana) :-
    persistencia:hechos(ana, Hechos),
    memberchk(perfil(ana, 5, 1, 8.5, 30, especializarse), Hechos),
    memberchk(interes(ana, ia), Hechos),
    memberchk(aprobo(ana, aed2), Hechos),
    \+ memberchk(recursa(ana, _), Hechos).

test(hechos_de_beto) :-
    persistencia:hechos(beto, Hechos),
    memberchk(perfil(beto, 3, 1, 6.5, 20, graduarse), Hechos),
    memberchk(recursa(beto, aed2), Hechos).

%% ---------------------------------------------------------------------------
%% Guardar y cargar
%% ---------------------------------------------------------------------------

test(guardar_y_recargar, [cleanup(persistencia_test_limpiar)]) :-
    persistencia_test_archivo(Archivo),
    persistencia_test_crear,
    persistencia:guardar(prueba, Archivo),
    exists_file(Archivo),
    persistencia_test_borrar_hechos,
    \+ perfiles:estudiante(prueba),
    persistencia:cargar(prueba, Archivo),
    perfiles:estudiante(prueba),
    perfiles:anio_actual(prueba, 3),
    perfiles:cuatrimestre_actual(prueba, 1),
    perfiles:promedio(prueba, 7.5),
    perfiles:max_creditos(prueba, 20),
    perfiles:objetivo(prueba, graduarse),
    perfiles:interes(prueba, sistemas),
    perfiles:aprobo(prueba, aed1),
    perfiles:recursa(prueba, aed2),
    \+ perfiles:aprobo(prueba, md2).

test(cargar_inexistente, [fail, cleanup(persistencia_test_limpiar)]) :-
    persistencia_test_limpiar,
    persistencia_test_archivo(Archivo),
    persistencia:cargar(prueba, Archivo).

test(eliminar_borra_el_archivo, [cleanup(persistencia_test_limpiar)]) :-
    persistencia_test_archivo(Archivo),
    persistencia_test_crear,
    persistencia:guardar(prueba, Archivo),
    exists_file(Archivo),
    persistencia:eliminar(prueba, Archivo),
    \+ exists_file(Archivo).

%% ---------------------------------------------------------------------------
%% Ruta por defecto
%% ---------------------------------------------------------------------------

test(archivo_por_defecto) :-
    persistencia:archivo_perfil(beto, Archivo),
    once(sub_atom(Archivo, _, _, _, 'datos/perfil_beto.pl')).

:- end_tests(persistencia).
