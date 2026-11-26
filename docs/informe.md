# ARES — Informe técnico

**Academic Recommendation Expert System**  
Sistema experto en Prolog para recomendar asignaturas y planificar el avance académico de estudiantes de Ciencias de la Computación.

- **Plan base:** FaMAF–UNC, 29 espacios curriculares (`PlanEstudio.md`).
- **Implementación:** SWI-Prolog 10.1.20.
- **Estado:** fases 0 a 4 completas; 151 pruebas PLUnit en verde.
- **Fecha:** noviembre de 2026.

---

## 1. Resumen

ARES recomienda qué materias cursar, en qué orden y con qué carga, a partir del plan oficial de la carrera y de la situación real de cada estudiante. El sistema no modifica la malla: personaliza la trayectoria dentro de ella.

El resultado es un motor declarativo con cinco capacidades:

1. **Elegibilidad:** qué materias puede cursar un perfil en su cuatrimestre.
2. **Puntuación:** un ranking explicable de las materias elegibles.
3. **Recomendación:** una selección que respeta la carga máxima.
4. **Planificación:** un plan multsemestre hasta el egreso.
5. **Análisis:** escenarios *what-if* y alertas de riesgo.

Todo se ejecuta desde una CLI en SWI-Prolog y se valida con una suite PLUnit.

---

## 2. Objetivo y alcance

### 2.1 Objetivo

Construir un sistema experto que responda, para un estudiante concreto:

- ¿Qué puedo cursar este cuatrimestre?
- ¿Qué me conviene priorizar y por qué?
- ¿Qué optativas elegir y qué área darle al Trabajo Especial?
- ¿Cuándo voy a egresar y qué riesgos tengo?
- ¿Qué pasa si cambio el tope de créditos, postergo una materia o apruebo otra?

### 2.2 Alcance

**Incluido:**

- Plan de estudios FaMAF–UNC como base fija.
- Tres perfiles de demostración con situaciones distintas.
- Catálogo simulado de 15 optativas.
- Recomendación, explicaciones, planificación, *what-if* y alertas.
- CLI interactiva y persistencia de perfiles en archivos Prolog.

**Excluido:**

- Inscripción real, fechas de exámenes y calendario administrativo.
- Historial académico real o integración con sistemas de la facultad.
- Notas parciales, correlatividades oficiales detalladas y cupos reales.
- Interfaz web o aplicación móvil.

---

## 3. Supuestos

Los supuestos están explicitados porque afectan las conclusiones del sistema.

| Supuesto | Detalle |
|---|---|
| Plan fijo | La malla y la carga horaria provienen de `PlanEstudio.md`; ARES no crea materias nuevas. |
| Correlatividades reconstruidas | Las 24 relaciones `prerrequisito/2` se derivaron del orden del plan. **No son las oficiales.** |
| Catálogo de optativas simulado | Las 15 optativas son plausibles y coherentes con las áreas, pero no son la oferta oficial de FaMAF. |
| Créditos homogéneos | Todas las optativas otorgan 10 créditos. |
| Períodos académicos | La fecha de egreso se expresa como `Año-Cuatrimestre`, no como fecha calendario. |
| Aprobación completa | Una materia aprobada libera todos sus correlativos; no se modelan cursadas parciales ni finales pendientes. |
| Perfiles de demostración | Ana, Adrian y Carla son casos de prueba, no estudiantes reales. |

---

## 4. Arquitectura

### 4.1 Capas

```
main.pl
  └── ui/menu.pl ──────────────► ui/formato.pl
        │                        ui/persistencia.pl ──► datos/perfil_*.pl
        ▼
      core/ (motor)
        │
        ▼
      kb/ (base de conocimiento)
```

- **`kb/`**: hechos del dominio. Sin lógica de decisión.
- **`core/`**: reglas, inferencia y planificación. Sin entrada/salida interactiva.
- **`ui/`**: menú, formato y persistencia.
- **`tests/`**: suite PLUnit descubierta por `run_tests.pl`.

La separación permite probar el motor sin pasar por el menú y reutilizar los módulos desde consultas directas.

