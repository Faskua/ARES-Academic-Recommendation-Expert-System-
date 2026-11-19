%% ARES - Menu de la interfaz de linea de comandos
%%
%% Uso:
%%   swipl main.pl
%%
%% El menu trabaja sobre los tres perfiles de demostracion y delega en
%% los modulos de core/: avance, recomendador, puntuacion, selector de
%% optativas y explicaciones.

:- module(menu, [
    menu/0,
    opciones/1,
    ejecutar/1
]).

:- use_module('formato.pl').
:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Opciones
%% ---------------------------------------------------------------------------

opciones([
    perfil-'Ver datos del perfil',
    avance-'Ver avance academico',
    recomendacion-'Recomendar materias del cuatrimestre',
    optativas-'Recomendar par de optativas',
    explicacion-'Explicar una materia',
    salir-'Salir'
]).

%% ---------------------------------------------------------------------------
%% Bucle principal
%% ---------------------------------------------------------------------------

menu :-
    writeln(''),
    writeln('=== ARES - Recomendacion academica ==='),
    writeln('Perfiles disponibles: ana, beto, carla.'),
    repetir.

repetir :-
    writeln(''),
    opciones(Opciones),
    forall(member(Clave-Descripcion, Opciones),
           format('  ~w) ~w~n', [Clave, Descripcion])),
    write('Opcion: '),
    flush_output,
    read(Opcion),
    (   ( Opcion == salir ; Opcion == end_of_file )
    ->  writeln('Hasta luego.')
    ;   (   ejecutar(Opcion)
        ->  true
        ;   writeln('Opcion invalida.')
        ),
        repetir
    ).

%% ---------------------------------------------------------------------------
%% Acciones
%% ---------------------------------------------------------------------------

ejecutar(perfil) :-
    con_perfil(mostrar_perfil).
ejecutar(avance) :-
    con_perfil(mostrar_avance).
ejecutar(recomendacion) :-
    con_perfil(mostrar_recomendacion).
ejecutar(optativas) :-
    con_perfil(mostrar_optativas).
ejecutar(explicacion) :-
    con_perfil(mostrar_explicacion).

con_perfil(Objetivo) :-
    write('Perfil (ana/beto/carla): '),
    flush_output,
    read(Perfil),
    (   perfiles:estudiante(Perfil)
    ->  call(Objetivo, Perfil)
    ;   writeln('Perfil desconocido.')
    ).

%% ---------------------------------------------------------------------------
%% Vistas
%% ---------------------------------------------------------------------------

mostrar_perfil(Perfil) :-
    perfiles:anio_actual(Perfil, Anio),
    perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
    perfiles:promedio(Perfil, Promedio),
    perfiles:max_creditos(Perfil, Maximo),
    findall(Interes, perfiles:interes(Perfil, Interes), Intereses),
    formato:lista(Intereses, InteresesTexto),
    formato:creditos(Maximo, MaximoTexto),
    format('~nPerfil ~w: ano ~w, cuatrimestre ~w~n',
           [Perfil, Anio, Cuatrimestre]),
    format('Promedio: ~w~n', [Promedio]),
    format('Carga maxima: ~w~n', [MaximoTexto]),
    format('Intereses: ~w~n', [InteresesTexto]).

mostrar_avance(Perfil) :-
    avance:avance(Perfil, Porcentaje),
    avance:obligatorias_aprobadas(Perfil, Obligatorias),
    avance:optativas_aprobadas(Perfil, Optativas),
    formato:porcentaje(Porcentaje, PorcentajeTexto),
    format('~nAvance de ~w: ~w~n', [Perfil, PorcentajeTexto]),
    format('Obligatorias aprobadas: ~w de 25~n', [Obligatorias]),
    format('Optativas aprobadas: ~w de 2~n', [Optativas]).

mostrar_recomendacion(Perfil) :-
    recomendador:recomendar(Perfil, Seleccion, Creditos),
    findall([Curso, Puntaje, CreditosCurso],
            ( member(Curso, Seleccion),
              puntuacion:puntaje(Perfil, Curso, Puntaje),
              puntuacion:creditos_de(Curso, CreditosCurso)
            ),
            Filas),
    formato:tabla(['Materia', 'Puntaje', 'Creditos'], Filas, Tabla),
    formato:creditos(Creditos, CreditosTexto),
    format('~nRecomendacion para ~w~n~w~n', [Perfil, Tabla]),
    format('Total: ~w~n', [CreditosTexto]).

mostrar_optativas(Perfil) :-
    (   selector_optativas:recomendar_par(Perfil, [O1, O2])
    ->  selector_optativas:puntaje_par(Perfil, O1, O2, Puntaje),
        findall([Optativa, Nombre, Area],
                ( member(Optativa, [O1, O2]),
                  optativas:optativa(Optativa, Nombre, Area, _, _, _)
                ),
                Filas),
        formato:tabla(['Optativa', 'Nombre', 'Area'], Filas, Tabla),
        format('~nPar de optativas para ~w~n~w~n', [Perfil, Tabla]),
        format('Puntaje del par: ~w~n', [Puntaje])
    ;   format('~n~w no tiene optativas elegibles en este cuatrimestre.~n',
               [Perfil])
    ).

mostrar_explicacion(Perfil) :-
    write('Materia a explicar: '),
    flush_output,
    read(Curso),
    (   explicaciones:por_que(Perfil, Curso, Razones),
        Razones \= []
    ->  (   perfiles:aprobo(Perfil, Curso)
        ->  format('~nNota: ~w ya figura aprobada por ~w.~n', [Curso, Perfil])
        ;   true
        ),
        format('~nPor que ~w para ~w:~n', [Curso, Perfil]),
        forall(member(Razon, Razones),
               ( explicaciones:texto(Razon, Texto),
                 format('  - ~w~n', [Texto])
               ))
    ;   format('~nNo hay informacion para ~w.~n', [Curso])
    ).
