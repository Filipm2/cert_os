"""
bootstrap.py - cross-platform launcher for CERT.OS
==================================================
First run:  creates a .venv next to this script, installs PySide6
After:      just launches the app

Works on Windows, macOS, Linux. No system installation needed.

Usage:
    python bootstrap.py
"""
from __future__ import annotations

import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
APP_SCRIPT = SCRIPT_DIR / "cert_os.py"
VENV_DIR = SCRIPT_DIR / ".venv"
MARKER = VENV_DIR / ".cert_os_ready"

IS_WIN = platform.system() == "Windows"

if IS_WIN:
    VENV_PY = VENV_DIR / "Scripts" / "python.exe"
    VENV_PIP = VENV_DIR / "Scripts" / "pip.exe"
else:
    VENV_PY = VENV_DIR / "bin" / "python"
    VENV_PIP = VENV_DIR / "bin" / "pip"


# ---------- pretty printing ----------

USE_COLOR = sys.stdout.isatty()

def c(code, text):
    if USE_COLOR:
        return f"\033[{code}m{text}\033[0m"
    return text

def banner():
    print()
    print(" ", c("33", "CERT") + c("35", ".") + c("33", "OS"),
          c("90", " // certification practice exam simulator"))
    print()

def step(msg):
    print(f"  [{c('36', '*')}] {msg}")

def ok(msg):
    print(f"  [{c('32', 'ok')}] {msg}")

def err(msg):
    print(f"  [{c('31', 'err')}] {msg}", file=sys.stderr)


# ---------- python check ----------

def find_python_for_venv() -> str | None:
    """Locate a Python 3.10+ on this system to bootstrap the venv with."""
    # try the python that's currently running first
    if sys.version_info >= (3, 10):
        return sys.executable
    # then try common names
    for name in ("python3", "python", "py"):
        exe = shutil.which(name)
        if not exe:
            continue
        try:
            out = subprocess.run(
                [exe, "-c",
                 "import sys; print(f'{sys.version_info[0]}.{sys.version_info[1]}')"],
                check=True, capture_output=True, text=True, timeout=5,
            )
            major, minor = out.stdout.strip().split(".")
            if int(major) == 3 and int(minor) >= 10:
                return exe
        except Exception:
            continue
    return None


# ---------- main ----------

def main() -> int:
    banner()

    if not APP_SCRIPT.exists():
        err(f"cert_os.py not found in {SCRIPT_DIR}")
        return 1

    # First-run setup
    if not MARKER.exists():
        step("first run detected. setting up environment...")
        print()

        py = find_python_for_venv()
        if not py:
            err("Python 3.10 or newer not found.")
            print()
            print(f"  download from: {c('36', 'https://www.python.org/downloads/')}")
            if IS_WIN:
                print(f"  during install, check: {c('33', 'Add Python to PATH')}")
            print()
            return 1
        ok(f"using python at {py}")

        if VENV_DIR.exists():
            step("removing stale venv...")
            shutil.rmtree(VENV_DIR, ignore_errors=True)

        step("creating virtual environment...")
        try:
            subprocess.run([py, "-m", "venv", str(VENV_DIR)], check=True)
        except subprocess.CalledProcessError as e:
            err(f"venv creation failed: {e}")
            return 1
        ok("venv created")

        if not VENV_PY.exists():
            err(f"venv python missing at {VENV_PY}")
            return 1

        step("upgrading pip...")
        try:
            subprocess.run(
                [str(VENV_PY), "-m", "pip", "install", "--upgrade", "pip",
                 "--disable-pip-version-check", "--quiet"],
                check=True,
            )
        except subprocess.CalledProcessError:
            pass  # non-fatal

        step("installing PySide6 (~50MB, takes a minute)...")
        try:
            subprocess.run(
                [str(VENV_PY), "-m", "pip", "install",
                 "--disable-pip-version-check",
                 "PySide6"],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            err(f"dependency install failed: {e}")
            return 1
        ok("dependencies installed")

        MARKER.write_text("ready", encoding="utf-8")
        ok("setup complete")
        print()

    step("launching cert.os...")
    print()
    try:
        result = subprocess.run([str(VENV_PY), str(APP_SCRIPT)])
        return result.returncode
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    rc = main()
    if rc != 0 and IS_WIN:
        # keep window open so user can see error
        try:
            input("\npress enter to close...")
        except EOFError:
            pass
    sys.exit(rc)
