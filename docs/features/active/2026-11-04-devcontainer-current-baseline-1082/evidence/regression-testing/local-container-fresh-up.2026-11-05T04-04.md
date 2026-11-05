Timestamp: 2026-11-05T04-04
Started: 2026-11-05T04:02:41.7117015Z
Command: pwsh -NoLogo -NoProfile -File C:\Users\DANMOI~1\AppData\Local\Temp\codex-container-baseline\issue-1082\issue-1082-container.ps1 fresh
EXIT_CODE: 0
Output Summary:

```text
[OK] Debian GNU/Linux 12 (bookworm)
[2026-11-05T04:04:31.387Z] [OK] python 3.13.18
[2026-11-05T04:04:31.389Z] [OK] git 2.56.0
[2026-11-05T04:04:31.394Z] [OK] node v26.13.0
[2026-11-05T04:04:31.462Z] [OK] npm 11.20.0
[2026-11-05T04:04:31.538Z] [OK] pwsh 7.6.9
[2026-11-05T04:04:32.266Z] [OK] poetry 2.5.1
[2026-11-05T04:04:32.293Z] [OK] gh 2.103.3
[2026-11-05T04:04:32.385Z] [OK] dotnet 10.0.403
[2026-11-05T04:04:32.390Z] [OK] uv 0.13.7
[2026-11-05T04:04:32.398Z] [OK] claude 2.1.318
[2026-11-05T04:04:32.693Z] [OK] cswap 0.29.0
[2026-11-05T04:04:32.720Z] [OK] codex 0.166.0
[2026-11-05T04:04:32.723Z] [OK] shfmt v3.14.1
[2026-11-05T04:04:32.726Z] [OK] shellcheck 0.11.0
[2026-11-05T04:04:32.729Z] [OK] actionlint 1.7.12
[2026-11-05T04:04:32.908Z] [OK] gt 1.7.14
[2026-11-05T04:04:33.425Z] [OK] copilot 0.0.377
[2026-11-05T04:04:33.432Z] [OK] kcov v43
[2026-11-05T04:04:33.842Z] [OK] pester 6.2.0
[2026-11-05T04:04:34.162Z] [OK] pssa 1.25.0
[OK] bats is installed
[2026-11-05T04:04:34.162Z] [OK] bashdb is installed
[2026-11-05T04:04:34.163Z] [OK] .devcontainer/local/devcontainer.json
[2026-11-05T04:04:34.165Z] [OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.
[2026-11-05T04:04:34.166Z]
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

{"outcome":"success","containerId":"4ce6ae052778ee6e28fbff79b9b5ff6b34a6495faf0effa1cc060e260951c7a7","remoteUser":"vscode","remoteWorkspaceFolder":"REPO","ociAuthDiagnostics":{"authLookupWouldBeBlocked":false,"registryRedirectWouldPreventCredentialForwarding":false,"authServerRedirect":false}}
```

Raw output: SCRATCH/issue-1082-local-container-fresh-up.log
