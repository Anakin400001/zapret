@echo off
chcp 65001 >nul
:: 65001 - UTF-8

:: Define service name
set "SERVICE_NAME=ZAPRETAFTService"

:: Stop the service
echo Остановка сервис "%SERVICE_NAME%"...
net stop "%SERVICE_NAME%"

:: Delete the service
echo Удаление сервиса "%SERVICE_NAME%"...
sc delete "%SERVICE_NAME%"

:: Check if service deletion was successful
if %ERRORLEVEL% neq 0 (
    echo Ошибка при удалении сервиса.
    pause
    exit /b 1
)

echo Сервис "%SERVICE_NAME%" был удален успешно.
pause
