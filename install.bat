@echo off
title MDPro Custom Cards Installer

echo =====================================
echo  MDPro Custom Cards Installer
echo =====================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*

echo.
echo =====================================
echo  Installer finished.
echo =====================================
echo.
echo Press any key to close this window...
pause >nul
