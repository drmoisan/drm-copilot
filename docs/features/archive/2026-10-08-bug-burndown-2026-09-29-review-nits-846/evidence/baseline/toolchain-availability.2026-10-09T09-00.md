# Baseline: toolchain availability ([P0-T5])

Timestamp: 2026-10-09T20-56
Command: poetry run python --version
EXIT_CODE: 0
Output Summary: Python 3.13.12

## Block 2

Command: poetry run pytest --version
EXIT_CODE: 0
Output Summary: pytest 9.0.2

## Block 3

Command: node --version
EXIT_CODE: 0
Output Summary: v24.14.0

## Block 4

Command: npm --version
EXIT_CODE: 0
Output Summary: 11.9.0

## Block 5

Command: test -d extensions/drm-copilot/node_modules
EXIT_CODE: 1
Output Summary: node_modules absent in the worktree (exit 1), so the plan branch "run npm ci from extensions/drm-copilot" was taken.

## Block 6 (branch: node_modules absent)

Command: npm --prefix extensions/drm-copilot ci
EXIT_CODE: 0
Output Summary: "added 452 packages, and audited 453 packages in 6s"; "found 0 vulnerabilities". One deprecation warning for glob@10.5.0. Run with --prefix from the repository root, which is equivalent to running npm ci from extensions/drm-copilot.

## Block 7 (branch confirmation)

Command: git status --porcelain -- extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: printed nothing; package-lock.json is unchanged. A follow-up `test -d extensions/drm-copilot/node_modules` exited 0 (present).

## Block 8 (PowerShell tool, A7 branch rule)

Command: Get-Module -ListAvailable -Name Pester, PSScriptAnalyzer | Select-Object Name, Version
EXIT_CODE: not run
Output Summary: PowerShell tool unavailable. The PowerShell tool is not in this executor's tool set, and the executor is instructed not to route pwsh through the Bash tool.
Error: PowerShell tool unavailable
Outcome: LOCAL-PESTER-UNAVAILABLE
A7 branch selected: A7-CI for the Phase 0, Phase 8, and Phase 12 PowerShell tasks. The CI job `poshqc / PowerShell QC` on the PR head is authoritative for AC-30, AC-31, and AC-38, which stay unchecked and are listed as pending-CI.

The poetry install branch was not taken because `poetry run python --version` exited 0.
