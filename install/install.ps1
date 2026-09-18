#Requires -Version 5.1
# Family installer for Windows: detects R (R is never installed by this
# script), makes sure the product R package is installed in the selected
# library at the source version, and installs the command (CMD and PowerShell
# launchers) under the prefix. Run in PowerShell from the repository:
#
#   powershell -ExecutionPolicy Bypass -File install\install.ps1 [-Yes] [-Prefix DIR]
#       [-Tarball FILE | -Build] [-Component all|lib|cli] [-NoPath]
#
# The prefix defaults to %LOCALAPPDATA%\Programs\<product>, which needs no
# elevation; its bin directory is added to the user PATH unless -NoPath.
# The R library is always the user's default R library (R_LIBS_USER),
# resolved by R itself; it is never an argument.
[CmdletBinding()]
param(
    [switch]$Yes,
    [string]$Prefix = '',
    [string]$Tarball = '',
    [switch]$Build,
    [ValidateSet('all', 'lib', 'cli')][string]$Component = 'all',
    [switch]$NoPath
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
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
    $output = & {
        Push-Location -LiteralPath $WorkingDirectory
        try { & $Program @Arguments 2>&1 } finally { Pop-Location }
    }
    $output | ForEach-Object { Write-Host ("       " + $_) }
    if ($LASTEXITCODE -ne 0) { Stop-Install "$Program exited with $LASTEXITCODE" }
}
function Confirm-Step {
    param([string]$Question)
    if ($Yes) { return }
    $answer = Read-Host "$Question [y/N]"
    if ($answer -notmatch '^[yY]$') { Write-Host 'Aborted by user.'; exit 0 }
}
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

# ------------------------------------------------------------------ stage 1
Write-Stage 1 'Requirements'
$Rscript = Resolve-Rscript
if (-not $Rscript) { Stop-Install 'R is not installed or Rscript.exe is not on PATH or in the registry. Install R from https://cran.r-project.org/ and run this installer again.' }
$rVersion = (& $Rscript --vanilla -e 'cat(R.version$major, R.version$minor, sep = ".")') -join ''
$rMinimum = ((Get-Content -LiteralPath (Join-Path $Root 'lib\DESCRIPTION') | Select-String -Pattern 'R \(>= ([0-9.]+)\)').Matches | Select-Object -First 1).Groups[1].Value
if ($rMinimum) {
    $rOk = (& $Rscript --vanilla -e "cat(as.character(utils::compareVersion('$rVersion', '$rMinimum') >= 0))") -join ''
    if ($rOk -ne 'TRUE') { Stop-Install "R $rVersion is older than the required $rMinimum`: $Rscript" }
}
Write-Ok "R $rVersion at $Rscript"
$gitFound = [bool](Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue)
if ($gitFound) { Write-Ok 'git found; the receipt records the source commit' } else { Write-Warn2 'git not found; the receipt records the source as unknown' }
$pandocFound = [bool](Get-Command pandoc.exe -CommandType Application -ErrorAction SilentlyContinue)
if ($pandocFound) { Write-Ok 'pandoc found; package manual and vignettes will be built' } else { Write-Warn2 'pandoc not found; the package builds without manual or vignettes' }

$facts = (& $Rscript --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], "lib/DESCRIPTION"), fields = c("Package", "Version"))
cat(Dcf[1L, "Package"], Dcf[1L, "Version"], sep = "\n")
File <- file.path(Args[1L], "install/requirements.R")
if (file.exists(File)) {
  Cli <- source(File, local = TRUE)$value
  Field <- function(x) if (length(x)) x else ""
  cat(Field(Cli$command), Field(Cli$runtime), Field(Cli$minimum),
      paste(Cli$tools, collapse = " "), paste(Cli$optional, collapse = " "),
      Field(Cli$verify), sep = "\n")
}' $Root) | ForEach-Object { $_ }
$PackageName = $facts[0]
$sourceVersion = $facts[1]
$Command = $facts[2]
$Runtime = $facts[3]; if (-not $Runtime) { $Runtime = $Command }
$Minimum = $facts[4]
$Tools = $facts[5]
$Optional = $facts[6]
$Verify = $facts[7]
if (-not $PackageName -or -not $sourceVersion) { Stop-Install 'lib\DESCRIPTION must identify Package and Version' }
if ($Component -ne 'lib' -and -not $Command) { Stop-Install 'This product has no implemented CLI (install\requirements.R); use -Component lib' }
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
$Library = (& $Rscript --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))') -join ''
if (-not $Library) { Stop-Install "R reports no user library (R_LIBS_USER) for $env:USERNAME" }
if (-not (Test-Path -LiteralPath $Library)) { New-Item -ItemType Directory -Path $Library | Out-Null }
Write-Ok "R library: $Library"
if (-not $Prefix) { $Prefix = Join-Path $env:LOCALAPPDATA "Programs\$PackageName" }
if ($Prefix -notmatch '^[A-Za-z]:[\\/]|^\\\\') { $Prefix = Join-Path (Get-Location).Path $Prefix }
if ($Tarball -and $Tarball -notmatch '^[A-Za-z]:[\\/]|^\\\\') { $Tarball = Join-Path (Get-Location).Path $Tarball }
if ($Tarball -and $Build) { Stop-Install 'Select exactly one of -Tarball or -Build' }

