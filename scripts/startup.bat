@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "BASE_DIR=%%~fI"

set "FRONTEND_DIR=%BASE_DIR%\paper-meeting-vue3"
set "BACKEND_DIR=%BASE_DIR%\paper-meeting-server"
set "RUN_DIR=%SCRIPT_DIR%.run"
set "LOG_DIR=%SCRIPT_DIR%logs"
set "BACKEND_PID_FILE=%RUN_DIR%\backend.pid"
set "FRONTEND_PID_FILE=%RUN_DIR%\frontend.pid"
set "BACKEND_LOG=%LOG_DIR%\backend.log"
set "BACKEND_ERR_LOG=%LOG_DIR%\backend.err.log"
set "FRONTEND_LOG=%LOG_DIR%\frontend.log"
set "FRONTEND_ERR_LOG=%LOG_DIR%\frontend.err.log"

if not exist "%RUN_DIR%" mkdir "%RUN_DIR%" > nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" > nul 2>&1

call :require_command mvn "Maven"
if errorlevel 1 exit /b 1

call :require_command pnpm "pnpm"
if errorlevel 1 exit /b 1

call :ensure_not_running "%BACKEND_PID_FILE%" "backend"
if errorlevel 1 exit /b 1

call :ensure_not_running "%FRONTEND_PID_FILE%" "frontend"
if errorlevel 1 exit /b 1

echo [INFO] Starting meeting system in background without opening new windows.
echo [INFO] Log directory: %LOG_DIR%

del /q "%BACKEND_LOG%" "%BACKEND_ERR_LOG%" "%FRONTEND_LOG%" "%FRONTEND_ERR_LOG%" > nul 2>&1

for /f %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','cd /d ""%BACKEND_DIR%"" && call mvn -U -pl yudao-server -am install -DskipTests && call mvn -U -f yudao-server/pom.xml spring-boot:run -Dspring-boot.run.profiles=local -DskipTests' -WorkingDirectory '%BACKEND_DIR%' -RedirectStandardOutput '%BACKEND_LOG%' -RedirectStandardError '%BACKEND_ERR_LOG%' -WindowStyle Hidden -PassThru; $p.Id"') do set "BACKEND_PID=%%I"
if not defined BACKEND_PID (
  echo [ERROR] Failed to start backend.
  exit /b 1
)
> "%BACKEND_PID_FILE%" echo %BACKEND_PID%
echo [INFO] Backend started. PID=%BACKEND_PID%, URL: http://localhost:48080

for /f %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','cd /d ""%FRONTEND_DIR%"" && call pnpm dev' -WorkingDirectory '%FRONTEND_DIR%' -RedirectStandardOutput '%FRONTEND_LOG%' -RedirectStandardError '%FRONTEND_ERR_LOG%' -WindowStyle Hidden -PassThru; $p.Id"') do set "FRONTEND_PID=%%I"
if not defined FRONTEND_PID (
  echo [ERROR] Failed to start frontend.
  del /q "%BACKEND_PID_FILE%" > nul 2>&1
  taskkill /f /t /pid %BACKEND_PID% > nul 2>&1
  exit /b 1
)
> "%FRONTEND_PID_FILE%" echo %FRONTEND_PID%
echo [INFO] Frontend started. PID=%FRONTEND_PID%, URL: http://localhost:80
echo [INFO] Use stop.bat to stop the background processes.
exit /b 0

:require_command
where /q %~1
if errorlevel 1 (
  echo [ERROR] %~2 was not found. Make sure %~1 is installed and available in PATH.
  exit /b 1
)
exit /b 0

:ensure_not_running
if not exist "%~1" exit /b 0
set /p EXISTING_PID=<"%~1"
if not defined EXISTING_PID (
  del /q "%~1" > nul 2>&1
  exit /b 0
)
tasklist /fi "PID eq %EXISTING_PID%" | findstr /i "%EXISTING_PID%" > nul
if not errorlevel 1 (
  echo [ERROR] %~2 is already running with PID=%EXISTING_PID%. Run stop.bat or restart.bat first.
  exit /b 1
)
del /q "%~1" > nul 2>&1
exit /b 0
