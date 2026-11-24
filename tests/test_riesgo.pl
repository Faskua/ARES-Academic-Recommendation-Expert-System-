%% ARES - Pruebas de alertas y riesgos

:- begin_tests(riesgo).

%% ---------------------------------------------------------------------------
%% Cuellos de botella
%% ---------------------------------------------------------------------------

test(aed2_es_cuello_de_botella) :-
    riesgo:cuello_botella(aed2).

test(redes_es_cuello_de_botella) :-
    riesgo:cuello_botella(redes).

test(prob_es_cuello_de_botella) :-
    riesgo:cuello_botella(prob).

test(md1_no_es_cuello_de_botella, [fail]) :-
    riesgo:cuello_botella(md1).

%% ---------------------------------------------------------------------------
%% Fecha de egreso
%% ---------------------------------------------------------------------------

test(egreso_de_ana) :-
    riesgo:fecha_egreso(ana, 5-2).

test(egreso_de_adrian) :-
    riesgo:fecha_egreso(adrian, 7-1).

test(egreso_de_carla) :-
    riesgo:fecha_egreso(carla, 7-1).

%% ---------------------------------------------------------------------------
%% Alertas
%% ---------------------------------------------------------------------------

test(ana_sin_alertas_de_atraso) :-
    riesgo:alertas(ana, Alertas),
    \+ memberchk(riesgo_atraso(ana), Alertas),
    \+ memberchk(sobrecarga(_, _), Alertas).

test(adrian_con_atraso_y_cuello) :-
    riesgo:alertas(adrian, Alertas),
    memberchk(riesgo_atraso(adrian), Alertas),
    memberchk(cuello_botella(aed2), Alertas),
    memberchk(materia_critica_sin_aprobar(redes), Alertas).

test(adrian_posterga_md2) :-
    riesgo:alertas(adrian, Alertas),
    memberchk(conflicto_oferta(md2), Alertas).

test(carla_con_atraso_y_probabilidad) :-
    riesgo:alertas(carla, Alertas),
    memberchk(riesgo_atraso(carla), Alertas),
    memberchk(cuello_botella(prob), Alertas).

test(alertas_ordenadas_y_sin_duplicados) :-
    riesgo:alertas(adrian, Alertas),
    sort(Alertas, Ordenadas),
    Alertas == Ordenadas.

test(ningun_plan_base_esta_sobrecargado) :-
    forall(member(Perfil, [ana, adrian, carla]),
           ( riesgo:alertas(Perfil, Alertas),
             \+ memberchk(sobrecarga(_, _), Alertas)
           )).

:- end_tests(riesgo).