Write-Host ''
Write-Host "$PackageName installation"
Write-Host "Source:  $Root"
Write-Host "Prefix:  $Prefix"
Write-Host "Library: $Library"
Write-Host "R user:  $env:USERNAME"
Write-Host ''

if ($Command) {
    $previous = Get-Command $Command -CommandType Application -ErrorAction SilentlyContinue
    if ($previous -and $previous.Source -ne (Join-Path $Prefix "bin\$Command.cmd")) { Write-Warn2 "a previous $Command is first on PATH: $($previous.Source)" }
    foreach ($file in 'lib\DESCRIPTION', 'install\requirements.R', 'install\manifest.json', 'install\cli\manage.R',
                      'install\cli\checkPaths.ps1', 'install\installProduct.R', 'install\package.R', 'install\product.R') {
        if (-not (Test-Path -LiteralPath (Join-Path $Root $file))) { Stop-Install "Missing source file: $file" }
    }
    Write-Ok 'Payload complete: manifest, manager and launchers listed in install\manifest.json'
}

# ------------------------------------------------------------------ stage 2
Write-Stage 2 'R package'
$libraryR = $Library -replace '\\', '/'
$installedVersion = (& $Rscript --vanilla -e "cat(tryCatch(as.character(utils::packageVersion('$PackageName', lib.loc = '$libraryR')), error = function(e) ''))") -join ''
if ($installedVersion) { Write-Info "Installed: $PackageName $installedVersion in $Library" } else { Write-Info "$PackageName is not installed in $Library" }
Write-Info "Source:    $PackageName $sourceVersion"

