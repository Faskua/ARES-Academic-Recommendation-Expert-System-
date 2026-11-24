%% ARES - Simulacion de escenarios (what-if)
%%
%% Replanifica un perfil aplicando cambios hipoteticos sin modificar los
%% hechos originales. Para eso clona el perfil en un atomo temporal,
%% aplica los cambios, llama al planificador y borra el clon.
%%
%%   simular(Perfil, Escenario, Plan)
%%   comparar_planes(Perfil, Escenario, Comparacion)
%%
%% Un escenario es un cambio o una lista de cambios:
%%
%%   max_creditos(20)
%%   promedio(8.0)
%%   aprobar(md2)
%%   desaprobar(ia)
%%   cursar(prob)
%%   postergar(md2)
%%   interes(software)
%%
%% Ejemplos:
%%
%%   ?- what_if:simular(carla, max_creditos(20), Plan).
%%   ?- what_if:comparar_planes(carla, max_creditos(20), Comparacion).

:- module(what_if, [
    simular/3,
    comparar_planes/3
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Simulacion
%% ---------------------------------------------------------------------------

simular(Perfil, Escenario, Plan) :-
    perfiles:estudiante(Perfil),
    gensym(what_if, Nombre),
    setup_call_cleanup(
        crear_clon(Perfil, Nombre),
        (   aplicar_cambios(Nombre, Escenario),
            planificador:plan_hasta_egreso(Nombre, Plan)
        ),
        borrar_clon(Nombre)
    ).

%% ---------------------------------------------------------------------------
%% Clon temporal del perfil
%% ---------------------------------------------------------------------------

crear_clon(Perfil, Nombre) :-
    assertz(perfiles:estudiante(Nombre)),
    forall(perfiles:anio_actual(Perfil, Anio),
           assertz(perfiles:anio_actual(Nombre, Anio))),
    forall(perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
           assertz(perfiles:cuatrimestre_actual(Nombre, Cuatrimestre))),
    forall(perfiles:promedio(Perfil, Promedio),
           assertz(perfiles:promedio(Nombre, Promedio))),
    forall(perfiles:max_creditos(Perfil, Maximo),
           assertz(perfiles:max_creditos(Nombre, Maximo))),
    forall(perfiles:objetivo(Perfil, Objetivo),
           assertz(perfiles:objetivo(Nombre, Objetivo))),
    forall(perfiles:interes(Perfil, Interes),
           assertz(perfiles:interes(Nombre, Interes))),
    forall(perfiles:aprobo(Perfil, Curso),
           assertz(perfiles:aprobo(Nombre, Curso))),
    forall(perfiles:cursa(Perfil, Curso),
           assertz(perfiles:cursa(Nombre, Curso))),
    forall(perfiles:recursa(Perfil, Curso),
           assertz(perfiles:recursa(Nombre, Curso))).

borrar_clon(Nombre) :-
    retractall(perfiles:estudiante(Nombre)),
    retractall(perfiles:anio_actual(Nombre, _)),
    retractall(perfiles:cuatrimestre_actual(Nombre, _)),
    retractall(perfiles:promedio(Nombre, _)),
    retractall(perfiles:max_creditos(Nombre, _)),
    retractall(perfiles:objetivo(Nombre, _)),
    retractall(perfiles:interes(Nombre, _)),
    retractall(perfiles:aprobo(Nombre, _)),
    retractall(perfiles:cursa(Nombre, _)),
    retractall(perfiles:recursa(Nombre, _)).

%% ---------------------------------------------------------------------------
%% Cambios del escenario
%% ---------------------------------------------------------------------------

aplicar_cambios(Nombre, Escenario) :-
    cambios(Escenario, Cambios),
    forall(member(Cambio, Cambios), aplicar_cambio(Nombre, Cambio)).

cambios(Escenario, Cambios) :-
    (   is_list(Escenario)
    ->  Cambios = Escenario
    ;   Cambios = [Escenario]
    ).

aplicar_cambio(Nombre, max_creditos(Maximo)) :-
    integer(Maximo),
    Maximo > 0,
    retractall(perfiles:max_creditos(Nombre, _)),
    assertz(perfiles:max_creditos(Nombre, Maximo)).

aplicar_cambio(Nombre, promedio(Promedio)) :-
    number(Promedio),
    Promedio >= 0,
    Promedio =< 10,
    retractall(perfiles:promedio(Nombre, _)),
    assertz(perfiles:promedio(Nombre, Promedio)).

aplicar_cambio(Nombre, anio_actual(Anio)) :-
    integer(Anio),
    Anio >= 1,
    retractall(perfiles:anio_actual(Nombre, _)),
    assertz(perfiles:anio_actual(Nombre, Anio)).

aplicar_cambio(Nombre, cuatrimestre_actual(Cuatrimestre)) :-
    memberchk(Cuatrimestre, [1, 2]),
    retractall(perfiles:cuatrimestre_actual(Nombre, _)),
    assertz(perfiles:cuatrimestre_actual(Nombre, Cuatrimestre)).

aplicar_cambio(Nombre, objetivo(Objetivo)) :-
    atom(Objetivo),
    retractall(perfiles:objetivo(Nombre, _)),
    assertz(perfiles:objetivo(Nombre, Objetivo)).

aplicar_cambio(Nombre, interes(Area)) :-
    atom(Area),
    retractall(perfiles:interes(Nombre, _)),
    assertz(perfiles:interes(Nombre, Area)).

aplicar_cambio(Nombre, agregar_interes(Area)) :-
    atom(Area),
    assertz(perfiles:interes(Nombre, Area)).

aplicar_cambio(Nombre, sin_interes(Area)) :-
    retractall(perfiles:interes(Nombre, Area)).

aplicar_cambio(Nombre, aprobar(Curso)) :-
    grafo:es_curso(Curso),
    retractall(perfiles:aprobo(Nombre, Curso)),
    retractall(perfiles:cursa(Nombre, Curso)),
    retractall(perfiles:recursa(Nombre, Curso)),
    assertz(perfiles:aprobo(Nombre, Curso)).

aplicar_cambio(Nombre, agregar_aprobada(Curso)) :-
    aplicar_cambio(Nombre, aprobar(Curso)).

aplicar_cambio(Nombre, desaprobar(Curso)) :-
    grafo:es_curso(Curso),
    retractall(perfiles:aprobo(Nombre, Curso)).

aplicar_cambio(Nombre, quitar_aprobada(Curso)) :-
    aplicar_cambio(Nombre, desaprobar(Curso)).

aplicar_cambio(Nombre, cursar(Curso)) :-
    grafo:es_curso(Curso),
    retractall(perfiles:aprobo(Nombre, Curso)),
    retractall(perfiles:recursa(Nombre, Curso)),
    assertz(perfiles:cursa(Nombre, Curso)).

aplicar_cambio(Nombre, recursar(Curso)) :-
    grafo:es_curso(Curso),
    retractall(perfiles:aprobo(Nombre, Curso)),
    retractall(perfiles:cursa(Nombre, Curso)),
    assertz(perfiles:recursa(Nombre, Curso)).

aplicar_cambio(Nombre, postergar(Curso)) :-
    grafo:es_curso(Curso),
    retractall(perfiles:aprobo(Nombre, Curso)),
    retractall(perfiles:cursa(Nombre, Curso)).

%% ---------------------------------------------------------------------------
%% Comparacion de planes
%% ---------------------------------------------------------------------------

comparar_planes(Perfil, Escenario, Comparacion) :-
    planificador:plan_hasta_egreso(Perfil, Base),
    simular(Perfil, Escenario, Alternativo),
    duracion_plan(Base, DuracionBase),
    duracion_plan(Alternativo, DuracionAlternativa),
    Diferencia is DuracionAlternativa - DuracionBase,
    materias_afectadas(Base, Alternativo, Afectadas),
    Comparacion = comparacion(Base, Alternativo,
                              duracion(DuracionBase, DuracionAlternativa),
                              diferencia(Diferencia),
                              materias_afectadas(Afectadas)).

duracion_plan(Plan, Duracion) :-
    findall(_, member(periodo(_, _, _, _), Plan), Periodos),
    length(Periodos, Duracion).

materias_afectadas(Base, Alternativo, Afectadas) :-
    cursos_del_plan(Base, CursosBase),
    cursos_del_plan(Alternativo, CursosAlternativo),
    union(CursosBase, CursosAlternativo, Todos),
    findall(Curso,
            ( member(Curso, Todos),
              (   periodo_de_curso(Base, Curso, PeriodoBase),
                  periodo_de_curso(Alternativo, Curso, PeriodoAlternativo),
                  PeriodoBase \= PeriodoAlternativo
              ;   \+ periodo_de_curso(Base, Curso, _)
              ;   \+ periodo_de_curso(Alternativo, Curso, _)
              )
            ),
            Lista),
    sort(Lista, Afectadas).

cursos_del_plan(Plan, Cursos) :-
    findall(Curso,
            ( member(periodo(_, _, CursosPeriodo, _), Plan),
              member(Curso, CursosPeriodo)
            ),
            Lista),
    sort(Lista, Cursos).

periodo_de_curso(Plan, Curso, Periodo) :-
    once(( member(periodo(Anio, Cuatrimestre, Cursos, _), Plan),
           memberchk(Curso, Cursos)
         )),
    Periodo = Anio-Cuatrimestre.
