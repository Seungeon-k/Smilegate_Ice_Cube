@echo off

REM platform 리스트 : android, ios, win64
REM set platform=%1

REM 플랫폼에 따른 컴파일러 설정
REM set luacCmd=
REM if "%platform%" == "win64" ( 
    REM set luacCmd="..\..\shell\LuacBin\luac.exe"
REM ) else if "%platform%" == "android" (
    REM set luacCmd="..\..\shell\LuacBin\luac_a.exe"
REM ) else if "%platform%" == "ios" (
    REM set luacCmd="..\..\shell\LuacBin\luac_i.exe"
REM ) else (
    REM echo "Error: Unsupported platform %platform%"
    REM exit /b 1
REM )

set luacCmd=".\Packages\com.unity.china.luaframework\ByteCode\luac.exe"

REM 사용하려는 luacCmd 파일이 존재하는지 확인
if not exist %luacCmd% (
    echo "Error: Compiler %luacCmd% not found."
    exit /b 1
)

rem found_files.txt 초기화 (완전히 비우기)
.>found_files.txt 2>NUL

dir /s/b "Assets\*.lua" >> found_files.txt

shift

for /F "usebackq delims=" %%a in ("found_files.txt") do (
   @echo "%%~fa"
   "%luacCmd%" -o "%%~dpna.lua" "%%~fa"
)


exit /b 0
