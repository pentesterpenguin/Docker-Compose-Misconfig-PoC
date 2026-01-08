FROM python:3.9-slim

WORKDIR /app
COPY app/ .

# On lance juste le script innocent
CMD ["python", "main.py"]
