@echo off
REM install-init-project.cmd
REM
REM Launcher para quem prefere clicar duas vezes em vez de abrir o PowerShell
REM na mao. So repassa os argumentos para install-init-project.ps1, que faz
REM todo o trabalho real (ver esse arquivo para a logica completa).
REM
REM Uso:
REM   install-init-project.cmd [caminho\para\pasta-do-pacote]

setlocal

set "SCRIPT_DIR=%~dp0"
set "PS1=%SCRIPT_DIR%install-init-project.ps1"

if not exist "%PS1%" (
  echo ERRO: nao encontrei "%PS1%" ao lado deste .cmd.
  goto :fim
)

where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
)

:fim
echo.
pause
endlocal

