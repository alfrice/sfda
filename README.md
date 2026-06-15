# FastAPI Docker Demo

A minimal production-style FastAPI application packaged with Docker and managed with Poetry.

This project demonstrates a common containerization pattern used for Python microservices:

* FastAPI for the web framework
* Poetry for dependency management
* Docker for containerization
* Health checks for container monitoring
* Environment variables for configuration
* Reproducible builds using a lock file

The goal is to provide a simple example that can serve as the foundation for larger enterprise applications.

---

# Environment setup
I have included a script to ensure you have docker running, the correct python version and poetry installed. You can run it with
```
  sudo chmod 777 setup.sh
  ./setup.sh
```

This script:
* logs in to trimet's docker hub
* ensures docker is running
* ensures you have python 3.12 running
* ensures poetry is installed
* installs the local env


# Project Structure

```text
sfda/
├── main.py
pyproject.toml
poetry.lock
Dockerfile
.dockerignore
README.md
```

---

# Application Endpoints

## Root Endpoint

Returns basic service information.

**Request**

```bash
curl http://localhost:8000/
```

**Response**

```json
{
  "service": "demo-service",
  "version": "1.0.0",
  "environment": "demo"
}
```

---

## Health Endpoint

Used by Docker and orchestration platforms to determine application health.

**Request**

```bash
curl http://localhost:8000/api/health
```

**Response**

```json
{
  "status": "healthy"
}
```

---

# Local Development

## Prerequisites

* Python 3.12+
* Poetry 2.x

Verify installation:

```bash
python --version
poetry --version
```

---

## Install Dependencies

```bash
poetry config virtualenvs.in-project true     
poetry install
```

This creates a virtual environment and installs all project dependencies.

---

## Start the Application

```bash
poetry run uvicorn sfda.main:app --reload
```

The application will be available at:

```text
http://localhost:8000
```

Interactive API documentation:

```text
http://localhost:8000/docs
```

OpenAPI specification:

```text
http://localhost:8000/openapi.json
```

---

# Building the Docker Image

Build the container image:

```bash
docker build -t fastapi-demo:latest .
```

Verify the image exists:

```bash
docker images
```

Example output:

```text
REPOSITORY     TAG       IMAGE ID
fastapi-demo   latest    abc123def456
```

---

# Running the Container

Start the container:

```bash
docker run --name fastapi-demo -p 8000:8000 -e APP_ENV=demo fastapi-demo:latest
```

The service is now available at:

```text
http://localhost:8000
```

---

# Environment Variables

The application supports configuration through environment variables.

| Variable | Description              | Default |
| -------- | ------------------------ | ------- |
| APP_ENV  | Runtime environment name | local   |

Example:

```bash
docker run -p 8000:8000 -e APP_ENV=production fastapi-demo:latest
```

Response:

```json
{
  "service": "demo-service",
  "version": "1.0.0",
  "environment": "production"
}
```

---

# Docker Health Checks

The image defines a Docker health check:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/health')" || exit 1
```

The health check executes inside the container and verifies that the application can successfully respond to requests.

This does not require the container port to be exposed externally.

Inspect health status:

```bash
docker ps
```

Example:

```text
STATUS
Up 2 minutes (healthy)
```

Detailed inspection:

```bash
docker inspect fastapi-demo
```

---

# Why Poetry?

Poetry provides:

* Dependency resolution
* Lock file generation
* Reproducible builds
* Simplified package management
* Standardized project metadata

The lock file ensures all developers and deployment environments use identical dependency versions.

Install dependencies:

```bash
poetry install
```

Update dependencies:

```bash
poetry update
```

Generate lock file:

```bash
poetry lock
```

# Cleanup

Stop the container:

```bash
docker stop fastapi-demo
```

Remove the container:

```bash
docker rm fastapi-demo
```

Remove the image:

```bash
docker rmi fastapi-demo:latest
```
