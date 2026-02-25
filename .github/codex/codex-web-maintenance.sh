#!/usr/bin/env bash
set -euo pipefail

echo "=== drm-copilot [maintenance] Verifying environment ==="
python --version
poetry --version || true
ls -la
echo "=== drm-copilot [maintenance] Done ==="