@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "BASE_DIR=%%~fI"
set "BACKEND_DIR=%BASE_DIR%\paper-meeting-server"

where /q mvn
if errorlevel 1 (
  echo [ERROR] Maven was not found. Make sure mvn is installed and available in PATH.
  exit /b 1
)

cd /d "%BACKEND_DIR%"
echo [INFO] Starting backend in the current window...
echo [INFO] Working directory: %BACKEND_DIR%
echo [INFO] URL: http://localhost:48080
echo [INFO] Installing yudao-server and required modules to local Maven repository...
call mvn -U -pl yudao-server -am install -DskipTests
if errorlevel 1 (
  echo [ERROR] Backend install failed.
  exit /b 1
)

echo [INFO] Launching Spring Boot from yudao-server module...
call mvn -U -f yudao-server/pom.xml spring-boot:run -Dspring-boot.run.profiles=local -DskipTests
