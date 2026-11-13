%% ARES - Pruebas de elegibilidad

:- begin_tests(elegibilidad).

test(ana_obligatorias_elegibles) :-
    findall(Curso, elegibilidad:elegible(ana, Curso), Cursos),
    Cursos == [is2].

test(beto_elegibles) :-
    findall(Curso, elegibilidad:elegible(beto, Curso), Cursos),
    Cursos == [aed2, md2].

test(carla_elegibles) :-
    findall(Curso, elegibilidad:elegible(carla, Curso), Cursos),
    Cursos == [aed2, md2].

test(ana_optativas_elegibles) :-
    findall(Optativa, elegibilidad:elegible_optativa(ana, Optativa), Optativas),
    sort(Optativas, Ordenadas),
    Ordenadas == ['IA-01', 'IA-03', 'INV-01', 'INV-03',
                  'SIS-01', 'SW-01', 'SW-03', 'TEO-01'].

test(ana_optativa_ia01_en_primer_cuatrimestre) :-
    once(elegibilidad:elegible_optativa(ana, 'IA-01', i)).

test(ana_optativa_ia01_no_en_segundo_cuatrimestre, [fail]) :-
    elegibilidad:elegible_optativa(ana, 'IA-01', ii).

test(ana_no_puede_ia02, [fail]) :-
    elegibilidad:elegible_optativa(ana, 'IA-02').

test(beto_sin_optativas) :-
    findall(Optativa, elegibilidad:elegible_optativa(beto, Optativa), Optativas),
    Optativas == [].

test(ana_puede_trabajo_especial) :-
    elegibilidad:puede_trabajo_especial(ana).

test(beto_no_puede_trabajo_especial, [fail]) :-
    elegibilidad:puede_trabajo_especial(beto).

test(carla_no_puede_trabajo_especial, [fail]) :-
    elegibilidad:puede_trabajo_especial(carla).

test(no_elegible_ya_aprobada, [fail]) :-
    elegibilidad:elegible(beto, aed1).

test(no_elegible_por_prerequisito, [fail]) :-
    elegibilidad:elegible(beto, paradigmas).

test(no_elegible_por_oferta, [fail]) :-
    elegibilidad:elegible(carla, prob).

:- end_tests(elegibilidad).
