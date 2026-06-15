#!/usr/bin/env bash
set -euo pipefail

echo "=== Starting setup process ==="
echo ""

# check docker is running before anything else
echo "✓ Checking if Docker is running..."
if ! docker info &>/dev/null; then
  echo "✗ Docker is not running. Please start Docker Desktop and re-run this script."
  exit 1
fi
echo "✓ Docker is running"
echo ""

# docker login (use your trimet credentials)
echo "Step 1: Docker Registry Login"
echo "Please enter your Trimet LDAP credentials for Docker registry gitlab.trimet.org:4567"
docker login gitlab.trimet.org:4567
echo "✓ Docker login successful"
echo ""

# check the version of python is 3.12
echo "Step 2: Python Version Check"
PYTHON_VERSION=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "none")
echo "Current Python version: $PYTHON_VERSION"

if [[ "$PYTHON_VERSION" != 3.12* ]]; then
  echo "Python 3.12 not found. Installing via pyenv..."
  # if not check that pyenv is installed
  if ! command -v pyenv &>/dev/null; then
    # if pyenv is NOT installed, install it
    echo "  → Installing pyenv..."
    curl https://pyenv.run | bash
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    echo "  ✓ pyenv installed"
  else
    echo "  ✓ pyenv already installed"
  fi

  # if pyenv IS installed run pyenv local 3.12
  if ! pyenv versions --bare | grep -q "^3\.12"; then
    # if pyenv 3.12 is not installed, install it with pyenv
    echo "  → Installing Python 3.12 with pyenv..."
    pyenv install 3.12
    echo "  ✓ Python 3.12 installed"
  else
    echo "  ✓ Python 3.12 already installed with pyenv"
  fi

  # proceed with pyenv local 3.12 if pyenv local 3.12 had failed previously
  echo "  → Setting local Python version to 3.12..."
  pyenv local 3.12
  echo "  ✓ Local Python version set to 3.12"
else
  echo "✓ Python 3.12 is already available"
fi
echo ""

# once pyenv local 3.12 succeeds

# check that poetry is installed and the version is 2.3.x
echo "Step 3: Poetry Setup"
POETRY_VERSION=$(poetry --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "none")
echo "Current Poetry version: $POETRY_VERSION"

if [[ "$POETRY_VERSION" != 2.3.* ]]; then
  # if poetry is not installed, install it
  echo "  → Installing Poetry 2.3.x..."
  curl -sSL https://install.python-poetry.org | python3 -
  export PATH="$HOME/.local/bin:$PATH"
  echo "  ✓ Poetry installed"
else
  echo "  ✓ Poetry 2.3.x is already installed"
fi

# if or once poetry is installed run
echo "  → Configuring Poetry..."
poetry config virtualenvs.in-project true
echo "  → Installing project dependencies..."
poetry install
echo "  ✓ Dependencies installed"
echo ""

echo "Step 4: Activating Virtual Environment"
source .venv/bin/activate
echo "✓ Virtual environment activated"
echo ""
echo "=== Setup complete! ==="
