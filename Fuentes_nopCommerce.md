# Fuentes oficiales — Fuentes_nopCommerce.md

> Registro de **fuentes oficiales obligatorias** de los dos documentos del proyecto.
> **Última actualización:** 2026-10-18 · **Versión de referencia:** nopCommerce **4.90.8**
> **Documentos:** `Manual de desarrollo V01 de nopCommerce.md` · `Manual de usuario V01 de nopCommerce.md` (ambos completos; el de usuario con capturas oficiales incrustadas)

> **Nota:** Fuente de consulta y de verdad. Toda referencia técnica incluida en los manuales debe constar aquí con su fecha de consulta. Si una afirmación no figura en una fuente de esta lista, no se escribe en el documento.

---

## Advertencias de consulta

- `https://docs.nopcommerce.com` devuelve **HTTP 403** a las descargas automáticas. Las páginas se consultan en navegador o mediante `websearch`.
- **Equivalente legible por máquina:** el repositorio oficial **`nopSolutions/nopCommerce-Docs`** publica el archivo `.md` original de cada página del sitio. Mismo contenido, sin bloqueo:
  `https://raw.githubusercontent.com/nopSolutions/nopCommerce-Docs/master/en/<ruta>.md`
  (verificado 2026-10-17 con `en/index.md`, `en/getting-started/index.md`, `en/developer/tutorials/system-requirements-for-developing.md`, `en/developer/plugins/plugin.json.md`).
- **No existe edición oficial en español** de la documentación: todas las páginas están en `/en/`. El software sí traduce su interfaz a 56 idiomas. Todo texto en español de este proyecto es redacción propia sobre fuentes en inglés.
- Cada fuente se registra con **fecha de consulta**. Sin fecha, no se utiliza.

---

### B.1.b Nota de versión 4.90.8 → 5.00 (consulta 2026-10-17)

| URL | Propósito | Fecha consulta | Estado |
|---|---|---|---|
| `https://www.nopcommerce.com/en/release-notes` | Confirmar que **4.90.8** (04/09/2026) es la última versión estable | 2026-10-17 | Verificado |
| `https://github.com/nopSolutions/nopCommerce/releases` | Confirmar `release-4.90.8` como *Latest* y `release-5.00.0-beta` (30/09/2026) como *Pre-release* | 2026-10-17 | Verificado |
| `https://www.nopcommerce.com/en/boards/topic/103135` | Roadmap oficial 5.00: «Update to .NET 10» y lista de funcionalidades previstas | 2026-10-17 | Verificado |
| `https://www.nopcommerce.com/en/boards/topic/102721` | Declaración del equipo (A. Mazulnitsyn): RTM «un par de semanas» tras la beta | 2026-10-17 | Verificado |

> **Decisión de alcance:** el proyecto documenta **4.90.8 / .NET 9**. La 5.00 se monitoriza y se
> documenta solo como nota de versión mientras siga en beta. Cuando se publique la 5.00
> definitiva se evalúa una revisión de este manual (TFM `net10.0`, requisitos y API).

---

## A. Fuente de verdad del código

