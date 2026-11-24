%% ARES - Pruebas de escenarios what-if

:- begin_tests(what_if).

%% ---------------------------------------------------------------------------
%% Simulacion
%% ---------------------------------------------------------------------------

test(escenario_vacio_igual_al_plan_base) :-
    planificador:plan_hasta_egreso(ana, Base),
    what_if:simular(ana, [], Plan),
    Plan == Base.

test(carla_con_menos_creditos_posterga_md2) :-
    what_if:simular(carla, max_creditos(20), [periodo(3, 1, Cursos, _)|_]),
    Cursos == [aed2].

test(ana_sin_ia_debe_planificar_ia) :-
    what_if:simular(ana, desaprobar(ia), Plan),
    curso_en_plan(ia, Plan).

test(adrian_con_md2_aprobada_no_la_repite) :-
    what_if:simular(adrian, aprobar(md2), Plan),
    \+ curso_en_plan(md2, Plan).

test(escenario_multiple) :-
    what_if:simular(adrian, [max_creditos(20), aprobar(md2)], Plan),
    forall(member(periodo(_, _, _, Creditos), Plan), Creditos =< 20),
    \+ curso_en_plan(md2, Plan).

test(max_creditos_invalido, [fail]) :-
    what_if:simular(ana, max_creditos(0), _).

test(curso_inexistente, [fail]) :-
    what_if:simular(ana, aprobar(curso_inexistente), _).

test(no_modifica_el_perfil_original) :-
    what_if:simular(ana, max_creditos(10), _),
    perfiles:max_creditos(ana, 30),
    findall(Perfil, perfiles:estudiante(Perfil), Perfiles),
    sort(Perfiles, [adrian, ana, carla]).

%% ---------------------------------------------------------------------------
%% Comparacion
%% ---------------------------------------------------------------------------

test(comparacion_con_el_mismo_escenario) :-
    what_if:comparar_planes(ana, [], Comparacion),
    Comparacion = comparacion(_, _, duracion(Base, Alternativa),
                              diferencia(0), materias_afectadas([])),
    Base =:= Alternativa.

test(comparacion_de_carla_con_menos_creditos) :-
    what_if:comparar_planes(carla, max_creditos(20), Comparacion),
    Comparacion = comparacion(Base, Alternativo, duracion(_, _),
                              diferencia(Diferencia), materias_afectadas(Afectadas)),
    Base \== Alternativo,
    Diferencia > 0,
    memberchk(md2, Afectadas).

%% ---------------------------------------------------------------------------
%% Utilidades
%% ---------------------------------------------------------------------------

curso_en_plan(Curso, Plan) :-
    once(( member(periodo(_, _, Cursos, _), Plan),
           memberchk(Curso, Cursos)
         )).

:- end_tests(what_if).
