from dotenv import load_dotenv

# Load environment variables
load_dotenv()

import logging
from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
import database

# Models
from models import user, category, product, inventory, sales, loan, load_products

# Routes
from routes.auth import auth_router
from routes.ai import ai_router
from routes.charts import charts_router

# Logging
logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")

# Connect to the database
database.db.connect()
    
# Create tables
database.db.create_tables([
    user.User,
    category.Category,
    product.Product,
    inventory.Inventory,
    sales.Sales,
    loan.Loan,
    load_products.LoanProducts,
], safe=True)

# Crear la aplicación FastAPI con el gestor de contexto
app = FastAPI()

# Create the API router
api = APIRouter()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
api.include_router(auth_router, prefix="/auth")
api.include_router(ai_router, prefix="/ai")
api.include_router(charts_router, prefix="/charts")

# Includes
app.include_router(api, prefix="/api")