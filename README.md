# ARES — Academic Recommendation Expert System

Sistema experto en Prolog para recomendar asignaturas y planificar el avance académico de estudiantes de Ciencias de la Computación.

- **Plan base:** FaMAF–UNC, 29 espacios curriculares (`PlanEstudio.md`).
- **Estado:** Proyecto completo (fases 0–5); 151 pruebas PLUnit en verde.
- **Roadmap:** documento local de trabajo (no versionado).

## Requisitos

- **SWI-Prolog 10.x**

En este equipo se instaló **SWI-Prolog 10.1.20** en:

```
C:\Users\Lenovo\AppData\Local\Programs\SWI-Prolog
```

El directorio `bin` ya está agregado al `PATH` del usuario. Si `swipl` no se reconoce en una terminal abierta antes de la instalación, cerrarla y abrir una nueva. Como alternativa:

```powershell
$env:Path += ";C:\Users\Lenovo\AppData\Local\Programs\SWI-Prolog\bin"
swipl --version
```

## Cómo cargar el proyecto

Desde la raíz del proyecto:

```powershell
swipl load.pl
```

Eso carga la base de conocimiento y los módulos de `core/`. También se puede
cargar cada módulo por separado:

```prolog
?- use_module('kb/plan.pl').
?- use_module('kb/optativas.pl').
?- use_module('kb/perfiles.pl').
?- use_module('core/grafo.pl').
?- use_module('core/avance.pl').
?- use_module('core/elegibilidad.pl').
?- use_module('core/puntuacion.pl').
?- use_module('core/recomendador.pl').
?- use_module('core/explicaciones.pl').
?- use_module('core/optativas.pl').
?- use_module('core/trabajo_especial.pl').
?- use_module('core/planificador.pl').
?- use_module('core/what_if.pl').
?- use_module('core/riesgo.pl').
```

Consultas de ejemplo:

```prolog
% Todas las obligatorias del plan
?- plan:obligatoria(C).

% Prerrequisitos de una materia
?- plan:prerrequisito(aed2, P).

% Catálogo de optativas
?- optativas:optativa(Cod, Nombre, Area, Dif, Oferta, Requisitos).

% Materias aprobadas por un perfil
?- perfiles:aprobo(ana, C).

% Materias elegibles este cuatrimestre
?- elegibilidad:elegible(adrian, C).

% Qué desbloquea una materia
?- grafo:desbloquea(aed2, C).

% Avance del perfil
?- avance:avance(ana, Porcentaje).

% Puntaje de una materia
?- puntuacion:puntaje(adrian, aed2, Puntos).

% Recomendación para el cuatrimestre actual
?- recomendador:recomendar(adrian, Materias, Creditos).

% Por qué se recomienda una materia
?- explicaciones:por_que(adrian, aed2, Razones).
?- explicaciones:explicar(adrian, aed2, Texto).

% Par de optativas recomendado y área del Trabajo Especial
?- selector_optativas:recomendar_par(ana, Par).
?- trabajo_especial:area_trabajo_especial(ana, Area).

% Plan multsemestre hasta el egreso y carga de un cuatrimestre
?- planificador:plan_hasta_egreso(ana, Plan).
?- planificador:plan_cuatrimestre(ana, 5-1, Cursos).

% Escenarios hipotéticos sin tocar el perfil original
?- what_if:simular(carla, max_creditos(20), Plan).
?- what_if:simular(adrian, [max_creditos(25), aprobar(md2)], Plan).
?- what_if:comparar_planes(carla, max_creditos(20), Comparacion).

% Alertas, cuellos de botella y fecha estimada de egreso
?- riesgo:alertas(adrian, Alertas).
?- riesgo:cuello_botella(aed2).
?- riesgo:fecha_egreso(ana, Fecha).
```

Un escenario es un cambio o una lista de cambios:

