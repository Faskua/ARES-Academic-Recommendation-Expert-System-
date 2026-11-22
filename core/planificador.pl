%% ARES - Planificador multsemestre
%%
%% Proyecta el avance de un perfil hasta el egreso. El estado simulado
%% guarda anio, cuatrimestre, materias aprobadas, materias en curso,
%% cantidad de optativas y situacion del Trabajo Especial:
%%
%%   estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, Te)
%%
%%   plan_hasta_egreso(Perfil, Plan)
%%   plan_cuatrimestre(Perfil, Anio-Cuatrimestre, Cursos)
%%
%% El plan es una lista de periodos:
%%
%%   periodo(5, 1, [is2, 'IA-01'], 20)
%%
%% y, si corresponde, termina con:
%%
%%   anual(5, [trabajo_especial], 0)
%%
%% En cada cuatrimestre se priorizan las obligatorias por puntaje y se
%% completa la carga con una optativa como maximo. Si una eleccion no
%% permite cerrar el plan, Prolog retrocede y prueba otra optativa.

:- module(planificador, [
    plan_hasta_egreso/2,
    plan_cuatrimestre/3
]).

:- use_module(library(lists)).

max_periodos(24).

%% ---------------------------------------------------------------------------
%% Estado inicial
%% ---------------------------------------------------------------------------

estado_inicial(Perfil, estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, Te)) :-
    perfiles:anio_actual(Perfil, Anio),
    perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
    findall(Curso, perfiles:aprobo(Perfil, Curso), Aprobadas0),
    sort(Aprobadas0, Aprobadas),
    findall(Curso, perfiles:cursa(Perfil, Curso), Cursando0),
    sort(Cursando0, Cursando),
    contar_optativas(Aprobadas, Optativas),
    (   perfiles:aprobo(Perfil, trabajo_especial)
    ->  Te = aprobado
    ;   Te = no
    ).

%% ---------------------------------------------------------------------------
%% API
%% ---------------------------------------------------------------------------

plan_hasta_egreso(Perfil, Plan) :-
    estado_inicial(Perfil, Estado),
    max_periodos(Limite),
    once(planificar(Perfil, Estado, Limite, Periodos, EstadoFinal)),
    agregar_trabajo_especial(EstadoFinal, Periodos, Plan).

plan_cuatrimestre(Perfil, Anio-Cuatrimestre, Cursos) :-
    plan_hasta_egreso(Perfil, Plan),
    once(member(periodo(Anio, Cuatrimestre, Cursos, _), Plan)).

agregar_trabajo_especial(estado(_, _, _, _, _, anual(Anio)), Periodos, Plan) :-
    !,
    append(Periodos, [anual(Anio, [trabajo_especial], 0)], Plan).
agregar_trabajo_especial(_, Periodos, Periodos).

%% ---------------------------------------------------------------------------
%% Bucle de planificacion
%% ---------------------------------------------------------------------------

planificar(Perfil, Estado0, Limite, Plan, EstadoFinal) :-
    preparar_trabajo_especial(Estado0, Estado),
    (   egresado(Estado)
    ->  Plan = [],
        EstadoFinal = Estado
    ;   Limite > 0,
        Limite1 is Limite - 1,
        Estado = estado(Anio, Cuatrimestre, _, _, _, _),
        seleccionar_carga(Perfil, Estado, Seleccion, Creditos),
        avanzar_estado(Estado, Seleccion, Estado1),
        planificar(Perfil, Estado1, Limite1, Resto, EstadoFinal),
        (   Seleccion == []
        ->  Plan = Resto
        ;   Plan = [periodo(Anio, Cuatrimestre, Seleccion, Creditos)|Resto]
        )
    ).

preparar_trabajo_especial(estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, no),
                          Estado1) :-
    !,
    (   puede_trabajo_especial(Anio, Aprobadas)
    ->  Estado1 = estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, anual(Anio))
    ;   Estado1 = estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, no)
    ).
preparar_trabajo_especial(Estado, Estado).

puede_trabajo_especial(Anio, Aprobadas) :-
    Anio >= 5,
    findall(Curso, (plan:obligatoria(Curso), memberchk(Curso, Aprobadas)), Cursos),
    length(Cursos, AprobadasObligatorias),
    plan:requisito_trabajo_especial(Minimas),
    AprobadasObligatorias >= Minimas.

