Timestamp: 2026-02-24T10-36
Command: poetry run black .
EXIT_CODE: 0
Command: poetry run ruff check
EXIT_CODE: 0
Command: poetry run pyright
EXIT_CODE: 0
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
EXIT_CODE: 0
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
EXIT_CODE: 0
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Command: poetry run python -m scripts.dev_tools.format_json
EXIT_CODE: 0
Command: poetry run python -m scripts.dev_tools.validate_json
EXIT_CODE: 0
Command: poetry run shell-qc format
EXIT_CODE: 0
Command: poetry run shell-qc check
EXIT_CODE: 0
Command: poetry run shell-qc test
EXIT_CODE: 0
Output Summary: PASS final QA loop clean
