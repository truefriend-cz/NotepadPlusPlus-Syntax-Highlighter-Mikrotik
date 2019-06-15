@echo off
:checkPrivileges
net file 1>nul 2>nul
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)
echo.
echo.
echo.     **************************************************
echo.
echo.          Invoking UAC for Privilege Escalation...
echo.
echo.     **************************************************
echo.
echo.
setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
echo UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

echo Current path is %cd%
echo Changing directory to the path of the current script
cd %~dp0
echo Current path is %cd%

:gotPrivileges

rem --> Start

set "ThisDir=%~dp0"
set "ThisDir=%ThisDir:~0,-1%"
set "ScriptName=%~n0.bat"
pushd "%ThisDir%"
for %%* in (.) do (set "UpperDir=%%~nx*")
title Installing %UpperDir%

rem --> Detect processor Architecture
if %processor_architecture% == x86 (set "OSbit=32")
if %processor_architecture% == AMD64 (set "OSbit=64")
if not defined OSbit (
	echo "No detected processor architecture"
	ping.exe 127.0.0.1 -n 4 >nul 1>nul 2>nul
	exit
)

echo Context Menu - New file items and removing others...
reg.exe delete "HKEY_CLASSES_ROOT\.txt\ShellNew" /f>nul 1>nul 2>nul
rem ping.exe 127.0.0.1 -n 4>nul 1>nul 2>nul
reg.exe add "HKEY_CLASSES_ROOT\.txt" /ve /t REG_SZ /d "txtfile" /f>nul 1>nul 2>nul
reg.exe add "HKEY_CLASSES_ROOT\.txt\ShellNew" /v "NullFile" /t REG_SZ /d "" /f>nul 1>nul 2>nul

echo.
echo Define associations...

setlocal EnableDelayedExpansion
set x=1
:: get lines number in file
for /f %%C in ('find /V /C "" ^< "%ThisDir%\Data\Extensions.dat"') do (set "lines=%%C")
for /f "tokens=1,2,3,4,5 delims=;" %%i in (Data\Extensions.dat) do (call :process_types %%i %%j %%k %%l %%m)
goto thenextstep_from_types
:process_types
set "extension=%1"
set "extension=%extension:~1,-1%"
set "pathtoexe=%2"
set "pathtoexe=%pathtoexe:~1,-1%"
set "pathtoicon=%3"
set "pathtoicon=%pathtoicon:~1,-1%"
set "defaultdata=%4"
set "defaultdata=%defaultdata:~1,-1%"
set "defaultcommand=%5"
set "defaultcommand=%defaultcommand:~1,-1%"

if "%pathtoicon%" EQU "" set "pathtoicon=%pathtoexe%,0"

for %%f in ("%pathtoexe%") do (
	set "nameexe=%%~nxf"
	set "nameexe=!nameexe:~0,-4!"
)
set "str_first=%nameexe:~0,1%"
set "str_next=%nameexe:~1%"
for %%b in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
	set "str_first=!str_first:%%b=%%b!"
)
set "nameexe=%str_first%%str_next%"
for /f "tokens=1* delims=." %%a in ("%nameexe%") do (
	set "ftypename=%%afile"
)

((for /L %%P in (1,1,70) do pause>nul)&set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"
echo Extension: %extension% %TAB% set to %TAB% %nameexe% %TAB% (!x!/%lines% item)...

reg.exe delete "HKEY_CLASSES_ROOT\%extension%" /f>nul 1>nul 2>nul
reg.exe delete "HKEY_CLASSES_ROOT\SystemFileAssociations\%extension%" /f>nul 1>nul 2>nul
reg.exe delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%extension%" /f>nul 1>nul 2>nul

reg.exe add "HKEY_CLASSES_ROOT\%extension%" /ve /t REG_SZ /d "%ftypename%" /f>nul 1>nul 2>nul
if "%defaultdata%" NEQ "" (
	reg.exe add "HKEY_CLASSES_ROOT\%extension%\ShellNew" /v "Data" /t REG_SZ /d "%defaultdata%" /f
)>nul 1>nul 2>nul
reg.exe add "HKEY_CLASSES_ROOT\%ftypename%" /ve /t REG_SZ /d "%nameexe% File" /f>nul 1>nul 2>nul
if "%defaultdata%" NEQ "" (
	reg.exe add "HKEY_CLASSES_ROOT\%ftypename%" /t REG_SZ /v "FriendlyTypeName" /d "%nameexe%" /f>nul 1>nul 2>nul
)>nul 1>nul 2>nul
reg.exe add "HKEY_CLASSES_ROOT\%ftypename%\DefaultIcon" /ve /t REG_EXPAND_SZ /d "%pathtoicon%" /f>nul 1>nul 2>nul
reg.exe add "HKEY_CLASSES_ROOT\%ftypename%\Shell" /ve /t REG_SZ /d "" /f>nul 1>nul 2>nul
reg.exe add "HKEY_CLASSES_ROOT\%ftypename%\Shell\Open" /ve /t REG_SZ /d "" /f>nul 1>nul 2>nul
rem reg.exe add "HKEY_CLASSES_ROOT\%ftypename%\Shell\Open\Command" /ve /t REG_EXPAND_SZ /d "\"%pathtoexe%\" \"%%1\" %%*" /f>nul 1>nul 2>nul
if "%defaultcommand%" NEQ "" (
	reg.exe add "HKEY_CLASSES_ROOT\%ftypename%\Shell\Open\Command" /ve /t REG_EXPAND_SZ /d "%pathtoexe% %defaultcommand% %%1" /f>nul 1>nul 2>nul
) else (
	reg.exe add "HKEY_CLASSES_ROOT\%ftypename%\Shell\Open\Command" /ve /t REG_EXPAND_SZ /d "%pathtoexe% %%1" /f>nul 1>nul 2>nul
)
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%extension%\OpenWithList" /t REG_SZ /v "a" /d "%nameexe%.exe" /f>nul 1>nul 2>nul
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%extension%\OpenWithList" /t REG_SZ /v "MRUList" /d "a" /f>nul 1>nul 2>nul
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%extension%\OpenWithProgids" /t REG_NONE /v "%ftypename%" /d "" /f>nul 1>nul 2>nul
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%extension%\UserChoice" /t REG_SZ /v "ProgId" /d "%ftypename%" /f>nul 1>nul 2>nul
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%extension%\UserChoice" /t REG_SZ /v "Extension" /d "%extension%" /f>nul 1>nul 2>nul
"%ThisDir%\Data\Bin\SetUserFTA.exe" %extension% %ftypename%
rem cmd /c ftype %ftypename%="%pathtoexe%" "%%1" %%*>nul 1>nul 2>nul
if "%defaultcommand%" NEQ "" (
	cmd /c ftype %ftypename%="%pathtoexe%" %defaultcommand% "%%1">nul 1>nul 2>nul
) else (
	cmd /c ftype %ftypename%="%pathtoexe%" "%%1">nul 1>nul 2>nul
)
cmd /c assoc %extension%=%ftypename%>nul 1>nul 2>nul
set /a x=!x!+1
goto :EOF
:thenextstep_from_types
echo.

ping.exe 127.0.0.1 -n 4 >nul 1>nul 2>nul
exit