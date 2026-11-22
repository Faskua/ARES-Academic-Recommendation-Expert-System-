%% ARES - Pruebas del planificador multsemestre

:- begin_tests(planificador).

%% ---------------------------------------------------------------------------
%% Plan de Ana: el caso nominal
%% ---------------------------------------------------------------------------

test(ana_plan_completo) :-
    planificador:plan_hasta_egreso(ana, Plan),
    Plan == [ periodo(5, 1, [is2, 'IA-01'], 20),
              periodo(5, 2, [compiladores, 'IA-02'], 20),
              anual(5, [trabajo_especial], 0)
            ].

test(plan_cuatrimestre_de_ana) :-
    planificador:plan_cuatrimestre(ana, 5-1, Cursos),
    Cursos == [is2, 'IA-01'].

test(plan_cuatrimestre_inexistente, [fail]) :-
    planificador:plan_cuatrimestre(ana, 9-1, _).

%% ---------------------------------------------------------------------------
%% Todos los perfiles
%% ---------------------------------------------------------------------------

test(planes_no_superan_la_carga) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( planificador:plan_hasta_egreso(Perfil, Plan),
             perfiles:max_creditos(Perfil, Max),
             forall(member(periodo(_, _, _, Creditos), Plan),
                    Creditos =< Max)
           )).

test(planes_incluyen_trabajo_especial) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( planificador:plan_hasta_egreso(Perfil, Plan),
             memberchk(anual(_, [trabajo_especial], 0), Plan)
           )).

test(planes_incluyen_dos_optativas) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( planificador:plan_hasta_egreso(Perfil, Plan),
             optativas_en_plan(Plan, Optativas),
             length(Optativas, Cantidad),
             Cantidad >= 2
           )).

test(planes_completan_obligatorias) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( planificador:plan_hasta_egreso(Perfil, Plan),
             forall(plan:obligatoria(Curso),
                    ( perfiles:aprobo(Perfil, Curso)
                    ; curso_en_plan(Curso, Plan)
                    ))
           )).

test(planes_respetan_prerrequisitos) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( planificador:plan_hasta_egreso(Perfil, Plan),
             findall(Curso, perfiles:aprobo(Perfil, Curso), Aprobadas0),
             sort(Aprobadas0, Aprobadas),
             validar_prerrequisitos(Plan, Aprobadas)
           )).

test(planes_terminan_en_un_tiempo_razonable) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( planificador:plan_hasta_egreso(Perfil, Plan),
             length(Plan, Entradas),
             Entradas =< 16
           )).

%% ---------------------------------------------------------------------------
%% Utilidades
%% ---------------------------------------------------------------------------

optativas_en_plan(Plan, Optativas) :-
    findall(Optativa,
            ( member(periodo(_, _, Cursos, _), Plan),
              member(Optativa, Cursos),
              optativas:es_optativa(Optativa)
            ),
            Optativas).

curso_en_plan(Curso, Plan) :-
    member(periodo(_, _, Cursos, _), Plan),
    memberchk(Curso, Cursos).

validar_prerrequisitos([], _).
validar_prerrequisitos([anual(_, _, _)|Resto], Aprobadas) :-
    validar_prerrequisitos(Resto, Aprobadas).
validar_prerrequisitos([periodo(_, _, Cursos, _)|Resto], Aprobadas) :-
    forall(member(Curso, Cursos), requisitos_ok(Aprobadas, Curso)),
    append(Aprobadas, Cursos, Todas),
    sort(Todas, Aprobadas1),
    validar_prerrequisitos(Resto, Aprobadas1).

requisitos_ok(Aprobadas, Curso) :-
    (   plan:asignatura(Curso, _, _, _, _, _, _, _, _)
    ->  forall(plan:prerrequisito(Curso, Requisito), memberchk(Requisito, Aprobadas))
    ;   optativas:optativa(Curso, _, _, _, _, Requisitos),
        forall(member(Requisito, Requisitos), memberchk(Requisito, Aprobadas))
    ).

:- end_tests(planificador).
