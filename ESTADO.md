# ESTADO.md — Proyecto Doc_nopCommerce

> **Estado del proyecto a 2026-10-26.** La fuente de verdad del conocimiento es `MEMORIA_PROYECTO.md`;
> este fichero refleja el estado operativo y los próximos pasos.

## Cambios 2026-10-26 (renombrado del MCP de Microsoft Learn: `learn` → `mcp.net`)

- El servidor MCP de Microsoft Learn pasa a llamarse **`mcp.net`** en ambos `opencode.json`
  (repo y workspace `D:\Programacion\Proyectos_nopCommerce`) para más claridad; la URL remota
  no cambia.
- El workspace añade el comando **`/mcp.net [pregunta]`**
  (`.opencode/commands/mcp.net.md`), que responde preguntas de C#/.NET usando este servidor y
  citando el artículo oficial de Microsoft Learn.

## Cambios 2026-10-26 (retirada del MCP remoto y repo público)

Decisión del usuario, tomada el mismo día tras implementar la Fase 2:

- **Repo hecho público**: `nopdev2026/Doc_nopCommerce` pasa de privado a **público** (sin fichero
  `LICENSE` → todos los derechos reservados). El usuario no va a comercializar este contenido ni
  hacer libros sobre ello; la difusión a la comunidad se limita, de momento, a **enlazar el repo**.
- **MCP solo local**: se retira la Fase 2. Eliminados el codespace `nopdev-docs-jr56wvw95pg6hpx65`,
  el codespace secret `MCP_TOKEN`, la entrada `nopdev-docs-remote` del `opencode.json` del workspace
  y los ficheros `.mcp_token` y `arrancar-mcp-remoto.ps1`. El workspace queda con `nopdev-docs`
  (local) + `learn`.
- **Fase 3 descartada**: no habrá endpoint público (`mcp.nopdev.es` ni Cloudflare Worker). El
  estudio `Investigacion_Fase3_hosting_MCP.md` queda **archivado** por si se retoma.
- **Se conserva** el código de la Fase 2 en el repo (`mcp/http.js`, `mcp/start-server.sh`,
  `.devcontainer/`) con instrucciones de reactivación en el README.
- Nota sobre las 708 capturas de nopCommerce en el manual de usuario: el usuario asume mantenerlas
  con atribución (sin verificación adicional de licencia), dado que no hay servicio ni venta.
