%% ARES - Alertas y riesgos academicos
%%
%%   alertas(Perfil, Alertas)
%%   cuello_botella(Curso)
%%   fecha_egreso(Perfil, Anio-Cuatrimestre)
%%
%% Las alertas se calculan sobre el plan proyectado por planificador/2.
%% Un cuello de botella es una materia que habilita directamente 3 o mas
%% cursos (obligatorios u optativas).

:- module(riesgo, [
    alertas/2,
    cuello_botella/1,
    fecha_egreso/2
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Cuellos de botella
%% ---------------------------------------------------------------------------

cuello_botella(Curso) :-
    curso_valido(Curso),
    findall(Desbloqueado, grafo:requiere(Desbloqueado, Curso), Directos),
    sort(Directos, Unicos),
    length(Unicos, Cantidad),
    Cantidad >= 3.

curso_valido(Curso) :-
    (   ground(Curso)
    ->  once(grafo:es_curso(Curso))
    ;   grafo:es_curso(Curso)
    ).

%% ---------------------------------------------------------------------------
%% Fecha de egreso
%% ---------------------------------------------------------------------------

fecha_egreso(Perfil, Fecha) :-
    planificador:plan_hasta_egreso(Perfil, Plan),
    (   ultima_fecha(Plan, Fecha)
    ->  true
    ;   perfiles:anio_actual(Perfil, Anio),
        perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
        Fecha = Anio-Cuatrimestre
    ).

ultima_fecha(Plan, Fecha) :-
    findall(Anio-Cuatrimestre,
            member(periodo(Anio, Cuatrimestre, _, _), Plan),
            Fechas),
    Fechas \= [],
    last(Fechas, Fecha).

%% ---------------------------------------------------------------------------
%% Alertas
%% ---------------------------------------------------------------------------

alertas(Perfil, Alertas) :-
    planificador:plan_hasta_egreso(Perfil, Plan),
    findall(Alerta, alerta(Perfil, Plan, Alerta), Alertas0),
    sort(Alertas0, Alertas).

alerta(Perfil, _, cuello_botella(Curso)) :-
    pendiente(Perfil, Curso),
    cuello_botella(Curso).

alerta(Perfil, Plan, materia_critica_sin_aprobar(Curso)) :-
    pendiente(Perfil, Curso),
    cuello_botella(Curso),
    \+ curso_en_primer_periodo(Plan, Curso).

alerta(Perfil, Plan, sobrecarga(Anio-Cuatrimestre, Creditos)) :-
    perfiles:max_creditos(Perfil, Maximo),
    member(periodo(Anio, Cuatrimestre, _, Creditos), Plan),
    Creditos > Maximo.

alerta(Perfil, Plan, riesgo_atraso(Perfil)) :-
    ultima_fecha(Plan, Anio-_),
    duracion_nominal(Nominal),
    Anio > Nominal + 1.

alerta(Perfil, Plan, conflicto_oferta(Curso)) :-
    elegibilidad:elegible(Perfil, Curso),
    \+ curso_en_primer_periodo(Plan, Curso).

pendiente(Perfil, Curso) :-
    curso_valido(Curso),
    \+ perfiles:aprobo(Perfil, Curso),
    \+ perfiles:cursa(Perfil, Curso).

curso_en_primer_periodo(Plan, Curso) :-
    Plan = [periodo(_, _, Cursos, _)|_],
    memberchk(Curso, Cursos).

duracion_nominal(Nominal) :-
    findall(Anio,
            ( plan:obligatoria(Curso),
              plan:anio_nominal(Curso, Anio)
            ),
            Anios),
    max_list(Anios, Nominal).
