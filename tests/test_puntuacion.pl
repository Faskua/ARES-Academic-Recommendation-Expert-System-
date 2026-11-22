%% ARES - Pruebas de puntuacion de materias

:- begin_tests(puntuacion).

%% ---------------------------------------------------------------------------
%% Puntajes de los perfiles de demostracion
%% ---------------------------------------------------------------------------

test(ana_is2) :-
    puntuacion:puntaje(ana, is2, Puntos),
    Puntos =:= 20.

test(adrian_aed2) :-
    puntuacion:puntaje(adrian, aed2, Puntos),
    Puntos =:= 90.

test(adrian_md2) :-
    puntuacion:puntaje(adrian, md2, Puntos),
    Puntos =:= 60.

test(carla_aed2) :-
    puntuacion:puntaje(carla, aed2, Puntos),
    Puntos =:= 105.

test(carla_md2) :-
    puntuacion:puntaje(carla, md2, Puntos),
    Puntos =:= 75.

%% ---------------------------------------------------------------------------
%% Reglas puntuales
%% ---------------------------------------------------------------------------

test(ana_is2_solo_materia_nominal) :-
    puntuacion:detalle(ana, is2, Detalle),
    Detalle == [20-materia_nominal(5, 1)].

test(adrian_aed2_desbloquea_veinte) :-
    puntuacion:detalle(adrian, aed2, Detalle),
    once(memberchk(40-desbloquea(20, Cursos), Detalle)),
    length(Cursos, 20).

test(adrian_md2_desbloquea_seis) :-
    puntuacion:detalle(adrian, md2, Detalle),
    once(memberchk(40-desbloquea(6, Cursos), Detalle)),
    Cursos == ['INV-03', 'TEO-01', 'TEO-02', 'TEO-03', compiladores, lfc].

test(adrian_md2_detalle_completo) :-
    puntuacion:detalle(adrian, md2, Detalle),
    Detalle == [ 40-desbloquea(6, ['INV-03', 'TEO-01', 'TEO-02',
                                   'TEO-03', compiladores, lfc]),
                 20-materia_nominal(3, 1),
                 15-requisito_de(lfc),
                 -15-riesgo_dificultad(4, 6.5)
               ].

test(adrian_aed2_es_requisito_de_ia) :-
    puntuacion:detalle(adrian, aed2, Detalle),
    memberchk(15-requisito_de(ia), Detalle).

test(adrian_aed2_riesgo_por_promedio) :-
    puntuacion:detalle(adrian, aed2, Detalle),
    memberchk(-15-riesgo_dificultad(4, 6.5), Detalle).

test(adrian_aed2_recursada) :-
    puntuacion:detalle(adrian, aed2, Detalle),
    memberchk(30-recursada(aed2), Detalle).

test(adrian_md2_no_recursada, [fail]) :-
    puntuacion:detalle(adrian, md2, Detalle),
    memberchk(_-recursada(md2), Detalle).

test(ana_sin_riesgo_por_dificultad, [fail]) :-
    puntuacion:detalle(ana, is2, Detalle),
    memberchk(_-riesgo_dificultad(_, _), Detalle).

test(carla_afinidad_con_datos) :-
    puntuacion:detalle(carla, bd, Detalle),
    memberchk(10-afinidad(datos), Detalle).

test(ana_sin_afinidad_con_is2, [fail]) :-
    puntuacion:detalle(ana, is2, Detalle),
    memberchk(_-afinidad(_), Detalle).

%% ---------------------------------------------------------------------------
%% Carga y tope de creditos
%% ---------------------------------------------------------------------------

test(carga_actual_vacia) :-
    forall(member(Perfil, [ana, adrian, carla]),
           puntuacion:carga_actual(Perfil, 0)).

test(carga_exigente_en_el_umbral) :-
    puntuacion:carga_exigente(adrian, 15).

test(carga_no_exigente, [fail]) :-
    puntuacion:carga_exigente(adrian, 14).

test(materia_liviana_con_carga_exigente) :-
    puntuacion:detalle(adrian, sociedad, 16, Detalle),
    memberchk(10-carga_equilibrada, Detalle).

test(materia_liviana_sin_carga_exigente, [fail]) :-
    puntuacion:detalle(adrian, sociedad, 0, Detalle),
    memberchk(_-carga_equilibrada, Detalle).

test(excede_la_carga_maxima) :-
    puntuacion:detalle(adrian, md2, 15, Detalle),
    memberchk(-20-excede_carga(20), Detalle).

test(puntaje_con_carga_penaliza_md2) :-
    puntuacion:puntaje(adrian, md2, 15, Puntos),
    Puntos =:= 40.

test(puntaje_con_carga_no_penaliza_aed2) :-
    puntuacion:puntaje(adrian, aed2, 0, Puntos),
    Puntos =:= 90.

:- end_tests(puntuacion).
