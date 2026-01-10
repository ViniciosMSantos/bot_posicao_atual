import pandas as pd
from pathlib import Path
from datetime import datetime


def concat(pasta_salvar, pasta_csv):

    pasta_salvar = Path(pasta_salvar)
    pasta_csv = Path(pasta_csv)

    lista_df = []

    # Iterar SOMENTE arquivos Excel
    for arquivo in pasta_salvar.glob("*.xlsx"):
        df = pd.read_excel(arquivo, sheet_name=1)

        df = df.rename(columns={'Cnpj Empresa': 'CNPJ Empresa'})

        df['CNPJ Empresa'] = (
            df['CNPJ Empresa']
            .astype(str)
            .str.replace(r'[./-]', '', regex=True)
        )

        df = df.fillna("")
        lista_df.append(df)

    if not lista_df:
        raise ValueError("Nenhum arquivo Excel encontrado para merge.")

    # Concat
    resultado = pd.concat(lista_df, ignore_index=True)

    # Data e hora
    resultado['Data_do_download'] = datetime.now().strftime(
        '%Y-%m-%d %H:%M:%S'
    )

    # Criar Id
    resultado['Id'] = (
        resultado['CNPJ Empresa'].astype(str) +
        resultado['Número NFe'].astype(str)
    )

    # Criar pasta do CSV se não existir
    pasta_csv.mkdir(parents=True, exist_ok=True)

    # Salvar CSV
    caminho_csv = pasta_csv / "Unecont_celula_de_entrada.csv"
    resultado.to_csv(caminho_csv, index=False, encoding="utf-8-sig")

    # Limpar pasta de origem
    arquivos_csv = list(Path(pasta_salvar).glob('*'))
    for arquivo in arquivos_csv:
        arquivo.unlink()
