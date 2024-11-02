
from fastapi import APIRouter, UploadFile, File, HTTPException
from typing import List
from fastapi.responses import FileResponse

app = APIRouter(prefix="/api/login", responses={404: {"description": "Not found"}})