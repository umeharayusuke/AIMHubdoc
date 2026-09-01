# WindowsでAIMHub文書のPDFを作成する手順

このマニュアルでは、GitHub上のAIMHubdocリポジトリをフォーク・クローンし、Windowsへ軽量構成のTeX Liveを導入して、`AIMHub_documentation.pdf` を作成するまでの手順を説明します。

## 1. AIMHubdocリポジトリをフォークする

GitHubで元のリポジトリを開きます。

```text
https://github.com/KUAtmos/AIMHubdoc
```

画面右上の **Fork** を選び、自分のGitHubアカウントに次のようなフォークを作成します。

```text
<GitHubユーザー名>/AIMHubdoc
```


## 2. 自分のフォークをWindowsへクローンする

PowerShellを開き、次を実行します。`<GitHubユーザー名>` は自分のGitHubユーザー名に置き換えます。

```powershell
git clone https://github.com/<GitHubユーザー名>/AIMHubdoc.git C:\AIMHubdoc
cd C:\AIMHubdoc
```

- `git clone`：GitHub上のフォークをWindowsへコピーします。
- `C:\AIMHubdoc`：コピー先の例です。別の場所を使用する場合は、後述する `cd` のパスも読み替えます。
- `cd`：PowerShellの現在位置をAIMHubdocフォルダへ移動します。


## 3. TeX Liveインストーラーをダウンロードする

次のTeX Live公式ページをブラウザで開きます。

```text
https://tug.org/texlive/acquire-netinstall.html
```

Windows向けの `install-tl.zip` をクリックしてダウンロードし、ZIPファイルを任意のフォルダへ展開します。

## 4. TeX Liveを小規模構成で起動する

展開先にある `install-tl-windows.bat` と同じフォルダでPowerShellを開き、次を実行します。

```powershell
.\install-tl-windows.bat `
  --no-gui `
  --scheme=scheme-small `
  --no-doc-install `
  --no-src-install
```

PowerShellのバッククォート `` ` `` は、コマンドが次の行へ続くことを表します。バッククォートの後ろに空白を入れないでください。コピー時の改行が心配な場合は、次の1行でも同じ意味になります。

```powershell
.\install-tl-windows.bat --no-gui --scheme=scheme-small --no-doc-install --no-src-install
```

各オプションの意味は次のとおりです。

| オプション | 意味 |
|---|---|
| `--no-gui` | GUIではなく、PowerShell内のテキスト画面で設定します。 |
| `--scheme=scheme-small` | TeX Live全部入りではなく、小規模構成を選択します。 |
| `--no-doc-install` | パッケージの説明書をインストールしません。 |
| `--no-src-install` | パッケージのソースコードをインストールしません。 |

TeX Liveの標準構成は `scheme-full` ですが、この手順ではダウンロード時間と使用容量を抑えるため `scheme-small` を使用し、AIMHub文書に必要なパッケージだけを後から追加します。

## 5. 設定を確認してインストールを開始する

設定画面の下部に次のように表示されます。

```text
Actions:
 <I> start installation to hard disk
 <P> save installation profile to 'texlive.profile' and exit
 <Q> quit

