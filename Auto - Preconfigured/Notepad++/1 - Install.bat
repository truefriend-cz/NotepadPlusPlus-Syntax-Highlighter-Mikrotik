@echo off
set "ThisDir=%~dp0"
set "ThisDir=%ThisDir:~0,-1%"
set "ScriptName=%~n0.bat"
for %%* in (.) do (set "UpperDir=%%~nx*")
title Installing %UpperDir%

if %processor_architecture% == x86 (set "source=https://notepad-plus-plus.org/repository/7.x/7.7/npp.7.7.Installer.exe" && set "exist=yes")
if %processor_architecture% == AMD64 (set "source=https://notepad-plus-plus.org/repository/7.x/7.7/npp.7.7.Installer.x64.exe" && set "exist=yes")
if not defined exist (
	echo Error: No detected processor architecture. Software not installed.
	pause
	exit
)

for %%f in ("%source%") do (set "filename=%%~nxf")

if exist "%ThisDir%\Data\Bin\%filename%" (
	call :installing
) else (
	echo Downloading: %UpperDir% ^(%filename%^)
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ThisDir%\Data\Downloader.ps1" "%source%" "%ThisDir%\Data\Bin\%filename%"
	cls
	if exist "%ThisDir%\Data\Bin\%filename%" (
		call :installing
	) else (
		echo Error: No detected downloaded file. Software not installed.
		pause
	)
)

exit

:installing
echo Installing: %UpperDir% (%filename%)
start "" /wait "%ThisDir%\Data\Bin\%filename%" /S
goto :eof
