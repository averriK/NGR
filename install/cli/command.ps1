#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$Runtime = Join-Path (Split-Path -Parent $PSScriptRoot) 'libexec\@RUNTIME@'
. (Join-Path $Runtime 'install\cli\r.ps1')
$Rscript = Resolve-Rscript
@PATH_EXPORT@
# R diagnostics on stderr do not replace its process exit status.
$ErrorActionPreference = 'Continue'
& $Rscript (Join-Path $Runtime 'main.R') @args
exit $LASTEXITCODE
