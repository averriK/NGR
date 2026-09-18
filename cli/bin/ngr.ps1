#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$PreviousPath = $env:NGR_COMMAND_PATH
try {
    $env:NGR_COMMAND_PATH = $env:PATH
    # Installed layout: bin\ngr.ps1 with the payload in libexec\ngr; dev
    # checkout: cli\bin\ngr.ps1 with main.R beside bin\.
    $Main = Join-Path $PSScriptRoot '..\libexec\ngr\main.R'
    if (-not (Test-Path $Main)) { $Main = Join-Path $PSScriptRoot '..\main.R' }
    & Rscript.exe $Main @args
    $Status = $LASTEXITCODE
} finally {
    $env:NGR_COMMAND_PATH = $PreviousPath
}
exit $Status
