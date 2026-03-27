@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo [INFO] Restarting meeting system...
call "%SCRIPT_DIR%stop.bat"
timeout /t 2 > nul
call "%SCRIPT_DIR%startup.bat"
