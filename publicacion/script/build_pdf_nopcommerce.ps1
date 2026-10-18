# Build SOLO PDF (track LaTeX 7x10") para "El Códice del Desarrollador".
# Derivado de build_publicacion.ps1 de la colección, sin EPUB ni cubiertas.
# Uso: pwsh publicacion/script/build_pdf_nopcommerce.ps1 [-Libro 'Manual de desarrollo V01 de nopCommerce.md'] [-Tecnología NopCommerce]
# -Tecnología elige el libro para subtítulo, copyright y nombres de salida
# (textos en publicacion/script/tecnologias.json).
# El fuente real NUNCA se modifica: si el libro está bajo publicacion/imprimir/_build
# (copia temporal con el bloque mermaid ya sustituido) se omite el backup.
# Fuentes empaquetadas en publicacion/script/fonts y cargadas por ruta:
# TeX Gyre Pagella (cuerpo) + DejaVu Sans Mono (código).
param(
    [string]$Libro = "Manual de desarrollo V01 de nopCommerce.md",
    [string]$Tecnología = "NopCommerce"
)
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$scriptDir = $PSScriptRoot
$imprimirDir = [IO.Path]::GetFullPath((Join-Path $scriptDir "../imprimir"))
Set-Location $root

if (-not (Test-Path -LiteralPath $Libro)) {
    throw "No existe el fuente: $Libro"
}

# Backup del fuente antes de construir (no para copias temporales de _build).
if ($Libro -notlike "*_build*") {
    try {
        & (Join-Path $scriptDir "backup_fuente.ps1") -Libro $Libro
    } catch {
        Write-Error $_.Exception.Message
        exit 1
    }
}

# Registro compartido de tecnologías
$techKey = $Tecnología.ToUpperInvariant()
$reg = Get-Content -Raw -Encoding UTF8 (Join-Path $scriptDir "tecnologias.json") | ConvertFrom-Json
if (-not $reg.PSObject.Properties[$techKey]) {
    throw "Tecnología desconocida: $Tecnología. Válidas: HTML5, CSS3, JavaScript, NopCommerce"
}
$t = $reg.$techKey
$subtitulo = $t.subtitulo

# Detectar Python (py en Windows; python3/python en Linux)
$pyCmd = Get-Command py -ErrorAction SilentlyContinue
if (-not $pyCmd) { $pyCmd = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $pyCmd) { $pyCmd = Get-Command python -ErrorAction SilentlyContinue }
if (-not $pyCmd) { throw "No se encontró Python (py/python3/python)" }
$python = $pyCmd.Source

# Página de copyright (previa a la TOC del PDF)
$copyrightFile = Join-Path $imprimirDir "copyright_generado.tex"
$copyrightContent = @"
\thispagestyle{empty}
\vspace*{9cm}
\begin{center}
\begin{minipage}{0.82\textwidth}
\small
\textcopyright\ 2026 César Delgado Ruiz.\\
\medskip
\textbf{El Códice del Desarrollador.}\\
$subtitulo\\
\medskip
Reservados todos los derechos. Queda prohibida la reproducción total o parcial de esta obra por cualquier medio, incluido el electrónico, sin la autorización escrita del autor.\\
\medskip
$($t.legal)\\
\medskip
ISBN: \phantom{0000000000}\\
\end{minipage}
\end{center}
\clearpage
"@
Set-Content -LiteralPath $copyrightFile -Value $copyrightContent -Encoding UTF8

$libroBase = "Manual_$($t.archivo)"
# Sin sufijo "_Libro": el PDF que genera xelatex ya ES el entregable final
# (Manual_NopCommerce_Del_Desarrollador.pdf). No hay paso de copia posterior.
$libroTex = "${libroBase}.tex"
$libroPdf = "${libroBase}.pdf"
$libroLog = "${libroBase}.log"

Write-Host "=== 1/1 Interior PDF 7x10 (libro) ==="
pandoc $Libro -s -t latex --from markdown+lists_without_preceding_blankline --lua-filter (Join-Path $scriptDir "filtro_libro_nopcommerce.lua") `
  -H (Join-Path $scriptDir "header_libro.tex") -H "header_pdf.tex" `
  -H (Join-Path $scriptDir "fuentes_libro.tex") `
  --include-before-body $copyrightFile `
  --toc --toc-depth=1 --number-sections `
  -V documentclass=book `
  -V geometry:paperwidth=7in -V geometry:paperheight=10in `
  -V geometry:top=20mm -V geometry:bottom=22mm `
  -V geometry:outer=20mm -V geometry:inner=23mm -V geometry:twoside `
  -V fontsize=12pt -V linestretch=1.15 `
  --metadata title="El Códice del Desarrollador" `
  --metadata author="César Delgado Ruiz" `
  --metadata lang="es" --metadata date="2026" `
  --metadata subtitle="$subtitulo" `
  -o (Join-Path $imprimirDir $libroTex)

Push-Location $imprimirDir
try {
    foreach ($pasada in 1..2) {
        # EAP local 'Continue': MiKTeX escribe avisos por stderr y PowerShell 5.1
        # los convertiría en error terminante con 'Stop'.
        $out = & { $ErrorActionPreference = 'Continue'; xelatex -interaction=nonstopmode -halt-on-error $libroTex 2>&1 } | Out-String
        if ($LASTEXITCODE -ne 0) {
            $out -split "`n" | Select-Object -Last 40 | Write-Host
            Get-Content (Join-Path $imprimirDir $libroLog) -Tail 40 | Write-Host
            throw "xelatex falló (pasada $pasada). Ver $libroLog"
        }
    }
} finally {
    Pop-Location
}

# Verificación: nº de páginas y cumplimiento del gutter KDP por tramo.
$pdfPath = Join-Path $imprimirDir $libroPdf
$pagesRaw = & $python -c "import sys; from pypdf import PdfReader; print(len(PdfReader(sys.argv[1]).pages))" $pdfPath
$pages = [int]$pagesRaw.Trim()
Write-Host "Páginas: $pages"

# Cumplimiento KDP: gutter interior mínimo por tramo (ayuda oficial GVBQ3CMEQW3W2VL6).
$gutterMm = 23
if ($pages -le 150)      { $gutterMin = 9.6 }
elseif ($pages -le 300)  { $gutterMin = 12.7 }
elseif ($pages -le 500)  { $gutterMin = 15.9 }
elseif ($pages -le 700)  { $gutterMin = 19.1 }
else                     { $gutterMin = 22.3 }
Write-Host "Tramo KDP: $pages págs -> gutter mínimo $gutterMin mm (interior: $gutterMm mm)"
if ($gutterMm -lt $gutterMin) {
    Write-Warning "GUTTER INSUFICIENTE: el interior ($gutterMm mm) es menor que el mínimo KDP del tramo ($gutterMin mm)."
}

# Aviso de cajas overfull (posibles líneas de código/árbol desbordadas).
# -SimpleMatch evita el escape del backslash: "Overfull \hbox" es texto literal.
$overfull = (Select-String -Path (Join-Path $imprimirDir $libroLog) -SimpleMatch -Pattern 'Overfull \hbox' -AllMatches |
    Measure-Object).Count
Write-Host "Overfull hbox: $overfull (revisar en el log si persisten)"
if (-not (Test-Path -LiteralPath $pdfPath)) { throw "No se generó el PDF: $pdfPath" }
$pdfSize = (Get-Item -LiteralPath $pdfPath).Length
Write-Host ("=== PDF listo: {0} ({1:N0} B) ===" -f $pdfPath, $pdfSize)
