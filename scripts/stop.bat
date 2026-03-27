@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"
set "RUN_DIR=%SCRIPT_DIR%.run"
set "BACKEND_PID_FILE=%RUN_DIR%\backend.pid"
set "FRONTEND_PID_FILE=%RUN_DIR%\frontend.pid"

echo [INFO] Stopping meeting system processes...

call :stop_by_pid "%FRONTEND_PID_FILE%" "frontend"
call :stop_by_pid "%BACKEND_PID_FILE%" "backend"

echo [INFO] Stop operation finished.
exit /b 0

:stop_by_pid
if not exist "%~1" (
  echo [INFO] %~2 PID file was not found. Skipping PID stop.
  exit /b 0
)

set "TARGET_PID="
set /p TARGET_PID=<"%~1"
if not defined TARGET_PID (
  del /q "%~1" > nul 2>&1
  echo [INFO] %~2 PID file was empty and has been cleaned up.
  exit /b 0
)

tasklist /fi "PID eq %TARGET_PID%" | findstr /i "%TARGET_PID%" > nul
if errorlevel 1 (
  echo [INFO] %~2 process PID=%TARGET_PID% was not found. PID file cleaned up.
  del /q "%~1" > nul 2>&1
  exit /b 0
)

echo [INFO] Stopping %~2, PID=%TARGET_PID%
taskkill /f /t /pid %TARGET_PID% > nul 2>&1
if errorlevel 1 (
  echo [WARN] Failed to stop %~2 by PID.
) else (
  echo [INFO] %~2 stopped.
)
del /q "%~1" > nul 2>&1
exit /b 0
