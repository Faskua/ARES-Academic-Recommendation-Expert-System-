%% ARES - Base de conocimiento del plan de estudios
%% Fuente: PlanEstudio.md (FaMAF-UNC, 29 espacios curriculares)
%%
%% Las correlatividades fueron reconstruidas a partir del orden del plan.
%% NO son las oficiales: ver Roadmap.md, seccion 10 (supuestos).
%%
%% asignatura(Codigo, Nombre, Anio, Cuatrimestre, Creditos,
%%            HorasSemana, HorasTotales, Area, Dificultad)

:- module(plan, [
    asignatura/9,
    prerrequisito/2,
    requisito_ingreso/1,
    requisito_trabajo_especial/1,
    cupo_optativa/3,
    area/2,
    dificultad/2,
    creditos/2,
    horas_semana/2,
    horas_totales/2,
    anio_nominal/2,
    cuatrimestre_nominal/2,
    obligatoria/1,
    es_trabajo_especial/1
]).

%% ---------------------------------------------------------------------------
%% Nivelación
%% ---------------------------------------------------------------------------
asignatura(nivelacion, 'Curso de Nivelación', 0, 0, 7, 25, 100, induccion, 1).

%% ---------------------------------------------------------------------------
%% Primer año
%% ---------------------------------------------------------------------------
asignatura(md1, 'Matemática Discreta I', 1, 1, 10, 8, 120, matematica, 3).
asignatura(calc1, 'Cálculo I', 1, 1, 10, 8, 120, matematica, 3).
asignatura(intro_alg, 'Introducción a los Algoritmos', 1, 1, 10, 8, 120, programacion, 2).
asignatura(alg_lineal, 'Álgebra Lineal', 1, 2, 10, 8, 120, matematica, 3).
asignatura(calc2, 'Cálculo II', 1, 2, 10, 8, 120, matematica, 4).
asignatura(aed1, 'Algoritmos y Estructuras de Datos I', 1, 2, 15, 12, 180, programacion, 3).

%% ---------------------------------------------------------------------------
%% Segundo año
%% ---------------------------------------------------------------------------
asignatura(anum, 'Análisis Numérico', 2, 1, 10, 8, 120, matematica, 4).
asignatura(aed2, 'Algoritmos y Estructuras de Datos II', 2, 1, 15, 12, 180, programacion, 4).
asignatura(org, 'Organización del Computador', 2, 1, 10, 8, 120, sistemas, 3).
asignatura(log_intro, 'Introducción a la Lógica y la Computación', 2, 2, 10, 8, 120, teoria, 3).
asignatura(prob, 'Probabilidad y Estadística', 2, 2, 10, 8, 120, matematica, 3).
asignatura(so, 'Sistemas Operativos', 2, 2, 10, 8, 120, sistemas, 4).

%% ---------------------------------------------------------------------------
%% Tercer año
%% ---------------------------------------------------------------------------
asignatura(paradigmas, 'Paradigmas de Programación', 3, 1, 10, 8, 120, programacion, 3).
asignatura(md2, 'Matemática Discreta II', 3, 1, 10, 8, 120, matematica, 4).
asignatura(redes, 'Redes y Sistemas Distribuidos', 3, 1, 10, 8, 120, sistemas, 4).
asignatura(bd, 'Bases de Datos', 3, 2, 10, 8, 120, datos, 3).
asignatura(sociedad, 'Computación y Sociedad', 3, 2, 10, 8, 120, humanidades, 1).
asignatura(is1, 'Ingeniería del Software I', 3, 2, 10, 8, 120, software, 3).

%% ---------------------------------------------------------------------------
%% Cuarto año
%% ---------------------------------------------------------------------------
asignatura(lfc, 'Lenguajes Formales y Computabilidad', 4, 1, 10, 8, 120, teoria, 5).
asignatura(ia, 'Inteligencia Artificial', 4, 1, 10, 8, 120, ia, 4).
asignatura(ingles, 'Inglés', 4, 1, 5, 4, 60, idiomas, 1).
asignatura(logica, 'Lógica', 4, 2, 10, 8, 120, teoria, 4).
asignatura(arq, 'Arquitectura de Computadoras', 4, 2, 10, 8, 120, sistemas, 3).

%% ---------------------------------------------------------------------------
%% Quinto año
%% ---------------------------------------------------------------------------
asignatura(is2, 'Ingeniería del Software II', 5, 1, 10, 8, 120, software, 4).
asignatura(compiladores, 'Lenguajes y Compiladores', 5, 2, 10, 8, 120, teoria, 5).
asignatura(trabajo_especial, 'Trabajo Especial', 5, 0, 0, 0, 180, investigacion, 5).

%% ---------------------------------------------------------------------------
%% Requisitos generales
%% ---------------------------------------------------------------------------
requisito_ingreso(nivelacion).

%% Cantidad minima de obligatorias aprobadas para iniciar el Trabajo Especial.
requisito_trabajo_especial(20).

%% Cupos nominales de optativas en el plan (5.o año, 1.er y 2.o cuatrimestre).
cupo_optativa(5, 1, optativa_i).
cupo_optativa(5, 2, optativa_ii).

%% ---------------------------------------------------------------------------
%% Correlatividades (reconstruidas)
%% ---------------------------------------------------------------------------
prerrequisito(calc2, calc1).
prerrequisito(aed1, intro_alg).
prerrequisito(anum, calc2).
prerrequisito(anum, alg_lineal).
prerrequisito(aed2, aed1).
prerrequisito(org, intro_alg).
prerrequisito(log_intro, md1).
prerrequisito(prob, calc2).
prerrequisito(so, org).
prerrequisito(so, aed2).
prerrequisito(paradigmas, aed2).
prerrequisito(md2, md1).
prerrequisito(redes, so).
prerrequisito(bd, aed2).
prerrequisito(is1, paradigmas).
prerrequisito(lfc, md2).
prerrequisito(lfc, log_intro).
prerrequisito(ia, aed2).
prerrequisito(ia, prob).
prerrequisito(logica, log_intro).
prerrequisito(arq, org).
prerrequisito(is2, is1).
prerrequisito(compiladores, lfc).
prerrequisito(compiladores, paradigmas).

%% ---------------------------------------------------------------------------
%% Predicados derivados
%% ---------------------------------------------------------------------------
area(Cod, Area) :-
    asignatura(Cod, _, _, _, _, _, _, Area, _).

dificultad(Cod, Nivel) :-
    asignatura(Cod, _, _, _, _, _, _, _, Nivel).

creditos(Cod, Creditos) :-
    asignatura(Cod, _, _, _, Creditos, _, _, _, _).

horas_semana(Cod, Horas) :-
    asignatura(Cod, _, _, _, _, Horas, _, _, _).

horas_totales(Cod, Horas) :-
    asignatura(Cod, _, _, _, _, _, Horas, _, _).

anio_nominal(Cod, Anio) :-
    asignatura(Cod, _, Anio, _, _, _, _, _, _).

cuatrimestre_nominal(Cod, Cuatrimestre) :-
    asignatura(Cod, _, _, Cuatrimestre, _, _, _, _, _).

%% Una obligatoria es toda materia del plan con año >= 1, excluyendo
%% el Trabajo Especial (que se planifica aparte).
obligatoria(Cod) :-
    asignatura(Cod, _, Anio, _, _, _, _, _, _),
    Anio >= 1,
    Cod \= trabajo_especial.

es_trabajo_especial(trabajo_especial).
