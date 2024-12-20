@echo off
chcp 65001 >nul
:: Установка кодовой страницы UTF-8

:: Проверка, был ли скрипт запущен после обновления
if "%1"=="after_update" (
    cls
    echo =========================================
    echo        Обновление успешно применено
    echo =========================================
    echo.
    pause
)

:: Определение параметров службы
set "SERVICE_NAME=ZAPRETAFTService"
set "SERVICE_DISPLAY_NAME=ZAPRET: AFT Service"
set "SERVICE_DESCRIPTION=ZAPRET: AFT Фоновый Сервис"

:: Определение путей
set "CURRENT_DIR=%~dp0"
set "BATCH_PATH=%CURRENT_DIR%start_winws.bat"

:: Настройки обновлений
set "GITHUB_USER=Anakin400001"
set "GITHUB_REPO=zapret"
set "BRANCH=main"
set "VERSION_URL=https://raw.githubusercontent.com/%GITHUB_USER%/%GITHUB_REPO%/%BRANCH%/version.txt"
set "GITHUB_API_TREE_URL=https://api.github.com/repos/%GITHUB_USER%/%GITHUB_REPO%/git/trees/%BRANCH%?recursive=1"

:: Локальные файлы
set "LOCAL_VERSION_FILE=%CURRENT_DIR%version.txt"

:: Путь к NSSM (если добавлен в PATH, можно использовать просто "nssm.exe")
set "NSSM_PATH=%~dp0bin\nssm.exe"  :: Укажите правильный путь к nssm.exe, если не добавили в PATH

:MENU
cls
echo =========================================
echo           Управление ZapretAFT
echo =========================================
echo.
echo 1. Установить службу
echo 2. Удалить службу
echo 3. Запустить службу
echo 4. Остановить службу
echo 5. Перезапустить службу
echo 6. Проверить обновления
echo 7. Выход
echo.
set /p choice=Выберите действие (1-7): 

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto UNINSTALL
if "%choice%"=="3" goto START
if "%choice%"=="4" goto STOP
if "%choice%"=="5" goto RESTART
if "%choice%"=="6" goto UPDATE
if "%choice%"=="7" goto END

echo Неверный выбор. Пожалуйста, попробуйте снова.
pause
goto MENU

:INSTALL
cls
echo =========================================
echo              Установка службы
echo =========================================
echo.
:: Проверка существования службы
sc query "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo Служба "%SERVICE_NAME%" уже установлена.
    pause
    goto MENU
)

:: Проверка наличия NSSM
if not exist "%NSSM_PATH%" (
    echo Ошибка: NSSM не найден по пути "%NSSM_PATH%".
    pause
    goto MENU
)

:: Проверка существования start_winws.bat
if not exist "%BATCH_PATH%" (
    echo Ошибка: "%BATCH_PATH%" не найден.
    pause
    goto MENU
)

:: Создание службы с помощью NSSM
echo Создание службы "%SERVICE_NAME%" с использованием NSSM...
"%NSSM_PATH%" install "%SERVICE_NAME%" "cmd.exe" "/c \"%BATCH_PATH%\""

:: Проверка успешности создания службы
if %ERRORLEVEL% neq 0 (
    echo Ошибка при создании службы.
    pause
    goto MENU
)

:: Установка описания службы
sc description "%SERVICE_NAME%" "%SERVICE_DESCRIPTION%"

:: Настройка автоматического запуска
sc config "%SERVICE_NAME%" start= auto

:: Запуск службы
echo Запуск службы "%SERVICE_NAME%"...
net start "%SERVICE_NAME%"

:: Проверка успешности запуска службы
if %ERRORLEVEL% neq 0 (
    echo Ошибка при запуске службы.
    pause
    goto MENU
)

echo Служба "%SERVICE_NAME%" успешно установлена и запущена.
pause
goto MENU

:UNINSTALL
cls
echo =========================================
echo             Удаление службы
echo =========================================
echo.
:: Проверка существования службы
sc query "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Служба "%SERVICE_NAME%" не установлена.
    pause
    goto MENU
)

:: Остановка службы
echo Остановка службы "%SERVICE_NAME%"...
net stop "%SERVICE_NAME%"

