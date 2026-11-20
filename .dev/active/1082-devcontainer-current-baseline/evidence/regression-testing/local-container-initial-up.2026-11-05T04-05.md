Timestamp: 2026-11-05T04-05
Started: 2026-11-05T03:53:43Z
Completed: 2026-11-05T03:56:48Z
Command: node DEVCONTAINERS_CLI up --workspace-folder REPO --config REPO/.devcontainer/local/devcontainer.json --id-label drm-copilot.validation=current-baseline-1082-local --log-level info
EXIT_CODE: 0
Output Summary:

The full selected configuration built successfully, including the Docker feature, and executed the shared postCreateCommand. Container e525debb7e74 runs as vscode. The pinned base resolved to sha256:3f4f9dcfd377127908846abbac5f0c1e73e8d99425c03818438271c1f226cdf8. This first run reused the existing isolated Linux dependency volumes; the separate fresh-volume run records initial installation. Initial build output was captured by the tool transcript rather than a SCRATCH log; the following is the actual captured completion tail. Separate runtime probes have complete SCRATCH logs.

```text
Imported PoshQC from REPO/scripts/powershell/PoshQC/PoshQC.psd1
[2026-11-05T03:56:46.129Z] Devcontainer verification: local
[OK] Debian GNU/Linux 12 (bookworm)
[2026-11-05T03:56:46.131Z] [OK] python 3.13.18
[2026-11-05T03:56:46.133Z] [OK] git 2.56.0
[2026-11-05T03:56:46.137Z] [OK] node v26.13.0
[2026-11-05T03:56:46.191Z] [OK] npm 11.20.0
[2026-11-05T03:56:46.269Z] [OK] pwsh 7.6.9
[2026-11-05T03:56:46.980Z] [OK] poetry 2.5.1
[2026-11-05T03:56:47.005Z] [OK] gh 2.103.3
[2026-11-05T03:56:47.084Z] [OK] dotnet 10.0.403
[2026-11-05T03:56:47.090Z] [OK] uv 0.13.7
[2026-11-05T03:56:47.097Z] [OK] claude 2.1.318
[2026-11-05T03:56:47.394Z] [OK] cswap 0.29.0
[2026-11-05T03:56:47.423Z] [OK] codex 0.166.0
[2026-11-05T03:56:47.426Z] [OK] shfmt v3.14.1
[2026-11-05T03:56:47.429Z] [OK] shellcheck 0.11.0
[2026-11-05T03:56:47.432Z] [OK] actionlint 1.7.12
[2026-11-05T03:56:47.607Z] [OK] gt 1.7.14
[2026-11-05T03:56:48.118Z] [OK] copilot 0.0.377
[2026-11-05T03:56:48.141Z] [OK] kcov v43
[2026-11-05T03:56:48.544Z] [OK] pester 6.2.0
[2026-11-05T03:56:48.856Z] [OK] pssa 1.25.0
[2026-11-05T03:56:48.857Z] [OK] bats is installed
[2026-11-05T03:56:48.857Z] [OK] bashdb is installed
[2026-11-05T03:56:48.859Z] [OK] .devcontainer/local/devcontainer.json
[2026-11-05T03:56:48.861Z] [OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.
[2026-11-05T03:56:48.862Z]
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

{"outcome":"success","containerId":"e525debb7e74fd0492954a2a4929ef209ad18a4635ef7f381425abfc61f43389","remoteUser":"vscode","remoteWorkspaceFolder":"REPO","ociAuthDiagnostics":{"authLookupWouldBeBlocked":false,"registryRedirectWouldPreventCredentialForwarding":false,"authServerRedirect":false}}
```
