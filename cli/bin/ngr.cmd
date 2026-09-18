@echo off
setlocal
set "NGR_COMMAND_PATH=%PATH%"
rem Installed layout: bin\ngr.cmd with the payload in libexec\ngr; dev
rem checkout: cli\bin\ngr.cmd with main.R beside bin\.
set "MAIN=%~dp0..\libexec\ngr\main.R"
if not exist "%MAIN%" set "MAIN=%~dp0..\main.R"
Rscript.exe "%MAIN%" %*
exit /b %errorlevel%
