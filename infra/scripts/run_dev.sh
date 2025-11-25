#!/usr/bin/env bash
set -euo pipefail

echo "Starting EIXO dev stack..."
(cd "$(dirname "$0")/../../api" && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload) &

# Placeholder for Flutter hot-reload or ML worker commands.
echo "API running on http://localhost:8000"
