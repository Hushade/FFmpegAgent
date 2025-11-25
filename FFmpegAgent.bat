@echo off
setlocal enabledelayedexpansion

cd %~dp0

set inifile=%~dp0Config.ini

rem iniファイルを変数ファイルとして簡単に読み出し ｢;｣から始まるコメント行を除外
for /f "tokens=1,2 delims==" %%a in ('type %inifile% ^| findstr /v "^;"') do (set "%%a=%%b")

set /p "input=入力ファイルのパス> "
rem 引用符を除去
set input=%input:"=%

for %%A in ("%input%") do (
    set dirname=%%~dpA
    set filename=%%~nxA
)
for %%B in ("%filename%") do (
    set base=%%~nB
    set ext=%%~xB
)
set output=!dirname!!base!-Clip!ext!

set /p "start=動画の切り取りの開始時間(MM:SS)> "
set /p "end=動画の切り取りの終了時間(MM:SS)> "

ffmpeg -ss %start% -to %end% -i "%input%" -c:v %video_encoder% -pix_fmt %color_fmt% -color_range %color_range% -aspect:v %aspect% -r:v %framerate% %video_options% -c:a %audio_encoder% %audio_options% %option% "%output%"
endlocal
