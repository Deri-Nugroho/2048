# ─────────────────────────────────────────────
#  Stage 1 – Builder
# ─────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# Install dependencies in an isolated layer for better caching
COPY app/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# ─────────────────────────────────────────────
#  Stage 2 – Runtime
# ─────────────────────────────────────────────
FROM python:3.11-slim AS runtime

LABEL maintainer="debuglifeindonesia"
LABEL org.opencontainers.image.title="2048 Game – FastAPI"
LABEL org.opencontainers.image.description="2048 puzzle game served via FastAPI + Uvicorn"
LABEL org.opencontainers.image.version="1.0.0"

WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application source
COPY app/ ./
# Copy README.md into /app so game.py (running from /app) can find it if it uses open("README.md")
# Wait, I changed game.py to use `../README.md` because locally game.py is in `app/`.
# Let's change game.py to use `README.md` and copy it into `/app` so both local and Docker behave the same if CWD is the app dir.
# Actually, the simplest is to just copy README.md to the same directory
COPY readme.md ./README.md

# Expose the application port
EXPOSE 8080

# Run Uvicorn bound to all interfaces on port 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
