@echo off

echo ========================================
echo Atualizando codigo do repositorio Git...
echo ========================================

REM Muda para o diretório do script .bat (onde os .robot estão)
cd /d "%~dp0"

REM Atualiza o código do repositório Git
echo.
echo Executando git pull...
git pull origin main

REM Verifica se o git pull foi bem-sucedido
if %errorlevel% neq 0 (
    echo.
    echo AVISO: Erro ao atualizar o repositorio Git!
    echo Continuando com a versao atual do codigo...
    echo.
    pause
) else (
    echo.
    echo Codigo atualizado com sucesso!
    echo.
)

echo ========================================
echo Ativando ambiente virtual...
echo ========================================
echo.

REM Ativa o ambiente virtual Python
call venv\Scripts\activate

echo.
echo Instalando/atualizando dependencias...
pip install -r requirements.txt --quiet

echo.
echo ========================================
echo Iniciando execucao do bot...
echo ========================================
echo.

python executa.py


