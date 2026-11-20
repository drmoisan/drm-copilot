# CI result on the pull-request head (P3-T5)

Timestamp: 2026-11-19T07-28
Command: gh run view 44305159324 --json jobs (workflow CI, event pull_request, PR #1207)
EXIT_CODE: 0
Output Summary: CI run 44305159324 on head 4af3dfcbf60ff527c2012b5dca729ae6ebe5e668 completed with conclusion success. poshqc / PowerShell hook suites (Linux): success; poshqc / PowerShell QC: success; CI Required Gate: success. Every job in the run reported success.

Head SHA: 4af3dfcbf60ff527c2012b5dca729ae6ebe5e668
Run: https://github.com/drmoisan/drm-copilot/actions/runs/44305159324

## Job conclusions

- Change scope: success
- docs-validation / Documentation Validation: success
- CI full run: success
- shell-coverage / Shell Coverage (Bats + kcov): success
- poshqc / PowerShell hook suites (Linux): success
- poshqc / PowerShell QC static: success
- quality-checks7 / Python 3.13 static: success
- build-check / Build Package: success
- quality-checks7 / Python 3.13 coverage shard 2: success
- quality-checks7 / Code Quality & Tests (3.11): success
- poshqc / PowerShell QC shard 2: success
- drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest): success
- root-typescript-tests / Root TypeScript Tests (windows-latest): success
- NPM Audit Gate / npm audit (extensions/drm-copilot): success
- poshqc / PowerShell QC shard 1: success
- poshqc / PowerShell QC shard 3: success
- NPM Audit Gate / npm audit (packages/mcp-server): success
- quality-checks7 / Python 3.13 coverage shard 1: success
- NPM Audit Gate / npm audit (.): success
- quality-checks7 / Code Quality & Tests (3.12): success
- poshqc / PowerShell QC shard 6: success
- drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest): success
- poshqc / PowerShell QC shard 4: success
- poshqc / PowerShell QC shard 5: success
- root-typescript-tests / Root TypeScript Tests (ubuntu-latest): success
- security-scan / Security Scanning: success
- quality-checks7 / Code Quality & Tests (3.13): success
- poshqc / PowerShell QC: success
- CI Required Gate: success

## Acceptance-criterion mapping

- spec AC (bundled mirrors and pack manifests): the listed Pester suites run in the poshqc shard jobs (Windows) and the codex-hooks suites also in the Linux hook-suite job; the listed pytest contract tests run in quality-checks7 jobs. All reported success.
- spec AC and user-story AC (Linux hook suites): poshqc / PowerShell hook suites (Linux) reported success on the head.
- user-story AC (bundled mirrors, pack manifests and contract tests): as above.
