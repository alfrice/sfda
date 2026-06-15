#!/usr/bin/env bash
set -euo pipefail

echo "=== Starting cleanup process ==="

# Docker logout
echo "Logging out from docker registry gitlab.trimet.org:4567..."
if docker logout gitlab.trimet.org:4567; then
  echo "✓ Docker logout successful"
else
  echo "⚠ Docker logout failed or was not logged in"
fi

# Deactivate virtual environment if active
echo "Deactivating virtual environment..."
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  deactivate || true
fi

# Remove .pyenv-version file to reset to system Python
echo "Removing .pyenv-version file..."
if [[ -f .pyenv-version ]]; then
  rm .pyenv-version
  echo "✓ Removed .pyenv-version"
else
  echo "⚠ .pyenv-version not found"
fi

# Remove poetry virtual environment
echo "Removing poetry virtual environment..."
if [[ -d .venv ]]; then
  rm -rf .venv
  echo "✓ Removed .venv directory"
else
  echo "⚠ .venv directory not found"
fi

# Uninstall pyenv
echo "Uninstalling pyenv..."
if [[ -d "$HOME/.pyenv" ]]; then
  rm -rf "$HOME/.pyenv"
  echo "✓ Uninstalled pyenv from $HOME/.pyenv"
else
  echo "⚠ pyenv installation not found"
fi

# Uninstall poetry
echo "Uninstalling poetry..."
if [[ -d "$HOME/.local/share/pypoetry" ]]; then
  rm -rf "$HOME/.local/share/pypoetry"
  echo "✓ Removed poetry data directory"
fi

if [[ -f "$HOME/.local/bin/poetry" ]]; then
  rm -f "$HOME/.local/bin/poetry"
  echo "✓ Removed poetry executable"
else
  echo "⚠ poetry executable not found at $HOME/.local/bin/poetry"
fi

# Display current Python version
echo ""
CURRENT_PYTHON=$(python3 --version 2>&1 || echo "Python 3 not found")
echo "Current Python version: $CURRENT_PYTHON"

echo ""
echo "=== Cleanup complete ==="
echo "Please restart your shell or source your .bashrc/.zshrc to clear environment variables."
