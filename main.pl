%% ARES - Punto de entrada de la interfaz de linea de comandos
%%
%% Uso, desde la raiz del proyecto:
%%
%%   swipl main.pl
%%
%% Carga la base de conocimiento, los modulos de core/ y arranca el menu.

:- ensure_loaded('load.pl').
:- use_module('ui/menu.pl').

:- initialization(main, main).

main :-
    menu:menu,
    halt.
