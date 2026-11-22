%% ARES - Pruebas de explicaciones

:- begin_tests(explicaciones).

%% ---------------------------------------------------------------------------
%% Razones
%% ---------------------------------------------------------------------------

test(razones_de_adrian_para_aed2) :-
    explicaciones:por_que(adrian, aed2, Razones),
    memberchk(desbloquea(20, _), Razones),
    memberchk(materia_nominal(2, 1), Razones),
    memberchk(requisito_de(ia), Razones),
    memberchk(riesgo_dificultad(4, 6.5), Razones),
    memberchk(recursada(aed2), Razones),
    length(Razones, 5).

test(razones_de_ana_para_is2) :-
    explicaciones:por_que(ana, is2, Razones),
    Razones == [materia_nominal(5, 1)].

test(razones_de_carla_para_aed2) :-
    explicaciones:por_que(carla, aed2, Razones),
    memberchk(recursada(aed2), Razones),
    \+ memberchk(riesgo_dificultad(_, _), Razones).

test(sin_razon_de_recursada, [fail]) :-
    explicaciones:razon(ana, is2, recursada(_)).

%% ---------------------------------------------------------------------------
%% Texto
%% ---------------------------------------------------------------------------

test(texto_de_recursada) :-
    explicaciones:texto(recursada(aed2), Texto),
    once(sub_atom(Texto, _, _, _, 'recursas')).

test(texto_de_desbloqueo) :-
    explicaciones:texto(desbloquea(20, [ia, bd]), Texto),
    once(sub_atom(Texto, _, _, _, 'desbloquea 20 materias')).

test(todas_las_razones_tienen_texto) :-
    forall(member(Perfil-Curso, [adrian-aed2, carla-aed2, ana-is2]),
           forall(explicaciones:razon(Perfil, Curso, Razon),
                  explicaciones:texto(Razon, _))).

test(explicar_adrian) :-
    explicaciones:explicar(adrian, aed2, Texto),
    atom(Texto),
    once(sub_atom(Texto, _, _, _, '90 puntos')),
    once(sub_atom(Texto, _, _, _, 'desbloquea 20 materias')).

test(explicar_ana) :-
    explicaciones:explicar(ana, is2, Texto),
    atom(Texto),
    once(sub_atom(Texto, _, _, _, '20 puntos')).

:- end_tests(explicaciones).
