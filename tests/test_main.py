from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_home():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json()["message"] == "Welcome to Employee Management API"


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "unhealthy"


def test_version():
    response = client.get("/version")

    assert response.status_code == 200
    assert response.json()["application_version"] == "blue-v1"
