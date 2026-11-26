# ARES — Guion de exposición

**Duración objetivo:** 10 minutos.  
**Demo:** CLI en vivo con los tres perfiles.

---

## Antes de empezar

1. Abrir una terminal en la raíz del proyecto.
2. Verificar la suite:

   ```powershell
   swipl run_tests.pl
   ```

   Debe terminar con `All 151 tests passed`.

3. Abrir la CLI con fuente grande:

   ```powershell
   swipl main.pl
   ```

4. Tener a mano este guion y una segunda terminal con las consultas de respaldo.

**Regla de oro:** si una opción del menú falla, no improvisar frente al público. Pasar a la consulta equivalente en la terminal de respaldo y seguir.

---

## Guion minuto a minuto

### 0:00–1:00 — Problema y propuesta

**Decir:**

> Un estudiante de Computación no solo necesita saber qué materias aprobó. Necesita decidir qué cursar, en qué orden, con qué carga y qué pasa si cambia de planes.
>
> ARES es un sistema experto en Prolog que recomienda materias, explica por qué, planifica hasta el egreso y compara escenarios.

**Mostrar:** diapositiva 1 y 2.

### 1:00–2:00 — Arquitectura

**Decir:**

> El sistema tiene tres capas: la base de conocimiento con el plan y las optativas, el motor con las reglas, y la interfaz.
>
> El plan es fijo; lo que se personaliza es la trayectoria.

**Mostrar:** diapositiva 3 (diagrama de capas) y 4 (módulos).

### 2:00–3:00 — Perfil y avance

**En la CLI:**

```text
Opcion: perfil.
Perfil: ana.
```

Salida esperada:

```text
Perfil ana: ano 5, cuatrimestre 1
Promedio: 8.5
Carga maxima: 30 creditos
Intereses: ia
```

Luego:

```text
Opcion: avance.
Perfil: ana.
```

Salida esperada:

```text
Avance de ana: 85.82%
Obligatorias aprobadas: 23 de 25
Optativas aprobadas: 0 de 2
```

**Decir:** Ana está al día; le quedan dos obligatorias, las optativas y el Trabajo Especial.

### 3:00–4:00 — Recomendación y explicación

```text
Opcion: recomendacion.
Perfil: ana.
```

Salida esperada:

```text
Recomendacion para ana
Materia  Puntaje  Creditos
is2      20       10
Total: 10 creditos
```

```text
Opcion: explicacion.
Perfil: ana.
Materia a explicar: is2.
```

Salida esperada:

```text
Por que is2 para ana:
  - esta en tu año y cuatrimestre nominal (año 5, cuatrimestre 1)
```

**Decir:** la explicación sale del mismo detalle que produce el puntaje, así nunca se contradicen.

### 4:00–5:00 — Optativas y Trabajo Especial

```text
Opcion: optativas.
Perfil: ana.
```

Salida esperada:

```text
Par de optativas para ana
Optativa  Nombre                     Area
IA-01     Aprendizaje Automático     ia
IA-03     Minería de Datos           ia
Puntaje del par: 40
```

**Decir:** el par respeta la oferta del cuatrimestre y los prerrequisitos. Como Ana se quiere especializar, el sistema premia que ambas sean de IA.

Si hay tiempo, consultar el área del Trabajo Especial en la terminal de respaldo:

```prolog
?- trabajo_especial:area_trabajo_especial(ana, Area).
Area = ia.
```

### 5:00–6:30 — Planificador

**En la terminal de respaldo:**

```prolog
?- planificador:plan_hasta_egreso(ana, Plan).
```

Salida esperada:

```prolog
Plan = [ periodo(5, 1, [is2, 'IA-01'], 20),
         periodo(5, 2, [compiladores, 'IA-02'], 20),
         anual(5, [trabajo_especial], 0) ].
```

**Decir:** Ana egresa en 5-2. El plan respeta oferta, prerrequisitos, tope de créditos, dos optativas y Trabajo Especial.

Mostrar el caso de Adrian:

```prolog
?- planificador:plan_hasta_egreso(adrian, Plan).
```

**Decir:** Adrian empieza con AED II sola por el tope de 20 créditos y su plan se estira a 7-1. La recursada es una inversión: desbloquea 20 materias.

