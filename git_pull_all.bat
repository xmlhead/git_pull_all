@echo off
setlocal enableDelayedExpansion

REM Set color codes for output
Set _fYELLOW=[93m
set _fRED=[91m
Set _RESET=[0m
goto :Start
REM Function to check if a folder contains a Git repository
:CheckGitRepo
pushd %1
if exist ".git" (
    echo "%_fYELLOW%Fetching changes in: %CD%%_RESET%"
    git fetch --all -vvv 2>nul
    if errorlevel 1 (
        echo "%_fRED%Failed to fetch changes in: %CD%%_RESET%"
        popd
        exit /b 1
    )
    REM Get the default branch name
    for /f "tokens=*" %%i in ('git symbolic-ref refs/remotes/origin/HEAD 2^>nul') do set "default_branch=%%i"
    if not defined default_branch (
        echo "%_fRED%Could not determine default branch in: %CD%%_RESET%"
        popd
        exit /b 1
    )
    set "default_branch=!default_branch:refs/remotes/origin/=!"
    REM Checkout the default branch
    git checkout !default_branch! 2>nul
    if errorlevel 1 (
        echo "%_fRED%Failed to checkout branch !default_branch! in: %CD%%_RESET%"
        popd
        exit /b 1
    )
    REM Check if a remote is configured
    REM set "_gitMsg="
    REM for /f "tokens=* delims= " %%i in ('git remote') do set "_gitMsg=%%i"
    REM if "%_gitMsg%"=="" (
        REM echo "%_fRED%No remote configured for %CD%%_RESET% -  %_gitMsg%"
        REM popd
        REM exit /b 1
    REM )
    git pull 2>nul
    if errorlevel 1 (
        echo "%_fRED%Failed to pull updates for branch !default_branch! in: %CD%%_RESET%"
        popd
        exit /b 1
    )
    echo "Successfully pulled updates for branch !default_branch! in: %CD%"
)
popd
exit /b 0

REM Function to traverse directories recursively
:TraverseDirs
setlocal
set "currentDir=%~1"
for /d %%d in ("%currentDir%\*") do (
    call :CheckGitRepo "%%~fd"
    call :TraverseDirs "%%~fd"
)
endlocal
exit /b 0

REM Start label for the script
:Start
echo Starting directory traversal from %cd%
call :TraverseDirs "%cd%"

endlocal
