#!/usr/bin/env bash
# Build a CERT.OS.app bundle for macOS.
#
# Prefers py2app (produces a more native-feeling .app); falls back to
# PyInstaller if py2app isn't installed.
#
# Prereqs:
#   pip install pyside6 pillow
#   pip install py2app           # preferred
#   # or: pip install pyinstaller
#
# Run from the build/ directory:
#   ./build_mac.sh

set -euo pipefail

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$BUILD_DIR/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"
ICON="$REPO_ROOT/assets/cert_os.icns"
ENTRY="$REPO_ROOT/cert_os.py"
APP_NAME="CERT.OS"

mkdir -p "$DIST_DIR"
cd "$BUILD_DIR"

if python3 -c "import py2app" >/dev/null 2>&1; then
    echo ">> Building with py2app"
    SETUP="$BUILD_DIR/_setup_py2app.py"
    cat > "$SETUP" <<EOF
from setuptools import setup

APP = ['$ENTRY']
OPTIONS = {
    'argv_emulation': False,
    'iconfile': '$ICON',
    'plist': {
        'CFBundleName': '$APP_NAME',
        'CFBundleDisplayName': '$APP_NAME',
        'CFBundleIdentifier': 'com.manormindlabs.certos',
        'CFBundleVersion': open('$REPO_ROOT/VERSION').read().strip(),
        'CFBundleShortVersionString': open('$REPO_ROOT/VERSION').read().strip(),
        'NSHighResolutionCapable': True,
    },
    'packages': ['PySide6'],
    'resources': ['$REPO_ROOT/VERSION'],
}

setup(
    app=APP,
    name='$APP_NAME',
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)
EOF

    rm -rf "$BUILD_DIR/_py2app_build"
    python3 "$SETUP" py2app \
        --dist-dir "$DIST_DIR" \
        --bdist-base "$BUILD_DIR/_py2app_build"
    echo ""
    echo "Build complete. Output: $DIST_DIR/$APP_NAME.app"
elif python3 -c "import PyInstaller" >/dev/null 2>&1; then
    echo ">> Building with PyInstaller (py2app not installed)"
    pyinstaller \
        --windowed \
        --icon "$ICON" \
        --name "$APP_NAME" \
        --distpath "$DIST_DIR" \
        --workpath "$BUILD_DIR/_work" \
        --specpath "$BUILD_DIR/_spec" \
        --add-data "$REPO_ROOT/VERSION:." \
        "$ENTRY"
    echo ""
    echo "Build complete. Output: $DIST_DIR/$APP_NAME.app"
else
    echo "Neither py2app nor PyInstaller is installed." >&2
    echo "Install one of:" >&2
    echo "  pip install py2app" >&2
    echo "  pip install pyinstaller" >&2
    exit 1
fi
