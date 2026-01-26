@echo off
setlocal enabledelayedexpansion

rem 作業ディレクトリをスクリプトの場所に移動
cd /d "%~dp0"

rem 設定ファイル
set "inifile=%~dp0Config.ini"
if not exist "%inifile%" (
    echo Config.ini が見つかりません: "%inifile%"
    pause
    exit /b 1
)

rem ffmpeg が PATH にあるか確認
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo ffmpeg が見つかりません。PATH を確認してください。
    pause
    exit /b 1
)

rem --- Config.ini 読み込み (行頭が ; のコメントを除外) ---
for /f "tokens=1,2 delims==" %%a in ('type %inifile% ^| findstr /v "^;"') do (
    set "%%a=%%b"
)

rem --- 入力ファイルを取得: コマンドライン引数があればそれを使う ---
if "%~1"=="" (
    set /p "input=入力ファイルのパス> "
) else (
    set "input=%~1"
)

rem 引用符を除去してトリム
set "input=%input:"=%"
for %%A in ("%input%") do (
    set "dirname=%%~dpA"
    set "filename=%%~nxA"
)
for %%B in ("%filename%") do (
    set "base=%%~nB"
    set "ext=%%~xB"
)

if not exist "%input%" (
    echo 指定されたファイルが見つかりません: "%input%"
    pause
    exit /b 1
)


rem --- 切り取り時間の入力 ---
set /p "start=動画の切り取りの開始時間(MM:SS)> "
set /p "end=動画の切り取りの終了時間(MM:SS)> "

rem （簡易チェック ? 空でないこと）
if "%start%"=="" (
    echo 開始時間が指定されていません。
    pause
    exit /b 1
)
if "%end%"=="" (
    echo 終了時間が指定されていません。
    pause
    exit /b 1
)

rem 出力名
set "start_clean=%start::=-%"
set "end_clean=%end::=-%"
set "output=%dirname%%base%-%start_clean%-%end_clean%%ext%"

rem --- 実行前にコマンドを構築して表示（デバッグ用） ---
set "FFMPEG_CMD=ffmpeg -ss !start! -to !end! -i "!input!" -c:v !video_encoder! -pix_fmt !color_fmt! -color_range !color_range! -aspect:v !aspect! -r:v !framerate! !video_options! -c:a !audio_encoder! !audio_options! !option! "!output!""

echo 実行コマンド: %FFMPEG_CMD%
echo.

rem 実行
%FFMPEG_CMD%

echo 

endlocal
