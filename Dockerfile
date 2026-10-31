FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

ENV APP_VERSION=blue-v1

EXPOSE 8000

# Create a non-root user
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup --uid 10001 appuser

# Run application as non-root user
USER appuser

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]