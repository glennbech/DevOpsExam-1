FROM python:3.9-slim

# Sett arbeidskatalogen i containeren
WORKDIR /app

# Kopier kun filen som er nødvendig for å installere avhengigheter først
# Dette forbedrer caching av Docker layers
COPY requirements.txt ./

# Installer eventuelle avhengigheter
RUN pip install --no-cache-dir -r requirements.txt

# Kopier resten av koden din inn i containeren
COPY . .

# Kjør app.py når containeren starter
CMD ["python", "./app.py"]
