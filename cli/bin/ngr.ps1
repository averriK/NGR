#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$PreviousPath = $env:NGR_COMMAND_PATH
try {
    $env:NGR_COMMAND_PATH = $env:PATH
    & Rscript.exe (Join-Path $PSScriptRoot '..\main.R') @args
    $Status = $LASTEXITCODE
} finally {
    $env:NGR_COMMAND_PATH = $PreviousPath
}
exit $Status
