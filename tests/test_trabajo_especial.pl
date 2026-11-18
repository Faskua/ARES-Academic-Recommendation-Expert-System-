%% ARES - Pruebas del area de Trabajo Especial

:- begin_tests(trabajo_especial).

test(area_de_ana) :-
    trabajo_especial:area_trabajo_especial(ana, Area),
    Area == ia.

test(area_coincide_con_el_par_recomendado) :-
    trabajo_especial:area_trabajo_especial(ana, Area),
    selector_optativas:recomendar_par(ana, [O1, O2]),
    forall(member(O, [O1, O2]), optativas:area_optativa(O, Area)).

test(optativas_de_referencia_de_ana) :-
    trabajo_especial:optativas_elegidas(ana, Optativas),
    Optativas == ['IA-01', 'IA-03'].

test(beto_sin_area, [fail]) :-
    trabajo_especial:area_trabajo_especial(beto, _).

test(carla_sin_area, [fail]) :-
    trabajo_especial:area_trabajo_especial(carla, _).

test(beto_sin_optativas_de_referencia, [fail]) :-
    trabajo_especial:optativas_elegidas(beto, _).

:- end_tests(trabajo_especial).
