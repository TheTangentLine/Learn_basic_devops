FROM python:3.9-slim

# 1. Setup the user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
WORKDIR /app

# 2. Copy files FIRST
COPY requirements.txt .
COPY app.py .

# 3. Install dependencies as ROOT
RUN pip install -r requirements.txt

# 4. NOW switch to the secure user
USER appuser

# 5. Syntax: Separate arguments
CMD ["python", "app.py"]