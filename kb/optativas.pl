%% ARES - Catalogo de optativas (simulado y plausible)
%%
%% Las optativas NO son el listado oficial de FaMAF: se construyeron como
%% un catalogo coherente con las areas del plan. Ver Roadmap.md, seccion 10.
%%
%% optativa(Codigo, Nombre, Area, Dificultad, Oferta, Prerrequisitos)
%%   Oferta: i | ii (cuatrimestre en que se dicta)
%%   Prerrequisitos: codigos de materias del plan o de otras optativas

:- module(optativas, [
    optativa/6,
    es_optativa/1,
    area_optativa/2,
    dificultad_optativa/2,
    oferta/2,
    prerrequisito_optativa/2,
    cadena/2
]).

:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% IA y Datos
%% ---------------------------------------------------------------------------
optativa('IA-01', 'Aprendizaje Automático', ia, 4, i, [ia, prob]).
optativa('IA-02', 'Aprendizaje Profundo', ia, 5, ii, [ia, 'IA-01']).
optativa('IA-03', 'Minería de Datos', ia, 3, i, [bd, prob]).

%% ---------------------------------------------------------------------------
%% Sistemas, Redes y Seguridad
%% ---------------------------------------------------------------------------
optativa('SIS-01', 'Sistemas Distribuidos', sistemas, 4, i, [so, redes]).
optativa('SIS-02', 'Computación en la Nube', sistemas, 3, ii, [redes, 'SIS-01']).
optativa('SIS-03', 'Seguridad Informática', sistemas, 3, ii, [so, redes]).

%% ---------------------------------------------------------------------------
%% Ingenieria de Software
%% ---------------------------------------------------------------------------
optativa('SW-01', 'Arquitectura de Software', software, 3, i, [is1]).
optativa('SW-02', 'Testing y Calidad', software, 2, ii, [is1]).
optativa('SW-03', 'Desarrollo Web', software, 2, i, [bd, is1]).

%% ---------------------------------------------------------------------------
%% Teoria y Verificacion
%% ---------------------------------------------------------------------------
optativa('TEO-01', 'Verificación Formal', teoria, 5, i, [logica, lfc]).
optativa('TEO-02', 'Criptografía', teoria, 4, ii, [md2, prob]).
optativa('TEO-03', 'Teoría de la Computación Avanzada', teoria, 5, ii, [lfc]).

%% ---------------------------------------------------------------------------
%% Computacion Cientifica e Investigacion
%% ---------------------------------------------------------------------------
optativa('INV-01', 'Computación Gráfica', cientifica, 4, i, [alg_lineal, aed2]).
optativa('INV-02', 'Bioinformática', cientifica, 4, ii, [ia, prob]).
optativa('INV-03', 'Introducción a la Investigación', cientifica, 2, i, [is1, lfc]).

%% ---------------------------------------------------------------------------
%% Derivados
%% ---------------------------------------------------------------------------
es_optativa(Cod) :-
    optativa(Cod, _, _, _, _, _).

area_optativa(Cod, Area) :-
    optativa(Cod, _, Area, _, _, _).

dificultad_optativa(Cod, Nivel) :-
    optativa(Cod, _, _, Nivel, _, _).

oferta(Cod, Cuatrimestre) :-
    optativa(Cod, _, _, _, Cuatrimestre, _).

prerrequisito_optativa(Optativa, Requisito) :-
    optativa(Optativa, _, _, _, _, Requisitos),
    member(Requisito, Requisitos).

%% Una cadena es una optativa que requiere otra optativa.
cadena(Previa, Posterior) :-
    prerrequisito_optativa(Posterior, Previa).
