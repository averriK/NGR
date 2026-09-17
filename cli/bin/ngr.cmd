@echo off
setlocal
set "NGR_COMMAND_PATH=%PATH%"
Rscript.exe "%~dp0..\main.R" %*
exit /b %errorlevel%
