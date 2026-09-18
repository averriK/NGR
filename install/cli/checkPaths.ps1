param([Parameter(Mandatory = $true)][string]$PathList)
$ErrorActionPreference = 'Stop'
foreach ($path in Get-Content -LiteralPath $PathList -Encoding UTF8) {
    try {
        $item = Get-Item -LiteralPath $path -Force
    } catch [System.Management.Automation.ItemNotFoundException] {
        continue
    }
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Managed path is a reparse point: $path"
    }
}
