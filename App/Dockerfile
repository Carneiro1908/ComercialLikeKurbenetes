# Use a slim official Python base image
FROM python:3.11-slim

# Set system-level environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000 \
    APP_DIR=/app

# Set the working directory
WORKDIR ${APP_DIR}

# Install essential system dependencies for database drivers
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and prepare the application directory
RUN groupadd --system --gid 1000 app && useradd --system --uid 1000 --gid 1000 appuser \
    && chown -R appuser:app /app

# Copy Python dependencies and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source and frontend assets
COPY database.py .
COPY server.py .
COPY public/ ./public/

# Expose the application port
EXPOSE ${PORT}

# Run the FastAPI service as a non-root user
USER appuser
CMD ["python", "server.py"]
