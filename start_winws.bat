@echo off
chcp 65001 >nul
:: 65001 - UTF-8

:: Переход в директорию, где находится батник
cd /d "%~dp0"

:: Установка переменной BIN на поддиректорию bin\
set "BIN=%~dp0bin\"

:: Установка переменной для файла списка, находящегося в той же директории
set "LIST_PATH=%~dp0list-everything.txt"
set "IPSET_PATH=%~dp0ipset.txt"

:: Проверка наличия необходимых файлов
if not exist "%BIN%winws.exe" (
    echo Ошибка: %BIN%winws.exe не найден.
    pause
    exit /b 1
)

if not exist "%LIST_PATH%" (
    echo Ошибка: %LIST_PATH% не найден.
    pause
    exit /b 1
)

if not exist "%IPSET_PATH%" (
    echo Ошибка: %IPSET_PATH% не найден.
    pause
    exit /b 1
)

:: Запуск winws.exe с необходимыми параметрами
"%BIN%winws.exe" ^
    --wf-tcp=80,443 --wf-udp=443,50000-50099 ^
    --filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
    --filter-tcp=443 --hostlist="%LIST_PATH%" --dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=11 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
    --filter-tcp=443 --dpi-desync=fake,multidisorder --dpi-desync-split-pos=midsld --dpi-desync-repeats=6 --dpi-desync-fooling=badseq,md5sig --new ^
    --filter-udp=443 --hostlist="%LIST_PATH%" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
    --filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=11 --new ^
    --filter-udp=50000-50099 --ipset="%IPSET_PATH%" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 > "%~dp0winws_log.txt" 2>&1

:: Проверка завершения команды
if %errorlevel% neq 0 (
    echo winws.exe завершился с ошибкой %errorlevel%.
    pause
    exit /b %errorlevel%
)
pause