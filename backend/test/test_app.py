import unittest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestAPI(unittest.TestCase):
    def test_health_check(self):
        response = client.get("/api/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "healthy")

    def test_message(self):
        response = client.get("/api/message")
        self.assertEqual(response.status_code, 200)
        self.assertIn("integrated", response.json()["message"])

if __name__ == "__main__":
    unittest.main()
