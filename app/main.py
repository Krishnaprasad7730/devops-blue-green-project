from fastapi import FastAPI
import os

app = FastAPI(
    title="DevOps Employee Management API",
    description="End-to-end DevOps CI/CD project",
    version="1.0"
)

APP_VERSION = os.getenv("APP_VERSION", "blue-v1")

@app.get("/")
def home():
    return {
        "message": "Welcome to Employee Management API",
        "application": "DevOps Project"
    }

@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }

@app.get("/version")
def version():
    return {
        "application_version": APP_VERSION
    }
@app.get("/employee")
def get_employee():
    return {
        "employee_id": 101,
        "employee_name": "John",
        "department": "DevOps"
    }