:: Удаление службы с помощью NSSM
echo Удаление службы "%SERVICE_NAME%"...
"%NSSM_PATH%" remove "%SERVICE_NAME%" confirm

:: Проверка успешности удаления службы
if %ERRORLEVEL% neq 0 (
    echo Ошибка при удалении службы.
    pause
    goto MENU
)

echo Служба "%SERVICE_NAME%" успешно удалена.
pause
goto MENU

:START
cls
echo =========================================
echo               Запуск службы
echo =========================================
echo.
:: Проверка существования службы
sc query "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Служба "%SERVICE_NAME%" не установлена.
    pause
    goto MENU
)

:: Запуск службы
echo Запуск службы "%SERVICE_NAME%"...
net start "%SERVICE_NAME%"

:: Проверка успешности запуска службы
if %ERRORLEVEL% neq 0 (
    echo Ошибка при запуске службы.
    pause
) else (
    echo Служба запущена успешно.
    pause
)
goto MENU

:STOP
cls
echo =========================================
echo              Остановка службы
echo =========================================
echo.
:: Проверка существования службы
sc query "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Служба "%SERVICE_NAME%" не установлена.
    pause
    goto MENU
)

:: Остановка службы
echo Остановка службы "%SERVICE_NAME%"...
net stop "%SERVICE_NAME%"

:: Проверка успешности остановки службы
if %ERRORLEVEL% neq 0 (
    echo Ошибка при остановке службы.
    pause
) else (
    echo Служба остановлена успешно.
    pause
)
goto MENU

:RESTART
cls
echo =========================================
echo          Перезапуск службы
echo =========================================
echo.
:: Проверка существования службы
sc query "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Служба "%SERVICE_NAME%" не установлена.
    pause
    goto MENU
)

:: Проверка состояния службы
sc query "%SERVICE_NAME%" | findstr /I "RUNNING" >nul
if %ERRORLEVEL% == 0 (
    :: Служба запущена, пытаемся остановить
    echo Служба "%SERVICE_NAME%" запущена. Остановка...
    net stop "%SERVICE_NAME%"
    if %ERRORLEVEL% neq 0 (
        echo Ошибка при остановке службы.
        pause
        goto MENU
    )
) else (
    echo Служба "%SERVICE_NAME%" не запущена. Пропускаем остановку.
)

:: Небольшая пауза перед запуском
timeout /t 2 /nobreak >nul

:: Запуск службы
echo Запуск службы "%SERVICE_NAME%"...
net start "%SERVICE_NAME%"
if %ERRORLEVEL% neq 0 (
    echo Ошибка при запуске службы.
    pause
) else (
    echo Служба перезапущена успешно.
    pause
)
goto MENU

:UPDATE
cls
echo =========================================
echo           Проверка обновлений
echo =========================================
echo.

:: Определение временных файлов
set "TEMP_DIR=%TEMP%\ZapretAFT_Update"
set "REMOTE_VERSION_FILE=%TEMP_DIR%\remote_version.txt"
set "DOWNLOAD_FILE_LIST=%TEMP_DIR%\file_list.json"

:: Создание временной директории
if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%"
)

:: Загрузка удалённой версии
echo Загрузка информации о последней версии...
powershell -Command ^
    "try { Invoke-WebRequest -Uri '%VERSION_URL%' -OutFile '%REMOTE_VERSION_FILE%' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo Ошибка при загрузке удалённой версии.
    pause
    goto CLEANUP_AND_MENU
)

:: Чтение версий
set /p REMOTE_VERSION=<"%REMOTE_VERSION_FILE%"
if not exist "%LOCAL_VERSION_FILE%" (
    echo Локальный файл версии не найден. Предполагается, что это первая установка.
    set "LOCAL_VERSION=0.0.0"
) else (
    set /p LOCAL_VERSION=<"%LOCAL_VERSION_FILE%"
)

echo Текущая версия: %LOCAL_VERSION%
echo Доступная версия: %REMOTE_VERSION%

:: Сравнение версий
if "%REMOTE_VERSION%"=="%LOCAL_VERSION%" (
    echo Вы используете последнюю версию.
    pause
    goto CLEANUP_AND_MENU
)

