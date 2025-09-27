from app import app as application

# Gunicorn entrypoint:
#   gunicorn -w 2 -b 0.0.0.0:8080 sitlweb.wsgi:application
