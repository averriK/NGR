#Requires -Version 5.1
# Family installer for Windows: detects R (R is never installed by this
# script), installs the checkout package in the selected R library,
# and installs the command (CMD and PowerShell
# launchers) under the prefix. Run in PowerShell from the repository:
#
#   powershell -ExecutionPolicy Bypass -File install\install.ps1 [-Yes] [-Prefix DIR]
#       [-Tarball FILE] [-NoPath]
#
# The prefix defaults to %LOCALAPPDATA%\Programs\<product>, which needs no
# elevation; its bin directory is added to the user PATH unless -NoPath.
# The R library defaults to R_LIBS_USER; -Library overrides it.
# -Check validates destinations without building; -Dependency accepts archives.
[CmdletBinding()]
param(
    [switch]$Yes,
    [string]$Prefix = '',
    [string]$Library = '',
    [string[]]$Dependency = @(),
    [switch]$Check,
    [string]$Tarball = '',
    [switch]$NoPath
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$Stages = 5

function Write-Stage { param([int]$Number, [string]$Title) Write-Host ''; Write-Host "== Stage $Number/$Stages`: $Title ==" }
function Write-Ok { param([string]$Text) Write-Host "[OK]   $Text" }
function Write-Info { param([string]$Text) Write-Host "[INFO] $Text" }
function Write-Warn2 { param([string]$Text) [Console]::Error.WriteLine("[WARN] $Text") }
function Stop-Install { param([string]$Text) [Console]::Error.WriteLine("[ERROR] $Text"); exit 1 }
function Invoke-Logged {
    # Runs a program, echoes its output and stops on a failure.
    param([string]$Program, [string[]]$Arguments, [string]$WorkingDirectory = $Root)
    Write-Info ("> " + $Program + ' ' + ($Arguments -join ' '))
    $previousPreference = $ErrorActionPreference
    Push-Location -LiteralPath $WorkingDirectory
    try {
        $ErrorActionPreference = 'Continue'
        $output = & $Program @Arguments 2>&1
        $status = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
        Pop-Location
    }
    $output | ForEach-Object { Write-Host ("       " + $_) }
    if ($status -ne 0) { Stop-Install "$Program exited with $status" }
}
function Confirm-Step {
    param([string]$Question)
    if ($Yes) { return }
    Write-Host "$Question [y/N] " -NoNewline
    $answer = [Console]::ReadLine()
    if ($null -eq $answer) { Stop-Install 'End of input while confirming replacement; nothing was installed. Use -Yes for unattended installation.' }
    if ($answer -notmatch '^[yY]$') { Write-Host 'Aborted by user.'; exit 0 }
}
. (Join-Path $Root 'install\cli\r.ps1')

# ------------------------------------------------------------------ stage 1
$encodingBefore = [Console]::OutputEncoding
try {
[Console]::OutputEncoding = New-Object Text.UTF8Encoding($false)
Write-Stage 1 'Requirements'
$Rscript = Resolve-Rscript
if (-not $Rscript) { Stop-Install 'R is not installed or Rscript.exe is not on PATH or in the registry. Install R from https://cran.r-project.org/ and run this installer again.' }
$rVersion = (& $Rscript --vanilla -e 'cat(R.version$major, R.version$minor, sep = ''.'')') -join ''
$rMinimum = ((Get-Content -LiteralPath (Join-Path $Root 'lib\DESCRIPTION') | Select-String -Pattern 'R \(>= ([0-9.]+)\)').Matches | Select-Object -First 1).Groups[1].Value
if ($rMinimum) {
    $rOk = (& $Rscript --vanilla -e "cat(as.character(utils::compareVersion('$rVersion', '$rMinimum') >= 0))") -join ''
    if ($rOk -ne 'TRUE') { Stop-Install "R $rVersion is older than the required $rMinimum`: $Rscript" }
}
Write-Ok "R $rVersion at $Rscript"
$gitFound = [bool](Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue)
if ($gitFound) { Write-Ok 'git found; the receipt records the source commit' } else { Write-Warn2 'git not found; the receipt records the source as unknown' }
$pandocFound = [bool](Get-Command pandoc.exe -CommandType Application -ErrorAction SilentlyContinue)
if (-not $pandocFound) { Write-Warn2 'pandoc not found; documentation builds remain a separate maintenance operation' }

$facts = (& $Rscript --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], ''lib/DESCRIPTION''), fields = c(''Package'', ''Version''))
cat(Dcf[1L, ''Package''], Dcf[1L, ''Version''], sep = ''\n'')
File <- file.path(Args[1L], ''install/requirements.R'')
if (file.exists(File)) {
  Cli <- source(File, local = TRUE)$value
  Field <- function(x) if (length(x)) x else ''''
  cat(Field(Cli$command), Field(Cli$runtime),
      paste(Cli$tools, collapse = '' ''), paste(Cli$optional, collapse = '' ''), sep = ''\n'')
}' $Root) | ForEach-Object { $_ }
$PackageName = $facts[0]
$sourceVersion = $facts[1]
$Command = $facts[2]
$Runtime = $facts[3]; if (-not $Runtime) { $Runtime = $Command }
$Tools = $facts[4]
$Optional = $facts[5]
if (-not $PackageName -or -not $sourceVersion) { Stop-Install 'lib\DESCRIPTION must identify Package and Version' }
if (-not $Command) { Stop-Install 'This product needs a CLI declaration in install\requirements.R' }
if ($Tools) {
    foreach ($tool in $Tools -split ' ') {
        if (-not (Get-Command $tool -CommandType Application -ErrorAction SilentlyContinue)) { Stop-Install "Required executable unavailable: $tool" }
    }
}
if ($Optional) {
    foreach ($tool in $Optional -split ' ') {
        if (-not (Get-Command $tool -CommandType Application -ErrorAction SilentlyContinue)) { Write-Warn2 "Optional tool not found: $tool" }
    }
}
if (-not $Library) { $Library = (& $Rscript --vanilla -e 'cat(path.expand(Sys.getenv(''R_LIBS_USER'')))') -join '' }
if (-not $Library) { Stop-Install "R reports no user library (R_LIBS_USER) for $env:USERNAME" }
Write-Ok "R library: $Library"
if (-not $Prefix) { $Prefix = Join-Path $env:LOCALAPPDATA "Programs\$PackageName" }
if ($Prefix -notmatch '^[A-Za-z]:[\\/]|^\\\\') { $Prefix = Join-Path (Get-Location).Path $Prefix }
if ($Tarball -and $Tarball -notmatch '^[A-Za-z]:[\\/]|^\\\\') { $Tarball = Join-Path (Get-Location).Path $Tarball }

Write-Host ''
Write-Host "$PackageName installation"
Write-Host "Source:  $Root"
Write-Host "Prefix:  $Prefix"
Write-Host "Library: $Library"
Write-Host "R user:  $env:USERNAME"
if ($Tarball) { Write-Host "Archive: $Tarball" }
Write-Host ''

$previous = Get-Command $Command -CommandType Application -ErrorAction SilentlyContinue
if ($previous -and $previous.Source -ne (Join-Path $Prefix "bin\$Command.cmd")) { Write-Warn2 "a previous $Command is first on PATH: $($previous.Source)" }
foreach ($file in 'lib\DESCRIPTION', 'install\requirements.R', 'install\manifest.json', 'install\cli\manage.R',
                  'install\cli\checkPaths.ps1', 'install\installProduct.R', 'install\package.R', 'install\product.R') {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $file))) { Stop-Install "Missing source file: $file" }
}
Write-Ok 'Payload complete: manifest, manager and launchers listed in install\manifest.json'

# ------------------------------------------------------------------ stage 2
Write-Stage 2 'R package'
$env:R_LIBS = if ($env:R_LIBS) { "$Library;$env:R_LIBS" } else { $Library }
Invoke-Logged $Rscript @('--vanilla', (Join-Path $Root 'install\cli\manage.R'), 'check', $Prefix)
if ($Check) { Write-Ok 'Check passed; nothing was installed'; exit 0 }
$installedVersion = (& $Rscript --vanilla -e 'Args <- commandArgs(TRUE); if (dir.exists(file.path(Args[2L], Args[1L]))) cat(as.character(utils::packageVersion(Args[1L], lib.loc = Args[2L])))' $PackageName $Library) -join ''
if ($LASTEXITCODE -ne 0) { Stop-Install 'Cannot read the installed package metadata' }
if ($installedVersion) { Write-Info "Installed: $PackageName $installedVersion in $Library" } else { Write-Info "$PackageName is not installed in $Library" }
Write-Info "Source:    $PackageName $sourceVersion"

$runtimeDir = Join-Path $Prefix "libexec\$Runtime"
$receipt = Join-Path $runtimeDir 'install.json'
$replace = [bool]$installedVersion
if ((Test-Path -LiteralPath $receipt)) {
    $replace = $true
    Write-Info "Existing $PackageName CLI recorded at $receipt; it will be replaced through its receipt"
}
if ($Tarball -and (-not (Test-Path -LiteralPath $Tarball) -or -not (Test-Path -LiteralPath "$Tarball.rds"))) {
    Stop-Install "Package archive and its .rds record are required: $Tarball"
}
if ($replace) { Confirm-Step "Replace $PackageName library and CLI at the destinations shown above?" }

# The product installer (install\installProduct.R) owns every check and
# installation: artifact identity, dependencies, CLI tools and packages,
# exports, library shadowing. This script sequences it.
$kit = @('--vanilla', (Join-Path $Root 'install\installProduct.R'), $Root)
foreach ($archive in $Dependency) { $kit += @('--dependency', $archive) }
if ($Tarball) {
    $kit += @('--tarball', $Tarball)
} else {
    $buildDir = Join-Path ([System.IO.Path]::GetTempPath()) ("$PackageName-build-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    Write-Info "Building $PackageName $sourceVersion without manual or vignettes into $buildDir"
    $kit += @('--build', $buildDir)
}
$kit += @('--library', $Library, '--prefix', $Prefix)
Write-Info 'Product installer: checks, dependencies, package and CLI'
try { Invoke-Logged $Rscript $kit } finally {
    if ($buildDir -and (Test-Path -LiteralPath $buildDir)) { Remove-Item -LiteralPath $buildDir -Recurse -Force }
}
$installedVersion = (& $Rscript --vanilla -e 'Args <- commandArgs(TRUE); cat(as.character(utils::packageVersion(Args[1L], lib.loc = Args[2L])))' $PackageName $Library) -join ''
if ($LASTEXITCODE -ne 0) { Stop-Install 'Cannot read the installed package metadata' }
Write-Ok "$PackageName $installedVersion installed in $Library"

# ------------------------------------------------------------------ stage 3
Write-Stage 3 'Command-line interface'
$listed = & $Rscript --vanilla -e 'R <- jsonlite::read_json(commandArgs(TRUE)[1L], simplifyVector = TRUE); cat(file.path(commandArgs(TRUE)[2L], R$file), sep = ''\n'')' "$receipt" "$Prefix/"
foreach ($file in $listed) {
    if (-not (Test-Path -LiteralPath $file)) { Stop-Install "Expected installed file is missing: $file" }
    Write-Host "  - $file"
}
Write-Ok "$Command CLI installed under $Prefix"

# ------------------------------------------------------------------ stage 4
Write-Stage 4 'Verification'
Write-Ok "$Command verification passed before committing the CLI transaction"
$binDir = Join-Path $Prefix 'bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$onPath = ($userPath -split ';') -contains $binDir -or ($env:Path -split ';') -contains $binDir
if ($onPath) {
    Write-Ok "$binDir is on PATH"
} elseif ($NoPath) {
    Write-Warn2 "$binDir is not on PATH; add it to call $Command by name"
} else {
    $newPath = if ($userPath) { "$userPath;$binDir" } else { $binDir }
    try {
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        $record = Get-Content -LiteralPath $receipt -Raw -Encoding UTF8 | ConvertFrom-Json
        $record | Add-Member -NotePropertyName pathAdded -NotePropertyValue $true -Force
        [IO.File]::WriteAllText($receipt, ($record | ConvertTo-Json -Depth 20), (New-Object Text.UTF8Encoding($false)))
    } catch {
        [Environment]::SetEnvironmentVariable('Path', $userPath, 'User')
        throw
    }
    Write-Ok "User PATH: added $binDir (open a new terminal to use it)"
}
$defaultLibrary = (& $Rscript --vanilla -e 'cat(path.expand(Sys.getenv(''R_LIBS_USER'')))') -join ''
if (($Library -replace '\\', '/') -ne ($defaultLibrary -replace '\\', '/')) { Write-Warn2 "$Library is not the default R user library; keep R_LIBS=$Library in the shell that runs $Command" }

# ------------------------------------------------------------------ stage 5
Write-Stage 5 'Summary'
Write-Ok "$PackageName $installedVersion in $Library"
Write-Ok "$(Join-Path $Prefix "bin\$Command.cmd"), receipt $receipt"
Write-Host ''
Write-Host "Usage: $Command --help, $Command --version"
Write-Host 'Remove the CLI: powershell -ExecutionPolicy Bypass -File install\uninstall.ps1 [-Prefix DIR]'
Write-Host ''
Write-Host "The R package remains separate from CLI removal. Selected library: $Library"
} finally {
    [Console]::OutputEncoding = $encodingBefore
}
