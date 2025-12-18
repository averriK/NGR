#!/usr/bin/env zsh
set -e

# Entorno de desarrollo donde se instalan build/twine
DEV_ENV=$HOME/dev-python

echo "🚀 Preparing ngr (Python) release..."
echo "Using development environment: $DEV_ENV"

# Verificar que existe el entorno de desarrollo
if [[ ! -d "$DEV_ENV" ]]; then
  echo "❌ Development environment not found: $DEV_ENV"
  echo "Create it with: ~/.pyenv/versions/3.12.11/bin/python -m venv ~/dev-python"
  exit 1
fi

# Activar entorno
source "$DEV_ENV/bin/activate"
echo "✅ Activated: $VIRTUAL_ENV"

# Instalar/actualizar herramientas de release en el entorno de desarrollo
echo "📦 Installing/Updating build and twine in development environment..."
python -m pip install --upgrade pip build twine

# Ir al directorio del subproyecto Python (esta carpeta)
SCRIPT_DIR=$(cd -- "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

echo "🧹 Cleaning old artifacts..."
rm -rf dist build
find . -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true

# Construir el paquete (sdist + wheel)
echo "🔧 Building package..."
python -m build

# Subir a PyPI (producirá el registro del nombre 'ngr' la primera vez)
echo "📤 Uploading to PyPI with twine..."
echo "ℹ️  Twine will ask for your PyPI credentials (username __token__ and API token)."
twine upload dist/*

echo "✅ ngr release completed successfully!"
