@echo off
setlocal EnableExtensions
rem Instalador Windows 11 do comando /init-project.
rem Chama install-init-project.ps1 com ExecutionPolicy Bypass so neste processo.

set "SCRIPT=%~dp0install-init-project.ps1"
if not exist "%SCRIPT%" (
  echo ERRO: nao encontrado: %SCRIPT% 1>&2
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
set "RC=%ERRORLEVEL%"

rem Duplo clique abre o cmd com o caminho deste arquivo em cmdcmdline.
rem Num prompt ja aberto, cmdcmdline nao contem esse caminho: sem pause.
echo %cmdcmdline% | find /I "%~f0" >nul
if not errorlevel 1 pause

exit /b %RC%
