@echo off
setlocal
cd /d "%~dp0.."
if "%~1"=="" (
	powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0pack_release.ps1"
) else if /I "%~1"=="-ExtId" (
	powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0pack_release.ps1" %*
) else (
	powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0pack_release.ps1" -ExtId "%~1"
)
if errorlevel 1 (
	echo Pack failed.
	exit /b 1
)
