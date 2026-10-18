# ESTADO.md — Proyecto Doc_nopCommerce

> **Estado del proyecto a 2026-10-18.** La fuente de verdad del conocimiento es `MEMORIA_PROYECTO.md`;
> este fichero refleja el estado operativo y los próximos pasos.

## Estado global

**Dos manuales completos.** (1) El manual de desarrollo (plan v3, Fases 1-7) está cerrado y verificado
contra el código fuente de nopCommerce 4.90.8; genera PDF (interior KDP) y DOCX. (2) El **manual de
usuario** (V01, 57 capítulos en 12 partes + 3 apéndices) está completo, **con las 708 capturas oficiales
de `nopCommerce-Docs` incrustadas** en los capítulos, y genera PDF (516 pp) y DOCX, para uso personal
/no comercial.

**Ampliación 2026-10-18 (manual de desarrollo).** Se añadieron una **Parte I — Conceptos esenciales
(recordatorio)** con 3 capítulos de fichas —concepto general → clase/interfaz de nopCommerce→ enlace—
y el **Capítulo 12** de profundidad sobre *Carga de ensamblados (.dll) y descubrimiento de plugins en
runtime*. Los 28 capítulos previos se renumeraron: ahora hay **32 capítulos en 8 partes**. Se
regeneraron y verificaron las 106 referencias cruzadas, las anclas `{#capitulo-N}` y el índice (44
enlaces); PDF (274 pp) y DOCX reconstruidos. El dato de las fichas —`BaseEntity`, `IRepository<T>`,
`INopStartup`, `*ModelFactory`, gestores de caché, `IStoreContext`/`IWorkContext`, `GenericAttribute`,
`StandardPermission`— se verificó contra el código fuente de nopCommerce 4.90.8.

**Corrección del filtro de build (2026-10-18).** `filtro_libro_nopcommerce.lua` borraba el índice
estático con una bandera que se cerraba al ver la **primera** lista; como pandoc recorre las listas
anidadas **de dentro hacia fuera**, al añadir la Parte I al índice solo se eliminó su lista anidada
y el resto se filtró al PDF (índice duplicado). Ahora la zona se cierra en el **siguiente
encabezado** y se borran todas sus listas: PDF sin duplicado (274 pp) y TOC de LaTeX completa
con los 32 capítulos y las 8 partes.

## Entregables

