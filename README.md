# ARES — Academic Recommendation Expert System

Sistema experto en Prolog para recomendar asignaturas y planificar el avance académico de estudiantes de Ciencias de la Computación.

- **Plan base:** FaMAF–UNC, 29 espacios curriculares (`PlanEstudio.md`).
- **Estado:** Fase 0 completada (base de conocimiento). Fase 1 siguiente.
- **Roadmap completo:** [`Roadmap.md`](Roadmap.md).

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

## Cómo cargar la base de conocimiento

Desde la raíz del proyecto:

```prolog
?- use_module('kb/plan.pl').
?- use_module('kb/optativas.pl').
?- use_module('kb/perfiles.pl').
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
```

## Estructura

```
kb/
  plan.pl        Plan de estudios, correlatividades y predicados derivados.
  optativas.pl   Catálogo de 15 optativas con oferta y prerrequisitos.
  perfiles.pl    Perfiles de Ana, Beto y Carla.
core/            Motor de recomendación (fases 1–4).
ui/              Interfaz CLI y persistencia (fase 3).
tests/           Pruebas PLUnit (fases 1–5).
docs/            Informe y documentación (fase 5).
```

## Nota de instalación

La descarga desde `swi-prolog.org` estaba devolviendo error 502/503, por lo que se descargó el instalador oficial desde el release de GitHub (`SWI-Prolog/swipl-devel`, versión 10.1.20), se verificó su SHA-256 y se extrajo localmente en el directorio del usuario para evitar la elevación de privilegios (UAC). El ejecutable y las librerías funcionan correctamente.
