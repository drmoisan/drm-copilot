# P7-T5 Proof steps P1.2 to P1.4 for id1

Timestamp: 2026-10-17T02-48
Command: gh run view 38995143126 --repo drmoisan/drm-copilot --json conclusion,jobs --jq .conclusion, (.jobs[] | [.name,.conclusion] | @tsv) ; gh run view --repo drmoisan/drm-copilot --log --job 117285946237
EXIT_CODE: 0
Output Summary: id1 38995143126 on HEAD1 412c6ba20 concluded success; CI full run success; every heavy job success; Change scope decided code=true.

ID1: 38995143126
HEAD1: 412c6ba20512ceb6c219431ba6c5f5d8472cf07b

## `gh run view 38995143126 --repo drmoisan/drm-copilot --json conclusion,jobs --jq .conclusion, (.jobs[] | [.name,.conclusion] | @tsv)`

exit: 0

```text
success
Change scope	success
docs-validation / Documentation Validation	success
CI full run	success
NPM Audit Gate / npm audit (.)	success
poshqc / PowerShell hook suites (Linux)	success
poshqc / PowerShell QC static	success
poshqc / PowerShell QC shard 2	success
build-check / Build Package	success
quality-checks7 / Code Quality & Tests (3.10)	success
NPM Audit Gate / npm audit (extensions/drm-copilot)	success
quality-checks7 / Code Quality & Tests (3.11)	success
poshqc / PowerShell QC shard 1	success
quality-checks7 / Code Quality & Tests (3.12)	success
shell-coverage / Shell Coverage (Bats + kcov)	success
NPM Audit Gate / npm audit (packages/mcp-server)	success
quality-checks7 / Code Quality & Tests (3.13)	success
security-scan / Security Scanning	success
poshqc / PowerShell QC shard 3	success
root-typescript-tests / Root TypeScript Tests (windows-latest)	success
root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	success
drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success
poshqc / PowerShell QC	success
```

## `gh run view --repo drmoisan/drm-copilot --log --job 117285946237`

exit: 0

```text
Change scope	Decide the change scope	2026-10-17T02:30:06.3422447Z code=true reason=NO_FULL_GREEN_RUN
```
