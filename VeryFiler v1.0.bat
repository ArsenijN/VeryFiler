@echo off
>NUL chcp 65001

echo Creating folders...

2>NUL mkdir "1. Files for verify"
2>NUL mkdir "2. Verified logs"
2>NUL mkdir "2. Verified logs\Good"

set files=0
set count=0

echo The program works recursively. All files, including subfolders, will be processed.

rem Count the total number of files recursively
for /r "1. Files for verify" %%a in (*.*) do (
    set /a files+=1
)

rem Store the total number of files
set total_files=%files%

setlocal enableextensions enabledelayedexpansion

rem Process each file
for /r "1. Files for verify" %%a in (*.*) do (
    rem Strip the path before "1. Files for verify"
    set "filepath=%%a"
    set "logname=%%a"

    rem Remove everything before "1. Files for verify"
    set "logname=!logname:*1. Files for verify\=#!"

    rem Replace backslashes with #
    set "logname=!logname:\=#!"

    rem Run ffmpeg to check the file and create a log file with the modified path name
    ffmpeg.exe -v error -i "%%a" -f null - >"2. Verified logs\error_!logname!_.log" 2>&1 

    rem Update the count of processed files
    set /a count+=1

    rem Calculate the percentage
    set /a percent=count*100
    set /a percent=percent/total_files

    rem Display the progress in one line, overwrite each time
    <nul set /p="Processing: !percent!%%, !count!/%total_files% files are processed... "
)

endlocal

echo.
echo All files processed!

rem Move good log files (those with zero size) to the "Good" folder
for /r "2. Verified logs" %%a in (*.*) do if %%~za==0 (
    move "%%a" "2. Verified logs\Good\"
    echo File %%a is good!
)

rem Notify for files that may contain errors
for /r "2. Verified logs" %%a in (*.*) do if not %%~za==0 (
    echo File %%a may contain errors!
)

echo Total files processed: %count%