### 4.2 Módulos

| Módulo | Archivo | Responsabilidad | Predicados principales |
|---|---|---|---|
| `plan` | `kb/plan.pl` | Asignaturas, correlatividades, créditos y áreas | `asignatura/9`, `prerrequisito/2`, `obligatoria/1` |
| `optativas` | `kb/optativas.pl` | Catálogo simulado y cadenas | `optativa/6`, `cadena/2`, `creditos_optativa/1` |
| `perfiles` | `kb/perfiles.pl` | Estado dinámico de cada estudiante | `aprobo/2`, `cursa/2`, `recursa/2`, `max_creditos/2` |
| `grafo` | `core/grafo.pl` | Grafo unificado y validación | `requiere/2`, `desbloquea/2`, `validar_plan/1` |
| `avance` | `core/avance.pl` | Créditos, ítems y porcentaje | `avance/2`, `creditos_totales/1` |
| `elegibilidad` | `core/elegibilidad.pl` | Qué se puede cursar | `elegible/2`, `elegible_optativa/2`, `puede_trabajo_especial/1` |
| `puntuacion` | `core/puntuacion.pl` | Reglas de puntaje y detalle | `puntaje/3`, `detalle/3`, `regla/5` |
| `recomendador` | `core/recomendador.pl` | Ranking y selección greedy | `recomendar/3`, `seleccionar_hasta/3` |
| `explicaciones` | `core/explicaciones.pl` | Razones en texto | `por_que/3`, `explicar/3` |
| `selector_optativas` | `core/optativas.pl` | Mejor par de optativas | `recomendar_par/2`, `puntaje_par/4` |
| `trabajo_especial` | `core/trabajo_especial.pl` | Área sugerida del Trabajo Especial | `area_trabajo_especial/2` |
| `planificador` | `core/planificador.pl` | Plan multsemestre con backtracking | `plan_hasta_egreso/2`, `plan_cuatrimestre/3` |
| `what_if` | `core/what_if.pl` | Simulación y comparación de escenarios | `simular/3`, `comparar_planes/3` |
| `riesgo` | `core/riesgo.pl` | Fecha de egreso y alertas | `alertas/2`, `cuello_botella/1`, `fecha_egreso/2` |
| `menu` | `ui/menu.pl` | CLI interactiva | `menu/0`, `opciones/1`, `ejecutar/1` |
| `formato` | `ui/formato.pl` | Tablas y valores formateados | `tabla/3`, `porcentaje/2`, `lista/2` |
| `persistencia` | `ui/persistencia.pl` | Guardar y cargar perfiles | `guardar/1`, `cargar/1`, `listar/1` |

### 4.3 Dependencias

```
plan ◄── optativas ◄── perfiles
  ▲          ▲            ▲
  └──── grafo ────────────┘
         ▲
   elegibilidad ──► puntuacion ──► recomendador ──► explicaciones
         ▲               ▲
         │               └──────► selector_optativas ──► trabajo_especial
         │
     planificador ──► what_if
         └──────────► riesgo
```

`load.pl` carga todos los módulos en el orden correcto. `main.pl` solo carga `load.pl` y arranca `menu:menu`.

---

## 5. Base de conocimiento

### 5.1 Plan de estudios

- **27 asignaturas** en `asignatura/9`: nivelación, 25 obligatorias y Trabajo Especial.
- **24 correlatividades** reconstruidas.
- **282 créditos totales**, incluyendo nivelación, obligatorias, 2 cupos de optativas y Trabajo Especial.
- **2 cupos de optativas**, en 5.º año, 1.er y 2.º cuatrimestre.
- **Trabajo Especial** anual, habilitado en 5.º año con 20 obligatorias aprobadas.

Cada asignatura registra año, cuatrimestre, créditos, horas semanales, horas totales, área y dificultad (1 a 5). Esa información alimenta la elegibilidad, el puntaje y la planificación.

### 5.2 Optativas

15 optativas simuladas en cinco áreas:

