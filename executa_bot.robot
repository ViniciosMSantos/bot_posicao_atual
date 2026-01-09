*** Settings ***
Library           SeleniumLibrary    run_on_failure=${None}
Library           OperatingSystem

Test Timeout      15 minutes
Test Teardown     Run Keyword And Ignore Error    Close All Browsers

*** Variables ***
${URL}                     https://app.une.digital/_login/Login.aspx?ReturnUrl=%2FContador%2FDefault.aspx
${DIRETORIO_DOWNLOAD}      ${CURDIR}\\downloads\\original
${DIRETORIO_SALVAR}        ${CURDIR}\\downloads\\pasta_xlsx
${DIRETORIO_ATUAL}         ${CURDIR}
${TEMPO_ESPERA}            20s
${ID_ARQUIVO}              1g-e2IkWN6fEFgDStWO1KJ75JYrpvKwEKGu0IQEUPXJI
${ABA_ARQUIVO}             BHub
${NOME_ARQUIVO}            Une
${NOME_BASE}               Unecont BHUB
${DIR_EXC}                 ${CURDIR}\\results
${ID_PASTA}                1dW_hbVck2PgstOpDIZy4g5mnJ0cYGzXD
${email}                   ${EMAIL}
${senha}                   ${SENHA}
${conta}                   ${CONTA}

*** Tasks ***
Baixar Arquivo Excel Da Plataforma
    Create Directory    ${DIRETORIO_DOWNLOAD}
    Abrir Navegador E Fazer Login
    Verificar existencia de Mensagem
    Acessar Menu Empresas
    Excluir Excel Antigo    ${DIRETORIO_DOWNLOAD}
    Baixar Arquivo Atual
    Mover Arquivo    atual
    Excluir Excel Antigo    ${DIRETORIO_DOWNLOAD}
    Baixar Arquivo Antigo
    Mover Arquivo    anterior
    Fechar Navegador
    

*** Keywords ***
Abrir Navegador E Fazer Login
    Prepara Firefox Com Pasta de Download    ${URL}    ${DIRETORIO_DOWNLOAD}
    Maximize Browser Window
    Wait Until Element Is Visible    id=email    ${TEMPO_ESPERA}
    Input Text    id=email    ${email}
    Input Text    id=password    ${senha}
    Click Button    id=btnEntrar
    Sleep   10s
    
Verificar existencia de Mensagem
   ${modal_existe}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=modalPliq    timeout=10s
    Run Keyword If    ${modal_existe}    Click Element    xpath=//button[text()='Vamos nessa!']
    Run Keyword If    ${modal_existe}    Click Element    xpath=//a[contains(@class, 'pliq-btn-full-screen')]

    ${modal_2}=         Run Keyword And Return Status    Wait Until Element Is Visible    id=novidadeCadastroEmpresa    timeout=10s
    Run Keyword If    ${modal_2}    Click Element    xpath=//div[@id="novidadeCadastroEmpresa"]//button[@class="close"]

    ${modal_3}=         Run Keyword And Return Status    Wait Until Element Is Visible    id=novidadeProgramaIndicacao    timeout=10s
    Run Keyword If    ${modal_3}    Click Element    xpath=//div[@id="novidadeProgramaIndicacao"]//button[@class="close"]

    Sleep       20s

Acessar Menu Empresas
    Click Element    xpath=//a[span[contains(text(),'Posição Atual')]]
    Wait Until Element Is Visible    id=btExportarRelatorioServicoTomado    20s
    Sleep   10s


Excluir Excel Antigo
    [Arguments]         ${DIRETORIO_DOWNLOAD}
    ${arquivos}=         List Files In Directory    ${DIRETORIO_DOWNLOAD}
    Run Keyword If      len(${arquivos}) > 0    Remove Files    ${DIRETORIO_DOWNLOAD}\\*

Baixar Arquivo Atual
    Click Element    id=btExportarRelatorioServicoTomado
    Sleep    100s

Mover Arquivo
    [Arguments]    ${tipo}

    ${arquivos}=    List Files In Directory    ${DIRETORIO_DOWNLOAD}
    Should Be True    len(${arquivos}) == 1

    ${arquivo_original}=    Set Variable    ${arquivos}[0]

    IF    '${tipo}' == 'atual'
        ${novo_nome}=    Set Variable    relatorio_${conta}_mes_atual.xlsx
    ELSE IF    '${tipo}' == 'anterior'
        ${novo_nome}=    Set Variable    relatorio_${conta}_mes_anterior.xlsx
    ELSE
        Fail    Tipo inválido: ${tipo}
    END

    Move File
    ...    ${DIRETORIO_DOWNLOAD}\\${arquivo_original}
    ...    ${DIRETORIO_SALVAR}\\${novo_nome}


Baixar Arquivo Antigo
    Click Element    id=linkMesAnoReferenciaAnterior
    Sleep    15s
    Click Element    id=btExportarRelatorioServicoTomado
    Sleep    100s


Fechar Navegador
    ${arquivos}=         List Files In Directory    ${DIRETORIO_DOWNLOAD}
    ${qtde}=             Get Length                 ${arquivos}
    Run Keyword If       ${qtde} > 0                Close Browser


Prepara Firefox Com Pasta de Download
    [Arguments]    ${URL}    ${DOWNLOAD_FOLDER}
    [Documentation]    Configura uma pasta personalizada para downloads do firefox.
    Open Browser    ${URL}    browser=firefox    ff_profile_dir=set_preference("browser.download.folderList", 2);set_preference("browser.download.dir", r"${DOWNLOAD_FOLDER}");set_preference("browser.helperApps.neverAsk.saveToDisk", "application/zip")
