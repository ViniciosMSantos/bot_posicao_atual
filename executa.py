import os
import subprocess
from dotenv import load_dotenv
import arquivo
import salvar_drive

load_dotenv()

contas = ['BHUB', 'WELLSCO', 'CARNEVALE', 'ASPR', 'BR',
          'BLN', 'CONTJET', 'ACCORD', 'SERAC', 'PARTWORK',
          'CTZ', 'MANGINI', 'QUALITY', 'SAOLUCAS', 'VALOR', 
          'VERSAO2', 'EFFORTS']


ROBOT = "executa_bot.robot"

try:
    
    for conta in contas:
        email = os.getenv(f"EMAIL_UNECONT_{conta}")
        senha = os.getenv(f"SENHA_UNECONT_{conta}")

        print(f"Executando extração Unecont - conta {conta}")

        tentativas = 0
        max_tentativas = 3

        while tentativas < max_tentativas:
            try:
                subprocess.run([
                    "robot",
                    "-d", f"results",
                    "-v", f"EMAIL:{email}",
                    "-v", f"SENHA:{senha}",
                    "-v", f"CONTA:{conta}",
                    ROBOT
                ], check=True)

                break
            
            except subprocess.CalledProcessError as e:
                print(f"Erro ao executar o robô: {e}")
                tentativas += 1

                if tentativas == max_tentativas:
                    raise e

    arquivo.concat(
        pasta_salvar="downloads/pasta_xlsx",
        pasta_csv="downloads/pasta_csv"
    )

    salvar_drive.arquivo_drive(
        id_pasta_drive=os.getenv("ID_PASTA_DRIVE"),
        arquivo="downloads/pasta_csv/Unecont_celula_de_entrada.csv")

    arquivo.excluir_log("results")

except subprocess.CalledProcessError as e:
    print(f"Erro ao executar o robô: {e}")