Enter command:
```

`I` を入力してEnterを押します。

```text
I
```

- `I`：現在の設定でインストールを開始します。
- `P`：現在の設定をプロファイルへ保存して終了します。
- `Q`：インストールせず終了します。

開始前に、画面上で少なくとも次を確認します。

```text
set installation scheme: scheme-small
install macro/font doc tree: off
install macro/font source tree: off
adjust search path: on
```

必要容量と空き容量も表示されるため、十分な空きがあることを確認します。容量の数値はTeX Liveの更新状況によって変わります。

## 6. TeX Liveのインストールを完了する

インストーラーに完了メッセージが表示されるまで待ちます。完了後はインストーラーを閉じ、Windowsが新しい環境設定を読み込めるようにPowerShellも一度閉じて開き直します。

## 7. PowerShellからTeX Liveを使えるか確認する

次を実行します。

```powershell
Get-Command tlmgr
```

`tlmgr` は、TeX Liveのパッケージを管理するコマンドです。`C:\texlive\2026\bin\windows\tlmgr.bat` のようなパスが表示された場合は、次の節へ進みます。

「`tlmgr` は認識されません」と表示された場合は、TeX Liveの実行ファイルがあるフォルダを、現在のPowerShellの `PATH` に追加します。

```powershell
$texLiveBin = 'C:\texlive\2026\bin\windows'
$env:Path = "$texLiveBin;$env:Path"
```

- `$texLiveBin`：TeX Liveのコマンドが入っているフォルダを変数に保存します。
- `$env:Path = ...`：現在開いているPowerShellから、そのフォルダ内のコマンドを呼び出せるようにします。

もう一度確認します。

```powershell
Get-Command tlmgr
```

今後PowerShellを開くたびに設定しなくてもよいように、次のコマンドを一度だけ実行すると、ユーザー環境変数へ永続的に登録できます。

```powershell
$texLiveBin = 'C:\texlive\2026\bin\windows'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $texLiveBin) {
    [Environment]::SetEnvironmentVariable(
        'Path',
        "$texLiveBin;$userPath",
        'User'
    )
}
```

実行後はPowerShellを閉じて開き直します。

## 8. AIMHub文書に必要なパッケージを追加する

`scheme-small` には、`AIMHub_documentation.tex` が使用するすべてのパッケージは含まれていません。次を実行して必要なものを追加します。

```powershell
tlmgr install graphics tools hyperref multirow tipa amsmath amsfonts wasy wasysym isomath mathtools txfonts was tensor ulem l3packages soul seqsplit ltablex autobreak pdflscape nature psnfss
```

このコマンドは、指定したTeX Liveパッケージとその依存パッケージを `C:\texlive\2026` 以下にインストールします。`tlmgr install` はどのフォルダから実行しても構いません。

主なパッケージの意味は次のとおりです。

| パッケージ | 主な役割 |
|---|---|
| `graphics` | 画像、色、拡大縮小 |
| `tools` | 表などのLaTeX標準拡張 |
| `hyperref` | PDF内リンクとブックマーク |
| `multirow`、`ltablex` | 複雑な表、複数ページにまたがる表 |
| `amsmath`、`amsfonts`、`mathtools` | 数式と数学フォント |
| `tipa` | IPA発音記号 |
| `wasy`、`wasysym` | 追加記号フォントとその命令 |
| `was` | `upgreek.sty`（立体ギリシャ文字） |
| `txfonts`、`psnfss` | 本文・数式用フォント |
| `isomath`、`tensor` | 数式表記とテンソル表記 |
| `ulem`、`soul` | 下線などの文字装飾 |
| `l3packages` | `xfrac` などのLaTeX3系機能 |
| `seqsplit` | 長い文字列の途中改行 |
| `autobreak` | 長い数式の自動改行 |
| `pdflscape` | PDFの横向きページ |
| `nature` | 参考文献形式 `naturemag.bst` |

すでに入っているパッケージを再度指定しても、通常は `tlmgr` がインストール済みと判断してスキップします。

以前の手順で次もインストール済みの場合、そのままで問題ありません。

```text
collection-langjapanese
ptex-fontmaps
```

これらはpLaTeX用ですが、最終的に成功した通常の `latex` を使う手順では必須ではありません。

## 9. コマンドと重要ファイルを確認する

次を実行します。

```powershell
Get-Command latex,bibtex,dvipdfmx
```

各コマンドの役割は次のとおりです。

- `latex`：TeX原稿からDVIファイルを作ります。
- `bibtex`：`.bib` ファイルから参考文献一覧を作ります。
- `dvipdfmx`：DVIファイルをPDFへ変換します。

不足しやすかったファイルも確認します。

```powershell
kpsewhich wasysym.sty
kpsewhich upgreek.sty
kpsewhich naturemag.bst
```

`kpsewhich` は、TeX Live内から指定したファイルを探すコマンドです。それぞれファイルパスが表示されれば準備完了です。

## 10. AIMHubdocフォルダへ移動する

```powershell
cd C:\AIMHubdoc
```

TeX原稿は `EndNoteLibrary.bib` と `fig` フォルダ内の画像を相対パスで参照しています。そのため、以下のコンパイル処理は必ず `C:\AIMHubdoc` で実行します。

## 11. PDFを作成する

以下を上から順番に実行します。途中のコマンドがエラーで終了した場合は、後続コマンドを実行せず、そのエラーを先に解決します。

### 11.1 1回目のLaTeX処理

```powershell
latex -halt-on-error AIMHub_documentation.tex
```

この処理では、TeX原稿を読み込み、次のファイルなどを作成します。

- `AIMHub_documentation.dvi`：PDFへ変換する前の組版結果
- `AIMHub_documentation.aux`：引用や相互参照の中間情報

`-halt-on-error` は、エラーが発生した場合にその場で処理を止める指定です。

成功すると、最後に次のようなメッセージが表示されます。

```text
Output written on AIMHub_documentation.dvi
```

### 11.2 参考文献の作成

```powershell
bibtex AIMHub_documentation
```

この処理では、次のことを行います。

1. `AIMHub_documentation.aux` から引用された文献を確認します。
2. `EndNoteLibrary.bib` から該当文献を読み込みます。
3. `naturemag.bst` の書式を適用します。
4. `AIMHub_documentation.bbl` を作成します。

引数には拡張子を付けず、基本ファイル名だけを指定します。

### 11.3 引用・相互参照を確定する

```powershell
latex -halt-on-error AIMHub_documentation.tex
latex -halt-on-error AIMHub_documentation.tex
```

1回目の再実行で参考文献を本文へ取り込み、引用や参照情報を更新します。2回目の再実行で、ページ番号、図表番号、引用番号、目次、PDFブックマークなどを確定します。

### 11.4 DVIをPDFへ変換する

```powershell
dvipdfmx AIMHub_documentation.dvi
```

完成したDVIファイルをPDFへ変換します。出力先は次のとおりです。

```text
C:\AIMHubdoc\AIMHub_documentation.pdf
```

同名のPDFがすでに存在する場合は、新しいPDFで上書きされます。

## 12. PDFが更新されたことを確認する

```powershell
Get-Item .\AIMHub_documentation.pdf |
    Select-Object FullName, LastWriteTime, Length