| Fuente | Propósito | Documento | Fecha consulta | Estado |
|---|---|---|---|---|
| `D:\Programacion\Proyectos_C#\nopCommerce_4.90.8_Source\nopCommerce` (repo oficial local) | Verificación de código, namespaces, rutas, firmas y versiones de paquetes | Desarrollo | 2026-10-17 | Verificado |
| `src\Utils\Utils\NopVersion.cs` (`CURRENT_VERSION="4.90"`, `MINOR_VERSION="8"`) | Fijar la versión de referencia del manual | Desarrollo | 2026-10-17 | Verificado |
| `Directory.Build.props` (`<TargetFramework>net9.0</TargetFramework>`) | Confirmar la TFM de toda la solución | Desarrollo | 2026-10-17 | Verificado |
| `Libraries\Nop.Core\BaseEntity.cs`, `Libraries\Nop.Data\IRepository.cs`, `Libraries\Nop.Core\Infrastructure\INopStartup.cs` | Parte I (fichas): `BaseEntity` declara solo `int Id`; `IRepository<TEntity> where TEntity : BaseEntity`; `INopStartup` con `ConfigureServices`/`Configure`/`Order` | Desarrollo | 2026-10-18 | Verificado |
| `Libraries\Nop.Services\Plugins\` (`PluginManager`, `PluginsInfo`, `NopPluginDefaults`), `Presentation\Nop.Web.Framework\Infrastructure\Extensions\ApplicationPartManagerExtensions.cs`, `Libraries\Nop.Core\Infrastructure\WebAppTypeFinder.cs` | Capítulo 12: descubrimiento recursivo de `plugin.json` bajo `~/Plugins`, estado en `~/App_Data/plugins.json`, carga con `Assembly.LoadFrom`/`UnsafeLoadFrom` (`PluginConfig.UseUnsafeLoadAssembly=true`), registro como *application part*, una sola clase `IPlugin` por ensamblado, búsqueda de tipos con `WebAppTypeFinder` y detección de colisiones | Desarrollo | 2026-10-18 | Verificado |
| `Libraries\Nop.Core\Domain\Common\GenericAttribute.cs`, `Libraries\Nop.Core\Caching\{IStaticCacheManager,IShortTermCacheManager}.cs`, `IStoreContext.cs`/`IWorkContext.cs`, `Libraries\Nop.Services\Security\StandardPermission.cs`, `Nop.Core\Domain\Security\IAclSupported.cs`, `Areas\Admin\Factories\IBaseAdminModelFactory.cs` | Parte I (fichas): campos de `GenericAttribute`, alcance de los gestores de caché, contextos, catálogo de permisos y *Model Factory* | Desarrollo | 2026-10-18 | Verificado |

> El repo local **no contiene directorio `.git`**: no es posible confirmar el tag exacto de procedencia. La versión se declara por su propio contenido (`NopVersion.cs`).

> **Sombra (shadow copy) — hallazgo 2026-10-18:** en 4.90.8 **no hay *shadow copy* activo**. Una búsqueda en todo el código local no encuentra implementación; los nombres `UsePluginsShadowCopy` y `ClearPluginShadowDirectoryOnStartup` sobreviven únicamente como **cadenas de localización** en las migraciones `UpgradeTo440`/`UpgradeTo460`, y `PluginConfig` solo expone `UseUnsafeLoadAssembly`. El capítulo 12 lo declara así y no afirma sombra como mecanismo vigente.

---

## B. Manual de desarrollo

### B.1 Documentación oficial (docs.nopcommerce.com)

| URL | Propósito | Fecha consulta | Estado |
|---|---|---|---|
| `https://docs.nopcommerce.com/en/index.html` | Índice general de la documentación | 2026-10-17 | Verificado (índice) |
| `https://docs.nopcommerce.com/en/developer/index.html` | Índice de la guía de desarrollo | 2026-10-17 | Verificado (índice) |
| `https://docs.nopcommerce.com/en/developer/tutorials/system-requirements-for-developing.html` | Requisitos de desarrollo: .NET 9 SDK (9.0.100), Visual Studio 2022, SQL Server 2012+, MySQL 5.7+, PostgreSQL 9.2+, IIS 7.0+ | 2026-10-17 | Verificado (`…/en/developer/tutorials/system-requirements-for-developing.md`) |
| `https://docs.nopcommerce.com/en/developer/tutorials/coding-standards.html` | Estándares de codificación (origen del PDF local homónimo) | 2026-10-17 | Verificado (índice de `developer`) |
| `https://docs.nopcommerce.com/en/developer/plugins/plugin.json.html` | Estructura oficial de `plugin.json` y propiedad *Copy if newer* | 2026-10-17 | Verificado (`…/en/developer/plugins/plugin.json.md`) |
| `https://docs.nopcommerce.com/en/developer/plugins/how-to-write-plugin-4.90.html` | Guía oficial «cómo escribir un plugin» de la 4.90 (publicada 30/09/2025) | 2026-10-17 | Verificado |
| `https://docs.nopcommerce.com/en/developer/tutorials/unit-tests.html` | Pruebas unitarias en nopCommerce | 2026-10-17 | Verificado |
| `https://docs.nopcommerce.com/en/installation-and-upgrading/index.html` | Índice de instalación y actualización | 2026-10-17 | Verificado (índice) |
| `https://docs.nopcommerce.com/en/installation-and-upgrading/technology-and-system-requirements.html` | Requisitos tecnológicos y de sistema | 2026-10-17 | Verificado (búsqueda web) |
| `https://docs.nopcommerce.com/en/getting-started/advanced-configuration/plugins-in-nopcommerce.html` | Gestión e instalación manual de plugins en la tienda | 2026-10-17 | Verificado (búsqueda web) |