| Área | Optativas |
|---|---|
| IA | `IA-01`, `IA-02`, `IA-03` |
| Sistemas | `SIS-01`, `SIS-02`, `SIS-03` |
| Software | `SW-01`, `SW-02`, `SW-03` |
| Teoría | `TEO-01`, `TEO-02`, `TEO-03` |
| Científica | `INV-01`, `INV-02`, `INV-03` |

Cada una tiene dificultad, oferta (`i` o `ii`) y prerrequisitos. Las cadenas, como `IA-01 → IA-02`, permiten premiar una secuencia coherente.

### 5.3 Perfiles

| Perfil | Año/Cuat. | Situación | Promedio | Máx. créditos | Intereses | Objetivo |
|---|---|---|---|---|---|---|
| **Ana** | 5-1 | Al día; 23 obligatorias aprobadas | 8.5 | 30 | IA | Especializarse |
| **Adrian** | 3-1 | Recursa AED II; trabaja 30 hs/sem | 6.5 | 20 | Sistemas | Graduarse |
| **Carla** | 3-1 | Atrasada; recursa AED II y Probabilidad | 7.0 | 25 | Datos, Software | Equilibrar |

Los hechos de `perfiles` son dinámicos: la CLI puede cargar un perfil guardado y el *what-if* puede clonarlo sin alterar el original.

---

## 6. Motor de inferencia

### 6.1 Grafo de correlatividades

`core/grafo.pl` unifica los prerrequisitos del plan con los de las optativas y ofrece consultas en dos direcciones:

```prolog
?- grafo:requiere(aed2, aed1).
?- grafo:desbloquea(aed1, C).
?- grafo:prerrequisito_transitivo(compiladores, R).
```

`validar_plan/1` detecta cursos inexistentes, ciclos y referencias inválidas. Resultado actual: **válido, 0 errores** sobre 42 cursos (27 asignaturas + 15 optativas).

### 6.2 Elegibilidad

Una obligatoria es elegible si:

1. pertenece al plan y su año nominal no supera el año actual;
2. se dicta en el cuatrimestre actual;
3. no está aprobada ni en curso;
4. todos sus prerrequisitos están aprobados.

Una optativa es elegible desde 4.º año, si su oferta coincide con el cuatrimestre y sus prerrequisitos están aprobados. El Trabajo Especial requiere 5.º año y 20 obligatorias aprobadas.

### 6.3 Puntuación

Cada regla aporta puntos y una razón. El puntaje es la suma de las reglas aplicables:

| Puntos | Condición |
|---:|---|
| +40 | Desbloquea 3 o más materias pendientes |
| +25 | Desbloquea 1 o 2 materias pendientes |
| +20 | Está en el año y cuatrimestre nominal |
| +15 | Es prerrequisito directo de una materia de un año posterior |
| +10 | Coincide con un interés del perfil |
| +10 | Es liviana (dificultad ≤ 2) y la carga ya es exigente |
| −15 | Dificultad ≥ 4 con promedio < 7 |
| −20 | Supera la carga máxima |
| +30 | Es una materia que el perfil recursa |

Ejemplos reales:

```text
adrian/aed2 = 90
  +40 desbloquea 20 materias
  +20 materia nominal (2.º año, 1.er cuatrimestre)
  +15 requisito directo de ia
  −15 dificultad 4 con promedio 6.5
  +30 recursada

carla/aed2 = 105   (sin la penalización por promedio)
carla/md2  = 75    (+40 desbloquea 6, +20 nominal, +15 requisito de lfc)
```

El detalle se reutiliza tal cual en `explicaciones:por_que/3`, de modo que la explicación nunca se desincroniza del puntaje.

### 6.4 Recomendador

`recomendar/3` ordena las elegibles y elige de forma greedy. En cada paso vuelve a puntuar los candidatos con los créditos ya comprometidos, para que entren en juego:

- el tope de carga;
- el bonus por materias livianas;
- la penalización por exceder el máximo.

La selección resultante:

| Perfil | Recomendación | Créditos |
|---|---|---:|
| Ana | `[is2]` | 10 |
| Adrian | `[aed2]` | 15 |
| Carla | `[aed2, md2]` | 25 |

