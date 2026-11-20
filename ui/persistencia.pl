%% ARES - Persistencia de perfiles
%%
%% Guarda y carga perfiles como hechos Prolog legibles en datos/:
%%
%%   datos/perfil_ana.pl
%%
%% El archivo contiene un hecho perfil/6 con los datos generales y hechos
%% interes/2, aprobo/2, cursa/2 y recursa/2 para el resto.
%%
%%   guardar(Perfil)          guarda el perfil en la ruta por defecto
%%   guardar(Perfil, Archivo) guarda en una ruta explicita
%%   cargar(Perfil)           relee el perfil y actualiza el modulo perfiles
%%   cargar(Perfil, Archivo)  idem, desde una ruta explicita
%%   guardado(Perfil)         true si existe el archivo
%%   eliminar(Perfil)         borra el archivo guardado
%%   listar(Perfiles)         nombres de los perfiles guardados
%%   hechos(Perfil, Hechos)   hechos que se escriben para un perfil

:- module(persistencia, [
    guardar/1,
    guardar/2,
    cargar/1,
    cargar/2,
    guardado/1,
    eliminar/1,
    eliminar/2,
    listar/1,
    hechos/2,
    archivo_perfil/2
]).

:- use_module(library(lists)).
:- use_module(library(filesex)).

%% ---------------------------------------------------------------------------
%% Rutas
%% ---------------------------------------------------------------------------

%% El directorio de datos cuelga de la raiz del proyecto, no del cwd.
directorio_datos(Directorio) :-
    source_file(persistencia:guardar(_, _), Archivo),
    file_directory_name(Archivo, Ui),
    file_directory_name(Ui, Raiz),
    atomic_list_concat([Raiz, 'datos'], '/', Directorio).

archivo_perfil(Perfil, Archivo) :-
    directorio_datos(Directorio),
    atomic_list_concat([Directorio, '/perfil_', Perfil, '.pl'], Archivo).

asegurar_directorio(Archivo) :-
    file_directory_name(Archivo, Directorio),
    (   exists_directory(Directorio)
    ->  true
    ;   make_directory_path(Directorio)
    ).

%% ---------------------------------------------------------------------------
%% Hechos
%% ---------------------------------------------------------------------------

hechos(Perfil, Hechos) :-
    perfiles:estudiante(Perfil),
    perfiles:anio_actual(Perfil, Anio),
    perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
    perfiles:promedio(Perfil, Promedio),
    perfiles:max_creditos(Perfil, Maximo),
    perfiles:objetivo(Perfil, Objetivo),
    findall(interes(Perfil, Interes), perfiles:interes(Perfil, Interes), Intereses),
    findall(aprobo(Perfil, Curso), perfiles:aprobo(Perfil, Curso), Aprobadas),
    findall(cursa(Perfil, Curso), perfiles:cursa(Perfil, Curso), Cursando),
    findall(recursa(Perfil, Curso), perfiles:recursa(Perfil, Curso), Recursadas),
    append([Intereses, Aprobadas, Cursando, Recursadas], Extras),
    Hechos = [perfil(Perfil, Anio, Cuatrimestre, Promedio, Maximo, Objetivo)|Extras].

%% ---------------------------------------------------------------------------
%% Guardar
%% ---------------------------------------------------------------------------

guardar(Perfil) :-
    archivo_perfil(Perfil, Archivo),
    guardar(Perfil, Archivo).

guardar(Perfil, Archivo) :-
    hechos(Perfil, Hechos),
    asegurar_directorio(Archivo),
    setup_call_cleanup(
        open(Archivo, write, Stream),
        forall(member(Hecho, Hechos),
               write_term(Stream, Hecho, [quoted(true), fullstop(true), nl(true)])),
        close(Stream)
    ).

%% ---------------------------------------------------------------------------
%% Cargar
%% ---------------------------------------------------------------------------

cargar(Perfil) :-
    archivo_perfil(Perfil, Archivo),
    cargar(Perfil, Archivo).

