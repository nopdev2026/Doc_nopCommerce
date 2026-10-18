# Backup de seguridad del fuente .md antes de cada build.
# Verifica la integridad (sin bytes nulos) y guarda una copia con marca de tiempo:
#   1) en publicacion/backups/  (local, junto al proyecto)
#   2) en /tmp/opencode/backups/ (fuera del disco NTFS, por si se vuelve a corromper)
# Uso: pwsh publicacion/script/backup_fuente.ps1 -Libro 'Libro_Vademecum_JavaScript_V03.md'
# Devuelve: $LASTEXITCODE = 0 OK, 1 = fuente corrupto (aborta el build).
param(
    [string]$Libro
)
$ErrorActionPreference = "Stop"

if (-not $Libro) { throw "Falta -Libro" }
if (-not (Test-Path -LiteralPath $Libro)) { throw "No existe el fuente: $Libro" }

# --- 1) Verificar integridad: detectar bytes NUL (patrón de corrupción NTFS) ---
$bytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Libro))
if ($bytes -contains 0) {
    throw "FUENTE CORRUPTO: $Libro contiene bytes NUL. Abortando el build. Restaurar desde una copia de seguridad."
}

# --- 2) Directorios de backup ---
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$localBackupDir = Join-Path $root "publicacion/backups"
$extBackupDir = "/tmp/opencode/backups"
New-Item -ItemType Directory -Force -Path $localBackupDir | Out-Null
New-Item -ItemType Directory -Force -Path $extBackupDir | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$base = [System.IO.Path]::GetFileNameWithoutExtension($Libro)
$destName = "${base}_${stamp}.md"

Copy-Item -LiteralPath $Libro -Destination (Join-Path $localBackupDir $destName) -Force
if (Test-Path $extBackupDir) {
    Copy-Item -LiteralPath $Libro -Destination (Join-Path $extBackupDir $destName) -Force
}

Write-Host "Backup OK: $destName (publicacion/backups y /tmp/opencode/backups)"