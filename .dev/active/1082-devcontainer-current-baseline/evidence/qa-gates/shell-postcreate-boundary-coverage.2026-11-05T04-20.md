Validation disposition: INVALID HISTORICAL ATTEMPT. This probe incorrectly overrode HOME; its coverage is excluded from final acceptance. The corrected probe uses task-specific scratch state and GIT_CONFIG_GLOBAL only. The native Codex warning exposed by this attempt is retained as regression input, not an environment acceptance result.

Timestamp: 2026-11-05T04-20
Started: 2026-11-05T04:19:52.5981257Z
Command: docker exec -u vscode 4ce6ae052778 bash SCRATCH/issue-1082-postcreate-branches.sh
EXIT_CODE: 1
Output Summary:

```text
Installed modules:


[32;1mName            [0m[32;1m Version[0m
[32;1m----            [0m [32;1m-------[0m
PSScriptAnalyzer 1.25.0
Pester           6.2.0


Ensuring PowerShell QC dependencies...
[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1l[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1h[?1h[?1h[?1h[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1h[?1l[?1h[?1h[?1h[?1h[?1h[?1l[?1h[?1h[?1h[?1h
Importing PoshQC module...
[?1h[?1l[?1h[?1h[?1l[?1h[?1l[?1h[?1h[?1h[?1h[?1l[?1h[?1l[?1h[?1lImported PoshQC from REPO/scripts/powershell/PoshQC/PoshQC.psd1
[?1h
Git configuration not found. You may want to run:
  git config --global user.name 'Your Name'
  git config --global user.email 'your.email@example.com'
Devcontainer verification: local
[OK] Debian GNU/Linux 12 (bookworm)
[OK] python 3.13.18
[OK] git 2.56.0
[OK] node v26.13.0
[OK] npm 11.20.0
[OK] pwsh 7.6.9
[OK] poetry 2.5.1
[OK] gh 2.103.3
[OK] dotnet 10.0.403
[OK] uv 0.13.7
[OK] claude 2.1.318
[OK] cswap 0.29.0
[FAIL] codex reports unsupported version proceeding,
[OK] shfmt v3.14.1
[OK] shellcheck 0.11.0
[OK] actionlint 1.7.12
[OK] gt 1.7.14
[OK] copilot 0.0.377
[OK] kcov v43
[OK] pester 6.2.0
[OK] pssa 1.25.0
[OK] bats is installed
[OK] bashdb is installed
[OK] .devcontainer/local/devcontainer.json
[OK] Workspace virtual environment Python 3.13.18
Devcontainer verification failed. Rebuild using .devcontainer/local/devcontainer.json.
See .devcontainer/TROUBLESHOOTING.md for setup guidance.
```

Raw output: SCRATCH/issue-1082-shell-postcreate-boundary-coverage.log
