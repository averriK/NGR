#Requires -Version 5.1
# Remove the command installed under a prefix through its ownership receipt.
# The R package, its dependencies and R itself are left in place. Run in
# PowerShell from the repository:
#
#   powershell -ExecutionPolicy Bypass -File install\uninstall.ps1 [-Yes] [-Prefix DIR] [-NoPath]
#
# The prefix defaults to %LOCALAPPDATA%\Programs\<product>. The user PATH
# loses only the bin entry this installer added. The receipt is read with the
# jsonlite of the user's default R library (R_LIBS_USER), resolved by R.
[CmdletBinding()]
param(
    [switch]$Yes,
    [string]$Prefix = '',
    [string]$Library = '',
    [switch]$NoPath
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath

function Write-Ok { param([string]$Text) Write-Host "[OK]   $Text" }
function Write-Info { param([string]$Text) Write-Host "[INFO] $Text" }
function Write-Warn2 { param([string]$Text) [Console]::Error.WriteLine("[WARN] $Text") }
function Stop-Install { param([string]$Text) [Console]::Error.WriteLine("[ERROR] $Text"); exit 1 }
. (Join-Path $Root 'install\cli\r.ps1')

$encodingBefore = [Console]::OutputEncoding
try {
[Console]::OutputEncoding = New-Object Text.UTF8Encoding($false)
$Rscript = Resolve-Rscript
if (-not $Rscript) { Stop-Install 'Rscript.exe is not on PATH or in the registry; the receipt cannot be read.' }
if (-not $Library) { $Library = (& $Rscript --vanilla -e 'cat(path.expand(Sys.getenv(''R_LIBS_USER'')))') -join '' }
if (-not $Library) { Stop-Install "R reports no user library (R_LIBS_USER) for $env:USERNAME" }
$facts = (& $Rscript --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], ''lib/DESCRIPTION''), fields = ''Package'')
Cli <- source(file.path(Args[1L], ''install/requirements.R''), local = TRUE)$value
cat(Dcf[1L, ''Package''], Cli$command, sep = ''\n'')
cat(if (length(Cli$runtime)) Cli$runtime else Cli$command, ''\n'', sep = '''')' $Root) | ForEach-Object { $_ }
$PackageName = $facts[0]
$Command = $facts[1]
$Runtime = $facts[2]
if (-not $Prefix) { $Prefix = Join-Path $env:LOCALAPPDATA "Programs\$PackageName" }
if ($Prefix -notmatch '^[A-Za-z]:[\\/]|^\\\\') { $Prefix = Join-Path (Get-Location).Path $Prefix }

$receipt = Join-Path $Prefix "libexec\$Runtime\install.json"
if (-not (Test-Path -LiteralPath $receipt)) { Stop-Install "No installation receipt at $receipt; existing paths cannot be attributed to $PackageName." }
Write-Info "$PackageName CLI recorded at $receipt"
if (-not $Yes) {
    $answer = Read-Host "Remove the $Command CLI under $Prefix? [y/N]"
    if ($answer -notmatch '^[yY]$') { Write-Host 'Aborted by user.'; exit 0 }
}
$record = Get-Content -LiteralPath $receipt -Raw -Encoding UTF8 | ConvertFrom-Json
$env:R_LIBS = if ($env:R_LIBS) { "$Library;$env:R_LIBS" } else { $Library }
# Windows keeps Rscript's input file open; removal must run outside its payload.
$removal = Join-Path ([IO.Path]::GetTempPath()) ('cli-removal-' + [guid]::NewGuid().ToString('N'))
try {
    foreach ($file in 'lib\DESCRIPTION', 'install\requirements.R', 'install\manifest.json', 'install\cli\manage.R', 'install\cli\checkPaths.ps1') {
        $target = Join-Path $removal $file
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $Root $file) -Destination $target
    }
    & $Rscript --vanilla (Join-Path $removal 'install\cli\manage.R') uninstall $Prefix
    $status = $LASTEXITCODE
} finally {
    if (Test-Path -LiteralPath $removal) { Remove-Item -LiteralPath $removal -Recurse -Force }
}
if ($status -ne 0) { Stop-Install "manage.R uninstall exited with $status" }
Write-Ok "$Command CLI removed from $Prefix"
$binDir = Join-Path $Prefix 'bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not $NoPath -and $record.pathAdded -eq $true -and $userPath -and (($userPath -split ';') -contains $binDir)) {
    $newPath = (($userPath -split ';') | Where-Object { $_ -ne $binDir }) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Ok "User PATH: removed $binDir"
}
$remaining = Get-Command $Command -CommandType Application -ErrorAction SilentlyContinue
if ($remaining) { Write-Warn2 "$Command is still first on PATH: $($remaining.Source)" }
} finally {
    [Console]::OutputEncoding = $encodingBefore
}
