# Build DOCX (Word) para los manuales de nopCommerce (uso personal).
# pandoc + reference-doc + filtro_portada_docx.lua (limita el ancho de la
# portada cover*.png a 6in para la página carta). NO se aplica
# filtro_libro_nopcommerce.lua, que emite LaTeX crudo para book.
# El índice general del manual se conserva: sus enlaces #capitulo-N se resuelven
# como bookmarks internos en Word. El fuente NUNCA se modifica.
# Uso:
#   pwsh publicacion/script/build_docx_nopcommerce.ps1 -Manual usuario
#   pwsh publicacion/script/build_docx_nopcommerce.ps1 -Manual desarrollo
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('usuario','desarrollo')]
    [string]$Manual
)
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$imprimirDir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../imprimir"))
Set-Location $root

$refDoc = Join-Path $imprimirDir "reference_usuario.docx"
if (-not (Test-Path -LiteralPath $refDoc)) {
    throw "No existe la plantilla de referencia: $refDoc"
}

switch ($Manual) {
    'usuario' {
        $Libro = "Manual de usuario V01 de nopCommerce.md"
        $titulo = "Manual de usuario de nopCommerce"
        $outName = "Manual_NopCommerce_Del_Usuario.docx"
    }
    'desarrollo' {
        $Libro = "Manual de desarrollo V01 de nopCommerce.md"
        $titulo = "Manual de desarrollo de nopCommerce"
        $outName = "Manual_NopCommerce_Del_Desarrollador.docx"
    }
}

if (-not (Test-Path -LiteralPath $Libro)) {
    throw "No existe el fuente: $Libro"
}

$out = Join-Path $imprimirDir $outName

Write-Host "=== Build DOCX ($Manual): $Libro ==="
# --resource-path=. resuelve img/... y img/usuario/... desde la raiz del proyecto.
# SIN --toc: el indice clicable lo aporta el propio "Índice general" del manual
# (enlaces #capitulo-N -> bookmarks de pandoc). --metadata title genera el
# bloque Title de portada. No se aplica --number-sections: los capitulos ya
# llevan "Capítulo N" en el titulo.
pandoc $Libro -s -t docx `
  --from markdown+lists_without_preceding_blankline `
  --reference-doc="$refDoc" `
  --resource-path=. `
  --lua-filter (Join-Path $PSScriptRoot "filtro_portada_docx.lua") `
  --metadata title="$titulo" `
  --metadata author="César Delgado Ruiz" `
  --metadata lang="es" `
  -o "$out"

if ($LASTEXITCODE -ne 0) { throw "pandoc falló (DOCX $Manual)." }
if (-not (Test-Path -LiteralPath $out)) { throw "No se generó el DOCX: $out" }

$size = (Get-Item -LiteralPath $out).Length
Write-Host ("=== DOCX listo: {0} ({1:N0} B) ===" -f $out, $size)
