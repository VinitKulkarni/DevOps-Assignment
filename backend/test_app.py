import unittest
from app import app

class FlaskTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    def test_health(self):
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)

    def test_message(self):
        response = self.app.get('/api/message')
        self.assertIn(b"Hello", response.data)

if __name__ == '__main__':
    unittest.main()
