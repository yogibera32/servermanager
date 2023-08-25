@echo off
setlocal

set "serverPath=replaceme"
set "configPath=server.cfg"

set "authorizedPassword=%FXServer_PASSWORD%"

set "authenticated=false"
set "authenticationDone=false"

echo Please log in using 'bebo login'.

:main
echo --(root@user)-[~]--$

set /p "command="
if "%command%"=="bebo login" (
    call :authenticateUser
) else if "%authenticated%"=="true" (
    if "%command%"=="bebo start" (
        call :startServer
        echo CFX server started.
    ) else if "%command%"=="bebo stop" (
        call :stopServer
        echo CFX server stopped.
    ) else if "%command%"=="bebo restart" (
        call :restartServer
        echo CFX server restarted.
    ) else if "%command%"=="bebo logout" (
        set "authenticated=false"
        set "authenticationDone=false"
        echo You have been logged out.
    ) else (
        echo Unknown command. Valid commands are 'bebo login', 'bebo start', 'bebo stop', 'bebo restart', and 'bebo logout'.
    )
) else (
    echo You need to log in using 'bebo login'.
)

goto main

:authenticateUser
setlocal enabledelayedexpansion
powershell -command "$password = Read-Host 'Enter password' -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)" > key.txt
set /p "password=" < key.txt
del key.txt
if "%password%"=="%authorizedPassword%" (
    endlocal
    set "authenticated=true"
    set "authenticationDone=true"
    echo Authentication successful.
) else (
    endlocal
    echo Authentication failed.
)
goto :eof

:startServer
start "" "%serverPath%" +exec %configPath%
goto :eof

:stopServer
taskkill /f /im FXServer.exe
timeout /t 5 /nobreak > nul
goto :eof

:restartServer
call :stopServer
call :startServer
goto :eof