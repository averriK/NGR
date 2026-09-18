#Requires -Version 5.1
# Isolated tests of the family installer for the enclosing product, Windows
# edition. Scratch prefix and scratch R library with spaces and Unicode;
# profiles and environ are emptied. No elevation is used. Run from anywhere:
#   powershell -ExecutionPolicy Bypass -File install\cli\test-installers.ps1
$ErrorActionPreference = 'Continue'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:failures = 0
$LogFile = $null

function Report-Result { param([string]$Status, [string]$Label)
    Write-Host "  $Status`: $Label"
    if ($Status -eq 'FAIL') { $script:failures += 1 }
}
function Check {
    param([string]$Label, [scriptblock]$Probe)
    try {
        $result = & $Probe 2>&1
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { Report-Result 'FAIL' $Label; return }
        if ($result -is [bool] -and -not $result) { Report-Result 'FAIL' $Label; return }
        Report-Result 'PASS' $Label
    } catch {
        ($_ | Out-String) | Add-Content -LiteralPath $LogFile
        Report-Result 'FAIL' $Label
    }
}

$Rscript = (Get-Command Rscript.exe -CommandType Application -ErrorAction SilentlyContinue).Source
if (-not $Rscript) { Write-Host '[ERROR] Rscript is required to test the installer'; exit 1 }

$work = Join-Path ([System.IO.Path]::GetTempPath()) ('install-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $work | Out-Null
$LogFile = Join-Path $work 'test.log'
try {
    $realLib = (& $Rscript --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))') -join ''
    $Library = Join-Path $work 'library á with spaces'
    $Prefix = Join-Path $work 'prefix á with spaces'
    New-Item -ItemType Directory -Path $Library | Out-Null
    $env:R_LIBS_USER = $Library
    $env:R_LIBS = "$Library;$realLib"
    $env:R_ENVIRON_USER = Join-Path $work 'Renviron'
    $env:R_PROFILE_USER = Join-Path $work 'Rprofile'
    New-Item -ItemType File -Path $env:R_ENVIRON_USER, $env:R_PROFILE_USER | Out-Null

    $facts = (& $Rscript --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], "lib/DESCRIPTION"), fields = c("Package", "Version"))
