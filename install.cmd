@echo off
rem Installer for the Windows version of ncore.pro-autologin. Remove it with: install.cmd -Uninstall
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
pause
