Timestamp: 2026-11-05T03-10
Started: 2026-11-05T03:10:02.8346182Z
Command: docker exec --user vscode --workdir REPO 40c5007b16b3 kcov --include-pattern=REPO/.devcontainer/post-create.sh SCRATCH/issue-1082-kcov-postcreate-script .devcontainer/post-create.sh
EXIT_CODE: 0
Output Summary:

```text
Pester           5.9.1


Ensuring PowerShell QC dependencies...
[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1l[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1h[?1h[?1h[?1h[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1h[?1l[?1h[?1h[?1h[?1h[?1h[?1l[?1h[?1h[?1h[?1h
Importing PoshQC module...
[?1h[?1l[?1h[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1l[?1h[?1l[?1h[?1lImported PoshQC from REPO/scripts/powershell/PoshQC/PoshQC.psd1
[?1hDevcontainer verification: local
[OK] Debian GNU/Linux 12 (bookworm)
[OK] python 3.13.17
[OK] node v26.13.0
[OK] npm 11.20.0
[OK] pwsh 7.6.9
[OK] poetry 2.3.2
[OK] shfmt v3.14.1
[OK] shellcheck 0.11.0
[OK] actionlint 1.7.12
[OK] git is installed
[OK] gh is installed
[OK] kcov is installed
[OK] bats is installed
[OK] bashdb is installed
[OK] claude is installed
[OK] cswap is installed
[OK] .devcontainer/local/devcontainer.json
[OK] Workspace virtual environment Python 3.13.17
All devcontainer checks passed.

===================================
Dev Container Setup Complete!
===================================

Available commands:
  poetry run pytest                         # Run Python tests
  poetry run black .                        # Format Python code
  poetry run ruff check                     # Lint Python code
  poetry run pyright                        # Type check Python code
  pwsh -File scripts/dev-tools/fix-all.ps1  # Run all QC checks

VS Code tasks are available via:
  Ctrl+Shift+P -> Tasks: Run Task

To build the package:
  poetry build

```

Raw output: SCRATCH/issue-1082-shell-postcreate-coverage.log
