@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "BASE_DIR=%%~fI"
set "FRONTEND_DIR=%BASE_DIR%\paper-meeting-vue3"

where /q pnpm
if errorlevel 1 (
  echo [ERROR] pnpm was not found. Make sure pnpm is installed and available in PATH.
  exit /b 1
)

cd /d "%FRONTEND_DIR%"
echo [INFO] Starting frontend in the current window...
echo [INFO] Working directory: %FRONTEND_DIR%
echo [INFO] URL: http://localhost:80
call pnpm dev
