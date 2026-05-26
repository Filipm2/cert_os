# Compute SHA-256 of every file in dist/ and write dist/SHA256SUMS.txt.
#
# Run from the build/ directory after build_windows.ps1:
#   .\make_checksums.ps1

$ErrorActionPreference = "Stop"

$BuildDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $BuildDir
$DistDir  = Join-Path $RepoRoot "dist"
$Output   = Join-Path $DistDir "SHA256SUMS.txt"

if (-not (Test-Path $DistDir)) {
    Write-Error "dist/ does not exist at $DistDir. Run a build first."
    exit 1
}

if (Test-Path $Output) {
    Remove-Item $Output
}

$lines = @()
Get-ChildItem -Path $DistDir -File -Recurse |
    Where-Object { $_.Name -ne "SHA256SUMS.txt" } |
    Sort-Object FullName |
    ForEach-Object {
        $hash = (Get-FileHash -Algorithm SHA256 -Path $_.FullName).Hash.ToLower()
        $rel  = $_.FullName.Substring($DistDir.Length + 1) -replace '\\', '/'
        $lines += "$hash  $rel"
    }

$lines | Set-Content -Path $Output -Encoding ASCII

Write-Host "Wrote $Output"
$lines | ForEach-Object { Write-Host $_ }
