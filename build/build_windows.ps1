# Build a single-file Windows binary for CERT.OS via PyInstaller.
#
# Prereqs:
#   pip install pyinstaller pyside6 pillow
#
# Run from the build/ directory:
#   .\build_windows.ps1

$ErrorActionPreference = "Stop"

$BuildDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $BuildDir

Push-Location $BuildDir
try {
    pyinstaller `
        --onefile `
        --windowed `
        --icon "$RepoRoot\assets\cert_os.ico" `
        --name CERT.OS `
        --distpath ../dist `
        --workpath ../build/_work `
        --specpath ../build/_spec `
        --add-data "$RepoRoot\VERSION;." `
        ../cert_os.py

    if ($LASTEXITCODE -ne 0) {
        throw "pyinstaller exited with code $LASTEXITCODE"
    }

    Write-Host ""
    Write-Host "Build complete. Output: $RepoRoot\dist\CERT.OS.exe"
}
finally {
    Pop-Location
}
