@echo off
setlocal enabledelayedexpansion

rem 현재 디렉토리의 file.txt 파일 설정
set "filePath=found_files.txt"

rem 파일이 존재하는지 확인
if not exist "%filePath%" (
    echo 파일이 존재하지 않습니다: %filePath%
    exit /b 1
)

rem 파일을 한줄씩 읽기
for /f "tokens=*" %%a in (%filePath%) do (
    set "line=%%a"
    echo !line!
	
	rem 확장자 .byte로 변경
    set "changedLine=!line:.lua=.bytes!"
    REM echo !changedLine!
	if exist "!changedLine!" (
        del "!changedLine!"
        echo 파일이 삭제되었습니다: !changedLine!
    ) else (
        echo 파일을 찾을 수 없습니다: !changedLine!
    )
	
	set "changedLine=!changedLine!.meta"
	REM echo !changedLine!
	if exist "!changedLine!" (
        del "!changedLine!"
        echo 파일이 삭제되었습니다: !changedLine!
    ) else (
        echo 파일을 찾을 수 없습니다: !changedLine!
    )
)

del %filePath%

endlocal

exit /b 0