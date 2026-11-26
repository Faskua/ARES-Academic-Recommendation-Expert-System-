%% ARES - Pruebas de seleccion de optativas

:- begin_tests(selector_optativas).

%% ---------------------------------------------------------------------------
%% Candidatas
%% ---------------------------------------------------------------------------

test(elegibles_de_ana) :-
    selector_optativas:optativas_elegibles(ana, Optativas),
    Optativas == ['IA-01', 'IA-03', 'INV-01', 'INV-03',
                  'SIS-01', 'SW-01', 'SW-03', 'TEO-01'].

test(adrian_sin_elegibles) :-
    selector_optativas:optativas_elegibles(adrian, Optativas),
    Optativas == [].

test(carla_sin_elegibles) :-
    selector_optativas:optativas_elegibles(carla, Optativas),
    Optativas == [].

%% ---------------------------------------------------------------------------
%% Puntaje individual
%% ---------------------------------------------------------------------------

test(optativa_afin) :-
    selector_optativas:puntaje_optativa(ana, 'IA-01', Puntos),
    Puntos =:= 15.

test(optativa_sin_afinidad) :-
    selector_optativas:puntaje_optativa(ana, 'TEO-01', Puntos),
    Puntos =:= 0.

test(optativa_riesgosa_para_adrian) :-
    selector_optativas:puntaje_optativa(adrian, 'SIS-01', Puntos),
    Puntos =:= 5.

%% ---------------------------------------------------------------------------
%% Puntaje del par
%% ---------------------------------------------------------------------------

test(par_afin_y_misma_area) :-
    selector_optativas:puntaje_par(ana, 'IA-01', 'IA-03', Puntos),
    Puntos =:= 40.

test(par_con_cadena) :-
    selector_optativas:puntaje_par(ana, 'IA-01', 'IA-02', Puntos),
    Puntos =:= 50.

test(par_diverso_para_equilibrar) :-
    selector_optativas:puntaje_par(carla, 'IA-03', 'SW-03', Puntos),
    Puntos =:= 25.

test(misma_area_no_bonifica_si_equilibra) :-
    selector_optativas:puntaje_par(carla, 'IA-01', 'IA-03', Puntos),
    Puntos =:= 0.

test(cadena_para_adrian) :-
    selector_optativas:puntaje_par(adrian, 'SIS-01', 'SIS-02', Puntos),
    Puntos =:= 30.

test(par_de_dificultad_alta_para_adrian) :-
    selector_optativas:puntaje_par(adrian, 'SIS-01', 'TEO-01', Puntos),
    Puntos =:= -20.

%% ---------------------------------------------------------------------------
%% Mejor par
%% ---------------------------------------------------------------------------

test(par_de_ana) :-
    selector_optativas:recomendar_par(ana, Par),
    Par == ['IA-01', 'IA-03'].

test(par_de_ana_respeta_oferta) :-
    selector_optativas:recomendar_par(ana, Par),
    \+ memberchk('IA-02', Par).

test(adrian_sin_par, [fail]) :-
    selector_optativas:recomendar_par(adrian, _).

test(carla_sin_par, [fail]) :-
    selector_optativas:recomendar_par(carla, _).

:- end_tests(selector_optativas).