### 6.5 Optativas y Trabajo Especial

El par de optativas se puntúa con:

- +15 por optativa afín a los intereses;
- −10 por dificultad alta con promedio bajo;
- +10 si comparten área y el objetivo es especializarse;
- +10 si son de áreas distintas y el objetivo es equilibrar;
- +10 si una es prerrequisito de la otra;
- −15 si la dificultad total es alta y el promedio es bajo.

Para Ana, el mejor par es `['IA-01', 'IA-03']` con 40 puntos. El área sugerida para su Trabajo Especial es **IA**: se pondera el área de las optativas aprobadas o, si no hay, la del par recomendado, con un extra si coincide con sus intereses.

### 6.6 Planificador multsemestre

El planificador mantiene un estado simulado:

```prolog
estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, Te)
```

En cada período:

1. prepara el Trabajo Especial si el perfil ya está habilitado;
2. detecta si egresó (sin obligatorias pendientes, 2 optativas y TE);
3. selecciona obligatorias elegibles por puntaje hasta el tope;
4. agrega como máximo una optativa si queda carga;
5. avanza al cuatrimestre siguiente.

La optativa es un **punto de retroceso**: si la elección no permite cerrar el plan, Prolog prueba la siguiente. Un límite de 24 períodos evita la explosión combinatoria. El plan se devuelve como:

```prolog
periodo(5, 1, [is2, 'IA-01'], 20)
anual(5, [trabajo_especial], 0)
```

### 6.7 What-if

`simular/3` clona el perfil en un átomo temporal con `gensym/2`, aplica los cambios y planifica. `setup_call_cleanup/3` garantiza que el clon se borre aunque la planificación falle.

Escenarios soportados:

```prolog
max_creditos(20)
promedio(8.0)
aprobar(md2)
desaprobar(ia)
cursar(prob)
recursar(aed2)
postergar(md2)
interes(software)
agregar_interes(datos)
sin_interes(ia)
```

También acepta listas: `[max_creditos(25), aprobar(md2)]`.

`comparar_planes/3` devuelve:

```prolog
comparacion(Base, Alternativo,
            duracion(PeriodosBase, PeriodosAlternativo),
            diferencia(D),
            materias_afectadas([...]))
```

### 6.8 Alertas y fecha de egreso

| Alerta | Condición |
|---|---|
| `cuello_botella(C)` | `C` habilita directamente 3 o más cursos |
| `materia_critica_sin_aprobar(C)` | Cuello de botella que no entra en el primer período |
| `sobrecarga(Periodo, Creditos)` | Créditos del período > `max_creditos` |
| `riesgo_atraso(Perfil)` | Egreso proyectado > año nominal + 1 |
| `conflicto_oferta(C)` | Materia elegible que el plan posterga |

Las alertas se calculan sobre el plan proyectado, se ordenan y se deduplican. `fecha_egreso/2` devuelve el último período del plan.

---

## 7. Interfaz y persistencia

El menú (`ui/menu.pl`) ofrece:

| Opción | Acción |
|---|---|
| `perfil` | Datos del perfil |
| `avance` | Créditos, obligatorias, optativas y porcentaje |
| `recomendacion` | Materias recomendadas con puntaje y créditos |
| `optativas` | Par recomendado con nombre y área |
| `explicacion` | Razones de una materia |
| `alertas` | Alertas y fecha estimada de egreso |
| `whatif` | Comparación contra un escenario |
| `guardar` / `cargar` | Persistencia en `datos/` |
| `salir` | Fin de la sesión |

La persistencia guarda hechos Prolog legibles en `datos/perfil_<nombre>.pl`. `datos/` está ignorado por Git: son archivos de trabajo del usuario. En Windows, el borrado reintenta para tolerar bloqueos transitorios del antivirus o del indexador.

---

## 8. Pruebas

### 8.1 Ejecución

```powershell
swipl run_tests.pl
```

`run_tests.pl` carga `load.pl`, descubre `tests/test_*.pl` y ejecuta PLUnit.

### 8.2 Cobertura

**151 pruebas en verde**, sin warnings:

