# P7-T7 Proof step P2.1: docs-only run id2

Timestamp: 2026-10-17T03-09
Command: gh run view 38997218418 --repo drmoisan/drm-copilot --json conclusion,createdAt,updatedAt,jobs --jq .conclusion, .createdAt, .updatedAt, (.jobs[] | [.name,.conclusion] | @tsv)
EXIT_CODE: 0
Output Summary: id2 38997218418 (PR #967 pull_request run on HEAD2' a27ffadb4) concluded success; Change scope success; CI full run, root-typescript-tests, NPM Audit Gate skipped; the 11 required contexts success.

ID2: 38997218418
HEAD2: a27ffadb4582c490a9facfdd1d6ac0af84412390 (PR #966 merged before the first docs-only commit eef09af44 produced a run; the docs-only proof runs on follow-up PR #967, whose head adds one more docs-only commit)
PR: 967

## `gh run view 38997218418 --repo drmoisan/drm-copilot --json conclusion,createdAt,updatedAt,jobs --jq .conclusion, .createdAt, .updatedAt, (.jobs[] | [.name,.conclusion] | @tsv)`

exit: 0

```text
success
2026-10-17T03:02:05Z
2026-10-17T03:02:36Z
Change scope	success
docs-validation / Documentation Validation	success
build-check / Build Package	success
security-scan / Security Scanning	success
drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success
shell-coverage / Shell Coverage (Bats + kcov)	success
quality-checks7 / Code Quality & Tests (3.13)	success
drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
quality-checks7 / Code Quality & Tests (3.10)	success
quality-checks7 / Code Quality & Tests (3.12)	success
quality-checks7 / Code Quality & Tests (3.11)	success
poshqc / PowerShell QC	success
root-typescript-tests	skipped
CI full run	skipped
poshqc / PowerShell hook suites (Linux)	skipped
poshqc / PowerShell QC static	skipped
NPM Audit Gate	skipped
poshqc / PowerShell QC shard ${{ matrix.shard }}	skipped
```
