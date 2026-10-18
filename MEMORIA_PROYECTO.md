# MEMORIA_PROYECTO.md — Conocimiento acumulado del proyecto Doc_nopCommerce

> **Archivo de conocimiento persistente** — Se actualiza con cada sesión relevante.
> Última actualización: 2026-10-17

> **Nota:** Para instrucciones genéricas de creación ver `AGENTS.md`.
> Este archivo contiene conocimiento específico del proyecto Doc_nopCommerce.

---

## 1. Naturaleza del proyecto

- **Tipo:** Manual de desarrollo profesional de nopCommerce para programadores
- **Título:** Manual de desarrollo V01 de nopCommerce
- **Idioma:** Español (nunca generar contenido en inglés)
- **Formato de salida:** Markdown estándar (GitHub, GitLab, Azure DevOps, VSCode, Obsidian, MkDocs, Docusaurus); destino futuro DOCX/PDF/EPUB3 vía fase KDP (fuera de alcance actual)
- **Versión de referencia:** nopCommerce 4.90.8 (04/09/2026), .NET 9, SQL Server
- **Fuente de verdad:** `Fuentes_nopCommerce.md` + código fuente oficial local
- **Repo de verificación:** `D:\Programacion\Proyectos_C#\nopCommerce_4.90.8_Source\nopCommerce`
- **nopCommerce 5.00:** solo beta (.NET 10); se menciona únicamente como advertencia, nunca como referencia

---

## 2. Estructura del documento (formato V01)

- 28 capítulos distribuidos en 7 partes + 3 apéndices
- Portada con metadatos y `## Índice general {#indice}` con 39 enlaces anclados
- Jerarquía: `# Parte ... {#parte-x}` → `## Capítulo N — Título {#capitulo-N}` → `### Sección` → `#### Subsección`
- Sin numeración de secciones (nada de `1.1`, `19.5`)
- Cada capítulo abre con su bloque de cabecera y cierra con `---`
- Imágenes en ficheros externos `img/*.png` (nunca base64 en el Markdown)
- Las referencias a otros capítulos usan «Capítulo N» sin número de sección

### 2.1 Formato de capítulo (template V01)

```markdown
## Capítulo N — Nombre {#capitulo-N}

[Descripción del capítulo en 1 frase, sin título repetido y sin blockquote]

**Parte Y — Nombre de la parte** · Nivel: [Básico|Intermedio|Avanzado]

Este capítulo cubre [qué se trata]. Sirve para [para qué sirve]. Los conceptos clave
incluyen [conceptos]. Prerrequisitos: [capítulos]. Caso de uso típico: [cuándo aplica].

**Trampas frecuentes:**

> - [Trampa]
> - [Trampa]

---

[Contenido del capítulo]
```

---

## 3. Estilo de redacción

1. Evitar «Se refiere a...» → definiciones directas
2. Listar elementos importantes (no usar «etc.»)
3. Voz activa, frases cortas, párrafos pequeños
4. Tercera persona del singular en toda la documentación (nunca segunda persona)
5. Afirmaciones negadas verificadas son válidas («No existe X en la 4.90.8») cuando el repo lo confirma
6. Todo dato técnico necesita fuente oficial; si no existe: «Información pendiente de documentar»

---

## 4. Metodología de verificación (aplicada y reutilizable)

