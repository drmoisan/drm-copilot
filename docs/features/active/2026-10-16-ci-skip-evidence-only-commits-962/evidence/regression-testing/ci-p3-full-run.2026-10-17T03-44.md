# P7-T16 Proof step P3 verification for id3 (AC-34)

Timestamp: 2026-10-17T03-44
Command: gh run view 38998609176 --repo drmoisan/drm-copilot --json conclusion,jobs --jq .conclusion, (.jobs[] | [.name,.conclusion] | @tsv) ; gh run view --repo drmoisan/drm-copilot --log --job 117296558215
EXIT_CODE: 0
Output Summary: id3 38998609176 (PR #968 pull_request run on HEAD3 27895da3d) concluded success; CI full run success; every heavy job success; Change scope decided code=true for the non-allowlisted module path.

ID3: 38998609176
HEAD3: 27895da3da954df03ba9bd80ff6531c5c5b0be38
PR: 968

## `gh run view 38998609176 --repo drmoisan/drm-copilot --json conclusion,jobs --jq .conclusion, (.jobs[] | [.name,.conclusion] | @tsv)`

exit: 0

```text
success
Change scope	success
docs-validation / Documentation Validation	success
NPM Audit Gate / npm audit (.)	success
root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	success
build-check / Build Package	success
NPM Audit Gate / npm audit (packages/mcp-server)	success
root-typescript-tests / Root TypeScript Tests (windows-latest)	success
poshqc / PowerShell hook suites (Linux)	success
NPM Audit Gate / npm audit (extensions/drm-copilot)	success
shell-coverage / Shell Coverage (Bats + kcov)	success
quality-checks7 / Code Quality & Tests (3.13)	success
security-scan / Security Scanning	success
poshqc / PowerShell QC shard 1	success
quality-checks7 / Code Quality & Tests (3.11)	success
poshqc / PowerShell QC shard 3	success
CI full run	success
quality-checks7 / Code Quality & Tests (3.12)	success
quality-checks7 / Code Quality & Tests (3.10)	success
poshqc / PowerShell QC shard 2	success
drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
poshqc / PowerShell QC static	success
drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success
poshqc / PowerShell QC	success
```

## `gh run view --repo drmoisan/drm-copilot --log --job 117296558215`

exit: 0

```text
Change scope	Decide the change scope	2026-10-17T03:23:59.6402846Z code=true reason=NON_ALLOWLISTED_PATH: scripts/ci/CiChangeScope.psm1
```