- Los dos documentos de apoyo viven en local: `Manual_MCP_Remoto_nopdev-docs.md` e
  `Investigacion_Fase3_hosting_MCP.md` (en `D:\Investigaciones_con_IA\CurriculumCesar\`).

## Cambios 2026-10-26 (MCP remoto vía GitHub Codespaces — Fase 2)

- **MCP remoto operativo**: el servidor `nopdev-docs` se expone en HTTPS público desde un Codespace
  del repo privado. Codespace `nopdev-docs-jr56wvw95pg6hpx65` (WestEurope, `basicLinux32gb`,
  idle 30 min); endpoint `https://nopdev-docs-jr56wvw95pg6hpx65-8787.app.github.dev/mcp` y salud
  en `/health`.
- **Refactor del servidor**: `mcp/server.js` (núcleo compartido: parser + 4 tools), `mcp/index.js`
  (stdio, local) y `mcp/http.js` (Streamable HTTP stateless en :8787, auth `Bearer MCP_TOKEN` o
  `?token=`, CORS, `enableJsonResponse`). Script `npm run start:http`.
- **Pruebas locales y públicas superadas**: health 200 · sin token 401 · `initialize` 200 ·
  `tools/list` con las 4 tools · `toc` 3.020 chars · `get_chapter` usuario «RGPD» 3.338 chars
  (Capítulo 9) — contra la URL pública. `opencode mcp list` → `nopdev-docs-remote connected`.
- **devcontainer** (`.devcontainer/devcontainer.json`): imagen node-22, feature `sshd` (necesaria
  para `gh codespace ssh/logs`), `postCreate` con `npm ci`, puerto 8787. Hallazgos: GitHub **no
  inyecta** los codespaces secrets en los scripts de ciclo de vida (token en `~/.nopdev-docs.env`),
  el `postStart` **solo corre al crear** el codespace (no en arranques posteriores) y el puerto
  **vuelve a `private` en cada arranque**.
- **Workflow de arranque** en un solo comando: `D:\Programacion\Proyectos_nopCommerce\arrancar-mcp-remoto.ps1`
  (escribe el env-file, ejecuta `mcp/start-server.sh` con `setsid`, pone el puerto en `public` y
  verifica `/health` → 200). La config remota de OpenCode (`nopdev-docs-remote`, cabecera Bearer,
  `oauth: false`) está en el `opencode.json` de ese workspace, **fuera de git**.
- **Token**: 43 caracteres en `Proyectos_nopCommerce\.mcp_token` + codespace secret de usuario
  `MCP_TOKEN` (restringido al repo). **Nunca commiteado.**
- **Pendiente cerrado**: el renombrado `Proyectos_nopCommerde` → `Proyectos_nopCommerce` (anotado
  el 2026-10-24) ya está hecho.
- **Pendiente (Fase 3)**: decisión de licencia/derechos antes de publicar el endpoint propio
  (Cloudflare Worker + `mcp.nopdev.es`).

## Cambios 2026-10-24 (limpieza, MCP y coherencia)

- **Limpieza del repo**: borrados de `PDFs\` los 3 entregables antiguos
  (`Manual_NopCommerce_Del_Desarrollador.docx`, `…_Del_Usuario.docx` y `…_Del_Usuario.pdf`, unos 70 MB;
  eran versiones obsoletas sin versionar) y movidos los 6 `.bak.md` de la raíz a
  `publicacion/backups/` (10 ficheros en total allí). Raíz y `git status` limpios.
- **Servidor MCP `nopdev-docs`** (`mcp/`, Node + `@modelcontextprotocol/sdk`, stdio): expone los dos
  manuales con 4 tools —`toc`, `get_chapter`, `search`, `reload`— probadas por JSON-RPC (inicializado,
  tools/list, TOC agrupado por partes, capítulo por número/ancla/título y búsqueda con plegado de
  acentos). Requiere Node ≥ 18 (comprobada v26.4.0) y `npm install` en `mcp/`
  (`node_modules/` ignorado). Configuración en `opencode.json` (raíz del repo y workspace
  `D:\Programacion\Proyectos_nopCommerce`): servidor local `nopdev-docs` + `learn` de Microsoft Learn.
- **`check_pdf.py` actualizado** (32 → 34): la ampliación había renumerado el capítulo de Rendimiento
  al 34 y el verificador quedó desfasado. Ahora las 4 comprobaciones de TOC imprimen `True`.
- **Cifras reales verificadas hoy** (pypdf + zip): desarrollo PDF 298 pp · 2.663.977 B; DOCX 621.884 B ·
  38 Heading2 · 305 bookmarks; usuario PDF 516 pp · 43.438.444 B; DOCX 37.365.749 B · 61 Heading2.
  README y este fichero actualizados a esos valores.
- **Pendiente**: renombrar `D:\Programacion\Proyectos_nopCommerde` → `Proyectos_nopCommerce`
  (bloqueado por otra sesión de OpenCode y una terminal PowerShell con cwd dentro; tras cerrarlas,
  el renombrado es inmediato: la config ya está escrita en la carpeta).

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

**Revisión de la Parte I (2026-10-19).** Revisión de «Parte I — Conceptos esenciales (recordatorio)» del manual de desarrollo: fichas de presentación de los 3 capítulos reescritas como lista etiquetada (servicio, utilidad, conceptos clave, prerrequisitos, caso de uso), corrección de la redacción de la ficha pub-sub y separación del marcador «Información pendiente de documentar» de la línea «Enlace». Ampliación de las fichas de repositorio (paginación, `ISoftDeletedEntity`), eventos (`EntityInsertedEvent<T>` y operaciones `Publish`/`PublishAsync`, mecanismo en memoria), caché (operaciones de los gestores), contextos (métodos asíncronos), localización (`LocaleStringResource`, `ILanguageService`) y permisos (`PermissionRecordCustomerRoleMapping`). Los datos de nopCommerce se verificaron contra el código 4.90.8 —`IEventPublisher` + `IConsumer<T>` vigentes, sin MassTransit; `plugin.json` con su lista completa de campos— y los conceptos .NET con el servidor MCP de Microsoft Learn, citados en el nuevo **Apéndice A.7** del manual. `Fuentes_nopCommerce.md` actualizado (fila de Microsoft Learn verificada). Respaldo: `Manual de desarrollo V01 de nopCommerce.pre-revision-partei.bak.md`. No se regeneraron PDF/DOCX.

**Ampliación de la Parte I y capítulos de linq2db (2026-10-19, manual de desarrollo).**
Ampliadas en el sitio las **13 fichas de la Parte I** con un bloque «Concepto general» nuevo y un
apunte `> Fuente:` por ficha; los conceptos de C#/.NET/ASP.NET Core se verificaron con el servidor
MCP de Microsoft Learn (23 artículos recogidos en el **Apéndice A.7**, reescrito: se corrigió la
fila «Principios arquitectónicos (SOLID)» —`Architectural principles` no incluye SOLID— y se
añadieron las fuentes de reflejo, eventos, caché, options, estado asíncrono, localización,
autorización, abierto/cerrado y fábrica). Añadidos 3 ejemplos C# cortos aprobados (registro DI,
declaración/lanzamiento de eventos, localizador por clave). Parte I: 191 → 342 líneas. Nuevos
**Capítulo 7 «linq2db: qué es y cómo se usa»** y **Capítulo 8 «linq2db en nopCommerce (capa
Nop.Data)»** —documentados con `https://linq2db.github.io/` y el código 4.90.8, con **Apéndice A.8**
de referencias—; la Parte II pasa de 5 a 7 capítulos y el manual de **32 a 34 capítulos**,
renumerados 108+ referencias, 52 anclas y referencias parentéticas obsoletas (además del arreglo
de la referencia a `IEventPublisher`, que apuntaba al Cap. 30 y es el Cap. 20). Ampliado el
Apéndice C con 5 tipos de `Nop.Data` (`EntityRepository<T>`, `BaseDataProvider`,
`MsSqlNopDataProvider`, `NopMappingSchema`, `FluentMigratorMetadataReader`), fila de linq2db en
`Fuentes_nopCommerce.md` y enlaces cruzados (Cap. 6 → 7-8; ficha repositorio → Cap. 8; Cap. 22 →
7-8). Respaldo previo: `Manual de desarrollo V01 de nopCommerce.pre-ampliacion.bak.md`.
No se regeneraron PDF/DOCX.

**Regeneración de entregables (2026-10-19, posterior a la ampliación).** Ambos entregables del
manual de desarrollo reconstruidos con el fuente ampliado. **PDF**: 274 → **298 páginas**
(2.663.977 B), gutter 23 mm (mínimo KDP del tramo de 151-300: 12,7 mm), fuentes incrustadas,
TOC con 34 capítulos / 8 partes / 3 apéndices y la portada nueva `cover_Desarrollador.png`
pintada a página completa. Cajas overfull: 160 —156 de tabla (≤3 mm) y 4 de texto (máx. 8,7 mm),
**ninguna >20 mm**—, ver §Hallazgo de desbordamiento. **DOCX**: 621.884 B, 38 Heading2,
305 bookmarks, 14 imágenes, los 34 enlaces del índice resueltos. Correcciones de pipeline
necesarias para que el build vuelva a ser reproducible:

- `preparar_fuente.py` admitía **un solo bloque mermaid**: con dos, sustituía ambos por la
  imagen del primero (un diagrama en el lugar de otro). Ahora extrae y sustituye **N bloques
  en orden** (`_1`, `_2`, …) y exige igualdad de recuentos; con un bloque conserva el
  comportamiento histórico.
- `header_libro.tex` apuntaba a `cover.png` (borrada): ahora usa `cover_Desarrollador.png` y
  **solo fija el ancho**. El asset nuevo mide 1024×1536 (2:3) y no 7×10; forzar ancho+alto lo
  habría deformado un 5%. La altura sobrante (0,25 in arriba y abajo) queda fuera del recorte.
- `mmdc` falla porque la caché de puppeteer no tiene `chrome-headless-shell`: se renderiza con
  `PUPPETEER_EXECUTABLE_PATH=$(command -v chromium)`.
- El diagrama del Cap. 8 pasó de `flowchart TD` a `LR`: en vertical medía 1,8×8 in y ocuparía
  la página entera como una tira; en horizontal entra en 5,1×0,5 in.

El manual de usuario **se reconstruyó con portada** (2026-10-19): el MD incluye ahora
`![](cover_usuarios.png)` tras los metadatos; en el PDF esa imagen se elimina del cuerpo
(`filtro_libro_nopcommerce.lua` ya casaba `cover*.png`) y la pinta `header_usuario.tex` con un
`\maketitle` a página completa (overlay TikZ, igual que `header_libro.tex`, pero anulando los
valores `Gin` por defecto de este header para no encoger la imagen). En Word la limita a 6 in el
nuevo `filtro_portada_docx.lua`.

## Entregables

| Fichero | Estado | Notas |
|---|---|---|
| `Manual de desarrollo V01 de nopCommerce.md` | **Completo** | 360.065 B · 6.206 líneas (LF, sin BOM) · 34 capítulos V01 · 8 partes · 3 apéndices · portada e índice con 46 enlaces |
| `publicacion/imprimir/Manual_NopCommerce_Del_Desarrollador.pdf` | **Completo** | Interior KDP 7×10": 298 páginas · 2.663.977 B · track LaTeX (pandoc + xelatex) · gutter 23 mm (mín. KDP 12,7 mm) · portada `cover_Desarrollador.png` a página completa · 160 cajas overfull (156 de tabla ≤3 mm; 4 de texto ≤8,7 mm; ninguna >20 mm) |
| `Manual de usuario V01 de nopCommerce.md` | **Completo** | 241.635 B · 57 capítulos V01 · 12 partes · 3 apéndices · índice con 72 enlaces · portada `cover_usuarios.png` tras los metadatos · **708 capturas oficiales incrustadas** (`img/usuario/`) · uso personal/no comercial |
| `publicacion/imprimir/Manual_NopCommerce_Del_Usuario.pdf` | **Completo** | Interior 7×10": 516 páginas · 43.438.444 B · 708 entradas XObject de imagen (699 únicas, portada incluida) · track LaTeX propio · portada `cover_usuarios.png` a página completa (pág. 1) · 21 cajas overfull, todas de tabla (≤2,8 mm), ninguna de texto · copyright de uso personal con atribución a nop Solutions Ltd · sin ISBN |
| `publicacion/imprimir/Manual_NopCommerce_Del_Usuario.docx` | **Completo** | Word vía pandoc + reference · 37.365.749 B · 700 imágenes incrustadas (portada incluida, 6 in de ancho vía `filtro_portada_docx.lua`) · 61 Heading2 · índice interno clicable (72 enlaces) |
| `publicacion/imprimir/Manual_NopCommerce_Del_Desarrollador.docx` | **Completo** | Word del manual de desarrollo vía pandoc + reference · 621.884 B · 14 imágenes · 38 Heading2 · índice interno clicable (305 bookmarks, 34 enlaces de capítulo) |
| `img/usuario/` | **Completo** | 699 capturas oficiales descargadas de `nopCommerce-Docs` (`_static/`), con atribución |
| `cover_Desarrollador.png` | **Completo** | Portada del libro de desarrollo (1024×1536, 2:3), aportada el 2026-10-19; la usa `header_libro.tex` |
| `cover_usuarios.png` | **Completo** | Portada del libro de usuario (1024×1536, 2:3), aportada el 2026-10-19; la usa `header_usuario.tex` en el PDF y el MD/DOCX del manual de usuario |
| `publicacion/script/` | **Completo** | Pipeline PDF: `build_pdf_nopcommerce.ps1`, `build_pdf_usuario_nopcommerce.ps1`, `build_docx_nopcommerce.ps1` (Word de ambos manuales), `filtro_libro_nopcommerce.lua`, `filtro_portada_docx.lua` (ancho de portada en Word), `preparar_fuente.py`, `generar_portada.py`, `tecnologias.json` (entradas NOPCOMMERCE y NOPCOMMERCE_USUARIO), `header_libro.tex`, `header_usuario.tex`, `fuentes_libro.tex`, `emoji.lua`, `backup_fuente.ps1`, `fonts/` |
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
298 páginas · 2.663.977 B; cifras re-verificadas el 2026-10-24). Reproduce el track LaTeX de la
colección (`MaquetaciónLibroGlobal.md`):
mismas tipografías (TeX Gyre Pagella + DejaVu Sans Mono), mismos márgenes 7×10" (gutter 23 mm) y
misma plantilla de build.