- Toda afirmación se verifica contra el repo oficial 4.90.8 antes de escribirla
- Edición siempre por texto exacto localizado con grep; nunca por número de línea
- Cambios masivos por lotes de reglas con runner (`run_rules.ps1`) e informe OK/MISS por regla
- Detección de regresiones con `detect_post.ps1` (escapes, fences, base64, 2ª persona, términos obsoletos) y `scan_mechanical.ps1`
- Los `.ps1` requieren BOM UTF-8 (PowerShell 5.1); los here-strings NO incluyen el `\n` final antes de `'@`
- Documentos de trabajo (borradores, informes, scripts, checklists `find_0X.md`): `C:\Users\cesard\AppData\Local\Temp\opencode\rev_nop\`

---

## 5. Estado y entregables (tabla actualizada 2026-10-18)

| Entregable | Estado |
|---|---|
| `Fuentes_nopCommerce.md` | Completo: 5 secciones con fechas de consulta |
| `Manual de desarrollo V01 de nopCommerce.md` | Completo: 32 capítulos V01, 8 partes, 3 apéndices, índice (322.130 B, 5.781 líneas, LF sin BOM) |
| `publicacion/imprimir/Manual_NopCommerce_Del_Desarrollador.pdf` | Completo: interior KDP 7×10", 274 páginas, 1.239.906 B, 127 cajas overfull (123 de tabla ≤3 mm, 4 de texto ≤8,7 mm) |
| `publicacion/imprimir/Manual_NopCommerce_Del_Desarrollador.docx` | Completo: Word, 36 Heading2, 288 bookmarks, 14 imágenes |
| `publicacion/imprimir/Manual_NopCommerce_Del_Usuario.pdf` | Completo: interior 7×10", 516 páginas, 42.013.261 B, 708 imágenes, 21 cajas overfull (todas de tabla ≤2,8 mm) |
| `publicacion/imprimir/Manual_NopCommerce_Del_Usuario.docx` | Completo: Word, 61 Heading2, 699 imágenes |
| Hallazgos `find_01`…`find_06` (108) | 0 pendientes |
| Reglas de corrección aplicadas | 169 (27 A + 27 B + 64 C + 17 mine + 13 mine2 + 12 p7fix + 9 final) |
| PARTE VII (10 módulos) | Verificada contra el repo (≈200 afirmaciones, 12 hallazgos corregidos) |

### 5.1 Backups conservados (en `Doc_nopCommerce`)

| Fichero | Tamaño | Momento |
|---|---|---|
| `Manual … .bak.md` | 869.322 B | Original pre-V01 |
| `Manual … .pre-reglas.bak.md` | 877.026 B | Antes de las 148 reglas de corrección |
| `Manual … .pre-parte7.bak.md` | 241.997 B | Antes de integrar la PARTE VII |
| `Manual … .pre-indice.bak.md` | 300.886 B | Antes de portada e índice |

### 5.2 Pipeline de publicación PDF (7×10", track LaTeX de la colección)

Estructura (réplica de `javascript/` y hermanos): `cover.png` + `header_pdf.tex` en la raíz y
`publicacion/{script,imprimir,backups}`. El manual fuente **nunca se toca**: el build lee una
copia temporal `publicacion/imprimir/_build/manual_tmp.md` que prepara `preparar_fuente.py`
(bloque mermaid → imagen pre-renderizada con `npx @mermaid-js/mermaid-cli`; imágenes que desbordan
el ancho útil 5,1" acotadas con `{width=…}`; las que ya caben quedan intactas).

Comandos de reconstrucción: ver `ESTADO.md` (sección «Publicación KDP»). Resumen:
`preparar_fuente.py extraer-mermaid` → `mmdc` → `preparar_fuente.py preparar` →
`build_pdf_nopcommerce.ps1 -Libro publicacion/imprimir/_build/manual_tmp.md -Tecnología NopCommerce`.

Trampas resueltas (no re-descubrir):

- **ucharclasses envenena el texto**: sus transiciones cambian de fuente al entrar en una clase
  Unicode (flechas, dibujos de caja) y **no vuelven** a la fuente principal; el texto tras un «→»
  de prosa quedaba entero en Segoe UI Symbol (cabeceras y cuerpo de los capítulos 19+). Se sustituyó
  `header_pdf.tex` por uno local sin ucharclasses: el filtro Lua emite cada glifo ausente en Pagella
  como `RawInline {\symbolfont\char"2192}` **acotado a un grupo**. Los bloques de código no se tocan
  (DejaVu Sans Mono sí tiene `← ├ ─ │ ▼`; los árboles quedan alineados).
- **`\newunicodechar` rompe microtype**: «Argument of \MT@is@char has an extra }» en `\begin{document}`.
  Por eso la sustitución va en el filtro, no en LaTeX.
- **pandoc no numera sin `--number-sections`**: sin esa bandera sale `secnumdepth=-∞` y no hay
  «Capítulo 1.» ni números en la TOC. Con ella, book numera y el filtro retira las marcas
  duplicadas del manual («Capítulo N — », «Apéndice X — », «A.1 », «Parte N — »).
- **`# Parte` no puede borrarse**: el filtro de la colección borra TODOS los H1; aquí solo se borra
  el primero (título) y los demás van a `\part`. «Apéndices» usa `\part*` + `\addcontentsline` para
  no numerarse como «Parte VIII» y `\renewcommand{\chaptername}{Apéndice}` para «Apéndice A. …».
- **PS 5.1 + UTF-8**: `Get-Content` de `tecnologias.json` exige `-Encoding UTF8` (si no, el copyright
  sale con mojibake «trÃ³nico»); los `.ps1` nuevos requieren BOM UTF-8; y los avisos de stderr de
  xelatex (banner de actualización de MiKTeX) rompen el script con `$ErrorActionPreference='Stop'` —
  se ejecuta xelatex con EAP local `Continue` capturando la salida.
