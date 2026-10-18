# Build SOLO PDF (track LaTeX 7x10") para el "Manual de usuario de nopCommerce".
# Derivado de build_pdf_nopcommerce.ps1, sin portada de imagen ni ISBN.
# Uso: pwsh publicacion/script/build_pdf_usuario_nopcommerce.ps1 [-Libro 'Manual de usuario V01 de nopCommerce.md']
# Copyright de uso personal (sin "todos los derechos reservados" ni ISBN).
# El fuente real NUNCA se modifica: se construye sobre una copia en _build.
# Fuentes empaquetadas en publicacion/script/fonts y cargadas por ruta.
param(
    [string]$Libro = "Manual de usuario V01 de nopCommerce.md"
)
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$scriptDir = $PSScriptRoot
$imprimirDir = [IO.Path]::GetFullPath((Join-Path $scriptDir "../imprimir"))
Set-Location $root

if (-not (Test-Path -LiteralPath $Libro)) {
    throw "No existe el fuente: $Libro"
}

# Registro de tecnologías
$techKey = "NOPCOMMERCE_USUARIO"
$reg = Get-Content -Raw -Encoding UTF8 (Join-Path $scriptDir "tecnologias.json") | ConvertFrom-Json
$t = $reg.$techKey
$subtitulo = $t.subtitulo

# Detectar Python
$pyCmd = Get-Command py -ErrorAction SilentlyContinue
if (-not $pyCmd) { $pyCmd = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $pyCmd) { $pyCmd = Get-Command python -ErrorAction SilentlyContinue }
if (-not $pyCmd) { throw "No se encontró Python (py/python3/python)" }
$python = $pyCmd.Source

# Página de copyright (uso personal, con atribución a nopCommerce)
$copyrightFile = Join-Path $imprimirDir "copyright_usuario_generado.tex"
$copyrightContent = @"
\thispagestyle{empty}
% Rutas de capturas: la raiz del proyecto (donde pandoc escribe img/usuario/...)
% frente al directorio de build (imprimir) desde el que corre xelatex.
\graphicspath{{$($root -replace '\\','/')/}}
\vspace*{8cm}
\begin{center}
\begin{minipage}{0.84\textwidth}
\small
\textcopyright\ 2026 César Delgado Ruiz.\\
\medskip
\textbf{Manual de usuario de nopCommerce}.\\
$subtitulo\\
\medskip
Documento de uso personal y autoaprendizaje. No está destinado a la venta ni a la publicación.\\
\medskip
Basado en la documentación oficial de nopCommerce 4.90.8. nopCommerce es una marca comercial de nop Solutions Ltd. Las capturas de pantalla y los contenidos de esa documentación pertenecen a nop Solutions Ltd y se reproducen con atribución. nopCommerce se distribuye bajo licencia de código abierto (licencia oficial en el repositorio). Este documento no está afiliado a nop Solutions Ltd.\\
\end{minipage}
\end{center}
\clearpage
"@
Set-Content -LiteralPath $copyrightFile -Value $copyrightContent -Encoding UTF8

$libroBase = "Manual_$($t.archivo)"
$libroTex = "${libroBase}_Libro.tex"
$libroPdf = "${libroBase}_Libro.pdf"
$libroLog = "${libroBase}_Libro.log"

Write-Host "=== 1/1 Interior PDF 7x10 (manual de usuario) ==="
pandoc $Libro -s -t latex --from markdown+lists_without_preceding_blankline-implicit_figures --lua-filter (Join-Path $scriptDir "filtro_libro_nopcommerce.lua") `
  -H (Join-Path $scriptDir "header_usuario.tex") -H "header_pdf.tex" `
  -H (Join-Path $scriptDir "fuentes_libro.tex") `
  --include-before-body $copyrightFile `
  --toc --toc-depth=1 --number-sections `
  -V documentclass=book `
  -V geometry:paperwidth=7in -V geometry:paperheight=10in `
  -V geometry:top=20mm -V geometry:bottom=22mm `
  -V geometry:outer=20mm -V geometry:inner=23mm -V geometry:twoside `
  -V fontsize=12pt -V linestretch=1.15 `
  --metadata title="Manual de usuario de nopCommerce" `
  --metadata author="César Delgado Ruiz" `
  --metadata lang="es" --metadata date="2026" `
  --metadata subtitle="$subtitulo" `
  -o (Join-Path $imprimirDir $libroTex)

Push-Location $imprimirDir
try {
    foreach ($pasada in 1..2) {
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

# Verificación: nº de páginas.
$pdfPath = Join-Path $imprimirDir $libroPdf
$pagesRaw = & $python -c "import sys; from pypdf import PdfReader; print(len(PdfReader(sys.argv[1]).pages))" $pdfPath
$pages = [int]$pagesRaw.Trim()
Write-Host "Páginas: $pages"

$overfull = (Select-String -Path (Join-Path $imprimirDir $libroLog) -Pattern "Overfull \\hbox" -AllMatches |
    Measure-Object).Count
Write-Host "Overfull hbox: $overfull (revisar en el log si persisten)"
if (-not (Test-Path -LiteralPath $pdfPath)) { throw "No se generó el PDF: $pdfPath" }

# Nombre final solicitado (sin sufijo _Libro). Se MUEVE en vez de copiar para no
# dejar en imprimir/ un duplicado byte a byte del interior (42 MB).
$finalPdf = Join-Path $imprimirDir "Manual_NopCommerce_Del_Usuario.pdf"
Move-Item -LiteralPath $pdfPath -Destination $finalPdf -Force
$pdfSize = (Get-Item -LiteralPath $finalPdf).Length
Write-Host ("=== PDF listo: {0} ({1:N0} B) ===" -f $finalPdf, $pdfSize)
