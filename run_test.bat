@echo off
REM run_test.bat — Validate YAMLs, ensure device, record screen and run Maestro suite
setlocal enabledelayedexpansion

:: Configurable
set AVD_NAME=
set RECORD_SIZE=1280x720
set RECORD_SECONDS=1800
set SUITE_FILE=maestro-e2e-automation\master_suite.yaml
set REPORT_DIR=build\reports
set ARTIFACT_DIR=build\artifacts
set REMOTE_RECORD=/sdcard/execution_recording.mp4

:: 1) Validate YAMLs
echo [1/6] Validating YAML files...
python scripts/validate_yaml.py
if errorlevel 1 (
  echo YAML validation failed. Fix errors and re-run.
  exit /b 1
)

:: 2) Verify ADB device
echo [2/6] Checking connected Android devices (adb)...
adb devices | findstr /R "device$" >nul
if errorlevel 1 (
  echo No device detected. If you have an AVD, start it now:
  echo   emulator -avd ^<YOUR_AVD_NAME^>
  echo Then re-run this script.
  exit /b 2
)

:: 3) Prepare artifacts dirs
echo [3/6] Preparing artifact folders...
mkdir "%REPORT_DIR%" 2>nul
mkdir "%ARTIFACT_DIR%" 2>nul

:: 4) Start screen recording on device (time-limited)
echo [4/6] Starting on-device screen recording (%RECORD_SIZE%, %RECORD_SECONDS%s)...
start "record" /B cmd /c "adb shell screenrecord --size %RECORD_SIZE% --time-limit %RECORD_SECONDS% %REMOTE_RECORD%"
REM Small delay to ensure recorder starts
timeout /t 2 /nobreak >nul

:: 5) Run Maestro test runner (try `maestro` then fallback to `npx`)
echo [5/6] Running Maestro test suite: %SUITE_FILE%
where maestro >nul 2>&1
if %errorlevel%==0 (
  maestro test --format junit --output "%REPORT_DIR%\junit-report.xml" --test-output-dir "%ARTIFACT_DIR%" "%SUITE_FILE%"
) else (
  echo 'maestro' not found in PATH — attempting via npx...
  npx maestro test --format junit --output "%REPORT_DIR%\junit-report.xml" --test-output-dir "%ARTIFACT_DIR%" "%SUITE_FILE%"
)
set RC=%ERRORLEVEL%

:: 6) Stop/collect recording (if created)
echo [6/6] Pulling on-device recording (if exists)...
adb shell ls %REMOTE_RECORD% >nul 2>&1
if %ERRORLEVEL%==0 (
  adb pull %REMOTE_RECORD% "%ARTIFACT_DIR%\execution_recording.mp4"
  adb shell rm %REMOTE_RECORD% >nul 2>&1
  echo Recording saved at %ARTIFACT_DIR%\execution_recording.mp4
) else (
  echo No on-device recording found.
)

:: Finalize
echo Done. Maestro exit code: %RC%
if %RC% neq 0 (
  echo Check logs under %ARTIFACT_DIR% and %REPORT_DIR%
  exit /b %RC%
)
exit /b 0
