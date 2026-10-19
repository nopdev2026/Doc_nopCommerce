# Documentación de nopCommerce 4.90.8

Dos manuales técnicos en español sobre **nopCommerce 4.90.8 sobre .NET 9**, escritos en Markdown y
maquetados a PDF (interior KDP 7×10") y a DOCX con pandoc + XeLaTeX.

## Contenido

| Manual | Fichero fuente | Estructura |
|---|---|---|
| Desarrollo | `Manual de desarrollo V01 de nopCommerce.md` | 32 capítulos en 8 partes + 3 apéndices |
| Usuario | `Manual de usuario V01 de nopCommerce.md` | 57 capítulos en 12 partes + 3 apéndices |

Ambos manuales se documentan únicamente contra la versión **4.90.8** de nopCommerce. No hay
información sobre versiones anteriores ni posteriores.

## Entregables

Cuatro ficheros generados en `publicacion/imprimir/`:

| Fichero | Formato | Datos verificados |
|---|---|---|
| `Manual_NopCommerce_Del_Desarrollador.pdf` | Interior KDP 7×10" | 274 páginas · 1.239.906 B · gutter 23 mm |
| `Manual_NopCommerce_Del_Desarrollador.docx` | Word | 602.813 B · 36 *Heading 2* |
| `Manual_NopCommerce_Del_Usuario.pdf` | Interior 7×10" | 516 páginas · 42.013.261 B · 708 imágenes |
| `Manual_NopCommerce_Del_Usuario.docx` | Word | 35.844.675 B · 61 *Heading 2* |

### Convención de nombres

Los nombres siguen el patrón `Manual_NopCommerce_Del_<Rol>.<ext>`, con `<Rol>` en `Desarrollador`
o `Usuario` y `<ext>` en `pdf` o `docx`.

La parte variable **no está escrita en los scripts**: nace del campo `archivo` de las entradas
`NOPCOMMERCE` y `NOPCOMMERCE_USUARIO` de `publicacion/script/tecnologias.json`, que ambos builds
leen mediante `$libroBase = "Manual_$($t.archivo)"`. Cambiar el nombre de un entregable se hace en
ese único fichero.

> **Importante**: los artefactos intermedios `Manual_NopCommerce_Del_Usuario_Libro.{tex,log,toc,aux}`
> conservan el sufijo `_Libro` porque son transitorios: el script los mueve al nombre final una vez
> termina xelatex.

## Estructura del repositorio

```text
Doc_nopCommerce/
├── README.md                                   Este fichero
├── AGENTS.md                                   Instrucciones para agentes de IA
├── ESTADO.md                                   Estado de entregables, árbol y hallazgos
├── MEMORIA_PROYECTO.md                         Memoria técnica del proyecto
├── Fuentes_nopCommerce.md                      Fuentes de referencia con fechas de consulta
├── cover_Desarrollador.png                  Portada del manual de desarrollo (1024×1536, 2:3)
├── cover_usuarios.png                       Portada del manual de usuario (1024×1536, 2:3)
├── header_pdf.tex                              fontspec + fuente de respaldo
├── Manual de desarrollo V01 de nopCommerce.md  FUENTE del manual de desarrollo
├── Manual de usuario V01 de nopCommerce.md     FUENTE del manual de usuario
├── img/                                        14 imágenes del manual de desarrollo
│   └── usuario/                                708 capturas del manual de usuario
├── PDFs/                                       PDF heredados de otros documentos
└── publicacion/
    ├── backups/                                Respaldos automáticos del fuente
    ├── imprimir/
    │   ├── Manual_NopCommerce_Del_Desarrollador.pdf/.docx   ENTREGABLES
    │   ├── Manual_NopCommerce_Del_Usuario.pdf/.docx         ENTREGABLES
    │   ├── *.tex/.log/.toc/.aux                             Artefactos regenerables
    │   ├── reference_usuario.docx                           Plantilla de los DOCX
    │   └── _build/                                          Copia temporal + verificadores
    └── script/
        ├── tecnologias.json                    Única fuente de nombres de salida
        ├── preparar_fuente.py                  Copia temporal (mermaid + anchos de imagen)
        ├── build_pdf_nopcommerce.ps1           PDF de desarrollo
        ├── build_pdf_usuario_nopcommerce.ps1   PDF de usuario
        ├── build_docx_nopcommerce.ps1          DOCX de ambos manuales
        ├── filtro_libro_nopcommerce.lua        Partes, capítulos, apéndices y quiebres de ruta
        ├── filtro_portada_docx.lua            Word: portada cover*.png a 6 in de ancho
        ├── emoji.lua / header_libro.tex / header_usuario.tex / fuentes_libro.tex
        ├── backup_fuente.ps1 / generar_portada.py
        └── fonts/                              TeX Gyre Pagella + DejaVu Sans Mono
```

Los ficheros de artefactos (`.aux`, `.log`, `.toc`, `.tex`, `manual_tmp.md`) y los respaldos
(`*.bak.md`, `publicacion/backups/`) están excluidos por `.gitignore`: se regeneran en cada build.

## Requisitos para reconstruir los entregables

Entorno con el que están verificados los builds:

| Herramienta | Versión comprobada | Uso |
|---|---|---|
| pandoc | 3.10.1 | Markdown → LaTeX / DOCX |
| MiKTeX (XeTeX) | MiKTeX-XeTeX 4.18 (MiKTeX 26.5) | PDF con xelatex |
| Python | 3.15.0 | Preparación de fuentes y verificación |
| pypdf | 6.21.1 | Lectura de PDF en los verificadores |
| PowerShell | 7.6.7 (`pwsh`) | Ejecución de los builds |
| Git | 2.54.0 | Control de versiones |

Además, `pdftoppm` (se instala con MiKTeX) permite revisar una página concreta como imagen.

## Reconstruir los entregables

Se ejecutan **desde la raíz del repositorio**. El manual fuente nunca se modifica: los builds
trabajan sobre copias.

### 1. PDF de desarrollo

El PDF de desarrollo exige una preparación previa que sustituye los bloques `mermaid` por una imagen
pre-renderizada y acota el ancho de las que desbordan el texto:

```powershell
python publicacion/script/preparar_fuente.py preparar "Manual de desarrollo V01 de nopCommerce.md" publicacion/imprimir/_build/manual_tmp.md publicacion/imprimir/_build/mermaid_miniaturas.png
pwsh -File publicacion/script/build_pdf_nopcommerce.ps1 -Libro publicacion/imprimir/_build/manual_tmp.md
```

> **Importante**: la ruta del PNG de `mermaid_miniaturas.png` debe escribirse con **barra normal
> (`/`)**, no con barra invertida. Si se usa `\`, la ruta llega literal al LaTeX y rompe la
> ejecución de xelatex.

### 2. PDF de usuario

```powershell
pwsh -File publicacion/script/build_pdf_usuario_nopcommerce.ps1
```

### 3. DOCX

```powershell
pwsh -File publicacion/script/build_docx_nopcommerce.ps1 -Manual desarrollo
pwsh -File publicacion/script/build_docx_nopcommerce.ps1 -Manual usuario
```

## Verificación

Ambos verificadores usan rutas relativas: deben ejecutarse desde la raíz del repositorio.

```powershell
python publicacion/imprimir/_build/check_pdf.py
python publicacion/imprimir/_build/locate.py
```

`check_pdf.py` comprueba número de páginas, copyright sin *mojibake*, páginas de apertura de partes
y capítulos, mapa de fuentes del capítulo 32 y cuatro entradas de la TOC. Debe imprimir `True` en
las cuatro comprobaciones de TOC.

La verificación de la TOC contra la página impresa (32/32 en desarrollo y 60/60 en usuario) y el
desglose de cajas *overfull* se recogen en `ESTADO.md`, apartado «Hallazgo de desbordamiento».

## Documentación de estado

| Fichero | Contenido |
|---|---|
| `ESTADO.md` | Tabla de entregables, verificaciones, árbol de publicación y hallazgos |
| `MEMORIA_PROYECTO.md` | Memoria técnica: decisiones, problemas resueltos y checklist |
| `Fuentes_nopCommerce.md` | Fuentes de referencia con fecha de consulta |

## Notas legales

- **Este repositorio no incluye un fichero `LICENSE`.** Mientras no se añada una licencia, el
  contenido queda con todos los derechos reservados: no se concede permiso para copiar, modificar,
  distribuir ni revender los manuales ni su fuente.
- Los manuales son documentación independiente. **nopCommerce** es un producto de
  **nop Solutions Ltd**; las marcas y nombres de producto se citan únicamente con fines
  descriptivos, y estos documentos no son material oficial de nop Solutions Ltd.
- El manual de usuario incrusta **708 capturas de la documentación oficial de nopCommerce**
  (nop Solutions Ltd), reproducidas con atribución. Según su propia página de copyright es un
  «documento de uso personal y autoaprendizaje. No es un material editorial destinado a la venta».
- Todos los textos son originales en español. No se copia código fuente de nopCommerce: las
  referencias a clases, métodos y rutas describen su comportamiento en la versión 4.90.8.

> **Nota**: el manual de desarrollo lleva copyright electrónico en la página 2: «© 2026 César
> Delgado Ruiz. El Códice del Desarrollador. […] Reservados todos los derechos. Queda prohibida la
> reproducción total o parcial de esta obra por cualquier medio, incluido el electrónico, sin la
> autorización escrita del autor».
