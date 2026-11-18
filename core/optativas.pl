%% ARES - Seleccion de optativas
%%
%% El catalogo vive en kb/optativas.pl (modulo optativas). Este modulo
%% decide que par de optativas conviene cursar, segun las reglas del
%% Roadmap, seccion 8.3:
%%
%%   +15 por optativa afin a los intereses del perfil
%%   -10 por optativa de dificultad alta con promedio bajo
%%   +10 si ambas comparten area y el objetivo es especializarse
%%   +10 si las areas son distintas y el objetivo es equilibrar
%%   +10 si una es prerrequisito de la otra (cadena)
%%   -15 si la dificultad total es alta y el promedio es bajo
%%
%% Solo se consideran optativas elegibles: oferta del cuatrimestre actual
%% y prerrequisitos aprobados.

:- module(selector_optativas, [
    puntaje_optativa/3,
    puntaje_par/4,
    recomendar_par/2,
    optativas_elegibles/2
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Candidatas
%% ---------------------------------------------------------------------------

optativas_elegibles(Perfil, Optativas) :-
    findall(Optativa, elegibilidad:elegible_optativa(Perfil, Optativa), Lista),
    sort(Lista, Optativas).

%% ---------------------------------------------------------------------------
%% Puntaje individual
%% ---------------------------------------------------------------------------

puntaje_optativa(Perfil, Optativa, Puntos) :-
    findall(P, regla_optativa(Perfil, Optativa, P), Lista),
    sum_list(Lista, Puntos).

regla_optativa(Perfil, Optativa, 15) :-
    optativas:area_optativa(Optativa, Area),
    perfiles:interes(Perfil, Area).

regla_optativa(Perfil, Optativa, -10) :-
    optativas:dificultad_optativa(Optativa, Dificultad),
    Dificultad >= 4,
    perfiles:promedio(Perfil, Promedio),
    Promedio < 7.

%% ---------------------------------------------------------------------------
%% Puntaje del par
%% ---------------------------------------------------------------------------

puntaje_par(Perfil, O1, O2, Puntos) :-
    puntaje_optativa(Perfil, O1, P1),
    puntaje_optativa(Perfil, O2, P2),
    bonus_composicion(Perfil, O1, O2, B1),
    bonus_cadena(O1, O2, B2),
    penalizacion_dificultad(Perfil, O1, O2, B3),
    Puntos is P1 + P2 + B1 + B2 + B3.

%% Misma area si el objetivo es especializarse; areas distintas si es equilibrar.
bonus_composicion(Perfil, O1, O2, Bonus) :-
    optativas:area_optativa(O1, A1),
    optativas:area_optativa(O2, A2),
    perfiles:objetivo(Perfil, Objetivo),
    (   (   Objetivo == especializarse, A1 == A2
        ;   Objetivo == equilibrar, A1 \== A2
        )
    ->  Bonus = 10
    ;   Bonus = 0
    ).

%% Una cadena es un par donde una optativa habilita a la otra.
bonus_cadena(O1, O2, Bonus) :-
    (   (   optativas:prerrequisito_optativa(O2, O1)
        ;   optativas:prerrequisito_optativa(O1, O2)
        )
    ->  Bonus = 10
    ;   Bonus = 0
    ).

penalizacion_dificultad(Perfil, O1, O2, Penalizacion) :-
    optativas:dificultad_optativa(O1, D1),
    optativas:dificultad_optativa(O2, D2),
    perfiles:promedio(Perfil, Promedio),
    (   D1 + D2 >= 9, Promedio < 7
    ->  Penalizacion = -15
    ;   Penalizacion = 0
    ).

%% ---------------------------------------------------------------------------
%% Mejor par
%% ---------------------------------------------------------------------------

recomendar_par(Perfil, Par) :-
    optativas_elegibles(Perfil, Optativas),
    findall(Puntos-[O1, O2],
            ( par_candidato(Optativas, [O1, O2]),
              puntaje_par(Perfil, O1, O2, Puntos)
            ),
            Pares),
    sort(0, @>=, Pares, [_-Par|_]).

%% Pares sin repetir y en orden canonico, para no duplicar [A,B] y [B,A].
par_candidato(Optativas, [O1, O2]) :-
    select(O1, Optativas, Resto),
    member(O2, Resto),
    O1 @< O2.
