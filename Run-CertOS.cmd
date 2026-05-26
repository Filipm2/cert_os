@echo off
title CERT.OS launcher
cd /d "%~dp0"

rem Locate Python
set PY=
for %%p in (python python3 py) do (
    where %%p >nul 2>nul && set PY=%%p && goto :found
)
:found

if "%PY%"=="" (
    echo.
    echo   [err] Python 3.10 or newer not found.
    echo.
    echo   download from: https://www.python.org/downloads/
    echo   during install, check "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

%PY% bootstrap.py
if errorlevel 1 pause
