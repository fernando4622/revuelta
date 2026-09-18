@REM ----------------------------------------------------------------------------
@REM Maven Start Up Batch script for Windows
@REM ----------------------------------------------------------------------------

@if "%KEYS%" == "" set KEYS=off
@echo %KEYS%

@setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set MAX_FD=maximum

@REM Find the project root directory
set MAVEN_PROJECTBASEDIR=%DIRNAME%

set MAVEN_COMMAND=mvn
where mvn >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set MAVEN_COMMAND=mvn
) else (
    echo Maven is not installed in PATH. Please use Docker or install Apache Maven.
    exit /b 1
)

%MAVEN_COMMAND% %*
