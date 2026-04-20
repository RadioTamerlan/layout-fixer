@echo off
REM Layout Fixer — Windows installer.
REM Copies LayoutFixer.exe to %LOCALAPPDATA%\LayoutFixer, adds a Startup
REM shortcut, and launches the app. Run by double-clicking.

setlocal
set "APP_DIR=%LOCALAPPDATA%\LayoutFixer"
set "EXE=%APP_DIR%\LayoutFixer.exe"
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

if not exist "%~dp0LayoutFixer.exe" (
    echo [ERROR] LayoutFixer.exe not found next to this installer.
    pause
    exit /b 1
)

echo Installing to %APP_DIR% ...
if not exist "%APP_DIR%" mkdir "%APP_DIR%"
copy /Y "%~dp0LayoutFixer.exe" "%EXE%" >nul

echo Adding to Startup ...
powershell -NoProfile -Command ^
  "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%STARTUP%\LayoutFixer.lnk'); $s.TargetPath = '%EXE%'; $s.Save()"

echo Launching Layout Fixer ...
start "" "%EXE%"

echo.
echo Done. Layout Fixer is running in the system tray and will auto-start on login.
echo Hotkey: Ctrl+Shift+S to convert the selected text.
pause
