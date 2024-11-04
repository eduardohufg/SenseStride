# config.py

from pymongo import MongoClient
import os

# Cargar variables de entorno desde un archivo .env (opcional)
from dotenv import load_dotenv
load_dotenv()

# Obtener la URI de conexión desde una variable de entorno
MONGO_URI = os.getenv('MONGO_URI')

if not MONGO_URI:
    raise Exception("La variable de entorno MONGO_URI no está definida")

# Conexión a MongoDB Atlas
client = MongoClient(MONGO_URI)
db = client['SenseStride']
users_collection = db['usuarios']
metrics_collection = db['metricas']