### B.2 Repositorios GitHub oficiales

| Repositorio | Propósito | Fecha consulta | Estado |
|---|---|---|---|
| `https://github.com/nopSolutions/nopCommerce` | Código fuente oficial (ramas `4.30-bug-fixes` … `4.90-bug-fixes`) | 2026-10-17 | Verificado (API de ramas) |
| `https://github.com/nopSolutions/nopCommerce-Docs` | Fuentes `.md` de toda la documentación | 2026-10-17 | Verificado (descarga directa) |
| `https://github.com/nopSolutions/nopCommerce-plugin-template-VS` | Plantilla oficial de plugin para Visual Studio | 2026-10-17 | Verificado |

### B.3 Tecnologías citadas en el manual

| Tecnología | Versión | Fuente de verificación | Fecha consulta | Estado |
|---|---|---|---|---|
| .NET / ASP.NET Core | 9.0 (TFM `net9.0`) | `Directory.Build.props` del repo local | 2026-10-17 | Verificado |
| .NET 9 SDK | 9.0.100 | `system-requirements-for-developing.md` (enlace oficial de descarga) | 2026-10-17 | Verificado |
| Visual Studio | 2022 (17.14 o superior) | `technology-and-system-requirements` (búsqueda web) | 2026-10-17 | Verificado |
| linq2db (ORM; sin EF Core) | 5.4.1 | `Libraries\Nop.Data\Nop.Data.csproj` L17 | 2026-10-17 | Verificado |
| FluentMigrator / FluentMigrator.Runner | 7.1.0 | `Libraries\Nop.Data\Nop.Data.csproj` L15-L16 | 2026-10-17 | Verificado |
| Autofac (contenedor de DI) | `Autofac.Extensions.DependencyInjection` 10.0.0 | `Libraries\Nop.Core\Nop.Core.csproj` L15 | 2026-10-17 | Verificado |
| NUnit | 4.4.0 | `Tests\Nop.Tests\Nop.Tests.csproj` L19 | 2026-10-17 | Verificado |
| NUnit3TestAdapter | 5.1.0 | `Tests\Nop.Tests\Nop.Tests.csproj` L20 | 2026-10-17 | Verificado |
| Microsoft.NET.Test.Sdk | 17.14.1 | `Tests\Nop.Tests\Nop.Tests.csproj` L17 | 2026-10-17 | Verificado |
| SQL Server / MySQL / PostgreSQL | 2012+ / 5.7+ / 9.2+ | `system-requirements-for-developing.md` | 2026-10-17 | Verificado |
| Imágenes por defecto (Docker) | `mssql/server:2019-latest` | `docker-compose.yml` del repo local | 2026-10-17 | Verificado |
| Licencia | nopCommerce Public License v3 (AGPL v3 + cláusula «powered by nopCommerce») | `LICENSE.md` del repo local | 2026-10-17 | Verificado |
| Microsoft Learn (.NET, ASP.NET Core) | — | `https://learn.microsoft.com` | pendiente | **Pendiente de consultar** |

---

## C. Manual de usuario — secciones oficiales (preparatorio)

> Extraídas del índice oficial `en/index.md` y `en/getting-started/index.md` (2026-10-17). Listado de secciones reales; el detalle capítulo a capítulo se completa al iniciar el manual de usuario.

