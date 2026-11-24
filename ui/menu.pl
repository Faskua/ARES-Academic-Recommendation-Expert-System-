%% ARES - Menu de la interfaz de linea de comandos
%%
%% Uso:
%%   swipl main.pl
%%
%% El menu trabaja sobre los tres perfiles de demostracion y delega en
%% los modulos de core/: avance, recomendador, puntuacion, selector de
%% optativas, explicaciones, riesgo y what-if.

:- module(menu, [
    menu/0,
    opciones/1,
    ejecutar/1
]).

:- use_module('formato.pl').
:- use_module('persistencia.pl').
:- use_module(library(lists)).

%% ---------------------------------------------------------------------------
%% Opciones
%% ---------------------------------------------------------------------------

opciones([
    perfil-'Ver datos del perfil',
    avance-'Ver avance academico',
    recomendacion-'Recomendar materias del cuatrimestre',
    optativas-'Recomendar par de optativas',
    explicacion-'Explicar una materia',
    alertas-'Ver alertas y fecha de egreso',
    whatif-'Comparar un escenario what-if',
    guardar-'Guardar el perfil actual',
    cargar-'Cargar un perfil guardado',
    salir-'Salir'
]).

%% ---------------------------------------------------------------------------
%% Bucle principal
%% ---------------------------------------------------------------------------

menu :-
    writeln(''),
    writeln('=== ARES - Recomendacion academica ==='),
    perfiles_disponibles,
    repetir.

perfiles_disponibles :-
    findall(Perfil, perfiles:estudiante(Perfil), Encontrados),
    sort(Encontrados, Perfiles),
    formato:lista(Perfiles, Texto),
    format('Perfiles disponibles: ~w~n', [Texto]).

repetir :-
    writeln(''),
    opciones(Opciones),
    forall(member(Clave-Descripcion, Opciones),
           format('  ~w) ~w~n', [Clave, Descripcion])),
    write('Opcion: '),
    flush_output,
    read(Opcion),
    (   ( Opcion == salir ; Opcion == end_of_file )
    ->  writeln('Hasta luego.')
    ;   (   ejecutar(Opcion)
        ->  true
        ;   writeln('Opcion invalida.')
        ),
        repetir
    ).

%% ---------------------------------------------------------------------------
%% Acciones
%% ---------------------------------------------------------------------------

ejecutar(perfil) :-
    con_perfil(mostrar_perfil).
ejecutar(avance) :-
    con_perfil(mostrar_avance).
ejecutar(recomendacion) :-
    con_perfil(mostrar_recomendacion).
ejecutar(optativas) :-
    con_perfil(mostrar_optativas).
ejecutar(explicacion) :-
    con_perfil(mostrar_explicacion).
ejecutar(alertas) :-
    con_perfil(mostrar_alertas).
ejecutar(whatif) :-
    con_perfil(mostrar_what_if).
ejecutar(guardar) :-
    con_perfil(mostrar_guardado).
ejecutar(cargar) :-
    cargar_perfil.

con_perfil(Objetivo) :-
    write('Perfil: '),
    flush_output,
    read(Perfil),
    (   perfiles:estudiante(Perfil)
    ->  call(Objetivo, Perfil)
    ;   writeln('Perfil desconocido.')
    ).

%% ---------------------------------------------------------------------------
%% Vistas
%% ---------------------------------------------------------------------------

mostrar_perfil(Perfil) :-
    perfiles:anio_actual(Perfil, Anio),
    perfiles:cuatrimestre_actual(Perfil, Cuatrimestre),
    perfiles:promedio(Perfil, Promedio),
    perfiles:max_creditos(Perfil, Maximo),
    findall(Interes, perfiles:interes(Perfil, Interes), Intereses),
    formato:lista(Intereses, InteresesTexto),
    formato:creditos(Maximo, MaximoTexto),
    format('~nPerfil ~w: ano ~w, cuatrimestre ~w~n',
           [Perfil, Anio, Cuatrimestre]),
    format('Promedio: ~w~n', [Promedio]),
    format('Carga maxima: ~w~n', [MaximoTexto]),
    format('Intereses: ~w~n', [InteresesTexto]).

mostrar_avance(Perfil) :-
    avance:avance(Perfil, Porcentaje),
    avance:obligatorias_aprobadas(Perfil, Obligatorias),
    avance:optativas_aprobadas(Perfil, Optativas),
    formato:porcentaje(Porcentaje, PorcentajeTexto),
    format('~nAvance de ~w: ~w~n', [Perfil, PorcentajeTexto]),
    format('Obligatorias aprobadas: ~w de 25~n', [Obligatorias]),
    format('Optativas aprobadas: ~w de 2~n', [Optativas]).

