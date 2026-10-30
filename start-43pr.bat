@echo off
setlocal
title 43PR Desktop Launcher
echo ===================================================
echo           43PR Rice for Windows - Starting
echo ===================================================

:: Ensure GlazeWM is located
where glazewm >nul 2>&1
if %ERRORLEVEL% equ 0 (
    start "" glazewm
    goto :done
)

if exist "%LOCALAPPDATA%\Programs\glzr\bin\glazewm.exe" (
    start "" "%LOCALAPPDATA%\Programs\glzr\bin\glazewm.exe"
    goto :done
)

if exist "%ProgramFiles%\glzr\bin\glazewm.exe" (
    start "" "%ProgramFiles%\glzr\bin\glazewm.exe"
    goto :done
)

echo [ERROR] glazewm.exe not found! Please run install.ps1 first.
pause
exit /b 1

:done
echo 43PR Desktop is now active!
