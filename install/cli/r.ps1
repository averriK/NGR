# R's installer registers Current Version under the user or machine R-core key.
# A 32-bit installer on 64-bit Windows writes the machine key in the 32-bit
# registry view, which a 64-bit PowerShell does not reach through HKLM:, so
# both views are read: the native one first. The architecture binary is
# preferred to the bin\Rscript.exe front end, which fails on a multi-line -e.
function Resolve-Rscript {
    foreach ($hive in 'CurrentUser', 'LocalMachine') {
        foreach ($view in 'Registry64', 'Registry32') {
            $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::$hive, [Microsoft.Win32.RegistryView]::$view)
            $record = $base.OpenSubKey('SOFTWARE\R-core\R')
            if (-not $record) { continue }
            $version = $record.GetValue('Current Version')
            if (-not $version) { continue }
            $entry = $record.OpenSubKey($version)
            if (-not $entry) { continue }
            $install = $entry.GetValue('InstallPath')
            if (-not $install) { continue }
            foreach ($relative in 'bin\x64\Rscript.exe', 'bin\Rscript.exe') {
                $candidate = Join-Path $install $relative
                if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
            }
            throw "Current registered Rscript is unavailable: $candidate. Repair the R installation or its registry entry."
        }
    }
    throw 'Current R is not registered. Run the R installer with its registry option, or RSetReg.exe /Personal.'
}