egresado(estado(_, _, Aprobadas, _, Optativas, Te)) :-
    sin_obligatorias_pendientes(Aprobadas),
    Optativas >= 2,
    Te \= no.

sin_obligatorias_pendientes(Aprobadas) :-
    forall(plan:obligatoria(Curso), memberchk(Curso, Aprobadas)).

avanzar_estado(estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, Te),
               Seleccion,
               estado(Anio1, Cuatrimestre1, Aprobadas1, [], Optativas1, Te)) :-
    append(Cursando, Seleccion, Nuevas),
    append(Aprobadas, Nuevas, Todas),
    sort(Todas, Aprobadas1),
    contar_optativas(Nuevas, NuevasOptativas),
    Optativas1 is Optativas + NuevasOptativas,
    siguiente_cuatrimestre(Anio, Cuatrimestre, Anio1, Cuatrimestre1).

siguiente_cuatrimestre(Anio, 1, Anio, 2).
siguiente_cuatrimestre(Anio, 2, Anio1, 1) :-
    Anio1 is Anio + 1.

contar_optativas(Cursos, Total) :-
    findall(Optativa,
            ( member(Optativa, Cursos),
              optativas:es_optativa(Optativa)
            ),
            Optativas),
    length(Optativas, Total).

%% ---------------------------------------------------------------------------
%% Carga del cuatrimestre
%% ---------------------------------------------------------------------------

seleccionar_carga(Perfil, Estado, Seleccion, Creditos) :-
    Estado = estado(_, _, _, Cursando, Optativas, _),
    creditos_lista(Cursando, CreditosCursando),
    perfiles:max_creditos(Perfil, Max),
    Disponible is Max - CreditosCursando,
    Disponible >= 0,
    candidatos_obligatorias(Estado, Candidatos),
    seleccionar_hasta_estado(Perfil, Estado, Candidatos, 0, Disponible, Obligatorias),
    creditos_lista(Obligatorias, CreditosObligatorias),
    Restante is Disponible - CreditosObligatorias,
    (   Optativas < 2,
        optativa_candidata(Perfil, Estado, Restante, Optativa),
        append(Obligatorias, [Optativa], Seleccion)
    ;   Seleccion = Obligatorias
    ),
    creditos_lista(Seleccion, Creditos).

candidatos_obligatorias(Estado, Candidatos) :-
    findall(Curso, elegible_obligatoria(Estado, Curso), Candidatos).

elegible_obligatoria(estado(Anio, Cuatrimestre, Aprobadas, Cursando, _, _), Curso) :-
    plan:obligatoria(Curso),
    plan:anio_nominal(Curso, AnioNominal),
    AnioNominal =< Anio,
    plan:cuatrimestre_nominal(Curso, Cuatrimestre),
    \+ memberchk(Curso, Aprobadas),
    \+ memberchk(Curso, Cursando),
    prerrequisitos_ok(Aprobadas, Curso).

prerrequisitos_ok(Aprobadas, Curso) :-
    forall(plan:prerrequisito(Curso, Requisito), memberchk(Requisito, Aprobadas)).

elegible_optativa(estado(Anio, Cuatrimestre, Aprobadas, Cursando, _, _), Optativa) :-
    optativas:optativa(Optativa, _, _, _, Oferta, Requisitos),
    oferta_del_cuatrimestre(Cuatrimestre, Oferta),
    Anio >= 4,
    \+ memberchk(Optativa, Aprobadas),
    \+ memberchk(Optativa, Cursando),
    forall(member(Requisito, Requisitos), memberchk(Requisito, Aprobadas)).

oferta_del_cuatrimestre(1, i).
oferta_del_cuatrimestre(2, ii).

seleccionar_hasta_estado(Perfil, Estado, Candidatos, Usados, Max, Seleccion) :-
    findall(Puntaje-Curso,
            ( member(Curso, Candidatos),
              puntuacion:creditos_de(Curso, Creditos),
              Creditos > 0,
              Usados + Creditos =< Max,
              puntaje_estado(Perfil, Estado, Curso, Usados, Puntaje)
            ),
            Puntuados),
    sort(0, @>=, Puntuados, Ordenados),
    (   Ordenados = [_-Mejor|_]
    ->  puntuacion:creditos_de(Mejor, Creditos),
        Usados1 is Usados + Creditos,
        selectchk(Mejor, Candidatos, Restantes),
        Seleccion = [Mejor|Cola],
        seleccionar_hasta_estado(Perfil, Estado, Restantes, Usados1, Max, Cola)
    ;   Seleccion = []
    ).

