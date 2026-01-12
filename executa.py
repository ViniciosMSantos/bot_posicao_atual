import os
import subprocess
from dotenv import load_dotenv
import arquivo
import salvar_drive

load_dotenv()

contas = ['BHUB', 'WELLSCO', 'CARNEVALE', 'ASPR', 'BR',
          'BLN', 'CONTJET', 'ACCORD', 'SERAC', 'PARTWORK']

ROBOT = "executa_bot.robot"

try:
    
    for conta in contas:
        email = os.getenv(f"EMAIL_UNECONT_{conta}")
        senha = os.getenv(f"SENHA_UNECONT_{conta}")

        print(f"Executando extração Unecont - conta {conta}")

        subprocess.run([
            "robot",
            "-d", f"results",
            "-v", f"EMAIL:{email}",
            "-v", f"SENHA:{senha}",
            "-v", f"CONTA:{conta}",
            ROBOT
        ], check=True)

    arquivo.concat(
        pasta_salvar="downloads/pasta_xlsx",
        pasta_csv="downloads/pasta_csv"
    )

    salvar_drive.arquivo_drive(
        id_pasta_drive=os.getenv("ID_PASTA_DRIVE"),
        arquivo="downloads/pasta_csv/Unecont_celula_de_entrada.csv")

except subprocess.CalledProcessError as e:
    print(f"Erro ao executar o robô: {e}")
