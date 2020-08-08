@echo off

powershell -Command Set-ExecutionPolicy RemoteSigned

cd /d %~dp0
powershell -File install_wmf.ps1
powershell -File main.ps1 -d 2 %*
