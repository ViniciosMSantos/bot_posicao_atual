import os
from robot.api.deco import keyword
from datetime import datetime

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload

# Escopo necessário para upload
SCOPES = ["https://www.googleapis.com/auth/drive.file"]


@keyword
def arquivo_drive(id_pasta_drive, arquivo):
    creds = None

    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                "client_secret.json", SCOPES)
            creds = flow.run_local_server(port=0)

        with open("token.json", "w") as token:
            token.write(creds.to_json())

    try:
        service = build("drive", "v3", credentials=creds)

        # ID da pasta do Google Drive onde deseja salvar o arquivo
        folder_id = id_pasta_drive

        # Caminho local do arquivo que será enviado
        file_path = arquivo

        query = f"'{folder_id}' in parents and trashed = false"
        results = service.files().list(q=query, fields="files(id, name)").execute()
        files = results.get("files", [])

        for file in files:
            print(f"Excluindo: {file['name']}")
            service.files().delete(fileId=file["id"]).execute()

        # Define nome e pasta de destino
        data_atual = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')

        file_metadata = {
            "name": f"Unecont_celula_de_entrada_{data_atual}.csv",
            "parents": [folder_id]
        }

        media = MediaFileUpload(file_path, mimetype="text/csv")

        # Faz o upload
        file = service.files().create(
            body=file_metadata,
            media_body=media,
            fields="id"
        ).execute()

    except HttpError as error:
        print(f"Ocorreu um erro: {error}")
