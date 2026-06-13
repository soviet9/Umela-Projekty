@echo off

if exist "%ProgramFiles%\Git\bin\bash.exe" (
    set "BASH=%ProgramFiles%\Git\bin\bash.exe"
) else if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
    set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
) else (
    echo Git Bash not found.
    pause
    exit /b 1
)

echo Found Git Bash: %BASH%
"%BASH%" "%~dp0Main.sh"