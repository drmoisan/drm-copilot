Timestamp: 2026-11-04T02-26
Command: docker run --rm --user root --security-opt seccomp=unconfined --mount repository-readonly --mount isolated-venv --mount SCRATCH:/coverage vsc-drm-copilot-e593fee203d55a66ea1452f0c5df0aee6691b7b1807f1b2ccbad654ee8bf0557 bash /coverage/issue-1069-container-scenarios.sh baseline supported
EXIT_CODE: 0
Output Summary:   poetry run pytest                         # Run Python tests
  poetry run black .                        # Format Python code
  poetry run ruff check                     # Lint Python code
  poetry run pyright                        # Type check Python code
  pwsh -File scripts/dev-tools/fix-all.ps1  # Run all QC checks

VS Code tasks are available via:
  Ctrl+Shift+P -> Tasks: Run Task

To build the package:
  poetry build