```

- `FullName`：PDFの出力場所
- `LastWriteTime`：PDFが最後に更新された日時
- `Length`：PDFのファイルサイズ

`LastWriteTime` が今回の実行時刻付近になっていれば、更新に成功しています。

Git上の変更ファイルを確認する場合は、次を実行します。

```powershell
git status --short
```

通常は、編集した `.tex` と作り直した `.pdf` が変更ファイルとして表示されます。`.aux`、`.bbl`、`.dvi`、`.log` などの中間ファイルは、このリポジトリの `.gitignore` で除外されています。

## 13. 注意事項とエラーへの対応

### この文書では `platex` ではなく `latex` を使用する

リポジトリにある古い `tex.sh` は `platex` と `pbibtex` を使用します。しかし、今回使用したTeX Live 2026環境では、pLaTeXのフォント処理中に次のエラーが発生しました。

```text
! Missing \endcsname inserted.
```

`AIMHub_documentation.tex` は実質的に英語文書であるため、通常の `latex` と `bibtex` を使用することで正常にPDFを作成できました。この成功手順では、次のpLaTeX固有の指定は使用しません。

- `platex`
- `pbibtex`
- `-kanji=utf8`
- `ptex-ipa.map`

### BibTeXが `.aux` ファイルを開けない場合

次のようなエラーは、1回目の `latex` が失敗し、`.aux` ファイルが作成されなかったことを意味します。

```text
I couldn't open file name `AIMHub_documentation.aux'
```

この場合は `bibtex` を繰り返さず、最初の `latex` コマンドに戻って、そのエラーを解決します。



### `.sty` ファイルがないと言われた場合

例えば `example.sty` がないというエラーが出た場合は、次のコマンドで収録パッケージを検索します。

```powershell
tlmgr search --global --file "/example.sty"
```

検索結果に表示されたパッケージ名をインストールします。

```powershell
tlmgr install package-name
```

## 14. 2回目以降の通常ビルド

初回設定がすべて完了した後は、TeX原稿を編集するたびに次の5コマンドだけを実行します。

```powershell
cd C:\AIMHubdoc
latex -halt-on-error AIMHub_documentation.tex
bibtex AIMHub_documentation
latex -halt-on-error AIMHub_documentation.tex
latex -halt-on-error AIMHub_documentation.tex
dvipdfmx AIMHub_documentation.dvi
```

## 15. PDF作成処理を `tex.bat` にまとめる

前節の5コマンドは、Windowsのバッチファイルへまとめることができます。この設定は一度だけ行い、次回からは `tex.bat` を実行するだけでPDFを更新します。

### 15.1 参考文献のUnicode文字をLaTeX形式へ直す

元の `EndNoteLibrary.bib` には、通常のLaTeXで直接処理できないUnicodeのマイナス記号 `−`（U+2212）が含まれています。`EndNoteLibrary.bib` を開き、次の文献タイトルを修正します。

修正前：

```bibtex
title = {An emission pathway for stabilization at 6 Wm−2 radiative forcing},
```

修正後：

```bibtex
title = {An emission pathway for stabilization at 6~Wm$^{-2}$ radiative forcing},
```

これにより、参考文献を読み込む際の次のエラーを防ぎます。

```text
LaTeX Error: Unicode character − (U+2212) not set up for use with LaTeX.
```

### 15.2 `tex.bat` を書き換える

Positronで `C:\AIMHubdoc\tex.bat` を開き、既存の内容を次の内容へ置き換えて保存します。

```bat
@echo off
setlocal