| Fichero | Estado | Notas |
|---|---|---|
| `Manual de desarrollo V01 de nopCommerce.md` | **Completo** | 322.130 B · 5.781 líneas (LF, sin BOM) · 32 capítulos V01 · 8 partes · 3 apéndices · portada e índice con 44 enlaces |
| `publicacion/imprimir/Manual_NopCommerce_Del_Desarrollador.pdf` | **Completo** | Interior KDP 7×10": 274 páginas · 1.239.906 B · track LaTeX (pandoc + xelatex) · gutter 23 mm · 127 cajas overfull (123 de tabla ≤3 mm; 4 de texto ≤8,7 mm; ver §Hallazgo de desbordamiento) |
| `Manual de usuario V01 de nopCommerce.md` | **Completo** | 241.610 B · 57 capítulos V01 · 12 partes · 3 apéndices · índice con 72 enlaces · **708 capturas oficiales incrustadas** (`img/usuario/`) · uso personal/no comercial |
| `publicacion/imprimir/Manual_NopCommerce_Del_Usuario.pdf` | **Completo** | Interior 7×10": 516 páginas · 42.013.261 B · 708 imágenes XObject · track LaTeX propio · 21 cajas overfull, todas de tabla (≤2,8 mm), ninguna de texto · copyright de uso personal con atribución a nop Solutions Ltd · sin ISBN |
| `publicacion/imprimir/Manual_NopCommerce_Del_Usuario.docx` | **Completo** | Word vía pandoc + reference · 35.844.675 B · 699 imágenes incrustadas · 61 Heading2 · índice interno clicable (72 enlaces) |
| `publicacion/imprimir/Manual_NopCommerce_Del_Desarrollador.docx` | **Completo** | Word del manual de desarrollo vía pandoc + reference · 602.813 B · 14 imágenes · 36 Heading2 · índice interno clicable (288 bookmarks) |
| `img/usuario/` | **Completo** | 699 capturas oficiales descargadas de `nopCommerce-Docs` (`_static/`), con atribución |
| `cover.png` | **Completo** | Portada 2100×3000 px (7×10" @300 dpi), plantilla de la colección |
| `publicacion/script/` | **Completo** | Pipeline PDF: `build_pdf_nopcommerce.ps1`, `build_pdf_usuario_nopcommerce.ps1`, `build_docx_nopcommerce.ps1` (Word de ambos manuales), `filtro_libro_nopcommerce.lua`, `preparar_fuente.py`, `generar_portada.py`, `tecnologias.json` (entradas NOPCOMMERCE y NOPCOMMERCE_USUARIO), `header_libro.tex`, `header_usuario.tex`, `fuentes_libro.tex`, `emoji.lua`, `backup_fuente.ps1`, `fonts/` |
| `Fuentes_nopCommerce.md` | **Completo** | 5 secciones (Advertencias + A-D) con fechas de consulta; 37 enlaces oficiales |
| `MEMORIA_PROYECTO.md` | **Actualizado** | Conocimiento persistente del proyecto (reescrito 2026-10-17) |
| `ESTADO.md` | **Este fichero** | Estado operativo |
| `Como escribir un widget para nopCommerce.docx` | Fuente secundaria | Binario de referencia, sin cambios |

## Ejecución del plan v3

| Fase | Resultado |
|---|---|
| 1. Registro de fuentes | `Fuentes_nopCommerce.md` |
| 2. Preparación | Renombrado a V01 + 4 respaldos |
| 3. Correcciones | 169 reglas aplicadas (148 + 12 p7fix + 9 final), informe OK/MISS 100% |
| 4. Reestructuración | 28 capítulos con anclas, cabeceras V01, imágenes externas en `img/` (14 ficheros) |
| 5. Ampliación | PARTE VII integrada (capítulos 19-28, verificada ≈200 afirmaciones) + portada e índice |
| 6. Memoria | `MEMORIA_PROYECTO.md` reescrito |
| 7. Cierre | Revisión por bloques (skill `revisar-documentos`), checklist final, snapshot `MEMORIA_GLOBAL.md` |

## Hallazgos

- Checklists de origen: `find_01.md` … `find_06.md` (152 iniciales → **108 tras descartes y deduplicación**).
- Estado: **0 pendientes**. Resueltos con las tandas A (27), B (27), C (64), mine (17), mine2 (13),
  p7fix (12) y final (9); los descartados quedan justificados en los propios checklists
  (falsos positivos, desviaciones justificadas o texto ya correcto por convergencia).
- Verificación final: `detect_post.ps1` y `scan_mechanical.ps1` limpios salvo falsos positivos
  documentados (1 línea de prosa que empieza por «namespace»; rutas Windows con guion bajo).
- Revision final (Fase 2 del skill, 2026-10-17): 14/14 bloques leidos; el informe fase2_informe.md recogio
  3 ERROR, 11 INCONSISTENCIA y 2 MEJORA (0 sin verificar). Los 16 hallazgos quedan corregidos
  (23 reglas rules_fase2.ps1 + fix_trees_fase2.ps1 para los dos arboles de directorios) y
  detect_post vuelve a quedar limpio.

## Respaldo y recuperación

| Fichero | Tamaño | Momento |
|---|---|---|
| `Manual … .bak.md` | 869.322 B | Original pre-V01 |
| `Manual … .pre-reglas.bak.md` | 877.026 B | Antes de las 148 reglas de corrección |
| `Manual … .pre-parte7.bak.md` | 241.997 B | Antes de integrar la PARTE VII |
| `Manual … .pre-indice.bak.md` | 300.886 B | Antes de portada e índice |

Los respaldos se conservan deliberadamente. Para volver a un estado anterior, restaurar el
fichero correspondiente como `Manual de desarrollo V01 de nopCommerce.md`.

## Publicación KDP (interior PDF)

El interior PDF **está generado y verificado** (`publicacion/imprimir/Manual_NopCommerce_Del_Desarrollador.pdf`,
274 páginas · 1.239.906 B). Reproduce el track LaTeX de la colección (`MaquetaciónLibroGlobal.md`):
mismas tipografías (TeX Gyre Pagella + DejaVu Sans Mono), mismos márgenes 7×10" (gutter 23 mm) y
misma plantilla de build.

Secuencia de reconstrucción (el manual original no se modifica nunca; el build trabaja sobre una
copia temporal en `publicacion/imprimir/_build/`):

```powershell
# 1) Copia temporal con el bloque mermaid sustituido por imagen y anchos acotados
python publicacion/script/preparar_fuente.py extraer-mermaid 'Manual de desarrollo V01 de nopCommerce.md' 'publicacion/imprimir/_build/mermaid_miniaturas.mmd'
npx -y @mermaid-js/mermaid-cli -i publicacion/imprimir/_build/mermaid_miniaturas.mmd -o publicacion/imprimir/_build/mermaid_miniaturas.png -b white -s 2
python publicacion/script/preparar_fuente.py preparar 'Manual de desarrollo V01 de nopCommerce.md' 'publicacion/imprimir/_build/manual_tmp.md' 'publicacion/imprimir/_build/mermaid_miniaturas.png'
# 2) Build LaTeX (pandoc + xelatex ×2 + verificación de páginas/gutter con pypdf)
powershell -NoProfile -ExecutionPolicy Bypass -File publicacion/script/build_pdf_nopcommerce.ps1 -Libro 'publicacion/imprimir/_build/manual_tmp.md' -Tecnología NopCommerce
# 3) Portada (solo si hay que regenerarla)
python publicacion/script/generar_portada.py cover.png
```

Adaptaciones propias respecto a la colección (detalladas en `MEMORIA_PROYECTO.md`):

- `filtro_libro_nopcommerce.lua`: mapea `# Parte` → `\part` (con las marcas «Parte N — » retiradas),
  `# Apéndices` → `\part*` + `\appendix`, y retira la marca «Capítulo N — »/«Apéndice X — »/«A.1 »
  para que book numere (`Capítulo 1. Visión general`, `Apéndice A. Recursos y referencias`).
- `header_pdf.tex` **sin ucharclasses ni `\newunicodechar`** (rompen texto/microtype): las flechas
  «→» de prosa se sustituyen en el filtro con `\symbolfont` acotado; los bloques de código usan
  DejaVu Sans Mono, que sí incluye flechas y dibujos de caja (árboles alineados).
- `--number-sections` activo: numeración canónica de capítulos y secciones en cuerpo y TOC.

Verificaciones superadas: fuentes incrustadas, TOC numerada, partes centradas, copyright sin
mojibake, apéndices A/B/C, `├─│←` alineados en código, figura mermaid (Figura 15) y 10 imágenes
acotadas al ancho útil. El recuento de cajas overfull se describe en el apartado siguiente.

## Hallazgo de desbordamiento (overfull)

Corregido el 2026-10-18 un **bug de medición** en `build_pdf_nopcommerce.ps1`: el patrón de
`Select-String` era `"Overfull \\\\hbox"` (cuatro barras), una expresión que no puede coincidir
nunca, de modo que **el build informaba siempre de «0 overfull» sin medir nada**. El patrón
correcto es `-SimpleMatch -Pattern 'Overfull \hbox'`; el script del manual de usuario ya era
correcto.

Con la medición real, el interior del manual de desarrollo acumulaba **175 cajas overfull**:

| Tipo | Cantidad | Máximo | Efecto |
|---|---|---|---|
| Tabla (`in alignment`) | 123 | 3,0 mm | Desborde mínimo; el contenido queda dentro de la página |
| Texto (`in paragraph`) | 52 | 125,0 mm | **21 líneas desbordan más de 20 mm** |

**Causa**: rutas de archivo largas compuestas en DejaVu Sans Mono dentro de prosa, por ejemplo
`Presentation/Nop.Web.Framework/Infrastructure/Extensions/ApplicationBuilderExtensions.cs`. La
monoespaciada no admite quiebres, de modo que la línea se desbordaba hacia el margen y **quedaba
recortada en el borde de la página** (verificado con `pdftoppm`, sección «28.6 Fuentes verificadas»).
Era un defecto **preexistente en la fuente**, no introducido por el renombrado de entregables.

### Corrección aplicada (2026-10-18)

Se intervino **solo** el filtro `publicacion/script/filtro_libro_nopcommerce.lua`; se descartó
tocar el `\XeTeXinterchartoks` global (reeflowearía todo el libro) y `header_libro.tex`. El filtro
añade dos elementos:

- **`Code()`**: los spans de código de 25 caracteres o más que contienen `/`, `.`, `_` o `-` se
  rehacen en segmentos `\texttt{…}` separados por `\allowbreak{}`.
- **`Str()`**: el mismo particionado se aplica a los tokens de **texto plano** de esa longitud.
  Es imprescindible porque las rutas de las celdas de tabla (`Views/Home/Index.cshtml`) se escriben
  sin acentos en la fuente y no son spans de código.

Dos detalles no obvios de la implementación:

- El `{}` de `\allowbreak{}` es obligatorio. Sin él, TeX leería `\allowbreakProduct` como **un
  único control sequence indefinido** al ir seguido de texto plano (en prosa no fallaba porque lo
  que venía después era `\texttt{`, y la llave cortaba la lectura).
- El umbral de 25 caracteres acota el alcance: solo se tocan tokens largos, de modo que la
  maquetación del resto del libro queda intacta.

### Resultado tras la corrección

Ambos interiores se reconstruyeron por completo:

| Interior | Páginas | Cajas overfull | De texto | Desborde máx. | >20 mm |
|---|---|---|---|---|---|
| Desarrollo | 274 (antes 272) | 127 (antes 175) | 4 (antes 52) | 8,7 mm (antes 125,0) | **0** (antes 21) |
| Usuario | 516 | 21 | 0 | 2,8 mm (tabla) | **0** |

En el peor caso la línea llega a 166,5 mm sobre los 177,8 mm de la hoja: quedan **11,3 mm** hasta el
borde, de modo que **ninguna línea sale de la página**. (El build solo verifica automáticamente el
gutter interior; este margen exterior se ha medido a partir de la geometría `paperwidth=7in`,
`outer=20mm`, `inner=23mm`.)

TOC verificada contra la página impresa: **32/32** capítulos en el de desarrollo y **60/60** en el de
usuario (desfazue de front matter = 6 en ambos).

> **Importante**: corregir el defecto alteró la paginación, como se anticipaba. El interior de
> desarrollo pasa de **272 a 274 páginas**; todas las cifras de este documento y de
> `MEMORIA_PROYECTO.md` están actualizadas a ese valor.

Verificación visual con `pdftoppm`: la ruta
`Presentation/Nop.Web.Framework/Infrastructure/Extensions/ApplicationBuilderExtensions.cs` parte
ahora a la segunda línea en lugar de cortarse en el margen.

## Próximos pasos (fuera del alcance actual)

1. Cubierta KDP full-wrap (con `ensamblar_cubierta.py` de la colección) cuando se cierre el lomo
   con las 274 páginas. **(Solo aplica al manual de desarrollo; el manual de usuario es de uso
   personal y no se publica.)**
2. Manual de usuario de nopCommerce: **COMPLETADO** (57 capítulos, **con las 708 capturas oficiales
   incrustadas**, PDF 516 pp y DOCX). Word del manual de desarrollo también generado.
   Actualizado cuando exista una versión estable de nopCommerce 5.00 (.NET 10).
3. Actualización de ambos manuales cuando exista una versión estable de nopCommerce 5.00 (.NET 10).

## Árbol de publicación

```
Doc_nopCommerce/
├── cover.png                      Portada 2100×3000 (7×10" @300 dpi)
├── header_pdf.tex                 fontspec + fuente de respaldo (sin ucharclasses)
└── publicacion/
    ├── backups/                   Respaldos automáticos del fuente (backup_fuente.ps1)
    ├── imprimir/
    │   ├── Manual_NopCommerce_Del_Desarrollador.pdf   ENTREGABLE: interior 274 págs
    │   ├── Manual_NopCommerce_Del_Desarrollador.docx  ENTREGABLE: Word (36 Heading2)
    │   ├── Manual_NopCommerce_Del_Desarrollador.tex/.log/.toc/.aux   Artefactos del build
    │   ├── Manual_NopCommerce_Del_Usuario.pdf         ENTREGABLE: interior 516 págs
    │   ├── Manual_NopCommerce_Del_Usuario.docx        ENTREGABLE: Word (61 Heading2)
    │   ├── Manual_NopCommerce_Del_Usuario_Libro.tex/.log/.toc/.aux   Artefactos del build
    │   ├── copyright_generado.tex / copyright_usuario_generado.tex   Copyright (generados)
    │   ├── reference_usuario.docx       Plantilla de referencia de los DOCX
    │   └── _build/                Copia temporal y assets: manual_tmp.md (regenerable),
    │                              mermaid_miniaturas.mmd/.png y utilidades de verificación
    └── script/
        ├── build_pdf_nopcommerce.ps1      Build solo-PDF (pandoc + xelatex ×2)
        ├── filtro_libro_nopcommerce.lua   Filtro del libro (partes, capítulos, apéndices)
        ├── preparar_fuente.py             Copia temporal: mermaid + anchos de imagen
        ├── generar_portada.py             cover.png (plantilla de la colección)
        ├── tecnologias.json               Textos del VOLUMEN IV (entrada NOPCOMMERCE)
        ├── header_libro.tex / fuentes_libro.tex / emoji.lua / backup_fuente.ps1
        └── fonts/                 TeX Gyre Pagella + DejaVu Sans Mono
```

## Ámbito excluido

`html5/`, `CSS3/`, `javascript/`, `webApi/` y el resto de la raíz de `Documentacion/`: otros
proyectos que no forman parte de este repositorio. El manual fuente queda cerrado e intacto.

El manual de usuario **no queda excluido**: es el segundo entregable y se publica junto a los
demás. Su propia página de copyright lo define como «documento de uso personal y autoaprendizaje.
No es un material editorial destinado a la venta», y sus 708 capturas proceden de la documentación
oficial de nop Solutions Ltd, reproducidas con atribución. La cubierta full-wrap de KDP solo se
prepara para el manual de desarrollo.
