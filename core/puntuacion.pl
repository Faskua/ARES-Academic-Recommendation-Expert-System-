%% ARES - Puntuacion de materias
%%
%% Asigna a cada materia candidata un puntaje segun las reglas del
%% Roadmap, seccion 8.2:
%%
%%   +40  desbloquea 3 o mas materias pendientes
%%   +25  desbloquea 1 o 2 materias pendientes
%%   +20  esta en el ano/cuatrimestre nominal del perfil
%%   +15  es prerrequisito directo de una materia de un ano posterior
%%   +10  coincide con los intereses del perfil
%%   +10  materia liviana cuando la carga ya es exigente
%%   -15  dificultad alta con promedio bajo
%%   -20  la materia excede la carga maxima del perfil
%%   +30  es una materia que el perfil recursa
%%
%% puntaje/4 permite indicar cuantos creditos ya se eligieron, para que
%% el recomendador pueda aplicar el tope y el balance de carga.

:- module(puntuacion, [
    puntaje/3,
    puntaje/4,
    detalle/3,
    detalle/4,
    regla/5,
    creditos_de/2,
    carga_actual/2,
    carga_exigente/2
]).

:- use_module(library(lists)).

%% 75 % de la carga maxima: a partir de ahi conviene balancear.
umbral_carga(Max, Umbral) :-
    Umbral is (Max * 3) // 4.

%% ---------------------------------------------------------------------------
%% Creditos y carga
%% ---------------------------------------------------------------------------

%% Creditos de una materia del plan o de una optativa del catalogo.
creditos_de(Curso, Creditos) :-
    (   plan:creditos(Curso, Creditos)
    ->  true
    ;   optativas:es_optativa(Curso),
        optativas:creditos_optativa(Creditos)
    ).

%% Creditos de las materias que el perfil cursa actualmente.
carga_actual(Perfil, Total) :-
    findall(Creditos,
            ( perfiles:cursa(Perfil, Curso),
              creditos_de(Curso, Creditos)
            ),
            Lista),
    sum_list(Lista, Total).

carga_exigente(Perfil, Acumulados) :-
    perfiles:max_creditos(Perfil, Max),
    umbral_carga(Max, Umbral),
    Acumulados >= Umbral.

%% ---------------------------------------------------------------------------
%% Reglas de puntuacion
%% ---------------------------------------------------------------------------
%%
%% regla(Perfil, Curso, CreditosAcumulados, Puntos, Razon)
%%
%% Cada materia produce como maximo una razon por regla, asi el puntaje
%% es la suma de los puntos de sus razones.

%% +40 / +25: desbloqueo de materias pendientes.
regla(Perfil, Curso, _, Puntos, desbloquea(N, Cursos)) :-
    desbloqueados_pendientes(Perfil, Curso, Cursos),
    length(Cursos, N),
    N > 0,
    (   N >= 3
    ->  Puntos = 40
    ;   Puntos = 25
    ).

%% +20: la materia pertenece al ano y cuatrimestre que cursa el perfil.
regla(Perfil, Curso, _, 20, materia_nominal(Anio, Cuatrimestre)) :-
    perfiles:anio_actual(Perfil, AnioActual),
    plan:anio_nominal(Curso, Anio),
    Anio =< AnioActual,
    perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
    plan:cuatrimestre_nominal(Curso, Cuatrimestre).

%% +15: habilita directamente una materia de un ano posterior.
regla(Perfil, Curso, _, 15, requisito_de(Futuro)) :-
    perfiles:anio_actual(Perfil, AnioActual),
    %% Una sola razon aunque haya varias materias futuras.
    findall(Candidato,
            ( plan:prerrequisito(Candidato, Curso),
              plan:anio_nominal(Candidato, AnioCandidato),
              AnioCandidato > AnioActual
            ),
            [Futuro|_]).

%% +10: afinidad con los intereses declarados.
regla(Perfil, Curso, _, 10, afinidad(Area)) :-
    plan:area(Curso, Area),
    perfiles:interes(Perfil, Area).

%% +10: materia liviana cuando la carga acumulada ya es exigente.
regla(Perfil, Curso, Acumulados, 10, carga_equilibrada) :-
    plan:dificultad(Curso, Dificultad),
    Dificultad =< 2,
    carga_exigente(Perfil, Acumulados).

%% -15: dificultad alta para un promedio bajo.
regla(Perfil, Curso, _, -15, riesgo_dificultad(Dificultad, Promedio)) :-
    plan:dificultad(Curso, Dificultad),
    Dificultad >= 4,
    perfiles:promedio(Perfil, Promedio),
    Promedio < 7.

%% -20: sumar la materia supera la carga maxima.
regla(Perfil, Curso, Acumulados, -20, excede_carga(Max)) :-
    creditos_de(Curso, Creditos),
    perfiles:max_creditos(Perfil, Max),
    Acumulados + Creditos > Max.

%% +30: materia que el perfil esta recursando.
regla(Perfil, Curso, _, 30, recursada(Curso)) :-
    perfiles:recursa(Perfil, Curso).

%% ---------------------------------------------------------------------------
%% Desbloqueo pendiente
%% ---------------------------------------------------------------------------

desbloqueados_pendientes(Perfil, Curso, Cursos) :-
    findall(Desbloqueado,
            ( grafo:desbloquea(Curso, Desbloqueado),
              \+ perfiles:aprobo(Perfil, Desbloqueado),
              \+ perfiles:cursa(Perfil, Desbloqueado)
            ),
            Lista),
    sort(Lista, Cursos).

%% ---------------------------------------------------------------------------
%% API
%% ---------------------------------------------------------------------------

%% Puntaje con la carga actual del perfil (materias en curso).
puntaje(Perfil, Curso, Puntos) :-
    carga_actual(Perfil, Acumulados),
    puntaje(Perfil, Curso, Acumulados, Puntos).

%% Puntaje con una cantidad de creditos ya comprometidos.
puntaje(Perfil, Curso, Acumulados, Puntos) :-
    detalle(Perfil, Curso, Acumulados, Detalle),
    findall(P, member(P-_, Detalle), SoloPuntos),
    sum_list(SoloPuntos, Puntos).

detalle(Perfil, Curso, Detalle) :-
    carga_actual(Perfil, Acumulados),
    detalle(Perfil, Curso, Acumulados, Detalle).

detalle(Perfil, Curso, Acumulados, Detalle) :-
    findall(Puntos-Razon,
            regla(Perfil, Curso, Acumulados, Puntos, Razon),
            Detalle).
