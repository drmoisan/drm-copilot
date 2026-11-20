Timestamp: 2026-11-05T03-11
Started: 2026-11-05T03:11:47.2322138Z
Command: docker exec --user vscode --workdir REPO 40c5007b16b3 kcov --include-pattern=REPO/.devcontainer/verify-container.sh SCRATCH/issue-1082-kcov-verifier .devcontainer/verify-container.sh
EXIT_CODE: 0
Output Summary:

```text
Devcontainer verification: local
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
```

Raw output: SCRATCH/issue-1082-shell-verifier-coverage.log
