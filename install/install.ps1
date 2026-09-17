#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$Repository = Split-Path -Parent $PSScriptRoot
$Rscript = Get-Command Rscript.exe -CommandType Application -ErrorAction Stop
& $Rscript.Source --vanilla (Join-Path $PSScriptRoot 'installProduct.R') $Repository @args
exit $LASTEXITCODE
