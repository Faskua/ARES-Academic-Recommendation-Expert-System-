%% ARES - Pruebas del recomendador

:- begin_tests(recomendador).

%% ---------------------------------------------------------------------------
%% Selecciones por perfil
%% ---------------------------------------------------------------------------

test(ana_recomendacion) :-
    recomendador:recomendar(ana, Seleccion, Creditos),
    Seleccion == [is2],
    Creditos =:= 10.

test(adrian_respeta_el_tope) :-
    recomendador:recomendar(adrian, Seleccion, Creditos),
    Seleccion == [aed2],
    Creditos =:= 15.

test(carla_entra_justo_en_el_tope) :-
    recomendador:recomendar(carla, Seleccion, Creditos),
    Seleccion == [aed2, md2],
    Creditos =:= 25.

test(adrian_candidatos_ordenados) :-
    recomendador:candidatos_puntuados(adrian, Puntuados),
    Puntuados == [90-aed2, 60-md2].

test(carla_candidatos_ordenados) :-
    recomendador:candidatos_puntuados(carla, Puntuados),
    Puntuados == [105-aed2, 75-md2].

test(ana_candidatos_ordenados) :-
    recomendador:candidatos_puntuados(ana, Puntuados),
    Puntuados == [20-is2].

%% ---------------------------------------------------------------------------
%% Tope de creditos
%% ---------------------------------------------------------------------------

test(nunca_supera_la_carga_maxima) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( recomendador:recomendar(Perfil, _, Creditos),
             perfiles:max_creditos(Perfil, Max),
             Creditos =< Max
           )).

test(seleccionar_con_candidatos_desordenados) :-
    recomendador:seleccionar_hasta(carla, [md2, aed2], Seleccion),
    Seleccion == [aed2, md2].

test(seleccionar_sin_candidatos) :-
    recomendador:seleccionar_hasta(adrian, [], Seleccion),
    Seleccion == [].

test(recomendar_sobre_un_subconjunto) :-
    recomendador:recomendar(adrian, [md2], Seleccion, Creditos),
    Seleccion == [md2],
    Creditos =:= 10.

:- end_tests(recomendador).