cargar(Perfil, Archivo) :-
    exists_file(Archivo),
    setup_call_cleanup(
        open(Archivo, read, Stream),
        cargar_desde(Stream, Perfil),
        close(Stream)
    ).

cargar_desde(Stream, Perfil) :-
    retractar_perfil(Perfil),
    bucle_hechos(Stream).

bucle_hechos(Stream) :-
    read(Stream, Hecho),
    (   Hecho == end_of_file
    ->  true
    ;   once(cargar_hecho(Hecho)),
        bucle_hechos(Stream)
    ).

cargar_hecho(perfil(Perfil, Anio, Cuatrimestre, Promedio, Maximo, Objetivo)) :-
    assertz(perfiles:estudiante(Perfil)),
    assertz(perfiles:anio_actual(Perfil, Anio)),
    assertz(perfiles:cuatrimestre_actual(Perfil, Cuatrimestre)),
    assertz(perfiles:promedio(Perfil, Promedio)),
    assertz(perfiles:max_creditos(Perfil, Maximo)),
    assertz(perfiles:objetivo(Perfil, Objetivo)).

cargar_hecho(interes(Perfil, Interes)) :-
    assertz(perfiles:interes(Perfil, Interes)).
cargar_hecho(aprobo(Perfil, Curso)) :-
    assertz(perfiles:aprobo(Perfil, Curso)).
cargar_hecho(cursa(Perfil, Curso)) :-
    assertz(perfiles:cursa(Perfil, Curso)).
cargar_hecho(recursa(Perfil, Curso)) :-
    assertz(perfiles:recursa(Perfil, Curso)).
cargar_hecho(_Otro) :-
    true.

retractar_perfil(Perfil) :-
    retractall(perfiles:estudiante(Perfil)),
    retractall(perfiles:anio_actual(Perfil, _)),
    retractall(perfiles:cuatrimestre_actual(Perfil, _)),
    retractall(perfiles:promedio(Perfil, _)),
    retractall(perfiles:max_creditos(Perfil, _)),
    retractall(perfiles:objetivo(Perfil, _)),
    retractall(perfiles:interes(Perfil, _)),
    retractall(perfiles:aprobo(Perfil, _)),
    retractall(perfiles:cursa(Perfil, _)),
    retractall(perfiles:recursa(Perfil, _)).

%% ---------------------------------------------------------------------------
%% Consultas y borrado
%% ---------------------------------------------------------------------------

guardado(Perfil) :-
    archivo_perfil(Perfil, Archivo),
    exists_file(Archivo).

eliminar(Perfil) :-
    archivo_perfil(Perfil, Archivo),
    eliminar(Perfil, Archivo).

eliminar(_Perfil, Archivo) :-
    borrar_archivo(Archivo, 5).

%% En Windows un antivirus o el indexador pueden retener el archivo un
%% instante despues de cerrarlo; se reintenta antes de rendirse.
borrar_archivo(Archivo, Intentos) :-
    (   \+ exists_file(Archivo)
    ->  true
    ;   catch(delete_file(Archivo), _, true),
        (   exists_file(Archivo),
            Intentos > 1
        ->  sleep(0.1),
            Restantes is Intentos - 1,
            borrar_archivo(Archivo, Restantes)
        ;   true
        )
    ).

listar(Perfiles) :-
    directorio_datos(Directorio),
    atomic_list_concat([Directorio, '/perfil_*.pl'], Patron),
    findall(Perfil,
            ( expand_file_name(Patron, Archivos),
              member(Archivo, Archivos),
              perfil_de_archivo(Archivo, Perfil)
            ),
            Encontrados),
    sort(Encontrados, Perfiles).

perfil_de_archivo(Archivo, Perfil) :-
    file_base_name(Archivo, Base),
    atom_concat('perfil_', Resto, Base),
    atom_concat(Perfil, '.pl', Resto).
