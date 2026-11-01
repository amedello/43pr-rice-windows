@echo off
setlocal
title 43PR Rice System Upgrader
echo ===================================================
echo           43PR Rice for Windows - Upgrade
echo ===================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\upgrade-43pr.ps1" %*

echo.
echo Premi un tasto per uscire...
pause >nul

