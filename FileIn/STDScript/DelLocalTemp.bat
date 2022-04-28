
@echo off

echo Close 3dsMax
taskkill /f /im 3dsmax.exe

echo Ready to delete the file
rem puase 5 seconds
timeout /t 5

rem Delete the file by force("C:\Users\m96v0102\AppData\Local\Temp\Local_temp.ms")
del /f %temp%\Local_temp.ms
echo Finish deleteing process.

pause