echo Обнаружено обновление. Начинается загрузка файлов...

:: Остановка и удаление службы перед обновлением
echo Остановка и удаление службы "%SERVICE_NAME%" перед обновлением...
sc query "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% == 0 (
    net stop "%SERVICE_NAME%"
    "%NSSM_PATH%" remove "%SERVICE_NAME%" confirm
)

:: Загрузка списка файлов с использованием GitHub API
echo Получение списка файлов из репозитория...
powershell -Command ^
    "try { Invoke-WebRequest -Uri '%GITHUB_API_TREE_URL%' -OutFile '%DOWNLOAD_FILE_LIST%' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo Ошибка при получении списка файлов из репозитория.
    pause
    goto CLEANUP_AND_MENU
)

:: Извлечение путей к файлам из JSON с помощью PowerShell и сохранение в временный файл
set "EXTRACTED_FILE_LIST=%TEMP_DIR%\extracted_file_list.txt"
powershell -Command ^
    "(Get-Content '%DOWNLOAD_FILE_LIST%') | ConvertFrom-Json | Select-Object -ExpandProperty tree | Where-Object { $_.type -eq 'blob' } | Select-Object -ExpandProperty path | Out-File -FilePath '%EXTRACTED_FILE_LIST%' -Encoding utf8"

:: Проверка успешности извлечения списка файлов
if not exist "%EXTRACTED_FILE_LIST%" (
    echo Ошибка при извлечении списка файлов.
    pause
    goto CLEANUP_AND_MENU
)

:: Цикл по списку файлов и их загрузка
for /f "usebackq delims=" %%A in ("%EXTRACTED_FILE_LIST%") do (
    set "FILE_PATH=%%A"
    call :DOWNLOAD_FILE "%%A"
)

:: Обновление локальной версии
echo %REMOTE_VERSION% > "%LOCAL_VERSION_FILE%"

:: Установка службы заново после обновления
echo Установка службы "%SERVICE_NAME%" с использованием NSSM...
"%NSSM_PATH%" install "%SERVICE_NAME%" "cmd.exe" "/c \"%BATCH_PATH%\""
if %ERRORLEVEL% neq 0 (
    echo Ошибка при установке службы.
    pause
    goto CLEANUP_AND_MENU
)

:: Установка описания службы
sc description "%SERVICE_NAME%" "%SERVICE_DESCRIPTION%"

:: Настройка автоматического запуска
sc config "%SERVICE_NAME%" start= auto

:: Запуск службы
echo Запуск службы "%SERVICE_NAME%"...
net start "%SERVICE_NAME%"
if %ERRORLEVEL% neq 0 (
    echo Ошибка при запуске службы.
    pause
    goto CLEANUP_AND_MENU
)

:: Перезапуск скрипта для применения обновлений
echo Обновление завершено успешно до версии %REMOTE_VERSION%.
echo Перезапуск manage_service.bat для применения обновлений...
start "" "%~f0" after_update
exit /b

:CLEANUP_AND_MENU
:: Очистка временных файлов
rd /s /q "%TEMP_DIR%"

goto MENU

:DOWNLOAD_FILE
:: Параметр %1 - относительный путь к файлу в репозитории
set "RELATIVE_PATH=%~1"
:: Формирование RAW URL для скачивания файла
set "RAW_URL=https://raw.githubusercontent.com/%GITHUB_USER%/%GITHUB_REPO%/%BRANCH%/%RELATIVE_PATH%"

:: Формирование локального пути к файлу
set "LOCAL_FILE=%CURRENT_DIR%%RELATIVE_PATH%"

:: Создание необходимых директорий
for %%F in ("%LOCAL_FILE%") do (
    if not exist "%%~dpF" (
        mkdir "%%~dpF"
    )
)

echo Загрузка файла: %RELATIVE_PATH%

:: Загрузка файла с GitHub
powershell -Command ^
    "try { Invoke-WebRequest -Uri '%RAW_URL%' -OutFile '%LOCAL_FILE%' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo Ошибка при загрузке файла: %RELATIVE_PATH%
    pause
    goto CLEANUP_AND_MENU
)
goto :eof

:END
exit /b
