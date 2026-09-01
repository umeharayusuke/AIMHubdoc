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
