from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from passlib.context import CryptContext
from config import users_collection  # Importamos la colección desde config.py

# Creación de la instancia de APIRouter
app = APIRouter(prefix="/api/load_data", responses={404: {"description": "Not found"}})


@app.get("/get_names")
async def get_names(number: str = Query(...)):
    # Verificar si el usuario ya existe
    usuario_existente = users_collection.find_one({"numero": number})
    if not usuario_existente:
        raise HTTPException(status_code=400, detail="El usuario no existe")
    return {"nombre": usuario_existente['nombre'], "apellidos": usuario_existente['apellidos']}