rem Always build from the directory containing this batch file.
cd /d "%~dp0"

rem Use the standard TeX Live 2026 location if PATH is not yet available.
where latex >nul 2>&1
if errorlevel 1 (
    if exist "C:\texlive\2026\bin\windows\latex.exe" (
        set "PATH=C:\texlive\2026\bin\windows;%PATH%"
    )
)

rem Check all commands before starting the build.
for %%C in (latex bibtex dvipdfmx) do (
    where %%C >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %%C was not found.
        echo Check the TeX Live installation and PATH setting.
        exit /b 1
    )
)

rem Remove stale intermediate files before the first LaTeX pass.
echo [0/5] Removing old intermediate files...
for %%E in (aux bbl blg dvi lof log lot out toc) do (
    if exist "AIMHub_documentation.%%E" (
        del /q "AIMHub_documentation.%%E"
        if exist "AIMHub_documentation.%%E" (
            echo [ERROR] Could not remove AIMHub_documentation.%%E.
            exit /b 1
        )
    )
)

echo [1/5] Running LaTeX...
latex -interaction=nonstopmode -halt-on-error AIMHub_documentation.tex
if errorlevel 1 goto :build_error

echo [2/5] Running BibTeX...
bibtex AIMHub_documentation
if errorlevel 1 goto :build_error

echo [3/5] Resolving bibliography and references...
latex -interaction=nonstopmode -halt-on-error AIMHub_documentation.tex
if errorlevel 1 goto :build_error

echo [4/5] Finalizing cross-references...
latex -interaction=nonstopmode -halt-on-error AIMHub_documentation.tex
if errorlevel 1 goto :build_error

echo [5/5] Creating PDF...
dvipdfmx AIMHub_documentation.dvi
if errorlevel 1 goto :build_error

echo.
echo [SUCCESS] AIMHub_documentation.pdf was created successfully.
exit /b 0