- El índice del manual es BulletList (no OrderedList) y se llama «Índice general»: el filtro debe
  saltarlo con `BulletList` y reconocer ambos títulos.
- La verificación automática del build (pypdf) cuenta páginas, calcula el gutter KDP por tramo
  (23 mm ≥ 12,7 mm para 274 pág.) y **mide** de verdad las cajas overfull hbox. Antes de corregir el
  patrón de búsqueda informaba «0» sin medir; el build de desarrollo actual da **127** (123 de tabla
  ≤3 mm y 4 de texto ≤8,7 mm), sin ninguna por encima de 20 mm.
- `pdftoppm` (MiKTeX) sirve para revisar páginas concretas del PDF como imagen.

---

## 6. Verificación de calidad (checklist por sesión)

### 6.1 Antes de dar por terminado un cambio

- [ ] `detect_post.ps1` limpio (0 escapes, 0 fences mal formados, 0 base64, 0 saltos de nivel, 0 2ª persona)
- [ ] 28 capítulos con `{#capitulo-N}`, 7 partes, 3 apéndices, índice con anclas válidas
- [ ] Em dash (U+2014) en títulos y «Parte · Nivel» (verificar por códigos de carácter, la consola los enmascara)
- [ ] Sin líneas en blanco dobles fuera de bloques de código
- [ ] Sin términos obsoletos (excepción: afirmaciones negadas verificadas «No existe X»)

### 6.2 Tras cada build (PDF 7×10")

- [ ] Build sin errores: pandoc + `xelatex` ×2 (el log no debe contener líneas `!`)
- [ ] `Overfull hbox: 0` y páginas dentro del tramo KDP (gutter 23 mm)
- [ ] Muestras visuales con `pdftoppm`: portada, copyright (sin mojibake), TOC numerada,
      una página de parte, una apertura de capítulo («Capítulo N.»), un árbol `├─│` alineado,
      una tabla con cabecera E8E8E8 y el apéndice A («A.1 …» sin duplicar numeración)
- [ ] Fuentes incrustadas (`pdffonts`: Pagella ×4, DejaVuSansMono ×3 y SegoeUISymbol solo para flechas)

---

## 7. Historial de cambios

| Fecha | Cambio | Motivo |
|---|---|---|
| 2026-10-17 | Interior PDF KDP 7×10" (252 págs): pipeline en `publicacion/` + `cover.png` | Aprobación del usuario (solo PDF) |
| 2026-10-17 | Reestructuración completa a V01: 28 capítulos, 7 partes, índice con anclas, PARTE VII | Plan v3 aprobado |
| 2026-10-17 | Resolución de los 108 hallazgos (`find_01`…`find_06`) | Corrección contra el repo 4.90.8 |
| 2026-10-17 | Creación de `Fuentes_nopCommerce.md` | Trazabilidad de fuentes |
| 2026-09-30 | Manual con resaltado manual a mano | Punto de partida |

---

## 8. Aprendizaje automático

### 8.1 Actualización del archivo

Este archivo se actualiza cuando:

1. Se detecta una nueva instrucción del usuario
2. Se corrige un error en el proceso
3. Se añade un patrón de contenido nuevo
4. Se verifica o resuelve una contradicción

### 8.2 Detección de contradicciones

Antes de añadir una instrucción: buscar instrucciones similares existentes, verificar que no contradiga otras y documentar la resolución.

---

## 9. Notas para futuras conversaciones

- **Verificar siempre** el estado actual antes de cambiar (grep por texto exacto)
- **No asumir** que un archivo está transformado sin comprobar con grep
- **Crear backup** antes de cada transformación importante
- **nopCommerce 4.90.8** es la única referencia válida salvo indicación explícita del usuario
- Hechos de API ya verificados (no re-descubrir): `GetWidgetViewComponent` devuelve `Type` (no existe `…NameAsync`); `QueuedEmailPriority` solo tiene `Low` y `High`; el campo real es `DontSendBeforeDateUtc`; `IThumbService` expone 6 miembros (`DeleteAllThumbsAsync` y `GetThumbsInfoAsync` están solo en la clase); la vista del plugin se copia con `PreserveNewest` (nunca `Copy always`)
- Errores de diagnóstico útiles: `ILogger` está en `Nop.Services.Logging` (no `Nop.Logging`); `RedisCacheManager` usa `IRedisConnectionWrapper`; `IDateTimeHelper` vive en `Nop.Services.Helpers`
