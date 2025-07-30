from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import router
from app.db import init_db

app = FastAPI(
    title="Math Microservice",
    description="API for power, fibonacci, and factorial",
    version="1.0"
)

# ✅ Allow all origins — you can restrict this later
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or specify ["http://localhost:5500"] if you serve HTML from a local server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    init_db()

app.include_router(router)

@app.get("/")
def root():
    return {"message": "Welcome to the Math Microservice!"}
