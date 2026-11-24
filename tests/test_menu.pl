%% ARES - Pruebas del menu

:- use_module('../ui/menu.pl').

:- begin_tests(menu).

test(opciones_disponibles) :-
    menu:opciones(Opciones),
    length(Opciones, 10),
    memberchk(perfil-_, Opciones),
    memberchk(alertas-_, Opciones),
    memberchk(whatif-_, Opciones),
    memberchk(guardar-_, Opciones),
    memberchk(cargar-_, Opciones),
    memberchk(salir-_, Opciones).

test(opciones_tienen_descripcion) :-
    menu:opciones(Opciones),
    forall(member(_-Descripcion, Opciones), atom(Descripcion)).

:- end_tests(menu).