Secuencia de reconstrucción (el manual original no se modifica nunca; el build trabaja sobre una
copia temporal en `publicacion/imprimir/_build/`):

```bash
# 1) Bloques mermaid -> .mmd (una ruta por línea; serie _1, _2, … si hay varios)
python publicacion/script/preparar_fuente.py extraer-mermaid 'Manual de desarrollo V01 de nopCommerce.md' 'publicacion/imprimir/_build/mermaid_miniaturas.mmd'
# 2) Render de cada bloque. PUPPETEER_EXECUTABLE_PATH es necesario si la caché
#    de puppeteer no tiene chrome-headless-shell instalado.
for f in publicacion/imprimir/_build/mermaid_miniaturas*.mmd; do
  PUPPETEER_EXECUTABLE_PATH="$(command -v chromium)" npx -y @mermaid-js/mermaid-cli -i "$f" -o "${f%.mmd}.png" -b white -s 2
done
# 3) Copia temporal: bloque i <- imagen i (el script exige igualdad de recuentos)
#    y acota el ancho de las imágenes que desbordan los 5,1 in útiles
python publicacion/script/preparar_fuente.py preparar 'Manual de desarrollo V01 de nopCommerce.md' 'publicacion/imprimir/_build/manual_tmp.md' publicacion/imprimir/_build/mermaid_miniaturas*.png
# 4) Build LaTeX (pandoc + xelatex ×2 + verificación de páginas/gutter con pypdf)
pwsh -NoProfile -ExecutionPolicy Bypass -File publicacion/script/build_pdf_nopcommerce.ps1 -Libro 'publicacion/imprimir/_build/manual_tmp.md' -Tecnología NopCommerce
# 5) Word (lee el fuente directamente, sin pasar por la copia temporal)
pwsh -NoProfile -ExecutionPolicy Bypass -File publicacion/script/build_docx_nopcommerce.ps1 -Manual desarrollo
# 6) Portada (solo si hay que regenerarla desde la plantilla; hoy la aporta el usuario)
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

TOC verificada contra la página impresa: **34/34** capítulos en el de desarrollo y **60/60** en el de
usuario (desfazue de front matter = 6 en ambos; el recuento de desarrollo se re-verificó el
2026-10-24 tras la ampliación a 34 capítulos, con `check_pdf.py` actualizado 32 → 34).

> **Importante**: corregir el defecto alteró la paginación, como se anticipaba. En aquel momento el
> interior de desarrollo pasó de **272 a 274 páginas**; tras la ampliación posterior (Parte I + cap.
> de profundidad, 2026-10-18/19) el interior quedó en **298 páginas**, valor que mantienen este
> documento y `MEMORIA_PROYECTO.md` (re-verificado el 2026-10-24).

Verificación visual con `pdftoppm`: la ruta
`Presentation/Nop.Web.Framework/Infrastructure/Extensions/ApplicationBuilderExtensions.cs` parte
ahora a la segunda línea en lugar de cortarse en el margen.

## Próximos pasos (fuera del alcance actual)

1. Cubierta KDP full-wrap (con `ensamblar_cubierta.py` de la colección) cuando se cierre el lomo
   con las 298 páginas. **(Solo aplica al manual de desarrollo; el manual de usuario es de uso
   personal y no se publica.)**
2. Manual de usuario de nopCommerce: **COMPLETADO** (57 capítulos, **con las 708 capturas oficiales
   incrustadas**, PDF 516 pp y DOCX). Word del manual de desarrollo también generado.
   Actualizado cuando exista una versión estable de nopCommerce 5.00 (.NET 10).
3. Actualización de ambos manuales cuando exista una versión estable de nopCommerce 5.00 (.NET 10).

## Árbol de publicación

```
Doc_nopCommerce/
├── cover_Desarrollador.png        Portada del libro de desarrollo (1024×1536, 2:3)
├── cover_usuarios.png             Portada del libro de usuario (1024×1536, 2:3)
├── header_pdf.tex                 fontspec + fuente de respaldo (sin ucharclasses)
└── publicacion/
    ├── backups/                   Respaldos automáticos del fuente (backup_fuente.ps1)
    ├── imprimir/
    │   ├── Manual_NopCommerce_Del_Desarrollador.pdf   ENTREGABLE: interior 298 págs
    │   ├── Manual_NopCommerce_Del_Desarrollador.docx  ENTREGABLE: Word (38 Heading2)
    │   ├── Manual_NopCommerce_Del_Desarrollador.tex/.log/.toc/.aux   Artefactos del build
    │   ├── Manual_NopCommerce_Del_Usuario.pdf         ENTREGABLE: interior 516 págs
    │   ├── Manual_NopCommerce_Del_Usuario.docx        ENTREGABLE: Word (61 Heading2)
    │   ├── Manual_NopCommerce_Del_Usuario_Libro.tex/.log/.toc/.aux   Artefactos del build
    │   ├── copyright_generado.tex / copyright_usuario_generado.tex   Copyright (generados)
    │   ├── reference_usuario.docx       Plantilla de referencia de los DOCX
    │   └── _build/                Copia temporal y assets: manual_tmp.md (regenerable),
    │                              mermaid_miniaturas[_N].mmd/.png y utilidades de verificación
    └── script/
        ├── build_pdf_nopcommerce.ps1      Build solo-PDF (pandoc + xelatex ×2)
        ├── filtro_libro_nopcommerce.lua   Filtro del libro (partes, capítulos, apéndices)
        ├── filtro_portada_docx.lua        Word: portada cover*.png a 6 in de ancho
        ├── preparar_fuente.py             Copia temporal: mermaid + anchos de imagen
        ├── generar_portada.py             cover*.png (plantilla; hoy las portadas las aporta el usuario)
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
