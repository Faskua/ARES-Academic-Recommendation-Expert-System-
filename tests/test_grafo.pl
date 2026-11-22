%% ARES - Pruebas del grafo de correlatividades

:- begin_tests(grafo).

test(plan_valido) :-
    grafo:validar_plan.

test(plan_sin_errores) :-
    grafo:validar_plan(Errores),
    Errores == [].

test(total_de_cursos) :-
    grafo:todos_los_cursos(Cursos),
    length(Cursos, 42).

test(todos_los_cursos_incluye_plan_y_optativas) :-
    grafo:todos_los_cursos(Cursos),
    memberchk(aed2, Cursos),
    memberchk('IA-01', Cursos),
    memberchk(trabajo_especial, Cursos).

test(compiladores_requiere_aed1) :-
    once(grafo:prerrequisito_transitivo(compiladores, aed1)).

test(lfc_requiere_md1) :-
    once(grafo:prerrequisito_transitivo(lfc, md1)).

test(aed1_no_se_requiere_a_si_mismo) :-
    \+ grafo:prerrequisito_transitivo(aed1, aed1).

test(aed2_desbloquea_cadena) :-
    forall(member(Curso, [so, paradigmas, bd, ia, redes, is1, is2, compiladores]),
           grafo:desbloquea(aed2, Curso)).

test(aed2_desbloquea_optativa) :-
    once(grafo:desbloquea(aed2, 'IA-01')).

test(desbloqueo_de_adrian) :-
    grafo:desbloquea(adrian, aed2, N),
    N =:= 20.

test(sin_ciclos, [fail]) :-
    grafo:ciclo(_).

:- end_tests(grafo).
