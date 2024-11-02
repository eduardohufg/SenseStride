
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from passlib.context import CryptContext
from config import users_collection  # Importamos la colección desde config.py

# Configuración del contexto de hash
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Definición del modelo de usuario
class User(BaseModel):
    nombre: str
    apellidos: str
    numero: str
    contraseña: str


# Creación de la instancia de APIRouter
app = APIRouter(prefix="/api/signup", responses={404: {"description": "Not found"}})

# Ruta para registrar usuarios
@app.post("/")
async def registrar_usuario(user: User):
    # Verificar si el usuario ya existe
    usuario_existente = users_collection.find_one({"numero": user.numero})
    if usuario_existente:
        raise HTTPException(status_code=400, detail="El usuario ya existe")
    
    # Hashear la contraseña antes de almacenarla
    user_dict = user.dict()
    user_dict['contraseña'] = pwd_context.hash(user.contraseña)
    
    # Insertar el usuario en la base de datos
    resultado = users_collection.insert_one(user_dict)
    return {"mensaje": "Usuario registrado exitosamente", "id_usuario": str(resultado.inserted_id)}