mostrar_recomendacion(Perfil) :-
    recomendador:recomendar(Perfil, Seleccion, Creditos),
    findall([Curso, Puntaje, CreditosCurso],
            ( member(Curso, Seleccion),
              puntuacion:puntaje(Perfil, Curso, Puntaje),
              puntuacion:creditos_de(Curso, CreditosCurso)
            ),
            Filas),
    formato:tabla(['Materia', 'Puntaje', 'Creditos'], Filas, Tabla),
    formato:creditos(Creditos, CreditosTexto),
    format('~nRecomendacion para ~w~n~w~n', [Perfil, Tabla]),
    format('Total: ~w~n', [CreditosTexto]).

mostrar_optativas(Perfil) :-
    (   selector_optativas:recomendar_par(Perfil, [O1, O2])
    ->  selector_optativas:puntaje_par(Perfil, O1, O2, Puntaje),
        findall([Optativa, Nombre, Area],
                ( member(Optativa, [O1, O2]),
                  optativas:optativa(Optativa, Nombre, Area, _, _, _)
                ),
                Filas),
        formato:tabla(['Optativa', 'Nombre', 'Area'], Filas, Tabla),
        format('~nPar de optativas para ~w~n~w~n', [Perfil, Tabla]),
        format('Puntaje del par: ~w~n', [Puntaje])
    ;   format('~n~w no tiene optativas elegibles en este cuatrimestre.~n',
               [Perfil])
    ).

mostrar_explicacion(Perfil) :-
    write('Materia a explicar: '),
    flush_output,
    read(Curso),
    (   explicaciones:por_que(Perfil, Curso, Razones),
        Razones \= []
    ->  (   perfiles:aprobo(Perfil, Curso)
        ->  format('~nNota: ~w ya figura aprobada por ~w.~n', [Curso, Perfil])
        ;   true
        ),
        format('~nPor que ~w para ~w:~n', [Curso, Perfil]),
        forall(member(Razon, Razones),
               ( explicaciones:texto(Razon, Texto),
                 format('  - ~w~n', [Texto])
               ))
    ;   format('~nNo hay informacion para ~w.~n', [Curso])
    ).

mostrar_alertas(Perfil) :-
    riesgo:fecha_egreso(Perfil, Fecha),
    riesgo:alertas(Perfil, Alertas),
    formato_fecha(Fecha, FechaTexto),
    format('~nRiesgos de ~w~n', [Perfil]),
    format('Egreso estimado: ~w~n', [FechaTexto]),
    (   Alertas == []
    ->  writeln('Sin alertas: el plan no muestra riesgos.')
    ;   writeln('Alertas:'),
        forall(member(Alerta, Alertas),
               ( alerta_texto(Alerta, Texto),
                 format('  - ~w~n', [Texto])
               ))
    ).

mostrar_what_if(Perfil) :-
    writeln(''),
    writeln('Escenarios disponibles:'),
    writeln('  max_creditos(N), promedio(N), aprobar(C), desaprobar(C),'),
    writeln('  cursar(C), recursar(C), postergar(C), interes(A),'),
    writeln('  agregar_interes(A), sin_interes(A)'),
    writeln('  Tambien una lista: [max_creditos(25), aprobar(md2)]'),
    write('Escenario: '),
    flush_output,
    read(Escenario),
    (   what_if:comparar_planes(Perfil, Escenario, Comparacion)
    ->  mostrar_comparacion(Perfil, Escenario, Comparacion)
    ;   writeln('Escenario invalido o no planificable.')
    ).

mostrar_comparacion(Perfil, Escenario,
                    comparacion(Base, Alternativo,
                                duracion(DuracionBase, DuracionAlternativa),
                                diferencia(Diferencia),
                                materias_afectadas(Afectadas))) :-
    format('~nComparacion para ~w: ~w~n', [Perfil, Escenario]),
    periodo_final(Base, EgresoBase),
    periodo_final(Alternativo, EgresoAlternativo),
    format('Egreso estimado: base ~w, alternativo ~w~n',
           [EgresoBase, EgresoAlternativo]),
    texto_diferencia(Diferencia, DiferenciaTexto),
    format('Periodos: base ~w, alternativo ~w (~w)~n',
           [DuracionBase, DuracionAlternativa, DiferenciaTexto]),
    mostrar_afectadas(Base, Alternativo, Afectadas).

