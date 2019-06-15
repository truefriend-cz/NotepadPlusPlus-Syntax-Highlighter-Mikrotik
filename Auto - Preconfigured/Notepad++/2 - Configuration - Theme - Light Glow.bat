@echo off
set "ThisDir=%~dp0"
set "ThisDir=%ThisDir:~0,-1%"
set "ScriptName=%~n0.bat"
pushd "%ThisDir%"
for %%* in (.) do (set "UpperDir=%%~nx*")
title Settings %UpperDir%

echo Setting: %UpperDir%

set "itemline=40"
set "item=        " 

del "%ThisDir%\Data\Settings-Light-Glow\Notepad++\config.xml" >nul 1>nul 2>nul
setLocal DisableDelayedExpansion
set "n=0"
for /f "usebackq tokens=* delims=" %%G in (`findstr /n "^" "%ThisDir%\Data\Template\config.xml"`) do (
    set "str=%%G"
	set /a n+=1
    setLocal EnableDelayedExpansion
	if "!n!"=="!itemline!" (echo !item!>> "%ThisDir%\Data\Settings-Light-Glow\Notepad++\config.xml") else echo !str:*:=!>> "%ThisDir%\Data\Settings-Light-Glow\Notepad++\config.xml"
    endlocal
)

xcopy.exe "%ThisDir%\Data\Settings-Light-Glow" "%AppData%" /S /H /E /K /F /C /Y >nul 1>nul 2>nul

del "%ThisDir%\Data\Settings-Light-Glow\Notepad++\config.xml" >nul 1>nul 2>nul

exit
