
@echo off

echo Close all 3dsMax, include background app
rem taskkill /f /im 3dsmax.exe
wmic process where name="3dsMax.exe" call terminate

echo Ready to delete the file
rem puase 5 seconds
timeout /t 1

rem Delete the file by force("C:\Users\m96v0102\AppData\Local\Temp\Local_temp.ms")
del /f %temp%\Local_temp.ms
echo Finish deleteing process.

pause