%% ARES - Ejecuta todas las pruebas PLUnit
%%
%% Uso, desde la raiz del proyecto:
%%   swipl run_tests.pl

:- initialization(main, main).

main :-
    consult('load.pl'),
    expand_file_name('tests/test_*.pl', Archivos),
    maplist(consult, Archivos),
    run_tests,
    halt.
