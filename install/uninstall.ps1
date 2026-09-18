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
    [switch]$NoPath
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Write-Ok { param([string]$Text) Write-Host "[OK]   $Text" }
function Write-Info { param([string]$Text) Write-Host "[INFO] $Text" }
function Write-Warn2 { param([string]$Text) [Console]::Error.WriteLine("[WARN] $Text") }
function Stop-Install { param([string]$Text) [Console]::Error.WriteLine("[ERROR] $Text"); exit 1 }
function Resolve-Rscript {
    $command = Get-Command Rscript.exe -CommandType Application -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    foreach ($hive in 'HKLM:\SOFTWARE\R-core\R', 'HKCU:\SOFTWARE\R-core\R', 'HKLM:\SOFTWARE\WOW6432Node\R-core\R') {
        try { $install = (Get-ItemProperty -LiteralPath $hive -ErrorAction Stop).InstallPath } catch { continue }
        $candidate = Join-Path $install 'bin\Rscript.exe'
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}

$Rscript = Resolve-Rscript
if (-not $Rscript) { Stop-Install 'Rscript.exe is not on PATH or in the registry; the receipt cannot be read.' }
$Library = (& $Rscript --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))') -join ''
if (-not $Library) { Stop-Install "R reports no user library (R_LIBS_USER) for $env:USERNAME" }
$facts = (& $Rscript --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], "lib/DESCRIPTION"), fields = "Package")
Cli <- source(file.path(Args[1L], "install/requirements.R"), local = TRUE)$value
cat(Dcf[1L, "Package"], Cli$command, sep = "\n")
cat(if (length(Cli$runtime)) Cli$runtime else Cli$command, "\n", sep = "")' $Root) | ForEach-Object { $_ }
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
$env:R_LIBS = $Library
& $Rscript --vanilla (Join-Path $Root 'install\cli\manage.R') uninstall $Prefix
if ($LASTEXITCODE -ne 0) { Stop-Install "manage.R uninstall exited with $LASTEXITCODE" }
Write-Ok "$Command CLI removed from $Prefix"
$binDir = Join-Path $Prefix 'bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not $NoPath -and $userPath -and (($userPath -split ';') -contains $binDir)) {
    $newPath = (($userPath -split ';') | Where-Object { $_ -ne $binDir }) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Ok "User PATH: removed $binDir"
}
$remaining = Get-Command $Command -CommandType Application -ErrorAction SilentlyContinue
if ($remaining) { Write-Warn2 "$Command is still first on PATH: $($remaining.Source)" }
Write-Host "The R package in $Library is untouched. To remove it: Rscript -e 'remove.packages(`"$PackageName`")'"
