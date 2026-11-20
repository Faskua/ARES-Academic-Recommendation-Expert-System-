%% ARES - Perfiles de demostracion
%%
%% Tres situaciones deliberadamente distintas:
%%   ana   : al dia, orientada a IA, decide optativas y Trabajo Especial.
%%   beto  : recursante y trabajador, decide entre retomar o avanzar.
%%   carla : atrasada, decide como repartir una carga maxima.
%%
%% cursa/2 significa "inscripto actualmente"; recursa/2 significa
%% "materia pendiente que puede volver a cursarse".

:- module(perfiles, [
    estudiante/1,
    anio_actual/2,
    cuatrimestre_actual/2,
    promedio/2,
    max_creditos/2,
    objetivo/2,
    interes/2,
    aprobo/2,
    cursa/2,
    recursa/2
]).

%% Los hechos de los perfiles se pueden modificar al cargar un perfil
%% guardado desde la CLI (ui/persistencia.pl).
:- dynamic estudiante/1, anio_actual/2, cuatrimestre_actual/2,
           promedio/2, max_creditos/2, objetivo/2, interes/2,
           aprobo/2, cursa/2, recursa/2.

%% Los hechos están agrupados por estudiante para facilitar la lectura,
%% por eso los predicados no son contiguos.
:- discontiguous estudiante/1, anio_actual/2, cuatrimestre_actual/2,
               promedio/2, max_creditos/2, objetivo/2, interes/2,
               aprobo/2, recursa/2.

%% ---------------------------------------------------------------------------
%% Ana: 5.o año, al dia, 23 obligatorias aprobadas.
%% ---------------------------------------------------------------------------
estudiante(ana).
anio_actual(ana, 5).
cuatrimestre_actual(ana, 1).
promedio(ana, 8.5).
max_creditos(ana, 30).
objetivo(ana, especializarse).
interes(ana, ia).

aprobo(ana, nivelacion).
aprobo(ana, md1).
aprobo(ana, calc1).
aprobo(ana, intro_alg).
aprobo(ana, alg_lineal).
aprobo(ana, calc2).
aprobo(ana, aed1).
aprobo(ana, anum).
aprobo(ana, aed2).
aprobo(ana, org).
aprobo(ana, log_intro).
aprobo(ana, prob).
aprobo(ana, so).
aprobo(ana, paradigmas).
aprobo(ana, md2).
aprobo(ana, redes).
aprobo(ana, bd).
aprobo(ana, sociedad).
aprobo(ana, is1).
aprobo(ana, lfc).
aprobo(ana, ia).
aprobo(ana, ingles).
aprobo(ana, logica).
aprobo(ana, arq).

%% ---------------------------------------------------------------------------
%% Beto: 3.er año, recursa AED II, trabaja 30 hs/semana.
%% Aprueba hasta 2.o año, 1.er cuatrimestre, incluida Probabilidad.
%% ---------------------------------------------------------------------------
estudiante(beto).
anio_actual(beto, 3).
cuatrimestre_actual(beto, 1).
promedio(beto, 6.5).
max_creditos(beto, 20).
objetivo(beto, graduarse).
interes(beto, sistemas).

aprobo(beto, nivelacion).
aprobo(beto, md1).
aprobo(beto, calc1).
aprobo(beto, intro_alg).
aprobo(beto, alg_lineal).
aprobo(beto, calc2).
aprobo(beto, aed1).
aprobo(beto, anum).
aprobo(beto, org).
aprobo(beto, log_intro).
aprobo(beto, prob).

recursa(beto, aed2).

%% ---------------------------------------------------------------------------
%% Carla: 3.er año, atrasada, recursa AED II y Probabilidad.
%% Aprueba hasta 2.o año, 1.er cuatrimestre.
%% ---------------------------------------------------------------------------
estudiante(carla).
anio_actual(carla, 3).
cuatrimestre_actual(carla, 1).
promedio(carla, 7.0).
max_creditos(carla, 25).
objetivo(carla, equilibrar).
interes(carla, datos).
interes(carla, software).

aprobo(carla, nivelacion).
aprobo(carla, md1).
aprobo(carla, calc1).
aprobo(carla, intro_alg).
aprobo(carla, alg_lineal).
aprobo(carla, calc2).
aprobo(carla, aed1).
aprobo(carla, anum).
aprobo(carla, org).
aprobo(carla, log_intro).

recursa(carla, aed2).
recursa(carla, prob).
