@chcp 65001
@echo off

cls

rem Включаем отложенное расширение переменных
setlocal enabledelayedexpansion

rem Определяем директорию, где находится скрипт
set script_dir=%~dp0

rem Определяем путь к папке с ADB
set adb_path=%script_dir%Adb\adb.exe

rem Директория, где находятся системные APK файлы
set sys_dir=%script_dir%Sys

rem Директория, где находятся рекомендуемые APK файлы
set apk_dir=%script_dir%Apk

REM Директория, где находятся пользовательские APK файлы
set app_dir=%script_dir%App

rem Директория для бэкапа
set backup_dir=%script_dir%backup


set "state=."
set "count=0"

:logo

cls
echo.
echo.                                                                          
echo                             ██████████████████████████████████████ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ██████                 ███ 
echo                             ███           ██████               ███ 
echo                             ███             ██████             ███ 
echo                             ███               ██████           ███ 
echo                             ███                 █████          ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ██████████████████████████████████████
echo.
echo.
echo                                        [93mZeekr Adb Toolkit[0m
echo                                   https://t.me/zeekr_infohub
echo.

rem Проверка подключения устройства
:waitForDevice
	echo [95m                                   Проверка подключения ADB...[0m
    TIMEOUT /t 3 /NOBREAK >nul
	
:checkDevice
"%adb_path%" shell echo Connected 1>nul 2>nul
if errorlevel 1 (
	echo  [91m                                   Устройство не подключено[0m
    TIMEOUT /t 3 /NOBREAK >nul
    goto checkDevice
)
    echo  [92m                                    Устройство подключено[0m
	TIMEOUT /t 2 /NOBREAK >nul

REM Проверка состояния package_verifier_enable
for /f "tokens=*" %%i in ('"%adb_path%" shell settings get global package_verifier_enable') do (
    set "verifier_status=%%i"
)

if "!verifier_status!"=="1" (
    echo [95m                                 Отключение проверки установки приложений...[0m
    "%adb_path%" shell pm disable com.ecarx.xsfinstallverifier
    "%adb_path%" shell settings put global package_verifier_enable 0
    "%adb_path%" shell settings put global verifier_verify_adb_installs 0
    echo  [92m                             Проверка установки сторонних приложений отключена.[0m
	TIMEOUT /t 2 /NOBREAK >nul
)

rem Вывод Меню
:MENU
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo  [93m     Меню сервисных функций ГУ Zeekr 001[0m
echo ------------------------------------------------------------------
echo  [96m 1. Перезагрузить ADB сервер[0m
echo  [96m 2. Перезагрузить планшет[0m
echo  [96m 3. Установить приложения из папки[0m[93m Sys[0m [[92mРусификация[0m]
echo  [96m 4. Установить приложения из папки[0m[93m Apk[0m [[92mРекомендуемые приложения[0m]
echo  [96m 5. Установить приложения из папки[0m[93m App[0m [[92mВаши приложения[0m]
echo  [96m 6. Смена часового пояса[0m
echo  [96m 7. Активировать Shizuku[0m
echo.
echo  [96m B. Создать резервную копию системных файлов[0m
echo  [96m S. Инфо[0m
echo  [96m Q. Выход[0m
echo ------------------------------------------------------------------
set /p Xz=Выберите пункт меню:

rem Передача управления на соответствующий пункт по выбору
if /i "%Xz%"=="1" goto reboot_adb_server
if /i "%Xz%"=="2" goto reboot_adb_host
if /i "%Xz%"=="3" goto check_sys
if /i "%Xz%"=="4" goto install_apk
if /i "%Xz%"=="5" goto install_user_apps
if /i "%Xz%"=="6" goto timezone
if /i "%Xz%"=="7" goto shizuku
if /i "%Xz%"=="b" goto backup_apps
if /i "%Xz%"=="s" goto info
if /i "%Xz%"=="q" goto eexit

goto MENU

rem перезагрузка сервера ADB
:reboot_adb_server
echo ------------------------------------------------------------------
echo [95m                    Перезагрузка сервера ADB...[0m
echo ------------------------------------------------------------------
"%adb_path%" kill-server
"%adb_path%" start-server
    TIMEOUT /t 2 /NOBREAK >nul
	
goto logo
	
rem Функция для вывода сообщения при отсутствии подключения
:show_adb_error
	echo.
	echo  [91m                                     Устройство не подключено.[0m
    echo  [91m                                      Проверьте подключение.[0m
	echo.
	
	pause
goto logo


rem Перезагрузка устройства
:reboot_adb_host
echo ------------------------------------------------------------------
echo [95m                 Попытка перезагрузки устройства...[0m
echo ------------------------------------------------------------------

rem Проверяем наличие подключенного устройства
"%adb_path%" devices | findstr "device" >nul
if %errorlevel% neq 0 (
	echo.
	echo  [91m                                     Устройство не подключено.[0m
    echo  [91m                                      Проверьте подключение.[0m
	echo.
    TIMEOUT /t 3 >nul
    pause
goto logo
)

rem Если устройство найдено, выполняем команду перезагрузки
"%adb_path%" reboot
if %errorlevel% neq 0 (
	echo.
    echo  [91m                                   Не удалось перезагрузить устройство.[0m
    echo  [91m                                      Проверьте подключение.[0m
	echo.
	TIMEOUT /t 3 >nul
goto logo

) else (
:loop
cls
echo.
echo.                                                                          
echo                             ██████████████████████████████████████ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ████                   ███ 
echo                             ███         ██████                 ███ 
echo                             ███           ██████               ███ 
echo                             ███             ██████             ███ 
echo                             ███               ██████           ███ 
echo                             ███                 █████          ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ███                   ████         ███ 
echo                             ██████████████████████████████████████
echo.
echo.
echo                                        [93mZeekr Adb Toolkit[0m
echo                                   https://t.me/zeekr_infohub
echo.
echo  [95m                                 Устройство перезагружается!%state%[0m

set /a count+=1

if !count! geq 24 (
    goto reboot_done
)

timeout /nobreak /t 1 >nul

if "!state!"=="..." (
    set "state=."
) else (
    set "state=!state!."
)

goto loop

:reboot_done
echo  [95m                                     Загрузка интерфейса...[0m
timeout /nobreak /t 2 >nul

goto logo

)


rem Установка приложений из папки Sys
:check_sys
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo [95m Проверяем наличие APK файлов в папке "%sys_dir%"...[0m
echo ------------------------------------------------------------------
if not exist "%sys_dir%\*.apk" (
	echo ------------------------------------------------------------------
    echo  [91m                                 Нет APK файлов для установки.[0m
	echo ------------------------------------------------------------------
    pause
    goto MENU
)

rem Проверка наличия резервной копии
if not exist "%backup_dir%" (
    mkdir "%backup_dir%"
) else (
	echo ------------------------------------------------------------------
    echo [95m Проверка наличия резервной копии...[0m
	echo ------------------------------------------------------------------
    
    if exist "%backup_dir%\*" (
		echo ------------------------------------------------------------------
        echo Внимание: [93m Бэкап уже существует в %backup_dir%.[0m
        echo [92m Установка приложений продолжается...[0m
		echo ------------------------------------------------------------------
        goto install_sys
    )
)

echo ------------------------------------------------------------------
echo [95m Резервная копия не найдена. Создание бэкапа...[0m
echo ------------------------------------------------------------------
TIMEOUT /T 3 >nul

call :create_backup

goto install_sys

:create_backup
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo [95m Создание бэкапа системных приложений...[0m
echo ------------------------------------------------------------------

call :pull_backup /system/app
call :pull_backup /system/priv-app

echo ------------------------------------------------------------------
echo [92m          Бэкап завершен.[0m
echo [92m Все приложения скопированы в %backup_dir%.[0m
echo ------------------------------------------------------------------

pause
exit /b

:pull_backup
setlocal
set "path=%~1"
echo.
echo [95m Копирование из %path%...[0m
"%adb_path%" pull "%path%" "%backup_dir%"
if errorlevel 1 (
	echo ------------------------------------------------------------------
    echo  [91m Ошибка при создании бэкапа из %path%.[0m
    echo  [91m Проверьте подключение.[0m
	echo ------------------------------------------------------------------
    TIMEOUT /T 3 >nul
    pause
    goto end
)
endlocal
exit /b

:install_sys
rem Проверка подключения перед установкой
"%adb_path%" devices | findstr "device" >nul
if %errorlevel% neq 0 (
    call :show_adb_error
    TIMEOUT /t 5 /NOBREAK >nul
    goto logo
)

"%adb_path%" root
if %errorlevel% neq 0 (
    echo.
    echo  [91m                                 Не удалось получить root права.[0m
    echo  [91m                                      Проверьте подключение.[0m
    echo.
    TIMEOUT /t 5 /NOBREAK >nul
    pause
    goto logo
)

"%adb_path%" remount
if %errorlevel% neq 0 (
    echo.
    echo  [91m                               Не удалось смонтировать файловую систему.[0m
    echo  [91m                                      Проверьте подключение.[0m
    echo.
    TIMEOUT /t 5 /NOBREAK >nul
    pause
    goto logo
)

TIMEOUT /T 3 > nul

echo.
echo [95m Установка APK файлов...[0m 
echo.
for %%f in ("%sys_dir%\*.apk") do (
    set "sys_file=%%f"
    set "sys_name=%%~nxf"

    echo  [92m                                  Найден APK файл: !sys_name![0m 

    rem Проверяем подключение перед установкой каждого APK
    "%adb_path%" devices | findstr "device" >nul
    if %errorlevel% neq 0 (
		echo ------------------------------------------------------------------
        echo  [91m                                   Устройство не подключено[0m
        echo  [91m                                      Проверьте подключение.[0m
		echo ------------------------------------------------------------------
    TIMEOUT /t 5 /NOBREAK >nul
        goto logo
    )

    if "!sys_name!"=="XCGallery.apk" (
    echo.
    echo [95m                                 Установка приложения "Галерея"...[0m 
    echo.
        "%adb_path%" push "!sys_file!" /system/app/XCGallery/
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="XCMedia2.apk" (
    echo.
    echo [95m                                 Установка приложения "Медиа"...[0m 
    echo.
        "%adb_path%" push "!sys_file!" /system/app/XCMedia2/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
	) else if "!sys_name!"=="ZeekrMediaCenter.apk" (
	echo.
	echo [95m                                 Установка приложения "Медиацентр"...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/app/ZeekrMediaCenter/
        "%adb_path%" install -g "!sys_file!"
	TIMEOUT /T 3 > nul
    ) else if "!sys_name!"=="ZeekrKindMode.apk" (
	echo.
	echo [95m                                 Установка ZeekrKindMode.apk...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/vendor/app/ZeekrKindMode/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="XCLauncher3.apk" (
	echo.
	echo [95m                                 Установка XCLauncher3.apk...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/app/XCLauncher3/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="XCMemberCenter.apk" (
	echo.
	echo [95m                                 Установка приложения "Центр пользователя"...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/app/XCMemberCenter/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="SystemUI.apk" (
	echo.
	echo [95m                                 Установка SystemUI.apk...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/priv-app/SystemUI/
        "%adb_path%" shell pkill -TERM -f com.android.systemui
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="EcarxBTPhone.apk" (
	echo.
	echo [95m                                 Установка приложения "Телефон"...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/app/EcarxBTPhone/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="GeelyHvac.apk" (
	echo.
	echo [95m                                 Установка приложения "Климат"...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/vendor/app/GeelyHvac/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 4 /NOBREAK >nul
    ) else if "!sys_name!"=="GeelySettings.apk" (
	echo.
	echo [95m                                 Установка GeelySettings.apk...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/app/GeelySettings/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 5 /NOBREAK >nul
    ) else if "!sys_name!"=="XCMyCar.apk" (
	echo.
	echo [95m                                 Установка приложения "Моя машина"...[0m 
	echo.
        "%adb_path%" push !sys_file!" /system/app/XCMyCar/
        "%adb_path%" install -g "!sys_file!!"
    TIMEOUT /t 3 /NOBREAK >nul
	) else if "!sys_name!"=="NotificationApp.apk" (
	echo.
	echo [95m                                 Установка экрана "Приложение уведомлений (всплывающие окна)"...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/app/NotificationApp/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="XSFNotificationCenter.apk" (
	echo.
	echo [95m                                 Установка экрана "Шторка"...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/priv-app/XSFNotificationCenter/
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    ) else if "!sys_name!"=="SentryMode.apk" (
	echo.
	echo [95m                                 Установка приложения "Охрана"...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/vendor/app/SentryMode/
        "%adb_path%" install -r -g "!sys_file!"
    TIMEOUT /t 5 /NOBREAK >nul
    ) else if "!sys_name!"=="ZeekrCarLauncher3D.apk" (
	echo.
	echo [95m                                 Установка ZeekrCarLauncher3D.apk...[0m 
	echo.
        "%adb_path%" push "!sys_file!" /system/priv-app/ZeekrCarLauncher3D/
        "%adb_path%" install -g "!sys_file!"
        "%adb_path%" shell pm clear com.zeekr.carlauncher3d
    TIMEOUT /t 3 /NOBREAK >nul
	) else if "!sys_name!"=="ZeekrCarManager.apk" (
	echo.
	echo [95m                                 Установка приложения "Менеджер системы, очистка"...[0m 
	echo.
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    )  else if "!sys_name!"=="ExteriorAudioPlayApp.apk" (
	echo.
	echo [95m                                 Установка приложения "Внешний звук"...[0m 
	echo.
        "%adb_path%" install -g "!sys_file!"
    TIMEOUT /t 3 /NOBREAK >nul
    ) else (
        echo.
        echo  [91m APK файл !sys_name! не поддерживается, пропускаем.[0m 
        echo.
    )
    
    echo.
    echo  [92m                                  Установка !sys_name! завершена.[0m 
    echo.
)

endlocal

echo.
echo  [92m                                    Все APK файлы обработаны.[0m 
echo.

TIMEOUT /t 3 /NOBREAK >nul
pause
goto MENU



rem Меню для установки приложений
:install_apk
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
		echo ------------------------------------------------------------------
echo  [93m     Выберите приложение[0m
		echo ------------------------------------------------------------------
echo  [96m 1. Отключение проверки для установки сторонних приложений[0m
echo  [96m 2. Клавиатура [93mGboard[0m
echo  [96m 3. Клавиатура [93mYandex[0m
echo  [96m 4. Магазин приложений [93mApkPure[0m
echo  [96m 5. Магазин приложений [93mRuStore[0m
echo  [96m 6. Антирадар [93mStrelka[0m
echo  [96m 7. Кнопка [93mНазад[0m
echo.
echo  [96m M. Меню[0m
echo  [96m Q. Выход[0m
		echo ------------------------------------------------------------------
echo Введите номера приложений для установки (например: 1,2,5) или M для меню, Q для выхода:
set /p choices="Ваш выбор: "
echo.

rem Проверка на пустой ввод
if "%choices%"=="" (
		echo ------------------------------------------------------------------
    echo [91m       Вы ничего не выбрали. Переход в предыдущее меню.[0m
		echo ------------------------------------------------------------------
    pause
    goto MENU
)

rem Обработка выбора меню или выхода
if /i "%choices%"=="m" goto MENU
if /i "%choices%"=="q" goto eexit

rem Установка команд
set "numCommands=0"
for /L %%i in (0,1,9) do (
    if not "!choices:~%%i,1!"=="" (
        set /a numCommands+=1
    )
)

"%adb_path%" shell echo Connected 1>nul 2>nul
if errorlevel 1 (
    echo  [91m                                   Устройство не подключено[0m
    TIMEOUT /t 3 /NOBREAK >nul
    goto logo
)

rem Выполняем команды последовательно
for /L %%i in (0,1,%numCommands%-1) do (
    set "action=!choices:~%%i,1!"
    
    if "!action!"=="1" (
		echo ------------------------------------------------------------------
        echo Вы выбрали:[96m              Отключение проверки для установки сторонних приложений[0m
		echo ------------------------------------------------------------------

        REM Проверка состояния package_verifier_enable
        for /f "tokens=*" %%i in ('"%adb_path%" shell settings get global package_verifier_enable') do (
            set "verifier_status=%%i"
        )

        if "!verifier_status!"=="1" (
            echo [95m                                 Отключение проверки...[0m
            "%adb_path%" shell pm disable com.ecarx.xsfinstallverifier
            "%adb_path%" shell settings put global package_verifier_enable 0
            "%adb_path%" shell settings put global verifier_verify_adb_installs 0
		echo ------------------------------------------------------------------
        echo  [92m                           Проверка установки сторонних приложений отключена.[0m
		echo ------------------------------------------------------------------
            TIMEOUT /t 5 /NOBREAK >nul
            pause
            goto logo
        )
        
    ) else if "!action!"=="2" (
		echo ------------------------------------------------------------------
        echo Вы выбрали:[96m                    Установить клавиатуру Gboard[0m
		echo ------------------------------------------------------------------
        echo [95m                               Установка клавиатуры...[0m
        "%adb_path%" install -r -g "%apk_dir%\Gboard.apk"
        "%adb_path%" shell ime enable com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME
        "%adb_path%" shell ime set com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME
        echo [92m                               Установка клавиатуры завершена.[0m
		echo ------------------------------------------------------------------
        TIMEOUT /t 3 >nul

    ) else if "!action!"=="3" (
        echo ------------------------------------------------------------------
        echo Вы выбрали:[96m                    Установить клавиатуру Yandex[0m
        echo ------------------------------------------------------------------
        echo [95m                               Установка клавиатуры Yandex...[0m
        "%adb_path%" install -r -g "%apk_dir%\Yboard.apk"
        "%adb_path%" shell ime enable ru.yandex.androidkeyboard/com.android.inputmethod.latin.LatinIME
		"%adb_path%" shell ime set ru.yandex.androidkeyboard/com.android.inputmethod.latin.LatinIME
        echo [92m                               Установка клавиатуры Yandex завершена.[0m
        TIMEOUT /t 3 >nul
        

    ) else if "!action!"=="4" (
        echo ------------------------------------------------------------------
        echo Вы выбрали:[96m                    Установить магазин приложений ApkPure[0m
        echo ------------------------------------------------------------------
		echo [95m                               Удаление старой версии...[0m
            "%adb_path%" -d shell am force-stop com.apkpure.aegon
            TIMEOUT /t 2 /NOBREAK >nul
            "%adb_path%" -d shell pm clear com.apkpure.aegon
            TIMEOUT /t 2 /NOBREAK >nul
            "%adb_path%" -d shell pm uninstall com.apkpure.aegon
            TIMEOUT /t 2 /NOBREAK >nul
		echo  [92m                              Удаление старой версии завершено...[0m
        echo ------------------------------------------------------------------
		echo [95m                               Установка магазина приложений...[0m
		echo.
            "%adb_path%" -d install -r -g %apk_dir%\APKPure.apk
            "%adb_path%" -d shell appops set com.apkpure.aegon REQUEST_INSTALL_PACKAGES allow
		echo  [92m                              Установка магазина приложений ApkPure завершена.[0m
		echo.
        TIMEOUT /t 3 >nul

    ) else if "!action!"=="5" (
        echo ------------------------------------------------------------------
        echo Вы выбрали:[96m                    Установить магазин приложений RuStore[0m
        echo ------------------------------------------------------------------
 		echo [95m                               Удаление старой версии...[0m
			"%adb_path%" -d shell am force-stop ru.vk.store
            TIMEOUT /t 2 /NOBREAK >nul
            "%adb_path%" -d shell pm clear ru.vk.store
            TIMEOUT /t 2 /NOBREAK >nul
            "%adb_path%" -d shell pm uninstall ru.vk.store
            TIMEOUT /t 2 /NOBREAK >nul
		echo  [92m                              Удаление старой версии завершено...[0m
        echo ------------------------------------------------------------------
		echo [95m                               Установка магазина приложений...[0m
            "%adb_path%" -d install -r -g %apk_dir%\RuStore.apk
            "%adb_path%" -d shell appops set ru.vk.store REQUEST_INSTALL_PACKAGES allow
		echo  [92m                              Установка магазина приложений RuStore завершена.[0m
        TIMEOUT /t 3 >nul

    ) else if "!action!"=="6" (
        echo ------------------------------------------------------------------
        echo Вы выбрали:[96m                    Установить Антирадар Strelka[0m
        echo ------------------------------------------------------------------
		echo [95m                               Установка антирадара...[0m
			"%adb_path%" -d install -g %apk_dir%\StrelkaSD.apk
			"%adb_path%" shell pm grant com.ivolk.StrelkaGPS android.permission.SYSTEM_ALERT_WINDOW
			"%adb_path%" shell dumpsys deviceidle whitelist +com.ivolk.StrelkaGPS
		echo  [92m                              Установка антирадара Strelka завершена.[0m
        TIMEOUT /t 3 >nul

    ) else if "!action!"=="7" (
		echo ------------------------------------------------------------------
		echo Вы выбрали:[96m                    Установить кнопку "Назад"[0m
		echo ------------------------------------------------------------------
		echo [95m                               Установка кнопки...[0m
			"%adb_path%" -d install -g %apk_dir%\Back_button.apk
			"%adb_path%" shell settings put secure enabled_accessibility_services com.appspot.app58us.backkey/.BackkeyService
		echo  [92m                              Установка кнопки "Назад" завершена.[0m
		TIMEOUT /t 3 >nul
    )

rem Если только одна команда, ставим паузу
    if %numCommands% equ 1 (
        pause
    )
)

echo.
		echo ------------------------------------------------------------------
		echo [92m                               Все выбранные APK файлы обработаны.[0m 
		echo ------------------------------------------------------------------
TIMEOUT /T 3 >nul
goto install_apk

rem Пауза в конце, если было введено несколько команд
if %numCommands% gtr 1 (
    pause
)

goto MENU




:install_user_apps
cls
set /a index=0
set "app_files="

echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo  [93m     Список доступных приложений для установки:[0m
echo ------------------------------------------------------------------

rem Перебираем приложение .apk в директории
for %%f in ("%app_dir%\*.apk") do (
    set /a index+=1
    echo  [96m !index!: %%~nxf [0m
    set "app_files=!app_files!%%~nxf;"
)

echo.
echo  [96m M. Меню[0m
echo  [96m Q. Выход[0m
echo ------------------------------------------------------------------

rem Проверка, есть ли доступные приложения
if !index! EQU 0 (
    echo [91m Нет доступных приложений для установки.[0m
    echo ------------------------------------------------------------------
    echo [96m Скопируйте необходимые приложения в папку App [0m
    echo.
    pause
    goto MENU
)

echo Введите номера приложений для установки (например: 1,2,5) или M для меню, Q для выхода:
set /p choices="Ваш выбор: "
echo.

rem Проверка на пустой ввод
if "%choices%"=="" (
    echo ------------------------------------------------------------------
    echo [91m       Вы ничего не выбрали. Переход в предыдущее меню.[0m
    echo ------------------------------------------------------------------
    pause
    goto MENU
)

rem Обработка выбора меню или выхода
if /i "%choices%"=="m" goto MENU
if /i "%choices%"=="q" goto eexit

rem Установка выбранных приложений
for %%n in (%choices%) do (
    if %%n GTR 0 (
        set /a app_index=%%n-1
        rem Получаем имя файла .apk по индексу
        set "current_index=0"
        for %%f in (!app_files!) do (
            rem Извлекаем имя файла и проверяем текущий индекс
            if !current_index! EQU !app_index! (
                "%adb_path%" install -r -g "%app_dir%\%%f"
                echo.
                echo  [92m                                    Установка %%f завершена.[0m
                echo.
                TIMEOUT /T 3 >nul
            )
            set /a current_index+=1
        )
    )
)

echo ------------------------------------------------------------------
echo  [92m                                    Все APK файлы обработаны.[0m 
echo ------------------------------------------------------------------

TIMEOUT /T 3 >nul
pause
goto MENU




:timezone
cls
setlocal
:: Получаем текущий часовой пояс
for /f "delims=" %%t in ('tzutil /g') do set timezone=%%t

:: Проверяем часовой пояс и устанавливаем переменную settime
if "%timezone%"=="Kaliningrad Standard Time" (
    set settime=+02:00 Калининград
) else if "%timezone%"=="Moscow Standard Time" (
    set settime=+03:00 Москва
) else if "%timezone%"=="Kazan Standard Time" (
    set settime=+03:00 Казань
) else if "%timezone%"=="Samara Standard Time" (
    set settime=+04:00 Самара
) else if "%timezone%"=="Saratov Standard Time" (
    set settime=+04:00 Саратов
) else if "%timezone%"=="Yekaterinburg Standard Time" (
    set settime=+05:00 Екатеринбург
) else if "%timezone%"=="Omsk Standard Time" (
    set settime=+06:00 Омск
) else if "%timezone%"=="North Asia Standard Time" (
    set settime=+07:00 Красноярск
) else if "%timezone%"=="N. Central Asia Standard Time" (
    set settime=+07:00 Новосибирск
) else if "%timezone%"=="North Asia East Standard Time" (
    set settime=+08:00 Иркутск
) else if "%timezone%"=="Yakutsk Standard Time" (
    set settime=+09:00 Якутск
) else if "%timezone%"=="Vladivostok Standard Time" (
    set settime=+10:00 Владивосток
) else if "%timezone%"=="Magadan Standard Time" (
    set settime=+11:00 Магадан
) else if "%timezone%"=="Kamchatka Standard Time" (
    set settime=+12:00 Камчатка
) else (
    set settime=[91mНе удалось выяснить [0m
)

rem Смена часового пояса

echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo [95m  Таймзона операционной системы Windows:[0m[92m %settime% [0m
echo ------------------------------------------------------------------
echo  [93m     Выберите часовой пояс для установки[0m
echo ------------------------------------------------------------------

:: Подсветка текущего часового пояса

if "%timezone%"=="Moscow Standard Time" (
    echo  [92m1. +03:00  Москва[0m
) else (
    echo  [96m1. +03:00  Москва[0m
)

if "%timezone%"=="Samara Standard Time" (
    echo  [92m2. +04:00  Самара[0m
) else (
    echo  [96m2. +04:00  Самара[0m
)

if "%timezone%"=="Yekaterinburg Standard Time" (
    echo  [92m3. +05:00  Екатеринбург[0m
) else (
    echo  [96m3. +05:00  Екатеринбург[0m
)

if "%timezone%"=="Omsk Standard Time" (
    echo  [92m5. +06:00  Омск[0m
) else (
    echo  [96m4. +06:00  Омск[0m
)

if "%timezone%"=="N. Central Asia Standard Time" (
    echo  [92m5. +07:00  Новосибирск[0m
) else (
    echo  [96m5. +07:00  Новосибирск[0m
)

if "%timezone%"=="North Asia East Standard Time" (
    echo  [92m6. +08:00  Иркутск[0m
) else (
    echo  [96m6. +08:00  Иркутск[0m
)

if "%timezone%"=="Yakutsk Standard Time" (
    echo  [92m7. +09:00  Якутск[0m
) else (
    echo  [96m7. +09:00  Якутск[0m
)

if "%timezone%"=="Vladivostok Standard Time" (
    echo  [92m8. +10:00  Владивосток[0m
) else (
    echo  [96m8. +10:00  Владивосток[0m
)

if "%timezone%"=="Magadan Standard Time" (
    echo  [92m9. +11:00  Магадан[0m
) else (
    echo  [96m9. +11:00  Магадан[0m
)

if "%timezone%"=="Kamchatka Standard Time" (
    echo  [92m6. +12:00  Камчатка[0m
) else (
    echo  [96m0. +12:00  Камчатка[0m
)

echo ------------------------------------------------------------------
echo  [96mM. Меню[0m
echo  [96mQ. Выход[0m
echo ------------------------------------------------------------------
set /p Xz=Выберите пункт меню:

rem Передача управления на соответствующий пункт по выбору
if "%Xz%"=="1" set region=Europe/Moscow & goto set_region
if "%Xz%"=="2" set region=Europe/Samara & goto set_region
if "%Xz%"=="3" set region=Asia/Yekaterinburg & goto set_region
if "%Xz%"=="4" set region=Asia/Omsk & goto set_region
if "%Xz%"=="5" set region=Asia/Novosibirsk & goto set_region
if "%Xz%"=="6" set region=Asia/Irkutsk & goto set_region
if "%Xz%"=="7" set region=Asia/Yakutsk & goto set_region
if "%Xz%"=="8" set region=Asia/Vladivostok & goto set_region
if "%Xz%"=="9" set region=Asia/Magadan & goto set_region
if "%Xz%"=="0" set region=Asia/Kamchatka & goto set_region

if /i "%Xz%"=="m" goto MENU
if /i "%Xz%"=="q" goto eexit
goto timezone

:set_region
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo                   Смена часового пояса на[93m %region%[0m
echo ------------------------------------------------------------------

rem Выполнение команды смены часового пояса
"%adb_path%" root
if %errorlevel% neq 0 (
    echo.
    echo  [91m                                 Не удалось получить root права.[0m
    echo  [91m                                      Проверьте подключение.[0m
    echo.
    TIMEOUT /t 5 /NOBREAK >nul
    goto logo
)

"%adb_path%" remount
if %errorlevel% neq 0 (
    echo.
    echo  [91m                               Не удалось смонтировать файловую систему.[0m
    echo  [91m                                      Проверьте подключение.[0m
    echo.
    TIMEOUT /t 5 /NOBREAK >nul
    goto logo
)
"%adb_path%" shell setprop persist.sys.timezone "%region%"
"%adb_path%" shell settings put global auto_time 1

echo  [92m                                    Выставлен часовой пояс %region% [0m
echo ------------------------------------------------------------------
TIMEOUT /t 5 /NOBREAK >nul

goto reboot_adb_host

:shizuku
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
		echo ------------------------------------------------------------------
        echo Вы выбрали:[96m                    Активировать Shizuku [0m
		echo ------------------------------------------------------------------
		echo.
		echo [95m                                 Активация Shizuku...[0m
		echo.
"%adb_path%" root	
if %errorlevel% neq 0 (
	echo.
    echo  [91m                                 Не удалось получить root права.[0m
	echo  [91m                                      Проверьте подключение.[0m
	echo.
    TIMEOUT /t 5 /NOBREAK >nul
goto logo
)

"%adb_path%" remount
if %errorlevel% neq 0 (
	echo.
    echo  [91m                               Не удалось смонтировать файловую систему.[0m
	echo  [91m                                      Проверьте подключение.[0m
	echo.
    TIMEOUT /t 5 /NOBREAK >nul
goto logo
)
			"%adb_path%" shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
    echo  [92m                                    Shizuku активирован.[0m
		echo.
pause
goto MENU


:backup_apps

rem Проверка подключения ADB
"%adb_path%" devices | findstr "device" >nul
if %errorlevel% neq 0 (
    call :show_adb_error
    TIMEOUT /t 3 /NOBREAK >nul
    pause
    goto logo
)

rem Функция проверки и создания директории
:check_backup
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo [95m Проверка наличия резервной копии...[0m
echo ------------------------------------------------------------------
    TIMEOUT /t 1 /NOBREAK >nul
	
if exist "%backup_dir%\*" (
    echo Внимание:[92m Бэкап уже существует в %backup_dir%.[0m
    echo ------------------------------------------------------------------
    set /p overwrite=Хотите переписать резервную копию? [Y/N]: 

    REM Удаляем лишние пробелы
    set overwrite=!overwrite:~0,1!

    if /i "!overwrite!"=="y" (
        goto create_backup
    ) else if /i "!overwrite!"=="n" (
        echo.
        echo ------------------------------------------------------------------
        echo [91m Отмена перезаписи резервной копии[0m
        echo ------------------------------------------------------------------
        pause
        goto MENU
    ) else (
        echo.
        echo Пожалуйста! введите Y или N.
        echo.
        goto check_backup
    )
)

:create_backup
cls
echo [93m                                                 Zeekr Adb Toolkit[0m
echo ------------------------------------------------------------------
echo [95m Создание бэкапа системных приложений...[0m
echo ------------------------------------------------------------------


rem Резервное копирование системных приложений
"%adb_path%" pull /system/app "%backup_dir%"
if %errorlevel% neq 0 (
    echo.
    echo  [91m Ошибка при создании бэкапа из /system/app.[0m
    echo  [91m Проверьте подключение.[0m
    echo.
    TIMEOUT /T 3 >nul
    pause
    goto logo
)

rem Резервное копирование привилегированных приложений
"%adb_path%" pull /system/priv-app "%backup_dir%"
if %errorlevel% neq 0 (
    echo.
    echo  [91m Ошибка при создании бэкапа из /system/priv-app.[0m
    echo  [91m Проверьте подключение.[0m
    echo.
    TIMEOUT /T 3 >nul
    pause
    goto logo
)

echo ------------------------------------------------------------------
echo [92m                    Бэкап завершен.[0m
echo [92m Все приложения скопированы в %backup_dir%.[0m
echo ------------------------------------------------------------------

pause
goto MENU

:info
cls
COLOR 0A
echo.
echo.
echo    	               ███████╗███████╗███████╗██╗  ██╗██████╗            
echo    	               ╚══███╔╝██╔════╝██╔════╝██║ ██╔╝██╔══██╗           
echo    	                 ███╔╝ █████╗  █████╗  █████╔╝ ██████╔╝           
echo    	                ███╔╝  ██╔══╝  ██╔══╝  ██╔═██╗ ██╔══██╗           
echo    	               ███████╗███████╗███████╗██║  ██╗██║  ██║           
echo    	               ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝           
echo.
echo  █████╗ ██████╗ ██████╗     ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██╗████████╗
echo  ██╔══██╗██╔══██╗██╔══██╗    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██║ ██╔╝██║╚══██╔══╝
echo  ███████║██║  ██║██████╔╝       ██║   ██║   ██║██║   ██║██║     █████╔╝ ██║   ██║   
echo  ██╔══██║██║  ██║██╔══██╗       ██║   ██║   ██║██║   ██║██║     ██╔═██╗ ██║   ██║   
echo  ██║  ██║██████╔╝██████╔╝       ██║   ╚██████╔╝╚██████╔╝███████╗██║  ██╗██║   ██║   
echo  ╚═╝  ╚═╝╚═════╝ ╚═════╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   
echo.
echo.
echo          [93m      Если безумно хочется угостить разработчиков кофе 😎 [0m
echo.
echo    [92m          4006 8006 0235 6726 (сбер) [0m на поддержку удобной утилиты
echo.
echo    [93m          Особая благодарность чату https://t.me/zeekr_infohub[0m
echo    [93m          за информацию и файлы русификации Zeekr 001 дорестайлинг [0m
echo.
    pause
goto logo

:eexit
cls
exit