# The product installer (install\installProduct.R) owns every check and
# installation: artifact identity, dependencies, CLI tools and packages,
# exports, library shadowing. This script sequences it.
$kit = @('--vanilla', (Join-Path $Root 'install\installProduct.R'), $Root)
$componentEffective = $Component
if ($Component -eq 'cli') {
    if (-not $installedVersion) { Stop-Install "-Component cli needs $PackageName installed in $Library" }
    Write-Ok 'Library stage skipped (-Component cli)'
} elseif (-not $installedVersion -or $Tarball -or $Build) {
    if ($installedVersion) { Confirm-Step "Replace $PackageName $installedVersion in $Library with the selected package?" }
    if ($Tarball) {
        if (-not (Test-Path -LiteralPath $Tarball) -or -not (Test-Path -LiteralPath "$Tarball.rds")) { Stop-Install "Package archive and its .rds record are required: $Tarball" }
        $kit += @('--tarball', $Tarball)
    } elseif ($pandocFound) {
        $buildDir = Join-Path ([System.IO.Path]::GetTempPath()) ("$PackageName-build-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
        Write-Info "Building $PackageName $sourceVersion with manual and vignettes into $buildDir"
        Invoke-Logged $Rscript @('--vanilla', '..\install\build.R', $buildDir) (Join-Path $Root 'lib')
        $Tarball = Join-Path $buildDir "$PackageName`_$sourceVersion.tar.gz"
        if (-not (Test-Path -LiteralPath $Tarball) -or -not (Test-Path -LiteralPath "$Tarball.rds")) { Stop-Install "Build did not produce $Tarball and its .rds" }
        $kit += @('--tarball', $Tarball)
    } else {
        $buildDir = Join-Path ([System.IO.Path]::GetTempPath()) ("$PackageName-build-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
        Write-Info "Building $PackageName $sourceVersion without manual or vignettes into $buildDir"
        $kit += @('--build', $buildDir)
    }
} elseif ($installedVersion -eq $sourceVersion) {
    Write-Ok "$PackageName $installedVersion is already installed at the source version; library unchanged"
    $componentEffective = 'cli'
} else {
    if ($Minimum) {
        $belowMinimum = (& $Rscript --vanilla -e "cat(as.character(utils::compareVersion('$installedVersion', '$Minimum') < 0))") -join ''
        if ($belowMinimum -eq 'TRUE') { Stop-Install "Installed $PackageName $installedVersion is older than the CLI minimum $Minimum. Update explicitly: powershell -ExecutionPolicy Bypass -File install\install.ps1 -Build" }
    }
    Stop-Install "Installed $PackageName $installedVersion differs from source $sourceVersion. Update explicitly: powershell -ExecutionPolicy Bypass -File install\install.ps1 -Build"
}
$kit += @('--component', $componentEffective, '--library', $Library)
if ($componentEffective -ne 'lib') { $kit += @('--prefix', $Prefix) }
$runtimeDir = Join-Path $Prefix "libexec\$Runtime"
$receipt = Join-Path $runtimeDir 'install.json'
if ($componentEffective -ne 'lib' -and (Test-Path -LiteralPath $receipt)) {
    Write-Info "Existing $PackageName CLI recorded at $receipt; it will be replaced through its receipt"
    Confirm-Step "Replace the $Command CLI under $Prefix?"
}
Write-Info 'Product installer: checks, dependencies, package and CLI'
Invoke-Logged $Rscript $kit
if ($componentEffective -ne 'cli') {
    $installedVersion = (& $Rscript --vanilla -e "cat(as.character(utils::packageVersion('$PackageName', lib.loc = '$libraryR')))") -join ''
    Write-Ok "$PackageName $installedVersion installed in $Library"
}

# ------------------------------------------------------------------ stage 3
Write-Stage 3 'Command-line interface'
if ($componentEffective -eq 'lib') {
    Write-Ok 'CLI stage skipped (-Component lib)'
} else {
    $env:R_LIBS = $Library
    $listed = & $Rscript --vanilla -e 'R <- jsonlite::read_json(commandArgs(TRUE)[1L], simplifyVector = TRUE); cat(file.path(commandArgs(TRUE)[2L], R$file), sep = "\n")' "$receipt" "$Prefix/"
    foreach ($file in $listed) {
        if (-not (Test-Path -LiteralPath $file)) { Stop-Install "Expected installed file is missing: $file" }
        Write-Host "  - $file"
    }
    Write-Ok "$Command CLI installed under $Prefix"
}

# ------------------------------------------------------------------ stage 4
Write-Stage 4 'Verification'
if ($componentEffective -eq 'lib') {
    Invoke-Logged $Rscript @('--vanilla', '-e', "invisible(loadNamespace('$PackageName', lib.loc = '$libraryR')); cat('$PackageName', as.character(utils::packageVersion('$PackageName', lib.loc = '$libraryR')), 'loads')")
    Write-Ok 'Package loads'
} else {
    $env:R_LIBS = $Library
    Invoke-Logged (Join-Path $Prefix "bin\$Command.cmd") @('--version')
    Write-Ok "$Command answers from $Prefix with $PackageName $installedVersion"
    if ($Verify) {
        Invoke-Logged (Join-Path $Prefix "bin\$Command.cmd") @($Verify)
        Write-Ok "$Command $Verify passed"
    }
    $binDir = Join-Path $Prefix 'bin'
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $onPath = ($userPath -split ';') -contains $binDir -or ($env:Path -split ';') -contains $binDir
    if ($onPath) {
        Write-Ok "$binDir is on PATH"
    } elseif ($NoPath) {
        Write-Warn2 "$binDir is not on PATH; add it to call $Command by name"
    } else {
        $newPath = if ($userPath) { "$userPath;$binDir" } else { $binDir }
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Ok "User PATH: added $binDir (open a new terminal to use it)"
    }
    $defaultLibrary = (& $Rscript --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))') -join ''
    if (($Library -replace '\\', '/') -ne ($defaultLibrary -replace '\\', '/')) { Write-Warn2 "$Library is not the default R user library; keep R_LIBS=$Library in the shell that runs $Command" }
}

# ------------------------------------------------------------------ stage 5
Write-Stage 5 'Summary'
Write-Ok "$PackageName $installedVersion in $Library"
if ($componentEffective -ne 'lib') {
    Write-Ok "$(Join-Path $Prefix "bin\$Command.cmd"), receipt $receipt"
    Write-Host ''
    Write-Host "Usage: $Command --help, $Command --version"
    Write-Host 'Remove the CLI: powershell -ExecutionPolicy Bypass -File install\uninstall.ps1 [-Prefix DIR]'
}
Write-Host ''
Write-Host "The R package is separate: Rscript -e 'remove.packages(`"$PackageName`")'"
