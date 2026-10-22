@echo off
title 43PR Desktop Launcher
echo Starting 43PR Desktop (GlazeWM + Zebar)...

:: Start Zebar floating status bar
start "" "%LOCALAPPDATA%\Programs\glzr\bin\zebar.exe"

:: Start GlazeWM Tiling Window Manager
start "" "%LOCALAPPDATA%\Programs\glzr\bin\glazewm.exe"

echo 43PR Desktop is now active!
