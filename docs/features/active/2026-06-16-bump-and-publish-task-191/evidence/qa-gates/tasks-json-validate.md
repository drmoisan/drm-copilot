# Final QC — .vscode/tasks.json Structural Validation

Timestamp: 2026-06-16T20-38

Command (1): JSONC parse via Node (strip // and /* */ comments, then JSON.parse)
EXIT_CODE: 0

Command (2): poetry run python -m scripts.dev_tools.validate_json
EXIT_CODE: 0

Output Summary:
- The file `.vscode/tasks.json` parses successfully as JSONC.
- The repository governed JSON schema validator (`scripts.dev_tools.validate_json`, which validates governed JSON against its `$schema`) passed with exit code 0; `.vscode/tasks.json` declares `$schema: ./schemas/tasks.schema.json`.
- New input present: `id=FullReleaseConfirm`, `type=pickString`, `options=["no","yes"]`, `default="no"`, description notes Marketplace and npm versions are immutable.
- New task present: label `Publish: Full Release (bump both + Marketplace + npm tag)`, `command=pwsh`, args `-NoLogo -NoProfile -ExecutionPolicy Bypass -File ${workspaceFolder}/scripts/dev-tools/Invoke-FullRelease.ps1 -ConfirmToken ${input:FullReleaseConfirm}`, `options.cwd=${workspaceFolder}`.
- The JSON remains valid after both additions.
