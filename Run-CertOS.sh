#!/usr/bin/env bash
# Run-CertOS.command - macOS/Linux launcher for CERT.OS
# Double-click on macOS to run. On Linux, run from terminal: ./Run-CertOS.command
# Note: on first run, macOS Gatekeeper may need: System Settings > Privacy & Security > Open Anyway

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Find python3 (Mac comes with Python 3 in /usr/bin or via Homebrew)
PYTHON=""
for cand in python3 python; do
    if command -v "$cand" >/dev/null 2>&1; then
        VER=$("$cand" -c "import sys; print(f'{sys.version_info[0]}.{sys.version_info[1]}')" 2>/dev/null || echo "")
        if [[ "$VER" =~ ^3\.(1[0-9]|[2-9][0-9])$ ]] || [[ "$VER" =~ ^([4-9]|[1-9][0-9])\. ]]; then
            PYTHON="$cand"
            break
        fi
    fi
done

if [[ -z "$PYTHON" ]]; then
    echo ""
    echo "  [err] Python 3.10 or newer not found."
    echo ""
    echo "  install from:  https://www.python.org/downloads/"
    echo "  or on macOS:   brew install python@3.12"
    echo ""
    read -p "press enter to close..."
    exit 1
fi

exec "$PYTHON" bootstrap.py
