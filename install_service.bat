@echo off
chcp 65001 >nul
:: 65001 - UTF-8

:: Define service parameters
set "SERVICE_NAME=ZAPRETAFTService"
set "SERVICE_DISPLAY_NAME=ZAPRET: AFT Service"
set "SERVICE_DESCRIPTION=ZAPRET: AFT Фоновый Сервис"

:: Get current directory
set "CURRENT_DIR=%~dp0"

:: Path to the batch file to run
set "BATCH_PATH=%CURRENT_DIR%start_winws.bat"

:: Create the service using sc.exe
echo Создание сервиса "%SERVICE_NAME%"...

sc create "%SERVICE_NAME%" ^
    binPath= "cmd.exe /c \"%BATCH_PATH%\"" ^
    start= auto ^
    DisplayName= "%SERVICE_DISPLAY_NAME%" ^
    depend= Tcpip

:: Check if service creation was successful
if %ERRORLEVEL% neq 0 (
    echo Ошибка при создании сервиса.
    pause
    exit /b 1
)

:: Set service description
sc description "%SERVICE_NAME%" "%SERVICE_DESCRIPTION%"

:: Start the service
echo Запуск сервиса "%SERVICE_NAME%"...
net start "%SERVICE_NAME%"

:: Check if service started successfully
if %ERRORLEVEL% neq 0 (
    echo Ошибка при запуске сервиса.
    pause
    exit /b 1
)

echo Сервис "%SERVICE_NAME%" успешно установлен и запущен.
pause
