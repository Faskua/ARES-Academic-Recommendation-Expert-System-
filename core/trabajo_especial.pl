%% ARES - Area sugerida para el Trabajo Especial
%%
%% El Trabajo Especial no tiene un area fija: se deriva de las optativas
%% que el perfil ya aprobo o, si todavia no curso ninguna, del par que el
%% recomendador sugiere. El area con mas peso se refuerza si coincide con
%% los intereses declarados (Roadmap, seccion 8.4).
%%
%%   area_trabajo_especial(ana, Area).
%%
%% Solo aplica a perfiles habilitados para iniciar el Trabajo Especial
%% (5.o ano y 20 obligatorias aprobadas).

:- module(trabajo_especial, [
    area_trabajo_especial/2,
    optativas_elegidas/2
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Optativas de referencia
%% ---------------------------------------------------------------------------

%% Si ya hay dos optativas aprobadas se usan esas; si no, el par sugerido.
optativas_elegidas(Perfil, Optativas) :-
    findall(Optativa,
            ( optativas:es_optativa(Optativa),
              perfiles:aprobo(Perfil, Optativa)
            ),
            Aprobadas),
    (   length(Aprobadas, N),
        N >= 2
    ->  Optativas = Aprobadas
    ;   selector_optativas:recomendar_par(Perfil, Optativas)
    ).

%% ---------------------------------------------------------------------------
%% Area
%% ---------------------------------------------------------------------------

area_trabajo_especial(Perfil, Area) :-
    elegibilidad:puede_trabajo_especial(Perfil),
    optativas_elegidas(Perfil, Optativas),
    length(Optativas, N),
    N >= 2,
    findall(A, (member(O, Optativas), optativas:area_optativa(O, A)), Areas),
    area_mas_afin(Perfil, Areas, Area).

%% Cada area suma 10 por aparicion y 1 extra si esta entre los intereses.
area_mas_afin(Perfil, Areas, Area) :-
    sort(Areas, Unicas),
    findall(Puntaje-Candidata,
            ( member(Candidata, Unicas),
              cuenta_area(Areas, Candidata, Cuenta),
              afinidad(Perfil, Candidata, Extra),
              Puntaje is Cuenta * 10 + Extra
            ),
            Puntuados),
    sort(0, @>=, Puntuados, [_-Area|_]).

cuenta_area(Areas, Area, Cuenta) :-
    findall(A, (member(A, Areas), A == Area), Iguales),
    length(Iguales, Cuenta).

afinidad(Perfil, Area, Extra) :-
    (   perfiles:interes(Perfil, Area)
    ->  Extra = 1
    ;   Extra = 0
    ).
