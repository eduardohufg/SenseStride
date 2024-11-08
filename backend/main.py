from fastapi import FastAPI
from routes import login, signup
import uvicorn
from fastapi.middleware.cors import CORSMiddleware



app = FastAPI() 
app.include_router(login.app)  
app.include_router(signup.app) 



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hello fast"}

