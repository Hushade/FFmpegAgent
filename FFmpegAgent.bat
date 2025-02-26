@echo off
setlocal enableDelayedExpansion
cd %~dp0

:LOOP

set inifile=%~dp0Config.ini

rem iniファイルを変数ファイルとして簡単に読み出し ｢;｣から始まるコメント行を除外
for /f "tokens=1,2 delims==" %%a in ('type %inifile% ^| findstr /v "^;"') do (set "%%a=%%b")

set /p "input=入力ファイルのパス> "
set /p "start=元動画の切り取りの開始時間> "
set /p "end=切り取られた動画の終了時間> "

for %%A in ("%input%") do (
    set "input_name=%%~nA"
    set "input_dir=%%~dpA"
)
rem 変数に代入（元のディレクトリを保持）
set "output=%input_dir%%input_name%-Clip.mp4"

ffmpeg -ss %start% -to %end% -i %input% -c:v %video_encoder% -pix_fmt %color_fmt% -color_range %color_range% -aspect:v %aspect% -r:v %framerate% %video_quality% -preset %preset% -c:a %audio_encoder% %audio_quality% %option% %output%

pause
GOTO LOOP

endlocal