| URL | Sección | Documento |
|---|---|---|
| `https://docs.nopcommerce.com/en/getting-started/index.html` | Puesta en marcha (configurar, catálogo, experiencia de cliente, marketing) | Usuario |
| `https://docs.nopcommerce.com/en/getting-started/admin-area-overview.html` | Visión del panel de administración | Usuario |
| `https://docs.nopcommerce.com/en/getting-started/design-your-store/index.html` | Diseño de la tienda (temas, logo, media) | Usuario |
| `https://docs.nopcommerce.com/en/getting-started/configure-payments/index.html` | Pagos y monedas | Usuario |
| `https://docs.nopcommerce.com/en/getting-started/configure-shipping/index.html` | Envíos, almacenes y puntos de recogida | Usuario |
| `https://docs.nopcommerce.com/en/getting-started/configure-taxes/index.html` | Impuestos | Usuario |
| `https://docs.nopcommerce.com/en/getting-started/advanced-configuration/multi-store` | Multi-tienda | Usuario y Desarrollo |
| `https://docs.nopcommerce.com/en/running-your-store/index.html` | Índice «Gestionar tu tienda» | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/catalog/index.html` | Catálogo (productos, categorías, fabricantes) | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/order-management/index.html` | Pedidos, inventario, devoluciones, envíos | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/customer-management/index.html` | Clientes, roles y ACL | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/content-management/index.html` | Contenido (páginas, blog, plantillas de mensaje) | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/promotional-tools/index.html` | Marketing (descuentos, puntos, tarjetas regalo, campañas) | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/vendor-management.html` | Multi-vendedor y drop shipping | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/system-administration/index.html` | Administración del sistema | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/reports.html` | Informes | Usuario |
| `https://docs.nopcommerce.com/en/running-your-store/search-engine-optimization.html` | SEO | Usuario y Desarrollo |

### C.1 — Cierre del manual de usuario (2026-10-18)

> El manual de usuario está **completo**: `Manual de usuario V01 de nopCommerce.md` (57 capítulos en 12 partes + 3 apéndices). Fuentes usadas:

| Concepto | Detalle |
|---|---|
| Fuente legible | `https://raw.githubusercontent.com/nopSolutions/nopCommerce-Docs/master/en/<ruta>.md` (`docs.nopcommerce.com` devuelve 403 a descargas automáticas) |
| Páginas descargadas y usadas | **140** (de 142 detectadas) |
| Excluidas (verificado ausentes en 4.90.8) | `ymm.md` y `price-lists.md` (4.90.8 solo tiene `TierPriceList`, feature distinto) |
| Verificación de versión | Cada área de negocio contrastada con los controladores del admin del repo local 4.90.8; plugins presentes confirmados (`Nop.Plugin.Misc.RFQ`, `Nop.Plugin.Misc.OmnibusDirective`, Brevo, Omnisend, PowerBI, Zettle) |
| Fecha de consulta | 2026-10-18 |
| Capturas | **Incrustadas**: 708 referencias (699 imágenes únicas) descargadas de `nopCommerce-Docs/_static/` a `img/usuario/` y colocadas como galería por capítulo (54 capítulos), con atribución a nop Solutions Ltd en la página de copyright y en la nota de la primera galería |

---

## D. Fuentes locales del proyecto (secundarias)

Son **traducciones al español** de páginas oficiales antiguas. Útiles como referencia de estilo y estructura; **no son válidas para datos actuales de la API**.

| Fichero | Qué aporta | Límites conocidos (verificados 2026-10-17) |
|---|---|---|
| `Cómo escribir un plugin para nopCommerce.pdf` | Estructura y ciclo de vida del plugin | API de ≤4.70: usa `Nop.Core.Plugins` y `NopStartup.cs` (hoy: `Nop.Services.Plugins` y `PluginNopStartup.cs`) |
| `Cómo escribir un widget para nopCommerce.docx` | Creación de widgets y `plugin.json` | API ≤4.50: `GetWidgetViewComponentName` (desde 4.60: `GetWidgetViewComponent(Type)`); `ClearPluginAssemblies.csproj` (nombre erróneo; es `ClearPluginAssemblies.proj`); `AreaNames.Admin` |
| `Crear widgets en nopcommerce.pdf` | Widget zones y componente `Widget` | Usa `BasePlugin` en `Nop.Core.Plugins` (hoy `Nop.Services.Plugins`); zonas en listados de vistas (hoy `PublicWidgetZones.cs`) |
| `Estándares de codificación.pdf` | Normas de codificación de nopCommerce | Complemento del HTML oficial `coding-standards.html`; verificar vigencia en la fuente en línea |

> **Regla:** cuando una fuente local contradiga al repo 4.90.8 o a `nopCommerce-Docs`, **prevalece el repo oficial**. Dicha divergencia se anota en el manual con su corrección.
