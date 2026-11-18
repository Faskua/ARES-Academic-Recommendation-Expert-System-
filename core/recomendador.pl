%% ARES - Recomendador de materias
%%
%% Ordena las materias elegibles por puntaje y arma una seleccion que no
%% supere la carga maxima del perfil.
%%
%%   recomendar(Perfil, Seleccion, Creditos)
%%   recomendar(Perfil, Candidatos, Seleccion, Creditos)
%%   seleccionar_hasta(Perfil, Candidatos, Seleccion)
%%
%% La seleccion es greedy: en cada paso se vuelve a puntuar cada candidato
%% con los creditos ya comprometidos, de modo que entren en juego el tope
%% de carga y el bonus por materias livianas.

:- module(recomendador, [
    recomendar/3,
    recomendar/4,
    seleccionar_hasta/3,
    candidatos_puntuados/2
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Candidatos ordenados
%% ---------------------------------------------------------------------------

candidatos_puntuados(Perfil, Puntuados) :-
    findall(Puntaje-Curso,
            ( elegibilidad:elegible(Perfil, Curso),
              puntuacion:puntaje(Perfil, Curso, Puntaje)
            ),
            Pares),
    sort(0, @>=, Pares, Puntuados).

%% ---------------------------------------------------------------------------
%% Recomendacion
%% ---------------------------------------------------------------------------

recomendar(Perfil, Seleccion, Creditos) :-
    findall(Curso, elegibilidad:elegible(Perfil, Curso), Candidatos),
    recomendar(Perfil, Candidatos, Seleccion, Creditos).

recomendar(Perfil, Candidatos, Seleccion, Creditos) :-
    seleccionar_hasta(Perfil, Candidatos, Seleccion),
    creditos_seleccion(Seleccion, Creditos).

%% seleccionar_hasta/3: elige materias mientras entren en la carga maxima.
seleccionar_hasta(Perfil, Candidatos, Seleccion) :-
    sort(Candidatos, Unicos),
    perfiles:max_creditos(Perfil, Max),
    seleccionar(Perfil, Unicos, 0, Max, Seleccion).

seleccionar(Perfil, Candidatos, Usados, Max, Seleccion) :-
    findall(Puntaje-Curso,
            ( member(Curso, Candidatos),
              puntuacion:creditos_de(Curso, Creditos),
              Creditos > 0,
              Usados + Creditos =< Max,
              puntuacion:puntaje(Perfil, Curso, Usados, Puntaje)
            ),
            Puntuados),
    sort(0, @>=, Puntuados, Ordenados),
    (   Ordenados = [_-Mejor|_]
    ->  puntuacion:creditos_de(Mejor, Creditos),
        Usados1 is Usados + Creditos,
        selectchk(Mejor, Candidatos, Restantes),
        Seleccion = [Mejor|Cola],
        seleccionar(Perfil, Restantes, Usados1, Max, Cola)
    ;   Seleccion = []
    ).

%% ---------------------------------------------------------------------------
%% Creditos de una seleccion
%% ---------------------------------------------------------------------------

creditos_seleccion([], 0).
creditos_seleccion([Curso|Cursos], Total) :-
    puntuacion:creditos_de(Curso, Creditos),
    creditos_seleccion(Cursos, Resto),
    Total is Creditos + Resto.