mostrar_afectadas(_, _, []) :-
    !,
    writeln('Materias afectadas: ninguna.').
mostrar_afectadas(Base, Alternativo, Afectadas) :-
    findall([Curso, Nombre, PeriodoBase, PeriodoAlternativo],
            ( member(Curso, Afectadas),
              nombre_curso(Curso, Nombre),
              periodo_texto(Base, Curso, PeriodoBase),
              periodo_texto(Alternativo, Curso, PeriodoAlternativo)
            ),
            Filas),
    formato:tabla(['Materia', 'Nombre', 'Base', 'Alternativo'], Filas, Tabla),
    format('~nMaterias afectadas:~n~w~n', [Tabla]).

alerta_texto(cuello_botella(Curso), Texto) :-
    nombre_curso(Curso, Nombre),
    format(atom(Texto),
           'Cuello de botella: ~w (~w) desbloquea 3 o mas materias.',
           [Curso, Nombre]).
alerta_texto(materia_critica_sin_aprobar(Curso), Texto) :-
    nombre_curso(Curso, Nombre),
    format(atom(Texto),
           'Materia critica sin aprobar: ~w (~w) no entra en el primer periodo.',
           [Curso, Nombre]).
alerta_texto(sobrecarga(Periodo, Creditos), Texto) :-
    formato_fecha(Periodo, PeriodoTexto),
    format(atom(Texto), 'Sobrecarga en ~w: ~w creditos.',
           [PeriodoTexto, Creditos]).
alerta_texto(riesgo_atraso(Perfil), Texto) :-
    format(atom(Texto),
           'Riesgo de atraso: el egreso de ~w supera el ano nominal + 1.',
           [Perfil]).
alerta_texto(conflicto_oferta(Curso), Texto) :-
    nombre_curso(Curso, Nombre),
    format(atom(Texto),
           'Conflicto de oferta: ~w (~w) es elegible pero el plan la posterga.',
           [Curso, Nombre]).
alerta_texto(Alerta, Texto) :-
    format(atom(Texto), '~w', [Alerta]).

texto_diferencia(0, 'sin cambios') :- !.
texto_diferencia(Diferencia, Texto) :-
    Diferencia > 0,
    !,
    format(atom(Texto), '+~w periodo(s)', [Diferencia]).
texto_diferencia(Diferencia, Texto) :-
    format(atom(Texto), '~w periodo(s)', [Diferencia]).

periodo_final(Plan, Texto) :-
    findall(Anio-Cuatrimestre,
            member(periodo(Anio, Cuatrimestre, _, _), Plan),
            Fechas),
    (   Fechas == []
    ->  Texto = '-'
    ;   last(Fechas, Anio-Cuatrimestre),
        formato_fecha(Anio-Cuatrimestre, Texto)
    ).

periodo_texto(Plan, Curso, Texto) :-
    (   periodos_de_curso(Plan, Curso, [Anio-Cuatrimestre|_])
    ->  formato_fecha(Anio-Cuatrimestre, Texto)
    ;   Texto = '-'
    ).

periodos_de_curso(Plan, Curso, Fechas) :-
    findall(Anio-Cuatrimestre,
            ( member(periodo(Anio, Cuatrimestre, Cursos, _), Plan),
              memberchk(Curso, Cursos)
            ),
            Fechas).

formato_fecha(Anio-Cuatrimestre, Texto) :-
    format(atom(Texto), '~w-~w', [Anio, Cuatrimestre]).

nombre_curso(Curso, Nombre) :-
    (   plan:asignatura(Curso, Nombre, _, _, _, _, _, _, _)
    ->  true
    ;   optativas:optativa(Curso, Nombre, _, _, _, _)
    ->  true
    ;   Nombre = Curso
    ).

mostrar_guardado(Perfil) :-
    persistencia:guardar(Perfil),
    persistencia:archivo_perfil(Perfil, Archivo),
    format('~nPerfil ~w guardado en ~w~n', [Perfil, Archivo]).

cargar_perfil :-
    write('Nombre del perfil guardado: '),
    flush_output,
    read(Nombre),
    (   persistencia:cargar(Nombre)
    ->  format('~nPerfil ~w cargado.~n', [Nombre]),
        perfiles_disponibles
    ;   format('~nNo hay un perfil guardado con ese nombre.~n', [])
    ).