### 6:30–8:00 — Alertas

**En la CLI:**

```text
Opcion: alertas.
Perfil: adrian.
```

Salida esperada (resumida):

```text
Riesgos de adrian
Egreso estimado: 7-1
Alertas:
  - Conflicto de oferta: md2 (Matemática Discreta II) es elegible pero el plan la posterga.
  - Cuello de botella: aed2 (Algoritmos y Estructuras de Datos II) desbloquea 3 o mas materias.
  ...
  - Riesgo de atraso: el egreso de adrian supera el ano nominal + 1.
```

Mostrar Ana:

```text
Opcion: alertas.
Perfil: ana.
```

Salida esperada:

```text
Riesgos de ana
Egreso estimado: 5-2
Sin alertas: el plan no muestra riesgos.
```

**Decir:** la ausencia de alertas también es información: el plan de Ana es consistente.

### 8:00–9:30 — What-if

**En la CLI:**

```text
Opcion: whatif.
Perfil: carla.
Escenario: max_creditos(20).
```

Salida esperada (resumida):

```text
Comparacion para carla: max_creditos(20)
Egreso estimado: base 7-1, alternativo 7-2
Periodos: base 9, alternativo 10 (+1 periodo(s))

Materias afectadas:
Materia  Nombre                               Base  Alternativo
md2      Matemática Discreta II               3-1   5-1
...
```

**Decir:** bajar la carga no es gratis: Carla posterga MD II y el egreso se corre un cuatrimestre. El perfil original no se modifica; el sistema clona el estado, simula y limpia.

Si el público pregunta por un escenario más ambicioso:

```text
Escenario: [max_creditos(25), aprobar(md2)].
```

### 9:30–10:00 — Pruebas y cierre

**Mostrar la terminal con la suite:**

```text
% All 151 tests passed
```

**Decir:**

> El sistema está cubierto por 151 pruebas: elegibilidad, puntajes, planes, *what-if*, alertas, formato y persistencia. La validación del grafo detecta ciclos y referencias inválidas.
>
> ARES no reemplaza al estudiante: le da una recomendación explicable, un plan y una forma de comparar decisiones.

**Cerrar con la diapositiva 12.**

---

## Frases de transición

- “Hasta acá, qué puede cursar. Ahora, qué le conviene.”
- “La recomendación es local; el plan es global.”
- “Un plan sin alertas es tan importante como un plan con alertas.”
- “No alcanza con recomendar: hay que mostrar el costo de la alternativa.”

---

## Plan de respaldo

Si la CLI se cuelga o una opción no responde, abrir otra terminal y usar consultas directas:

```prolog
?- recomendador:recomendar(ana, S, C).
?- explicaciones:explicar(ana, is2, T).
?- selector_optativas:recomendar_par(ana, P).
?- planificador:plan_hasta_egreso(ana, Plan).
?- riesgo:alertas(adrian, A).
?- what_if:comparar_planes(carla, max_creditos(20), C).
```

Si falla la carga del proyecto:

```powershell
swipl load.pl
```

y desde ahí ejecutar las consultas.

---

## Preguntas esperadas

**¿Por qué Prolog y no Python?**
Porque el problema es de reglas y relaciones: correlatividades, elegibilidad, desbloqueo. Prolog permite expresarlas de forma declarativa, explicarlas y explorar alternativas con retroceso.

**¿Las correlatividades son oficiales?**
No. Fueron reconstruidas a partir del orden del plan. Es el supuesto más importante y está documentado.

**¿El planificador garantiza el óptimo?**
No. Es greedy con retroceso sobre la optativa y un límite de períodos. Busca un plan válido y razonable, no el mínimo global.

**¿Qué pasa si el estudiante cambia de opinión?**
Se usa *what-if*: se clona el perfil, se aplica el cambio, se planifica y se compara. El perfil original queda intacto.

**¿Cómo se prueba?**
Con 151 pruebas PLUnit, más la validación del grafo. Los casos incluyen los tres perfiles, escenarios y condiciones de borde.

**¿Se puede usar con datos reales?**
Sí, reemplazando el plan y el catálogo de optativas. La arquitectura separa conocimiento de inferencia para facilitarlo.
