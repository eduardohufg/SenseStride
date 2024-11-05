from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel
from passlib.context import CryptContext
from datetime import datetime, timedelta
import jwt
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError
from config import (
    users_collection,
    secret_key,
    algorithm,
    access_token_expire_minutes,
    refreash_token_expire_days,  # Corrección en el nombre
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Modelos
class UserLogin(BaseModel):
    numero: str
    contraseña: str

class Token(BaseModel):
    access_token: str
    refresh_token: str

# Modelo para recibir el refresh token
class RefreshTokenRequest(BaseModel):
    refresh_token: str

# Función para decodificar y verificar un JWT token
def decode_jwt(token: str):
    try:
        payload = jwt.decode(token, secret_key, algorithms=[algorithm])
        return payload
    except ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="El token ha expirado")
    except InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token inválido")

# Instancia de APIRouter
app = APIRouter(prefix="/api/login", responses={404: {"description": "Not found"}})

# Función para verificar la contraseña
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

# Función para crear el access token
def create_access_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, secret_key, algorithm=algorithm)
    return encoded_jwt

# Función para crear el refresh token
def create_refresh_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, secret_key, algorithm=algorithm)
    return encoded_jwt

# Ruta para login
@app.post("/", response_model=Token)
async def login(user: UserLogin):
    # Buscar el usuario por número
    usuario = users_collection.find_one({"numero": user.numero})
    if not usuario:
        raise HTTPException(status_code=400, detail="Número o contraseña incorrectos")

    # Verificar la contraseña
    if not verify_password(user.contraseña, usuario["contraseña"]):
        raise HTTPException(status_code=400, detail="Número o contraseña incorrectos")

    # Crear tokens
    access_token_expires = timedelta(minutes=access_token_expire_minutes)
    refresh_token_expires = timedelta(days=refreash_token_expire_days)
    
    # Incluir información adicional en el token si es necesario
    access_token = create_access_token(
        data={"sub": usuario["numero"], "user_id": str(usuario["_id"])}, expires_delta=access_token_expires
    )
    refresh_token = create_refresh_token(
        data={"sub": usuario["numero"]}, expires_delta=refresh_token_expires
    )

    return {"access_token": access_token, "refresh_token": refresh_token}

# Ruta para refrescar el access token
@app.post("/refresh", response_model=Token)
async def refresh_access_token(request: RefreshTokenRequest):
    # Decodificar el refresh token
    payload = decode_jwt(request.refresh_token)
    
    # Obtener el identificador del usuario (e.g., número de teléfono) desde el payload
    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(status_code=401, detail="Token inválido")

    # Opcional: Verificar si el usuario existe en la base de datos
    usuario = users_collection.find_one({"numero": user_id})
    if not usuario:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")

    # Generar un nuevo access token
    access_token_expires = timedelta(minutes=access_token_expire_minutes)
    new_access_token = create_access_token(
        data={"sub": usuario["numero"], "user_id": str(usuario["_id"])},
        expires_delta=access_token_expires
    )
    
    return {"access_token": new_access_token, "refresh_token": request.refresh_token}

# Ruta opcional para validar el access token
@app.post("/validate-token")
async def validate_token(token: str):
    try:
        payload = jwt.decode(token, secret_key, algorithms=[algorithm])
        return {"valid": True, "user": payload.get("sub")}
    except ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="El token ha expirado")
    except InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token inválido")
