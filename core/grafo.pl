%% ARES - Grafo de correlatividades
%%
%% Unifica las correlatividades del plan y los prerrequisitos de las
%% optativas en un solo grafo, y ofrece consultas en ambas direcciones:
%%
%%   requiere(Curso, Requisito)          Curso necesita a Requisito
%%   desbloquea(Curso, Otro)             aprobar Curso habilita Otro
%%
%% Tambien valida la integridad del plan con validar_plan/0.

:- module(grafo, [
    requiere/2,
    prerrequisito_transitivo/2,
    desbloquea/2,
    desbloquea/3,
    es_curso/1,
    todos_los_cursos/1,
    ciclo/1,
    validar_plan/0,
    validar_plan/1
]).

%% Los chequeos de validacion estan agrupados por tema, no por predicado.
:- discontiguous error_plan/1.

%% ---------------------------------------------------------------------------
%% Aristas del grafo
%% ---------------------------------------------------------------------------

%% requiere(Curso, Requisito)
requiere(Curso, Requisito) :-
    plan:prerrequisito(Curso, Requisito).
requiere(Curso, Requisito) :-
    optativas:prerrequisito_optativa(Curso, Requisito).

%% es_curso/1: todo codigo valido, sea del plan o del catalogo de optativas.
es_curso(Curso) :-
    plan:asignatura(Curso, _, _, _, _, _, _, _, _).
es_curso(Curso) :-
    optativas:es_optativa(Curso).

todos_los_cursos(Cursos) :-
    findall(Curso, es_curso(Curso), Lista),
    sort(Lista, Cursos).

%% ---------------------------------------------------------------------------
%% Cierre transitivo hacia atras: que necesita un curso
%% ---------------------------------------------------------------------------

prerrequisito_transitivo(Curso, Requisito) :-
    setof(R, prereq_trans(Curso, R, [Curso]), Requisitos),
    member(Requisito, Requisitos).

prereq_trans(Curso, Requisito, _) :-
    requiere(Curso, Requisito).
prereq_trans(Curso, Requisito, Visitados) :-
    requiere(Curso, Intermedio),
    \+ memberchk(Intermedio, Visitados),
    prereq_trans(Intermedio, Requisito, [Intermedio|Visitados]).

%% ---------------------------------------------------------------------------
%% Cierre transitivo hacia adelante: que desbloquea un curso
%% ---------------------------------------------------------------------------

desbloquea(Curso, Desbloqueado) :-
    setof(D, desbloquea_trans(Curso, D, [Curso]), Desbloqueados),
    member(Desbloqueado, Desbloqueados).

desbloquea_trans(Curso, Desbloqueado, _) :-
    requiere(Desbloqueado, Curso).
desbloquea_trans(Curso, Desbloqueado, Visitados) :-
    requiere(Intermedio, Curso),
    \+ memberchk(Intermedio, Visitados),
    desbloquea_trans(Intermedio, Desbloqueado, [Intermedio|Visitados]).

%% desbloquea(Perfil, Curso, N): cuantas materias pendientes habilita Curso.
desbloquea(Perfil, Curso, N) :-
    findall(Desbloqueado,
            ( desbloquea(Curso, Desbloqueado),
              \+ perfiles:aprobo(Perfil, Desbloqueado),
              \+ perfiles:cursa(Perfil, Desbloqueado)
            ),
            Lista),
    sort(Lista, Unicos),
    length(Unicos, N).

%% ---------------------------------------------------------------------------
%% Deteccion de ciclos
%% ---------------------------------------------------------------------------

ciclo(Curso) :-
    requiere(Curso, Siguiente),
    alcanza(Siguiente, Curso, [Curso]).

alcanza(Objetivo, Objetivo, _).
alcanza(Actual, Objetivo, Visitados) :-
    requiere(Actual, Siguiente),
    (   Siguiente == Objetivo
    ;   \+ memberchk(Siguiente, Visitados),
        alcanza(Siguiente, Objetivo, [Siguiente|Visitados])
    ).

%% ---------------------------------------------------------------------------
%% Validacion de integridad
%% ---------------------------------------------------------------------------

%% validar_plan/0 imprime el resultado y falla si hay errores.
validar_plan :-
    validar_plan(Errores),
    (   Errores == []
    ->  writeln('Plan valido.')
    ;   writeln('Errores encontrados:'),
        forall(member(Error, Errores), format('  - ~w~n', [Error])),
        fail
    ).

%% validar_plan/1 devuelve la lista de errores (vacia si todo esta bien).
validar_plan(Errores) :-
    findall(Error, error_plan(Error), Errores).

error_plan(referencia_inexistente(Curso, Requisito)) :-
    requiere(Curso, Requisito),
    (   \+ es_curso(Curso)
    ;   \+ es_curso(Requisito)
    ).

error_plan(autoprerrequisito(Curso)) :-
    requiere(Curso, Curso).

error_plan(ciclo(Curso)) :-
    ciclo(Curso).

error_plan(optativa_sin_nucleo(Optativa)) :-
    optativas:es_optativa(Optativa),
    \+ tiene_prerequisito_nucleo(Optativa).

tiene_prerequisito_nucleo(Optativa) :-
    optativas:prerrequisito_optativa(Optativa, Requisito),
    plan:asignatura(Requisito, _, Anio, _, _, _, _, _, _),
    Anio >= 1.

error_plan(conteo_obligatorias(N)) :-
    findall(Curso, plan:obligatoria(Curso), Lista),
    length(Lista, N),
    N =\= 25.

error_plan(conteo_optativas(N)) :-
    findall(Optativa, optativas:es_optativa(Optativa), Lista),
    length(Lista, N),
    N =\= 15.

error_plan(conteo_cupos_optativas(N)) :-
    findall(Cupo, plan:cupo_optativa(_, _, Cupo), Lista),
    length(Lista, N),
    N =\= 2.
