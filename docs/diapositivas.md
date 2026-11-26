# ARES — Diapositivas

**12 diapositivas** para una exposición de 10 minutos.  
Sugerencia visual: fondo claro, una sola idea por diapositiva, código en fuente monoespaciada.

---

## 1. Título

**ARES**  
Academic Recommendation Expert System

Sistema experto en Prolog para recomendar asignaturas y planificar el avance académico.

- FaMAF–UNC · Ciencias de la Computación
- Noviembre de 2026

> Nota: incluir nombres de los integrantes y materia.

---

## 2. El problema

Un estudiante sabe qué aprobó, pero no siempre sabe:

- qué le conviene cursar;
- en qué orden;
- con qué carga;
- qué optativas elegir;
- cuándo va a egresar;
- qué pasa si cambia de planes.

**Idea:** el plan es fijo; la trayectoria no.

---

## 3. Propuesta

ARES responde cinco preguntas:

1. ¿Qué puedo cursar?
2. ¿Qué me conviene priorizar?
3. ¿Qué optativas y qué Trabajo Especial?
4. ¿Cuándo egreso y qué riesgos tengo?
5. ¿Qué pasa si cambio algo?

**Salida:** recomendación + explicación + plan + comparación + alertas.

---

## 4. Arquitectura

```
main.pl
  └── ui/        menú, formato, persistencia
        │
        ▼
      core/      reglas, recomendación, planificación
        │
        ▼
      kb/        plan, optativas, perfiles
```

- `kb/`: hechos del dominio.
- `core/`: inferencia sin entrada/salida.
- `ui/`: interacción y archivos.

**Ventaja:** el motor se prueba sin pasar por el menú.

---

## 5. Base de conocimiento

| Elemento | Cantidad |
|---|---:|
| Asignaturas | 27 |
| Obligatorias | 25 |
| Correlatividades | 24 |
| Optativas simuladas | 15 |
| Créditos totales | 282 |
| Cursos en el grafo | 42 |

Cada materia registra año, cuatrimestre, créditos, horas, área y dificultad.

> Aclarar: correlatividades reconstruidas, no oficiales.

---

## 6. Elegibilidad y puntuación

**Elegible:** año ≤ actual, oferta del cuatrimestre, prerrequisitos aprobados, no aprobada ni en curso.

**Puntaje:**

| Puntos | Regla |
|---:|---|
| +40 | Desbloquea ≥ 3 materias |
| +25 | Desbloquea 1–2 materias |
| +20 | Año/cuatrimestre nominal |
| +15 | Requisito de un año posterior |
| +10 | Afinidad con intereses |
| +10 | Materia liviana con carga exigente |
| −15 | Dificultad alta y promedio bajo |
| −20 | Excede la carga máxima |
| +30 | Recursada |

**Ejemplo:** Adrian + AED II = **90 puntos**.

---

## 7. Recomendación explicable

```
adrian/aed2 = 90
  +40 desbloquea 20 materias
  +20 materia nominal
  +15 requisito de ia
  −15 dificultad 4 con promedio 6.5
  +30 recursada
```

Selección greedy que se repuntúa con los créditos ya comprometidos.

| Perfil | Recomendación |
|---|---|
| Ana | `is2` (10 cr) |
| Adrian | `aed2` (15 cr) |
| Carla | `aed2 + md2` (25 cr) |

**La explicación usa el mismo detalle que el puntaje.**

---

## 8. Optativas y Trabajo Especial

Reglas del par:

- +15 por afinidad;
- −10 por dificultad alta con promedio bajo;
- +10 por composición según objetivo;
- +10 por cadena de prerrequisitos;
- −15 por dificultad total alta.

Ana → `['IA-01', 'IA-03']` (40 puntos)  
Área del Trabajo Especial → **IA**

**El sistema no elige solo materias: elige una dirección.**

---

## 9. Planificador multsemestre

Estado simulado:

```
estado(Anio, Cuatrimestre, Aprobadas, Cursando, Optativas, Te)
```

Cada período:

1. prepara el Trabajo Especial;
2. selecciona obligatorias por puntaje;
3. agrega como máximo una optativa;
4. avanza de cuatrimestre.

La optativa es un punto de retroceso. Límite: 24 períodos.

| Perfil | Egreso |
|---|---|
| Ana | 5-2 |
| Adrian | 7-1 |
| Carla | 7-1 |

---

## 10. What-if y alertas

**What-if:** clona el perfil con `gensym/2`, aplica el escenario, planifica y limpia con `setup_call_cleanup/3`.

```
Comparacion para carla: max_creditos(20)
Egreso: base 7-1 → alternativo 7-2
Diferencia: +1 período
Afectadas: md2, lfc, redes, ingles, SW-01/02/03
```

**Alertas:** cuello de botella, materia crítica, sobrecarga, riesgo de atraso, conflicto de oferta.

Ana: sin alertas.  
Adrian: 13 alertas.  
Carla: 14 alertas.

---

## 11. Pruebas y resultados

**151 pruebas PLUnit en verde.**

| Área | Pruebas |
|---|---:|
| Puntuación | 24 |
| Optativas | 16 |
| Avance / elegibilidad | 28 |
| Grafo | 11 |
| Planificador | 9 |
| What-if / riesgo | 23 |
| Resto | 40 |

Validación del grafo: **0 errores**.

**Hallazgo:** dos defectos en las pruebas se detectaron y corrigieron durante el cierre.

---

## 12. Conclusiones

- Prolog expresa naturalmente reglas, relaciones y alternativas.
- La separación `kb/` · `core/` · `ui/` hace el sistema testeable y explicable.
- El valor está en el conjunto: recomendación, plan, escenarios y alertas.
- Con datos oficiales, el mismo motor puede usarse en producción.

**El plan es fijo. La trayectoria se decide.**

¿Preguntas?

---

## Apéndice A — Demo (si se proyecta en vivo)

```text
Opcion: perfil.          → ana
Opcion: avance.          → 85.82 %
Opcion: recomendacion.   → is2
Opcion: explicacion.     → is2
Opcion: optativas.       → IA-01, IA-03
Opcion: alertas.         → adrian
Opcion: whatif.          → carla, max_creditos(20)
```

Respaldo:

```prolog
?- planificador:plan_hasta_egreso(ana, P).
?- riesgo:alertas(adrian, A).
?- what_if:comparar_planes(carla, max_creditos(20), C).
```

---

## Apéndice B — Frases clave

- “El plan es fijo; la trayectoria no.”
- “La recomendación es local; el plan es global.”
- “La explicación sale del mismo puntaje.”
- “Bajar la carga tiene un costo: el sistema lo muestra.”
- “No alcanza con recomendar: hay que comparar.”
