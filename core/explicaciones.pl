%% ARES - Explicaciones de las recomendaciones
%%
%% Traduce el detalle de puntuacion de una materia a razones legibles y a
%% una frase en espanol para mostrar en la CLI.
%%
%% Las razones son los mismos terminos que produce puntuacion:detalle/3,
%% asi la explicacion nunca se desincroniza del puntaje:
%%
%%   desbloquea(5, [so, redes, bd, is1, ia])
%%   afinidad(ia)
%%   recursada(aed2)
%%   materia_nominal(5, 1)
%%   requisito_de(compiladores)
%%   carga_equilibrada
%%   riesgo_dificultad(4, 6.5)
%%   excede_carga(30)

:- module(explicaciones, [
    por_que/3,
    razon/3,
    explicar/3,
    texto/2
]).

%% ---------------------------------------------------------------------------
%% Razones
%% ---------------------------------------------------------------------------

por_que(Perfil, Curso, Razones) :-
    findall(Razon, razon(Perfil, Curso, Razon), Razones).

razon(Perfil, Curso, Razon) :-
    puntuacion:detalle(Perfil, Curso, Detalle),
    member(_-Razon, Detalle).

%% ---------------------------------------------------------------------------
%% Texto de cada razon
%% ---------------------------------------------------------------------------

texto(desbloquea(N, Cursos), Texto) :-
    recortar(Cursos, 5, Mostrados, Restantes),
    (   Restantes > 0
    ->  format(atom(Texto),
               'desbloquea ~w materias pendientes (~w y ~w mas)',
               [N, Mostrados, Restantes])
    ;   format(atom(Texto),
               'desbloquea ~w materias pendientes (~w)',
               [N, Mostrados])
    ).

texto(materia_nominal(Anio, Cuatrimestre), Texto) :-
    format(atom(Texto),
           'esta en tu año y cuatrimestre nominal (año ~w, cuatrimestre ~w)',
           [Anio, Cuatrimestre]).

texto(requisito_de(Futuro), Texto) :-
    format(atom(Texto),
           'es requisito directo de ~w, del año siguiente',
           [Futuro]).

texto(afinidad(Area), Texto) :-
    format(atom(Texto), 'coincide con tus intereses en ~w', [Area]).

texto(carga_equilibrada, Texto) :-
    Texto = 'es una materia liviana que equilibra la carga'.

texto(riesgo_dificultad(Dificultad, Promedio), Texto) :-
    format(atom(Texto),
           'dificultad ~w con promedio ~w: conviene reforzarla',
           [Dificultad, Promedio]).

texto(excede_carga(Max), Texto) :-
    format(atom(Texto), 'excede tu carga maxima de ~w creditos', [Max]).

texto(recursada(Curso), Texto) :-
    format(atom(Texto), 'es una materia que recursas (~w)', [Curso]).

%% ---------------------------------------------------------------------------
%% Explicacion completa
%% ---------------------------------------------------------------------------

explicar(Perfil, Curso, Texto) :-
    por_que(Perfil, Curso, Razones),
    findall(Frase, (member(Razon, Razones), texto(Razon, Frase)), Frases),
    puntuacion:puntaje(Perfil, Curso, Puntos),
    atomic_list_concat(Frases, ' ', Cuerpo),
    format(atom(Texto), '~w (~w puntos). ~w', [Curso, Puntos, Cuerpo]).

%% ---------------------------------------------------------------------------
%% Utilidades
%% ---------------------------------------------------------------------------

%% recortar(+Lista, +Maximo, -Mostrados, -Restantes)
recortar(Lista, Maximo, Mostrados, Restantes) :-
    length(Lista, Largo),
    (   Largo =< Maximo
    ->  Mostrados = Lista,
        Restantes = 0
    ;   length(Mostrados, Maximo),
        append(Mostrados, Cola, Lista),
        length(Cola, Restantes)
    ).
