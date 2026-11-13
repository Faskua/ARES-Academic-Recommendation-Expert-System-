%% ARES - Pruebas de avance academico

:- begin_tests(avance).

test(creditos_totales_del_plan) :-
    avance:creditos_totales(Total),
    Total =:= 282.

test(items_totales_del_plan) :-
    avance:items_totales(28).

test(creditos_ana) :-
    avance:creditos_aprobados(ana, Creditos),
    Creditos =:= 242.

test(creditos_beto) :-
    avance:creditos_aprobados(beto, Creditos),
    Creditos =:= 112.

test(creditos_carla) :-
    avance:creditos_aprobados(carla, Creditos),
    Creditos =:= 102.

test(obligatorias_ana) :-
    avance:obligatorias_aprobadas(ana, N),
    N =:= 23.

test(obligatorias_beto) :-
    avance:obligatorias_aprobadas(beto, N),
    N =:= 10.

test(obligatorias_carla) :-
    avance:obligatorias_aprobadas(carla, N),
    N =:= 9.

test(sin_optativas_aprobadas) :-
    forall(member(Perfil, [ana, beto, carla]),
           ( avance:optativas_aprobadas(Perfil, N),
             N =:= 0
           )).

test(sin_trabajo_especial_aprobado) :-
    forall(member(Perfil, [ana, beto, carla]),
           \+ avance:trabajo_especial_aprobado(Perfil)).

test(items_aprobados_ana) :-
    avance:items_aprobados(ana, N),
    N =:= 23.

test(avance_ana) :-
    avance:avance(ana, Porcentaje),
    Porcentaje > 85.0,
    Porcentaje < 86.0.

test(avance_beto) :-
    avance:avance(beto, Porcentaje),
    Porcentaje > 39.0,
    Porcentaje < 40.0.

test(avance_carla) :-
    avance:avance(carla, Porcentaje),
    Porcentaje > 36.0,
    Porcentaje < 37.0.

:- end_tests(avance).
