from fastapi.middleware.cors import CORSMiddleware
from fastapi_wsgi import WSGIMiddleware
from main import app as fastapi_app

# Wrap FastAPI in WSGI middleware
app = WSGIMiddleware(fastapi_app)