:build_error
echo.
echo [ERROR] The PDF build failed. Review the error above.
exit /b 1
```

このバッチは次の処理を行います。

1. `tex.bat` が置かれているフォルダへ移動します。
2. TeX Liveのコマンドが利用可能か確認します。
3. 古い `.aux`、`.bbl`、`.dvi` などの中間ファイルを削除します。
4. `latex → bibtex → latex → latex → dvipdfmx` の順に処理します。
5. 途中でエラーが起きた場合は、その場で停止します。

古い中間ファイルを削除するのは、修正前の `.bbl` などが残り、新しい原稿を処理する前にエラーになることを防ぐためです。既存のPDFは開始時に削除しないため、失敗した場合でも直前のPDFは残ります。

### 15.3 バッチを初めて実行する

Positronのターミナルで次を実行します。

```powershell
cd C:\AIMHubdoc
.\tex.bat
```

すべて成功すると最後に次のように表示されます。

```text
[SUCCESS] AIMHub_documentation.pdf was created successfully.
```

最初のLaTeX処理中に表示される `Citation ... undefined` は、参考文献がまだ確定していない段階の警告です。後続処理で解消されるため、最後に `[SUCCESS]` が表示されればビルド成功です。`Overfull \hbox` と `Underfull \hbox` もレイアウトに関する警告であり、それだけでは処理は停止しません。

### 15.4 次回以降のPDF更新方法

次回からは次の手順だけで更新できます。

1. `AIMHub_documentation.tex` を編集して保存します。
2. Positronのターミナルで次を実行します。

```powershell
cd C:\AIMHubdoc
.\tex.bat
```

3. `[SUCCESS]` が表示されたことを確認します。
4. PDFの更新日時を確認します。

```powershell
Get-Item .\AIMHub_documentation.pdf |
    Select-Object FullName, LastWriteTime, Length
```

## 16. MarkdownマニュアルからHTMLを更新する

`WINDOWS_TEX_BUILD_MANUAL.md` を編集した後は、Quartoを使って可読性の高いHTMLへ変換できます。以下では、CSSやJavaScriptをHTML内へ埋め込み、単独で開けるHTMLを作成します。

### 16.1 Markdownを編集する

Positronで次のファイルを編集して保存します。

```text
C:\AIMHubdoc\WINDOWS_TEX_BUILD_MANUAL.md
```

ファイルを生成せずに表示だけ確認する場合は、Markdownを開いた状態で `Ctrl + Shift + V` を押します。

### 16.2 Quartoの場所を設定する

Positronのターミナルで次を実行します。

```powershell
$quartoExe = 'C:\Program Files\RStudio\resources\app\bin\quarto\bin\quarto.exe'
Test-Path -LiteralPath $quartoExe
```

`True` が表示されれば利用できます。PowerShellを閉じると `$quartoExe` の設定は消えるため、新しくターミナルを開いた場合はもう一度実行します。

### 16.3 単独HTMLを生成する

```powershell
cd C:\AIMHubdoc

if (Test-Path -LiteralPath '.\WINDOWS_TEX_BUILD_MANUAL_files') {
    Remove-Item -LiteralPath '.\WINDOWS_TEX_BUILD_MANUAL_files' -Recurse -Force
}

& $quartoExe render .\WINDOWS_TEX_BUILD_MANUAL.md `
    --to html `
    -M 'embed-resources:true' `
    -M 'toc:true' `
    -M 'lang:ja'
```

- `--to html`：MarkdownをHTMLへ変換します。
- `embed-resources:true`：CSSやJavaScriptをHTML内へ埋め込みます。
- `toc:true`：HTMLに目次を付けます。
- `lang:ja`：HTMLの文書言語を日本語として設定します。
- 既存の `_files` フォルダは、以前の通常レンダリングで作られた補助ファイルなので、単独HTMLを作る前に削除します。

出力ファイルは次のとおりです。

```text
C:\AIMHubdoc\WINDOWS_TEX_BUILD_MANUAL.html
```

### 16.4 HTMLを確認する

```powershell
Start-Process .\WINDOWS_TEX_BUILD_MANUAL.html
```

既定のWebブラウザでHTMLが開きます。Markdownを修正した場合は、保存後に再度 `quarto render` を実行するとHTMLが上書き更新されます。

### 16.5 Gitへ追加する

Markdown、HTML、バッチファイルなど、今回更新したファイルだけを明示してステージします。

```powershell
git add -- .\WINDOWS_TEX_BUILD_MANUAL.md .\WINDOWS_TEX_BUILD_MANUAL.html
git status
git diff --cached --stat
```

PDF、参考文献、バッチファイルも同じコミットへ含める場合は、次のように指定します。

```powershell
git add -- .\AIMHub_documentation.pdf .\EndNoteLibrary.bib .\tex.bat .\WINDOWS_TEX_BUILD_MANUAL.md .\WINDOWS_TEX_BUILD_MANUAL.html
```