| Cambio | Efecto |
|---|---|
| `max_creditos(N)` | Cambia el tope de créditos |
| `promedio(N)` | Cambia el promedio |
| `anio_actual(N)` / `cuatrimestre_actual(N)` | Reposiciona el avance |
| `aprobar(C)` / `desaprobar(C)` | Agrega o quita una aprobada |
| `cursar(C)` / `recursar(C)` | Marca la materia como en curso o recursada |
| `postergar(C)` | Quita `C` del estado (no aprobada ni en curso) |
| `interes(A)` / `agregar_interes(A)` / `sin_interes(A)` | Ajusta intereses |

`simular/3` clona el perfil en un átomo temporal, aplica los cambios, planifica y borra el clon. El perfil original queda intacto.

`comparar_planes/3` devuelve:

```prolog
comparacion(PlanBase, PlanAlternativo,
            duracion(PeriodosBase, PeriodosAlternativo),
            diferencia(Diferencia),
            materias_afectadas([...])).
```

Las alertas son:

| Alerta | Condición |
|---|---|
| `cuello_botella(C)` | `C` habilita directamente 3 o más cursos |
| `materia_critica_sin_aprobar(C)` | Cuello de botella que no se cursa en el primer período |
| `sobrecarga(Periodo, Creditos)` | Créditos del período > `max_creditos` |
| `riesgo_atraso(Perfil)` | Egreso proyectado más allá del año nominal + 1 |
| `conflicto_oferta(C)` | Materia elegible que el plan posterga |

## Uso de la interfaz

```powershell
swipl main.pl
```

El menú permite ver el perfil, el avance, la recomendación del cuatrimestre,
el par de optativas, la explicación de una materia, las alertas de riesgo con
la fecha estimada de egreso y la comparación de un escenario *what-if*.

En la opción `whatif` el escenario se escribe como término Prolog terminado en
punto, por ejemplo:

```prolog
max_creditos(20).
[max_creditos(25), aprobar(md2)].
```

La salida muestra el egreso base y el alternativo, la diferencia en períodos y
una tabla con las materias afectadas.

El menú también puede guardar y cargar perfiles como hechos Prolog en `datos/`:

```prolog
?- persistencia:guardar(ana).
?- persistencia:cargar(ana).
```

`datos/` no se versiona: son perfiles de trabajo del usuario.

## Pruebas

```powershell
swipl run_tests.pl
```

El script carga todos los módulos, descubre los archivos `tests/test_*.pl`
y ejecuta la suite PLUnit.

## Estructura

```
main.pl            Punto de entrada de la interfaz.
load.pl            Carga la base de conocimiento y los módulos de core/.
run_tests.pl       Ejecuta todas las pruebas PLUnit.
kb/
  plan.pl          Plan de estudios, correlatividades y predicados derivados.
  optativas.pl     Catálogo de 15 optativas con oferta y prerrequisitos.
  perfiles.pl      Perfiles de Ana, Adrian y Carla.
core/
  grafo.pl         Cierre transitivo, desbloqueo y validación del plan.
  avance.pl        Créditos, materias aprobadas y porcentaje de avance.
  elegibilidad.pl  Materias y optativas cursables por perfil.
  puntuacion.pl    Reglas de puntuación de materias (roadmap 8.2).
  recomendador.pl  Ranking y selección respetando la carga máxima.
  explicaciones.pl Razones y texto de cada recomendación.
  optativas.pl     Selección del par de optativas (módulo selector_optativas).
  trabajo_especial.pl Área sugerida para el Trabajo Especial.
  planificador.pl  Plan multsemestre hasta el egreso.
  what_if.pl       Simulación de escenarios y comparación de planes.
  riesgo.pl        Alertas, cuellos de botella y fecha de egreso.
ui/
  menu.pl          Menú interactivo.
  formato.pl       Tablas y textos de salida.
  persistencia.pl  Guardar y cargar perfiles en datos/.
tests/             Pruebas PLUnit (fases 1–5).
docs/              Informe, guion de exposición y diapositivas.
```

## Nota de instalación

La descarga desde `swi-prolog.org` estaba devolviendo error 502/503, por lo que se descargó el instalador oficial desde el release de GitHub (`SWI-Prolog/swipl-devel`, versión 10.1.20), se verificó su SHA-256 y se extrajo localmente en el directorio del usuario para evitar la elevación de privilegios (UAC). El ejecutable y las librerías funcionan correctamente.