%% La eleccion de optativa deja un punto de retroceso: si el plan no
%% cierra, se prueba la siguiente mejor.
optativa_candidata(Perfil, Estado, Disponible, Optativa) :-
    findall(Puntaje-Optativa,
            ( elegible_optativa(Estado, Optativa),
              puntuacion:creditos_de(Optativa, Creditos),
              Creditos =< Disponible,
              puntaje_optativa(Perfil, Estado, Optativa, Puntaje)
            ),
            Puntuados),
    sort(0, @>=, Puntuados, Ordenados),
    member(_-Optativa, Ordenados).

puntaje_optativa(Perfil, Estado, Optativa, Puntos) :-
    selector_optativas:puntaje_optativa(Perfil, Optativa, Base),
    bonus_optativa(Estado, Optativa, Bonus),
    Puntos is Base + Bonus.

bonus_optativa(Estado, Optativa, 10) :-
    Estado = estado(_, _, Aprobadas, _, _, _),
    optativas:cadena(Previa, Optativa),
    optativas:es_optativa(Previa),
    memberchk(Previa, Aprobadas),
    !.
bonus_optativa(Estado, Optativa, 5) :-
    optativas:cadena(Optativa, Posterior),
    Estado = estado(_, _, Aprobadas, _, _, _),
    \+ memberchk(Posterior, Aprobadas),
    !.
bonus_optativa(_, _, 0).

creditos_lista(Cursos, Total) :-
    findall(Creditos,
            ( member(Curso, Cursos),
              puntuacion:creditos_de(Curso, Creditos)
            ),
            CreditosLista),
    sum_list(CreditosLista, Total).

%% ---------------------------------------------------------------------------
%% Puntaje sobre el estado simulado
%% ---------------------------------------------------------------------------

puntaje_estado(Perfil, Estado, Curso, Acumulados, Puntos) :-
    findall(Puntaje, regla_estado(Perfil, Estado, Curso, Acumulados, Puntaje), PuntosLista),
    sum_list(PuntosLista, Puntos).

regla_estado(_, estado(_, _, Aprobadas, Cursando, _, _), Curso, _, Puntos) :-
    desbloquea_pendiente(Curso, Aprobadas, Cursando, Desbloqueados),
    length(Desbloqueados, N),
    N > 0,
    (   N >= 3
    ->  Puntos = 40
    ;   Puntos = 25
    ).

regla_estado(_, estado(Anio, Cuatrimestre, _, _, _, _), Curso, _, 20) :-
    plan:anio_nominal(Curso, AnioNominal),
    AnioNominal =< Anio,
    plan:cuatrimestre_nominal(Curso, Cuatrimestre).

regla_estado(_, estado(Anio, _, _, _, _, _), Curso, _, 15) :-
    findall(Futuro,
            ( plan:prerrequisito(Futuro, Curso),
              plan:anio_nominal(Futuro, AnioFuturo),
              AnioFuturo > Anio
            ),
            [Futuro|_]).

regla_estado(Perfil, _, Curso, _, 10) :-
    plan:area(Curso, Area),
    perfiles:interes(Perfil, Area).

regla_estado(Perfil, _, Curso, Acumulados, 10) :-
    plan:dificultad(Curso, Dificultad),
    Dificultad =< 2,
    puntuacion:carga_exigente(Perfil, Acumulados).

regla_estado(Perfil, _, Curso, _, -15) :-
    plan:dificultad(Curso, Dificultad),
    Dificultad >= 4,
    perfiles:promedio(Perfil, Promedio),
    Promedio < 7.

regla_estado(Perfil, _, Curso, Acumulados, -20) :-
    puntuacion:creditos_de(Curso, Creditos),
    perfiles:max_creditos(Perfil, Max),
    Acumulados + Creditos > Max.

regla_estado(Perfil, estado(_, _, Aprobadas, _, _, _), Curso, _, 30) :-
    perfiles:recursa(Perfil, Curso),
    \+ memberchk(Curso, Aprobadas).

desbloquea_pendiente(Curso, Aprobadas, Cursando, Desbloqueados) :-
    findall(Desbloqueado,
            ( grafo:desbloquea(Curso, Desbloqueado),
              \+ memberchk(Desbloqueado, Aprobadas),
              \+ memberchk(Desbloqueado, Cursando)
            ),
            Lista),
    sort(Lista, Desbloqueados).
