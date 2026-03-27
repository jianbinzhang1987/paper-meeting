@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set BASE_DIR=%SCRIPT_DIR%..

echo [INFO] Starting Frontend in current window...
cd /d "%BASE_DIR%\paper-meeting-vue3"
if errorlevel 1 (
  echo [ERROR] Cannot enter frontend directory: %BASE_DIR%\paper-meeting-vue3
  exit /b 1
)

where pnpm > nul 2>nul
if %errorlevel%==0 (
  call pnpm dev
) else (
  echo [WARN] pnpm not found, fallback to npm run dev
  call npm run dev
)

exit /b %errorlevel%
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
