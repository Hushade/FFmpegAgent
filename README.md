# FFmpeg Agent

FFmpeg を呼び出して、事前に設定したパラメータに基づき動画ファイルを切り抜くシンプルなラッパースクリプトです。

> **初めての方は:** [**`ELI5.md`**](ELI5.md) をお読みください
> （FFmpeg のインストールから実行まで、ステップバイステップで説明しています）。

目的
- GUI や複雑なコマンドを使わずに、手早く動画の一部をトリミングしたいときに使います。

特徴
- インタラクティブに入力ファイル / 開始・終了時刻を受け取り、同じフォルダに `-Clip` を付けた出力ファイルを生成します。
- 動画・音声エンコーダや細かい ffmpeg オプションは [`Config.ini`](Config.ini)  で変更可能です。

前提条件
- Windows 環境（バッチファイル `FFmpegAgent.bat` を想定）。
- `ffmpeg` が PATH に登録されているか、コマンドプロンプトから `ffmpeg` を実行できること。
- ハードウェアエンコーダ（例: `h264_nvenc`）を使う場合は対応する GPU / ドライバが必要です。

## 使い方

1. `FFmpegAgent.bat` をダブルクリックするか、コマンドプロンプトで実行します。
2. プロンプトに従い入力ファイルのパスを入力します（長いパスでも引用符で囲めば OK）。
3. 切り取り開始時間と終了時間を入力します（下記の時間書式を参照）。
4. 同じフォルダに `元ファイル名-fromHH-fromMM-fromSS-toHH-toMM-toSS` のファイルが出力されます。

実行例（コマンドプロンプト）:

```text
FFmpegAgent.bat
```

バッチファイル内部で実行されるコマンドの例（[`Config.ini`](Config.ini)  の既定値を使用した場合）:

```text
ffmpeg -ss 00:01:00 -to 00:02:00 -i "input.mp4" -c:v h264_nvenc -pix_fmt yuv420p -color_range tv -aspect:v 16:9 -r:v 60 -cq 23 -spatial-aq 1 -b_ref_mode 1 -multipass 1 -c:a aac -b:a 128k -ar 48k -hide_banner -movflags +faststart "input-Clip.mp4"
```

## 時刻フォーマット
- `hh:mm:ss[.xxx]` または `mm:ss` など、ffmpeg の Time Duration 構文に準拠します。
- 例: `00:01:23`, `1:23`, `00:00:10.500`

## [`Config.ini`](Config.ini)  の説明

以下は既存の [`Config.ini`](Config.ini)  にあるキーと用途の簡単な説明です（デフォルト値は実ファイルを参照）。

- `video_encoder` : 動画エンコーダ（例: `h264_nvenc`, `libx264`）。使用可能なエンコーダは `ffmpeg -encoders` または `ffmpeg -h encoder=<name>` で確認してください。
- `audio_encoder` : 音声エンコーダ（例: `aac`, `libmp3lame`）。
- `video_options` : 動画エンコーダ向けの追加オプション（例: `-cq 23 -spatial-aq 1 -multipass 1`）。
- `audio_options` : 音声エンコーダ向けのオプション（例: `-b:a 128k -ar 48k`）。
- `framerate` : 出力フレームレート（例: `60`）。
- `aspect` : アスペクト比（例: `16:9`）。内部では `-aspect:v` に渡されます。
- `color_fmt` : 出力のピクセルフォーマット（例: `yuv420p`）。
- `color_range` : カラー範囲（例: `tv` か `pc`）。
- `option` : 汎用オプション（例: `-hide_banner -movflags +faststart`）。

設定を変更したら `FFmpegAgent.bat` を再実行して新しい設定が使用されることを確認してください。

## 使い方のヒント / 注意点
- デフォルトでは高速シーク（キーフレーム単位）になります。非常に正確なフレームで切る必要がある場合は `-ss` と `-to` を `-i` の後に指定する方法を検討してください（その場合は動画ファイルの読み込み処理が遅くなることがあります）。
- 出力ファイル名は元のファイルと同じディレクトリに `-fromHH-fromMM-fromSS-toHH-toMM-toSS` を付けた名前になります。上書きに注意してください。
- デフォルトではエンコーダーは NVENC H.264 (`h264_nvenc`) を利用しています。GPU との互換性を確認してください。ソフトウェアエンコード（例: `libx264`）に切り替えれば問題が解消する場合があります。

## トラブルシュート
- ffmpeg が見つからない: コマンドプロンプトで `ffmpeg -version` を実行して確認してください。見つからない場合は https://ffmpeg.org/ を参照し、実行ファイルを取得、PATH に追加してください。
- 指定したエンコーダが無効: `ffmpeg -encoders` で一覧を確認し、[`Config.ini`](Config.ini)  の `video_encoder` を変更してください。
- 出力ファイルが作成されない / アクセス拒否: 出力先のフォルダに書き込み権限があるか確認してください。ファイルが既に存在する場合は削除または別名にしてください。
