%% ARES - Pruebas del formato de salida

%% Se carga el modulo sin importar predicados: las pruebas los llaman
%% calificados y plan:creditos/2 ya esta importado en user.
:- use_module('../ui/formato.pl', []).

:- begin_tests(formato).

test(porcentaje_con_dos_decimales) :-
    formato:porcentaje(85.5, Texto),
    Texto == '85.50%'.

test(creditos) :-
    formato:creditos(10, Texto),
    Texto == '10 creditos'.

test(lista) :-
    formato:lista([ia, software], Texto),
    Texto == 'ia, software'.

test(lista_vacia) :-
    formato:lista([], Texto),
    Texto == ''.

test(tabla_incluye_encabezado_y_filas) :-
    formato:tabla(['Materia', 'Puntaje'], [['aed2', 90]], Texto),
    split_string(Texto, "\n", "", Lineas),
    Lineas = [Encabezado, _Separador, Fila],
    sub_string(Encabezado, 0, 7, _, 'Materia'),
    sub_string(Fila, 0, 4, _, 'aed2').

test(tabla_alinea_las_columnas) :-
    formato:tabla(['Materia', 'P', 'Creditos'], [['aed2', 90, 15]], Texto),
    split_string(Texto, "\n", "", [Encabezado, Separador, Fila]),
    string_length(Encabezado, LargoEncabezado),
    string_length(Separador, LargoSeparador),
    string_length(Fila, LargoFila),
    LargoEncabezado =:= LargoFila,
    LargoSeparador >= LargoFila.

test(tabla_sin_filas) :-
    formato:tabla(['A'], [], Texto),
    split_string(Texto, "\n", "", Lineas),
    length(Lineas, 2).

:- end_tests(formato).
