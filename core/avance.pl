%% ARES - Avance academico del estudiante
%%
%% Calcula creditos, materias aprobadas y porcentaje de avance.
%% El total del plan incluye la nivelacion, las 25 obligatorias, los
%% 2 cupos de optativas y el Trabajo Especial (0 creditos en la tabla).

:- module(avance, [
    creditos_aprobados/2,
    creditos_totales/1,
    obligatorias_aprobadas/2,
    optativas_aprobadas/2,
    trabajo_especial_aprobado/1,
    items_aprobados/2,
    items_totales/1,
    avance/2
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Creditos
%% ---------------------------------------------------------------------------

creditos_aprobados(Perfil, Total) :-
    findall(Creditos,
            ( plan:asignatura(Curso, _, _, _, Creditos, _, _, _, _),
              perfiles:aprobo(Perfil, Curso)
            ),
            CreditosPlan),
    optativas:creditos_optativa(CreditosOptativa),
    findall(CreditosOptativa,
            ( optativas:es_optativa(Optativa),
              perfiles:aprobo(Perfil, Optativa)
            ),
            CreditosOptativas),
    append(CreditosPlan, CreditosOptativas, Todos),
    sum_list(Todos, Total).

creditos_totales(Total) :-
    findall(Creditos,
            plan:asignatura(_, _, _, _, Creditos, _, _, _, _),
            CreditosPlan),
    optativas:creditos_optativa(CreditosOptativa),
    findall(Cupo, plan:cupo_optativa(_, _, Cupo), Cupos),
    length(Cupos, NumCupos),
    Optativos is NumCupos * CreditosOptativa,
    sum_list(CreditosPlan, TotalPlan),
    Total is TotalPlan + Optativos.

%% ---------------------------------------------------------------------------
%% Materias aprobadas
%% ---------------------------------------------------------------------------

obligatorias_aprobadas(Perfil, N) :-
    findall(Curso,
            ( plan:obligatoria(Curso),
              perfiles:aprobo(Perfil, Curso)
            ),
            Cursos),
    sort(Cursos, Unicos),
    length(Unicos, N).

optativas_aprobadas(Perfil, N) :-
    findall(Optativa,
            ( optativas:es_optativa(Optativa),
              perfiles:aprobo(Perfil, Optativa)
            ),
            Optativas),
    sort(Optativas, Unicas),
    length(Unicas, N).

trabajo_especial_aprobado(Perfil) :-
    perfiles:aprobo(Perfil, trabajo_especial).

%% items_aprobados/2: 25 obligatorias + 2 optativas + 1 Trabajo Especial.
items_aprobados(Perfil, N) :-
    obligatorias_aprobadas(Perfil, NObligatorias),
    optativas_aprobadas(Perfil, NOptativas),
    (   trabajo_especial_aprobado(Perfil)
    ->  NTE = 1
    ;   NTE = 0
    ),
    N is NObligatorias + NOptativas + NTE.

items_totales(28).

%% ---------------------------------------------------------------------------
%% Porcentaje de avance (por creditos)
%% ---------------------------------------------------------------------------

avance(Perfil, Porcentaje) :-
    creditos_aprobados(Perfil, Aprobados),
    creditos_totales(Total),
    Total > 0,
    Porcentaje is (Aprobados / Total) * 100.
