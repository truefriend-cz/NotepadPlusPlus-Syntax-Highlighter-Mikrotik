@echo off

rem --> Check for permissions
>nul 1>nul 2>nul "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

rem --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges...
ping.exe 127.0.0.1 -n 2 >nul 1>nul 2>nul
goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"="
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B

:gotAdmin
pushd "%CD%"
CD /D "%~dp0"

rem --> Start

setlocal EnableDelayedExpansion

ftype Notepad++="C:\Program Files\Notepad++\notepad++.exe" "%%1">nul 1>nul 2>nul

set ext=^
	lua^
	rsc

set /a counter=1
for %%a in (%ext%) do (
	set "ext[!counter!]=%%~a"

	echo Associating .%%a
	reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%a" /f>nul 1>nul 2>nul
	reg delete "HKEY_CLASSES_ROOT\.%%a" /f>nul 1>nul 2>nul
	assoc .%%a=Notepad++>nul 1>nul 2>nul

	set /a counter=counter+1
)

exit
