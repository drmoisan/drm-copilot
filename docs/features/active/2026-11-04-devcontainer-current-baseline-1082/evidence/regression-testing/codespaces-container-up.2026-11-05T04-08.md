Timestamp: 2026-11-05T04-08
Started: 2026-11-05T04:07:12.8525144Z
Command: pwsh -NoLogo -NoProfile -File C:\Users\DANMOI~1\AppData\Local\Temp\codex-container-baseline\issue-1082\issue-1082-container.ps1 codespaces
EXIT_CODE: 0
Output Summary:

```text
[OK] Debian GNU/Linux 12 (bookworm)
[2026-11-05T04:08:36.901Z] [OK] python 3.13.18
[2026-11-05T04:08:36.904Z] [OK] git 2.56.0
[2026-11-05T04:08:36.908Z] [OK] node v26.13.0
[2026-11-05T04:08:36.997Z] [OK] npm 11.20.0
[2026-11-05T04:08:37.110Z] [OK] pwsh 7.6.9
[2026-11-05T04:08:37.889Z] [OK] poetry 2.5.1
[2026-11-05T04:08:37.914Z] [OK] gh 2.103.3
[2026-11-05T04:08:38.010Z] [OK] dotnet 10.0.403
[2026-11-05T04:08:38.016Z] [OK] uv 0.13.7
[2026-11-05T04:08:38.025Z] [OK] claude 2.1.318
[2026-11-05T04:08:38.323Z] [OK] cswap 0.29.0
[2026-11-05T04:08:38.355Z] [OK] codex 0.166.0
[2026-11-05T04:08:38.358Z] [OK] shfmt v3.14.1
[2026-11-05T04:08:38.360Z] [OK] shellcheck 0.11.0
[2026-11-05T04:08:38.364Z] [OK] actionlint 1.7.12
[2026-11-05T04:08:38.553Z] [OK] gt 1.7.14
[2026-11-05T04:08:39.035Z] [OK] copilot 0.0.377
[2026-11-05T04:08:39.041Z] [OK] kcov v43
[2026-11-05T04:08:39.443Z] [OK] pester 6.2.0
[2026-11-05T04:08:39.726Z] [OK] pssa 1.25.0
[OK] bats is installed
[OK] bashdb is installed
[OK] .devcontainer/codespaces/devcontainer.json
[2026-11-05T04:08:39.727Z] [OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.
[2026-11-05T04:08:39.727Z]
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

{"outcome":"success","containerId":"1a90d86c15919fa7fa1a483d2d446eb6707a268467a900609d06cff8475af5a2","remoteUser":"vscode","remoteWorkspaceFolder":"REPO","ociAuthDiagnostics":{"authLookupWouldBeBlocked":false,"registryRedirectWouldPreventCredentialForwarding":false,"authServerRedirect":false}}
```

Raw output: SCRATCH/issue-1082-codespaces-container-up.log
