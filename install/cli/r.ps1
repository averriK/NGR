# R's installer registers Current Version under the user or machine R-core key.
function Resolve-Rscript {
    foreach ($hive in 'HKCU:\SOFTWARE\R-core\R', 'HKLM:\SOFTWARE\R-core\R') {
        $record = Get-ItemProperty -LiteralPath $hive -ErrorAction SilentlyContinue
        if (-not $record) { continue }
        $version = $record.'Current Version'
        if (-not $version) { continue }
        $install = (Get-ItemProperty -LiteralPath (Join-Path $hive $version) -ErrorAction SilentlyContinue).InstallPath
        if (-not $install) { continue }
        $candidate = Join-Path $install 'bin\Rscript.exe'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        throw "Current registered Rscript is unavailable: $candidate. Repair the R installation or its registry entry."
    }
    throw 'Current R is not registered. Run the R installer with its registry option, or RSetReg.exe /Personal.'
}
