@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo === Instalando bibliotecas ===
python -m pip install -r requirements.txt
if errorlevel 1 (echo Erro de instalacao! & pause & exit /b 1)
echo === Executando testes ===
python -m pytest -q
if errorlevel 1 (echo Alguns testes falharam! & pause & exit /b 1)
echo === Verificacao sintetica da NOVA extensao A-B-C-D ===
python main.py --mode imbalance --smoke --budgets 10 --seeds 0
if errorlevel 1 (echo Verificacao falhou! & pause & exit /b 1)
echo.
echo Testes concluidos. Para usar Satimage real, veja README.md.
pause
