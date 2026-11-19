# ARES — Academic Recommendation Expert System

Sistema experto en Prolog para recomendar asignaturas y planificar el avance académico de estudiantes de Ciencias de la Computación.

- **Plan base:** FaMAF–UNC, 29 espacios curriculares (`PlanEstudio.md`).
- **Estado:** Fase 2 completada (obligatorias, optativas y Trabajo Especial). Fase 3 siguiente.
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
?- elegibilidad:elegible(beto, C).

% Qué desbloquea una materia
?- grafo:desbloquea(aed2, C).

% Avance del perfil
?- avance:avance(ana, Porcentaje).

% Puntaje de una materia
?- puntuacion:puntaje(beto, aed2, Puntos).

% Recomendación para el cuatrimestre actual
?- recomendador:recomendar(beto, Materias, Creditos).

% Por qué se recomienda una materia
?- explicaciones:por_que(beto, aed2, Razones).
?- explicaciones:explicar(beto, aed2, Texto).

% Par de optativas recomendado y área del Trabajo Especial
?- selector_optativas:recomendar_par(ana, Par).
?- trabajo_especial:area_trabajo_especial(ana, Area).
```

## Uso de la interfaz

```powershell
swipl main.pl
```

El menú permite ver el perfil, el avance, la recomendación del cuatrimestre,
el par de optativas y la explicación de una materia.

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
  perfiles.pl      Perfiles de Ana, Beto y Carla.
core/
  grafo.pl         Cierre transitivo, desbloqueo y validación del plan.
  avance.pl        Créditos, materias aprobadas y porcentaje de avance.
  elegibilidad.pl  Materias y optativas cursables por perfil.
  puntuacion.pl    Reglas de puntuación de materias (roadmap 8.2).
  recomendador.pl  Ranking y selección respetando la carga máxima.
  explicaciones.pl Razones y texto de cada recomendación.
  optativas.pl     Selección del par de optativas (módulo selector_optativas).
  trabajo_especial.pl Área sugerida para el Trabajo Especial.
ui/
  menu.pl          Menú interactivo.
  formato.pl       Tablas y textos de salida.
tests/             Pruebas PLUnit (fases 1–5).
docs/              Informe y documentación (fase 5).
```

## Nota de instalación

La descarga desde `swi-prolog.org` estaba devolviendo error 502/503, por lo que se descargó el instalador oficial desde el release de GitHub (`SWI-Prolog/swipl-devel`, versión 10.1.20), se verificó su SHA-256 y se extrajo localmente en el directorio del usuario para evitar la elevación de privilegios (UAC). El ejecutable y las librerías funcionan correctamente.
