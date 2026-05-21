# Use the official uv image with Python 3.14 for building
FROM ghcr.io/astral-sh/uv:python3.14-bookworm-slim AS builder

# Set working directory
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy dependency definition files first for caching
COPY pyproject.toml uv.lock ./

# Install dependencies (without installing the project itself)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-install-project

# Copy the rest of the project source code
COPY . .

# Sync project (installs the packages into the virtual environment)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Final slim runtime image
FROM python:3.14-slim-bookworm

WORKDIR /app

# Copy the virtual environment and files from the builder
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app /app

# Place virtual environment binaries in PATH
ENV PATH="/app/.venv/bin:$PATH"

# Expose the default proxy port
EXPOSE 8082

# Define volume for configuration storage
VOLUME ["/root/.fcc"]

# Environment defaults
ENV HOST=0.0.0.0
ENV PORT=8082
ENV FCC_OPEN_BROWSER=false

# Start the proxy server
CMD ["fcc-server"]
