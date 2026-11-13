%% ARES - Elegibilidad de materias
%%
%% Determina que puede cursar un perfil en su cuatrimestre actual:
%%   - obligatorias del plan (año <= actual, oferta del cuatrimestre,
%%     prerrequisitos aprobados, no aprobada y no en curso);
%%   - optativas (desde 4.o año, oferta i/ii y prerrequisitos aprobados);
%%   - Trabajo Especial (5.o año y 20 obligatorias aprobadas).

:- module(elegibilidad, [
    elegible/2,
    elegible_optativa/2,
    elegible_optativa/3,
    prerequisitos_ok/2,
    puede_trabajo_especial/1
]).

%% ---------------------------------------------------------------------------
%% Obligatorias
%% ---------------------------------------------------------------------------

elegible(Perfil, Curso) :-
    plan:obligatoria(Curso),
    plan:anio_nominal(Curso, AnioCurso),
    perfiles:anio_actual(Perfil, AnioActual),
    AnioCurso =< AnioActual,
    plan:cuatrimestre_nominal(Curso, Cuatrimestre),
    perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
    \+ perfiles:aprobo(Perfil, Curso),
    \+ perfiles:cursa(Perfil, Curso),
    prerequisitos_plan_ok(Perfil, Curso).

prerequisitos_plan_ok(Perfil, Curso) :-
    forall(plan:prerrequisito(Curso, Requisito),
           perfiles:aprobo(Perfil, Requisito)).

%% ---------------------------------------------------------------------------
%% Optativas
%% ---------------------------------------------------------------------------

elegible_optativa(Perfil, Optativa) :-
    elegible_optativa(Perfil, Optativa, _).

elegible_optativa(Perfil, Optativa, Oferta) :-
    optativas:optativa(Optativa, _, _, _, Oferta, Requisitos),
    oferta_actual(Perfil, Oferta),
    perfiles:anio_actual(Perfil, Anio),
    Anio >= 4,
    \+ perfiles:aprobo(Perfil, Optativa),
    \+ perfiles:cursa(Perfil, Optativa),
    prerequisitos_ok(Perfil, Requisitos).

oferta_actual(Perfil, i) :-
    perfiles:cuatrimestre_actual(Perfil, 1).
oferta_actual(Perfil, ii) :-
    perfiles:cuatrimestre_actual(Perfil, 2).

%% ---------------------------------------------------------------------------
%% Requisitos en general
%% ---------------------------------------------------------------------------

prerequisitos_ok(Perfil, Requisitos) :-
    forall(member(Requisito, Requisitos),
           perfiles:aprobo(Perfil, Requisito)).

%% ---------------------------------------------------------------------------
%% Trabajo Especial
%% ---------------------------------------------------------------------------

puede_trabajo_especial(Perfil) :-
    perfiles:anio_actual(Perfil, Anio),
    Anio >= 5,
    avance:obligatorias_aprobadas(Perfil, Aprobadas),
    plan:requisito_trabajo_especial(Minimas),
    Aprobadas >= Minimas.