cat(Dcf[1L, "Package"], Dcf[1L, "Version"], sep = "\n")
Cli <- source(file.path(Args[1L], "install/requirements.R"), local = TRUE)$value
Field <- function(x) if (length(x)) x else ""
cat(Field(Cli$command), Field(Cli$runtime), Field(Cli$minimum), Field(Cli$verify), sep = "\n")' $Root) | ForEach-Object { $_ }
    $PackageName = $facts[0]; $SourceVersion = $facts[1]; $Command = $facts[2]
    $Runtime = $facts[3]; if (-not $Runtime) { $Runtime = $Command }
    $Minimum = $facts[4]; $Verify = $facts[5]
    Write-Host "Testing $PackageName $SourceVersion ($Command) against $Prefix"
    $receipt = Join-Path $Prefix "libexec\$Runtime\install.json"
    $manager = Join-Path $Root 'install\cli\manage.R'
    $installer = Join-Path $Root 'install\install.ps1'
    $uninstaller = Join-Path $Root 'install\uninstall.ps1'

    $minversion = ((Get-Content -LiteralPath (Join-Path $Root 'cli\main.R') | Select-String -Pattern 'MINVERSION <- "([0-9.]+)"').Matches | Select-Object -First 1).Groups[1].Value
    if ($Minimum -or $minversion) {
        Check 'requirements.R minimum equals cli/main.R MINVERSION' { $Minimum -eq $minversion }
    }

    Check 'install.ps1 installs library and CLI' { & powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Yes -Prefix $Prefix -Component all -Build | Out-Null; $LASTEXITCODE -eq 0 }
    Check 'launchers exist' { (Test-Path -LiteralPath (Join-Path $Prefix "bin\$Command.cmd")) -and (Test-Path -LiteralPath (Join-Path $Prefix "bin\$Command.ps1")) }
    Check 'receipt is schema 4' { & $Rscript --vanilla -e 'R <- jsonlite::read_json(commandArgs(TRUE)[1L], simplifyVector = FALSE); stopifnot(identical(R$schema, 4L), length(R$kit) > 0L, length(R$created) > 0L)' "$receipt"; $LASTEXITCODE -eq 0 }
    Check 'BUILD_INFO recorded' { (Get-Content -LiteralPath (Join-Path $Prefix "libexec\$Runtime\BUILD_INFO") | Select-String -Pattern '^git_describe=').Matches.Count -eq 1 }

    $versionText = (& (Join-Path $Prefix "bin\$Command.cmd") '--version' 2>&1) -join "`n"
    Check '--version is the four contract lines' { $versionText -match "(?m)^$([regex]::Escape($Command)) " -and $versionText -match '(?m)^library: ' -and $versionText -match '(?m)^cli: ' -and $versionText -match '(?m)^build: ' }
    if ($Verify) { Check "verification verb $Verify passes" { & (Join-Path $Prefix "bin\$Command.cmd") $Verify | Out-Null; $LASTEXITCODE -eq 0 } }

    Check 'second run reports the library unchanged' { (& powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Yes -Prefix $Prefix 2>&1 | Out-String) -match 'already installed at the source version' }
    Check 'forced replacement with -Yes -Build' { & powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Yes -Prefix $Prefix -Build | Out-Null; $LASTEXITCODE -eq 0 }

    New-Item -ItemType File -Path (Join-Path $Prefix "libexec\$Runtime\keep.txt") -Value 'keep' | Out-Null
    Check 'uninstall.ps1 removes the CLI' { & powershell -NoProfile -ExecutionPolicy Bypass -File $uninstaller -Yes -Prefix $Prefix | Out-Null; $LASTEXITCODE -eq 0 }
    Check 'launchers and receipt are gone' { -not (Test-Path -LiteralPath (Join-Path $Prefix "bin\$Command.cmd")) -and -not (Test-Path -LiteralPath $receipt) }
    Check 'foreign file in libexec is preserved' { (Get-Content -LiteralPath (Join-Path $Prefix "libexec\$Runtime\keep.txt")) -eq 'keep' }
    Check 'the R package remains installed' { & $Rscript --vanilla -e "invisible(loadNamespace('$PackageName', lib.loc = commandArgs(TRUE)[1L]))" "$Library"; $LASTEXITCODE -eq 0 }
    Check 'uninstall without a receipt is refused' { (& $Rscript --vanilla $manager uninstall $Prefix 2>&1 | Out-String) -match 'No installation receipt' }

    $foreignBin = Join-Path $work 'foreign\bin'
    New-Item -ItemType Directory -Path $foreignBin | Out-Null
    Set-Content -LiteralPath (Join-Path $foreignBin "$Command.cmd") -Value 'foreign'
    Check 'foreign destination without receipt is rejected' { (& $Rscript --vanilla $manager install (Join-Path $work 'foreign') 2>&1 | Out-String) -match 'No installation receipt' }
    Check 'foreign file is untouched' { (Get-Content -LiteralPath (Join-Path $foreignBin "$Command.cmd")) -eq 'foreign' }

    Set-Content -LiteralPath (Join-Path $Root 'cli\bin\unlisted-helper') -Value '# helper'
    Check 'outdated manifest is rejected' { (& $Rscript --vanilla $manager check (Join-Path $work 'anywhere') 2>&1 | Out-String) -match 'out of date' }
    Remove-Item -LiteralPath (Join-Path $Root 'cli\bin\unlisted-helper')

    Write-Host "test-installers: $script:failures failure(s)"
    if ($script:failures -gt 0) { exit 1 }
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
