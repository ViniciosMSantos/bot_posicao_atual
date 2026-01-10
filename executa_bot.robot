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
${TEMPO_ESPERA}            100s
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
    Wait Until Element Is Enabled    id=email    ${TEMPO_ESPERA}
    Input Text    id=email    ${email}
    Input Text    id=password    ${senha}
    Click Button    id=btnEntrar


Fechar Modais
    Run Keyword And Ignore Error
    ...    Click Element    xpath=//button[text()='Vamos nessa!']

    Run Keyword And Ignore Error
    ...    Click Element    xpath=//a[contains(@class, 'pliq-btn-full-screen')]

    Run Keyword And Ignore Error
    ...    Click Element    xpath=//div[@id="novidadeCadastroEmpresa"]//button[@class="close"]

    Run Keyword And Ignore Error
    ...    Click Element    xpath=//div[@id="novidadeProgramaIndicacao"]//button[@class="close"]


Verificar existencia de Mensagem
    ${modal_apareceu}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    css=.modal-backdrop    30s

    Run Keyword If    ${modal_apareceu}
    ...    Fechar Modais

    Run Keyword If    ${modal_apareceu}    Wait Until Element Is Not Visible    css=.modal-backdrop    timeout=10s


Acessar Menu Empresas
    Wait Until Element Is Visible    xpath=//a[span[contains(text(),'Posição Atual')]]    ${TEMPO_ESPERA}
    Wait Until Element Is Enabled    xpath=//a[span[contains(text(),'Posição Atual')]]    ${TEMPO_ESPERA}
    Click Element    xpath=//a[span[contains(text(),'Posição Atual')]]


Excluir Excel Antigo
    [Arguments]         ${DIRETORIO_DOWNLOAD}
    ${arquivos}=         List Files In Directory    ${DIRETORIO_DOWNLOAD}
    Run Keyword If      len(${arquivos}) > 0    Remove Files    ${DIRETORIO_DOWNLOAD}\\*

Baixar Arquivo Atual
    Wait Until Element Is Visible    id=btExportarRelatorioServicoTomado    ${TEMPO_ESPERA}
    Wait Until Element Is Enabled    id=btExportarRelatorioServicoTomado    ${TEMPO_ESPERA}

    Click Element    id=btExportarRelatorioServicoTomado


Verificar Download XLSX
    ${xlsx}=    List Files In Directory    ${DIRETORIO_DOWNLOAD}    *.xlsx
    ${temp}=    List Files In Directory    ${DIRETORIO_DOWNLOAD}    *.part
    Should Be True    len(${xlsx}) == 1
    Should Be True    len(${temp}) == 0  
    sleep   5s


Mover Arquivo
    [Arguments]    ${tipo}

    Wait Until Keyword Succeeds    3 minutes    2s
    ...    Verificar Download XLSX 

    ${arquivos}=    List Files In Directory    ${DIRETORIO_DOWNLOAD}    *.xlsx
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
    
    Wait Until Element Is Enabled    id=btExportarRelatorioServicoTomado    ${TEMPO_ESPERA}
    Wait Until Element Is Enabled    id=btExportarRelatorioServicoTomado    ${TEMPO_ESPERA}

    Click Element    id=btExportarRelatorioServicoTomado


Fechar Navegador
    Wait Until Element Is Enabled    id=btExportarRelatorioServicoTomado    ${TEMPO_ESPERA}
    Wait Until Element Is Enabled    id=btExportarRelatorioServicoTomado    ${TEMPO_ESPERA}

    ${arquivos}=         List Files In Directory    ${DIRETORIO_DOWNLOAD}
    ${qtde}=             Get Length                 ${arquivos}
    Run Keyword If       ${qtde} > 0                Close Browser


Prepara Firefox Com Pasta de Download
    [Arguments]    ${URL}    ${DOWNLOAD_FOLDER}
    [Documentation]    Configura uma pasta personalizada para downloads do firefox.
    Open Browser    ${URL}    browser=firefox    ff_profile_dir=set_preference("browser.download.folderList", 2);set_preference("browser.download.dir", r"${DOWNLOAD_FOLDER}");set_preference("browser.helperApps.neverAsk.saveToDisk", "application/zip")
