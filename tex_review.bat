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

set "JOB=AIMHub_documentation_review"
set "SOURCE=AIMHub_documentation.tex"
set "OUTPUT_DIR=output\pdf"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if errorlevel 1 (
    echo [ERROR] Could not create %OUTPUT_DIR%.
    exit /b 1
)

rem Remove only the review build's stale intermediate files.
echo [0/5] Removing old review intermediate files...
for %%E in (aux bbl blg dvi lof log lot out toc) do (
    if exist "%JOB%.%%E" (
        del /q "%JOB%.%%E"
        if exist "%JOB%.%%E" (
            echo [ERROR] Could not remove %JOB%.%%E.
            exit /b 1
        )
    )
)

echo [1/5] Running LaTeX in change-review mode...
latex -interaction=nonstopmode -halt-on-error -jobname=%JOB% "\def\AIMHubReview{1}\input{%SOURCE%}"
if errorlevel 1 goto :build_error

echo [2/5] Running BibTeX...
bibtex %JOB%
if errorlevel 1 goto :build_error

echo [3/5] Resolving bibliography and references...
latex -interaction=nonstopmode -halt-on-error -jobname=%JOB% "\def\AIMHubReview{1}\input{%SOURCE%}"
if errorlevel 1 goto :build_error

echo [4/5] Finalizing cross-references...
latex -interaction=nonstopmode -halt-on-error -jobname=%JOB% "\def\AIMHubReview{1}\input{%SOURCE%}"
if errorlevel 1 goto :build_error

echo [5/5] Creating review PDF...
dvipdfmx -o "%OUTPUT_DIR%\%JOB%.pdf" "%JOB%.dvi"
if errorlevel 1 goto :build_error

echo.
echo [SUCCESS] %OUTPUT_DIR%\%JOB%.pdf was created successfully.
echo Changed and added passages are shown in red.
exit /b 0

:build_error
echo.
echo [ERROR] The review PDF build failed. Review the error above.
exit /b 1
