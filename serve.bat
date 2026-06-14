@echo off
echo ╔══════════════════════════════════════╗
echo ║   AlcreoVault — Local Server         ║
echo ╚══════════════════════════════════════╝
echo.
echo Checking Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js not installed.
    echo Download from: https://nodejs.org
    pause
    exit /b
)
echo Starting local server...
echo Open your browser at: http://localhost:3000
echo Press Ctrl+C to stop.
echo.
npx --yes serve . -p 3000
