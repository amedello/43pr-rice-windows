@echo off
title 43PR Desktop Stopper
echo Stopping GlazeWM and Zebar...

taskkill /IM glazewm.exe /F 2>nul
taskkill /IM zebar.exe /F 2>nul

echo 43PR Desktop stopped.
