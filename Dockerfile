FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

ENV APP_VERSION=blue-v1
ENV APP_VERSION=green-v2

EXPOSE 8000

RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup --uid 10001 appuser

USER appuser

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]