| Unidad | Pruebas |
|---|---:|
| `avance` | 14 |
| `elegibilidad` | 14 |
| `explicaciones` | 9 |
| `formato` | 7 |
| `grafo` | 11 |
| `menu` | 2 |
| `persistencia` | 6 |
| `planificador` | 9 |
| `puntuacion` | 24 |
| `recomendador` | 10 |
| `riesgo` | 13 |
| `selector_optativas` | 16 |
| `trabajo_especial` | 6 |
| `what_if` | 10 |
| **Total** | **151** |

Las pruebas cubren:

- valores exactos de créditos, avance y elegibilidad para los tres perfiles;
- puntajes y explicaciones;
- selección de optativas y área del Trabajo Especial;
- planes completos, tope de créditos, prerrequisitos y Trabajo Especial;
- *what-if* sin mutar el perfil original y comparación de escenarios;
- alertas, cuellos de botella y fecha de egreso;
- formato de tablas y persistencia.

### 8.3 Hallazgo durante el cierre

Al revisar la suite se detectaron dos defectos de las propias pruebas:

1. un `\\+` en `tests/test_optativas.pl` que impedía registrar una prueba;
2. un conflicto de importación en `tests/test_formato.pl` entre `plan:creditos/2` y `formato:creditos/2`.

Ambos se corrigieron. La suite pasó de 150 a **151 pruebas**, ahora sin errores de carga ni advertencias.

---

## 9. Resultados

### 9.1 Avance

| Perfil | Créditos | Avance | Obligatorias | Optativas | Ítems |
|---|---:|---:|---:|---:|---:|
| Ana | 242 / 282 | 85.82 % | 23 / 25 | 0 / 2 | 23 / 28 |
| Adrian | 112 / 282 | 39.72 % | 10 / 25 | 0 / 2 | 10 / 28 |
| Carla | 102 / 282 | 36.17 % | 9 / 25 | 0 / 2 | 9 / 28 |

### 9.2 Planes proyectados

**Ana — egreso en 5-2**

```prolog
periodo(5, 1, [is2, 'IA-01'], 20)
periodo(5, 2, [compiladores, 'IA-02'], 20)
anual(5, [trabajo_especial], 0)
```

**Adrian — egreso en 7-1**

```prolog
periodo(3, 1, [aed2], 15)
periodo(3, 2, [so, bd], 20)
periodo(4, 1, [paradigmas, redes], 20)
periodo(4, 2, [is1, logica], 20)
periodo(5, 1, [md2, ia], 20)
periodo(5, 2, [arq, sociedad], 20)
periodo(6, 1, [lfc, ingles], 15)
periodo(6, 2, [compiladores, 'SIS-03'], 20)
periodo(7, 1, [is2, 'SIS-01'], 20)
anual(6, [trabajo_especial], 0)
```

**Carla — egreso en 7-1**

```prolog
periodo(3, 1, [aed2, md2], 25)
periodo(3, 2, [prob, so], 20)
periodo(4, 1, [paradigmas, lfc, ingles], 25)
periodo(4, 2, [is1, bd], 20)
periodo(5, 1, [redes, ia], 20)
periodo(5, 2, [logica, sociedad], 20)
periodo(6, 1, [is2, 'SW-03'], 20)
periodo(6, 2, [compiladores, arq], 20)
periodo(7, 1, ['SW-01'], 10)
anual(5, [trabajo_especial], 0)
```

### 9.3 Alertas

| Perfil | Egreso | Alertas |
|---|---|---|
| Ana | 5-2 | Ninguna |
| Adrian | 7-1 | 13: 6 cuellos, 5 materias críticas, `conflicto_oferta(md2)`, `riesgo_atraso` |
| Carla | 7-1 | 14: 7 cuellos, 6 materias críticas, `riesgo_atraso` |

En Adrian se destaca `cuello_botella(aed2)`: recursarla temprano desbloquea 20 materias. En Carla, `cuello_botella(prob)` y la carga máxima de 25 créditos explican su atraso.

### 9.4 Escenario *what-if*

