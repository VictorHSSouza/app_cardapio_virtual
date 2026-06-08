@echo off
setlocal

REM --- Caminho completo do Flutter ---
set FLUTTER="C:\Users\vhsouza.plansul\flutter\bin\flutter.bat"

echo ============================================
echo  Deploy para GitHub Pages
echo ============================================
echo.

REM --- Salva a branch atual para voltar depois ---
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set BRANCH_ATUAL=%%i
echo Branch atual: %BRANCH_ATUAL%
echo.

REM --- Verifica se há alterações não commitadas (apenas arquivos rastreados) ---
git diff --quiet HEAD
if errorlevel 1 (
    echo [AVISO] Voce tem alteracoes nao commitadas.
    echo Faca commit ou stash antes de fazer o deploy.
    pause
    exit /b 1
)

REM --- Build web ---
echo [1/4] Gerando build web...
%FLUTTER% build web --base-href "/app_cardapio_virtual/"
if errorlevel 1 (
    echo [ERRO] Falha no build. Abortando.
    pause
    exit /b 1
)
echo Build concluido com sucesso.
echo.

REM --- Troca para a branch gh-pages ---
echo [2/4] Trocando para branch gh-pages...
git checkout gh-pages
if errorlevel 1 (
    echo [ERRO] Nao foi possivel trocar para gh-pages.
    pause
    exit /b 1
)
echo.

REM --- Copia os arquivos do build para a raiz ---
echo [3/4] Copiando arquivos do build...
xcopy /E /Y /I build\web\* . >nul 2>&1
echo Arquivos copiados.
echo.

REM --- Commit e push ---
echo [4/4] Fazendo commit e push...
git add .
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Deploy: build web atualizado - app cardapio virtual"
) else (
    echo Nenhuma alteracao no build, forcando commit vazio...
    git commit --allow-empty -m "Deploy: build web atualizado - app cardapio virtual"
)
git push origin gh-pages
if errorlevel 1 (
    echo [ERRO] Falha no push.
    git checkout %BRANCH_ATUAL%
    pause
    exit /b 1
)
echo.

REM --- Volta para a branch original ---
echo Voltando para branch %BRANCH_ATUAL%...
git checkout %BRANCH_ATUAL%
echo.

echo ============================================
echo  Deploy concluido!
echo  Acesse: https://victorhssouza.github.io/app_cardapio_virtual/
echo ============================================
pause
