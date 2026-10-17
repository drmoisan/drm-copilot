# P7-T10 Proof step P2.5: check runs on HEAD2

Timestamp: 2026-10-17T03-09
Command: gh api repos/drmoisan/drm-copilot/commits/a27ffadb4582c490a9facfdd1d6ac0af84412390/check-runs --paginate --jq .check_runs[] | [.name,.status,.conclusion] | @tsv
EXIT_CODE: 0
Output Summary: Check runs on HEAD2 listed verbatim; compared with the 11 required contexts.


## `gh api repos/drmoisan/drm-copilot/commits/a27ffadb4582c490a9facfdd1d6ac0af84412390/check-runs --paginate --jq .check_runs[] | [.name,.status,.conclusion] | @tsv`

exit: 0

```text
poshqc / PowerShell QC shard ${{ matrix.shard }}	completed	skipped
NPM Audit Gate	completed	skipped
poshqc / PowerShell QC static	completed	skipped
poshqc / PowerShell hook suites (Linux)	completed	skipped
CI full run	completed	skipped
root-typescript-tests	completed	skipped
poshqc / PowerShell QC	completed	success
quality-checks7 / Code Quality & Tests (3.11)	completed	success
quality-checks7 / Code Quality & Tests (3.12)	completed	success
quality-checks7 / Code Quality & Tests (3.10)	completed	success
drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	completed	success
quality-checks7 / Code Quality & Tests (3.13)	completed	success
shell-coverage / Shell Coverage (Bats + kcov)	completed	success
drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	completed	success
security-scan / Security Scanning	completed	success
build-check / Build Package	completed	success
docs-validation / Documentation Validation	completed	success
Change scope	completed	success
```