Comparación de Carla con tope de 20 créditos:

```prolog
?- what_if:comparar_planes(carla, max_creditos(20), C).
```

| Aspecto | Base (25 créditos) | Alternativo (20 créditos) |
|---|---|---|
| Egreso | 7-1 | 7-2 |
| Períodos | 9 | 10 |
| Diferencia | — | +1 período |
| Materias afectadas | — | `SW-01`, `SW-02`, `SW-03`, `ingles`, `lfc`, `md2`, `redes` |

El sistema muestra el costo de bajar la carga: MD II se posterga de 3-1 a 5-1 y el egreso se corre un cuatrimestre.

---

## 10. Limitaciones

1. **Correlatividades no oficiales.** Fueron reconstruidas; un cambio en ellas altera todos los planes.
2. **Catálogo de optativas simulado.** No representa la oferta real ni los cupos.
3. **Selección greedy.** No garantiza el óptimo global, aunque el retroceso del planificador mitiga el problema.
4. **Sin fechas calendario.** El egreso se expresa en cuatrimestres académicos.
5. **Sin cursadas parciales.** No se modelan finales pendientes, desaprobados ni equivalencias.
6. **Tres perfiles.** Los casos cubren situaciones distintas, pero no reemplazan una validación con estudiantes reales.
7. **Estado global dinámico.** Los perfiles viven en el módulo `perfiles`; no hay concurrencia ni transacciones.

---

## 11. Trabajo futuro

- Reemplazar las correlatividades por las oficiales de FaMAF.
- Cargar la oferta real de optativas por cuatrimestre.
- Modelar finales pendientes y materias desaprobadas.
- Incorporar fechas calendario y ventanas de inscripción.
- Optimizar el planificador con búsqueda best-first o programación dinámica.
- Agregar más perfiles y validar con datos reales.
- Exportar el plan a CSV o PDF.
- Integrar el motor en una interfaz web.

---

## 12. Conclusiones

ARES demuestra que Prolog es adecuado para un problema académico con reglas, excepciones y decisiones condicionadas por el contexto. La separación entre conocimiento (`kb/`), inferencia (`core/`) e interfaz (`ui/`) mantiene el sistema legible, testeable y explicable.

El valor principal no está en una única recomendación, sino en el conjunto:

- una recomendación justificada,
- un plan completo,
- una comparación de escenarios,
- y alertas que anticipan problemas.

La suite de 151 pruebas y la validación del grafo dan una base sólida para defender el diseño y para extenderlo con datos oficiales.

---

## 13. Referencias

- `PlanEstudio.md` — plan de estudios FaMAF–UNC.
- `Roadmap.md` — documento local de planificación y registro de decisiones (no versionado).
- SWI-Prolog 10.x — <https://www.swi-prolog.org/>.
- Documentación de PLUnit — <https://www.swi-prolog.org/pldoc/package/plunit.html>.
- Documentación de `library(lists)` — <https://www.swi-prolog.org/pldoc/man?section=lists>.

---

## Apéndice A — Comandos

```powershell
# Cargar el proyecto
swipl load.pl

# Ejecutar la CLI
swipl main.pl

# Ejecutar la suite
swipl run_tests.pl
```

```prolog
% Elegibilidad y recomendación
?- elegibilidad:elegible(adrian, C).
?- recomendador:recomendar(adrian, Materias, Creditos).

% Explicación
?- explicaciones:explicar(adrian, aed2, Texto).

% Optativas y Trabajo Especial
?- selector_optativas:recomendar_par(ana, Par).
?- trabajo_especial:area_trabajo_especial(ana, Area).

% Planificación
?- planificador:plan_hasta_egreso(ana, Plan).
?- planificador:plan_cuatrimestre(ana, 5-1, Cursos).

% What-if
?- what_if:simular(carla, max_creditos(20), Plan).
?- what_if:comparar_planes(carla, max_creditos(20), Comparacion).

% Riesgo
?- riesgo:fecha_egreso(ana, Fecha).
?- riesgo:alertas(adrian, Alertas).
?- riesgo:cuello_botella(aed2).
```
