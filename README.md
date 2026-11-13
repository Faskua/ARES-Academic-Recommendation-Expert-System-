# ARES — Academic Recommendation Expert System

Sistema experto en Prolog para recomendar asignaturas y planificar el avance académico de estudiantes de Ciencias de la Computación.

- **Plan base:** FaMAF–UNC, 29 espacios curriculares (`PlanEstudio.md`).
- **Estado:** Fase 1 completada (grafo, avance y elegibilidad). Fase 2 siguiente.
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
```

## Pruebas

```powershell
swipl run_tests.pl
```

El script carga todos los módulos, descubre los archivos `tests/test_*.pl`
y ejecuta la suite PLUnit.

## Estructura

```
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
ui/                Interfaz CLI y persistencia (fase 3).
tests/             Pruebas PLUnit (fases 1–5).
docs/              Informe y documentación (fase 5).
```

## Nota de instalación

La descarga desde `swi-prolog.org` estaba devolviendo error 502/503, por lo que se descargó el instalador oficial desde el release de GitHub (`SWI-Prolog/swipl-devel`, versión 10.1.20), se verificó su SHA-256 y se extrajo localmente en el directorio del usuario para evitar la elevación de privilegios (UAC). El ejecutable y las librerías funcionan correctamente.
