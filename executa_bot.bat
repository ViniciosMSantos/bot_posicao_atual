@echo off

REM Muda para o diretório do script .bat (onde os .robot estão)
cd /d "C:\Users\vinicios.santos_bhub\Desktop\Automacao\Bot_Ferramentas"

REM Caminhos dos arquivos e pastas
set SCRIPT_UNECONT_BHUB=.\robot\unecont_BHub.robot


REM set SCRIPT_SIEG=.\robot\SIEG.robot - Senha Incorreta
set OUTPUT=.\robot\results

REM Executa os testes Robot Framework
robot -d %OUTPUT% %SCRIPT_UNECONT_BHUB%


