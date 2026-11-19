%% ARES - Formato de salida para la CLI
%%
%% Funciones puras que devuelven atomos, para poder probarlas sin
%% depender de la entrada/salida del usuario.
%%
%%   tabla(Encabezados, Filas, Texto)
%%   porcentaje(Valor, Texto)
%%   creditos(Cantidad, Texto)
%%   lista(Elementos, Texto)

:- module(formato, [
    tabla/3,
    porcentaje/2,
    creditos/2,
    lista/2
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Tabla de ancho fijo
%% ---------------------------------------------------------------------------

tabla(Encabezados, Filas, Texto) :-
    anchos(Encabezados, Filas, Anchos),
    fila_texto(Encabezados, Anchos, Encabezado),
    separador(Anchos, Separador),
    findall(Linea,
            ( member(Fila, Filas),
              fila_texto(Fila, Anchos, Linea)
            ),
            Lineas),
    atomic_list_concat([Encabezado, Separador|Lineas], '\n', Texto).

anchos(Encabezados, Filas, Anchos) :-
    length(Encabezados, Columnas),
    numlist(1, Columnas, Indices),
    maplist(ancho_columna(Encabezados, Filas), Indices, Anchos).

ancho_columna(Encabezados, Filas, Indice, Ancho) :-
    findall(Largo,
            ( (   nth1(Indice, Encabezados, Celda)
              ;   member(Fila, Filas),
                  nth1(Indice, Fila, Celda)
              ),
              texto_celda(Celda, Texto),
              atom_length(Texto, Largo)
            ),
            Largos),
    max_list(Largos, Ancho).

fila_texto(Celdas, Anchos, Linea) :-
    maplist(celda_rellena, Celdas, Anchos, Rellenas),
    atomic_list_concat(Rellenas, '  ', Linea).

celda_rellena(Celda, Ancho, Rellena) :-
    texto_celda(Celda, Texto),
    format(atom(Rellena), '~w~t~*|', [Texto, Ancho]).

texto_celda(Celda, Texto) :-
    format(atom(Texto), '~w', [Celda]).

separador(Anchos, Separador) :-
    maplist(guiones, Anchos, Partes),
    atomic_list_concat(Partes, '-+-', Separador).

guiones(Ancho, Guiones) :-
    length(Codigos, Ancho),
    maplist(=(0'-), Codigos),
    atom_codes(Guiones, Codigos).

%% ---------------------------------------------------------------------------
%% Valores
%% ---------------------------------------------------------------------------

porcentaje(Valor, Texto) :-
    format(atom(Texto), '~2f%', [Valor]).

creditos(Cantidad, Texto) :-
    format(atom(Texto), '~w creditos', [Cantidad]).

lista(Elementos, Texto) :-
    (   Elementos == []
    ->  Texto = ''
    ;   atomic_list_concat(Elementos, ', ', Texto)
    ).
