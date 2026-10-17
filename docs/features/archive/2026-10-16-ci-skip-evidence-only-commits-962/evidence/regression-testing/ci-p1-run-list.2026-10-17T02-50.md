# P7-T2 Proof step P1.1: identify the full run

Timestamp: 2026-10-17T02-50
Command: gh run list --repo drmoisan/drm-copilot --workflow ci.yml --branch bug/ci-skip-evidence-only-commits-962 --event pull_request --limit 5 --json databaseId,headSha,status,conclusion,createdAt,updatedAt ; gh run view 38995143126 --repo drmoisan/drm-copilot --json conclusion,jobs --jq .conclusion, (.jobs[] | [.name,.conclusion] | @tsv)
EXIT_CODE: 0
Output Summary: One completed pull_request run on the branch: 38995143126 on 412c6ba20, conclusion success, CI full run success (PD-10 selects it as id1).

ID1: 38995143126
HEAD1: 412c6ba20512ceb6c219431ba6c5f5d8472cf07b

## `gh run list --repo drmoisan/drm-copilot --workflow ci.yml --branch bug/ci-skip-evidence-only-commits-962 --event pull_request --limit 5 --json databaseId,headSha,status,conclusion,createdAt,updatedAt`

exit: 0

```text
[{"conclusion":"success","createdAt":"2026-10-17T02:29:54Z","databaseId":38995143126,"headSha":"412c6ba20512ceb6c219431ba6c5f5d8472cf07b","status":"completed","updatedAt":"2026-10-17T02:46:04Z"}]
```

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
