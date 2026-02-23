# Multi-stage build for OpenClaw Agent - Sandboxed Docker Environment
# Stage 1: Builder stage for dependencies
FROM python:3.11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create and use non-root user for build
RUN groupadd -r openclaw && useradd -r -g openclaw -u 1000 -m openclaw

# Set working directory
WORKDIR /build

# Copy requirements first for better layer caching
COPY requirements.txt /build/

# Install packages to a specific directory
RUN pip install --no-cache-dir --target /build/packages -r requirements.txt

# Stage 2: Runtime stage - minimal image
FROM python:3.11-slim

# Install git (required for client to install OpenClaw)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (matching builder stage)
RUN groupadd -r openclaw && useradd -r -g openclaw -u 1000 openclaw

# Set working directory
WORKDIR /app

# Create directory for Python packages and copy from builder stage
RUN mkdir -p /home/openclaw/.local/lib/python3.11/site-packages && chown -R openclaw:openclaw /home/openclaw/.local
COPY --from=builder --chown=openclaw:openclaw /build/packages /home/openclaw/.local/lib/python3.11/site-packages

# Copy application code
COPY --chown=openclaw:openclaw app/ /app/

# Set PYTHONPATH to include installed packages and app directory
ENV PYTHONPATH=/app:/home/openclaw/.local/lib/python3.11/site-packages:$PYTHONPATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Create tmp directory with proper permissions
RUN mkdir -p /tmp && chown openclaw:openclaw /tmp

# Switch to non-root user
USER openclaw

# Health check (adjust command based on your agent's health endpoint)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# Default entrypoint (override in docker-compose or run script)
ENTRYPOINT ["python"]
CMD ["main.py"]
