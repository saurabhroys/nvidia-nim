# Use the official uv image with Python 3.14
FROM ghcr.io/astral-sh/uv:python3.14-bookworm-slim

WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy dependency definition files first to leverage Docker layer caching
COPY pyproject.toml uv.lock ./

# Install dependencies (without installing the project package itself)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-install-project

# Copy the rest of the project source code
COPY . .

# Sync the project (installs the package into the virtual environment)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Expose the default proxy port
EXPOSE 8082

# Define volume for configuration storage
VOLUME ["/root/.fcc"]

# Environment defaults
ENV HOST=0.0.0.0
ENV PORT=8082
ENV FCC_OPEN_BROWSER=false

# Start the proxy server using uvicorn directly
CMD ["uv", "run", "uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8082"]
