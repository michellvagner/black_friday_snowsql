@echo off
REM Deixa o .BAT como UTF-8.
chcp 65001 >nul
cls

REM Habilita mudança de variaveis dentro de loop
setlocal enabledelayedexpansion

echo.
echo @@@@@  @     @@@@@ @@@@@ @   @ @@@@@ @@@@  @@@ @@@@  @@@@@ @     @      @   @  @@@  @@@@  @@@ @@@@@  @@@@@  @   @
echo @    @ @     @   @ @     @  @  @     @   @  @  @   @ @   @  @   @       @   @ @   @ @   @  @      @  @   @  @@  @
echo @@@@@  @     @@@@@ @     @@@   @@@@@ @@@@   @  @   @ @@@@@   @ @  @@@@  @@@@@ @   @ @@@@   @     @   @   @  @ @ @
echo @    @ @     @   @ @     @  @  @     @  @   @  @   @ @   @    @         @   @ @   @ @  @   @    @    @   @  @  @@
echo @@@@@  @@@@@ @   @ @@@@@ @   @ @     @   @ @@@ @@@@  @   @    @         @   @  @@@  @   @ @@@ @@@@@  @@@@   @   @
echo.

REM Definição de caminhos.

REM Caminho DW rede \\onprem_data.
set NETWORK_PATH=\\onprem_data\horizon_events\DW\DB\99_DATA\BLACK_FRIDAY_ANO_ATUAL\

REM Caminho temporario de saída do arquivo.
set OUTPUT=%USERPROFILE%\temp_black_friday
set OUTPUT=%OUTPUT:\=/%

REM Caminho de execução do .BAT.
set FILE=%~dp0queries
set FILE=%FILE:\=/%

REM Definir 0 na variavel para ser utilizada depois.
set /a count=0

REM Cria uma pasta temporaria na pasta Users para salvar os arquivos.
if not exist "%OUTPUT%" mkdir "%OUTPUT%"

REM Para garantir deleta arquivos previamente criados(Nao é necessariamente obrigatório).
for %%f in ("%OUTPUT%\*.parquet" "%OUTPUT%\*.tsv") do (
    if exist "%%f" (
        del "%%f"
    )
)

REM Comando snowsql linha de comando para executar queries no snowflake
snowsql -c snow_conexoes -f "%FILE%\comandos.sql" ^
    --variable caminho_saida="%OUTPUT%" ^
    --variable caminho_queries="%FILE%" ^
    -o header=true ^
    -o friendly=false ^
    -o quiet=true ^
    -o timing=false ^
    -o variable_substitution=true

REM Deleta arquivos da pasta temporaria criada anteriormente.
for %%f in ("%OUTPUT%\*.parquet" "%OUTPUT%\*.tsv") do (
    set /a count+=1
    copy /Y "%%f" "%NETWORK_PATH%" >nul
)

rmdir /s /q "%OUTPUT%"

cscript //nologo "%~dp0scripts\enviar_email.vbs"

REM Printa fim de execução para o usuario final.
echo [INFO] Email encaminhado para Data Squad
echo [INFO] Queries executadas, foram copiados !count! arquivos para a rede. Power BI será atualizado
echo .
echo 🚀 Pressione qualquer tecla para sair . . .
REM Não fecha automaticamente a tela preta ao finalizar.
pause >nul