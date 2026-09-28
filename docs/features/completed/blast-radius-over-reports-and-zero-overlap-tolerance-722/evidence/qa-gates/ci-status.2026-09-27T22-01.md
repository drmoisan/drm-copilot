# CI Status (P18-T6, AC-38)

Timestamp: 2026-09-27T22-01
Commands:
- gh -R drmoisan/drm-copilot pr checks 748
- gh -R drmoisan/drm-copilot run view 36367250815 --json conclusion,headSha,name
- gh -R drmoisan/drm-copilot pr view 748 --json mergeStateStatus,headRefOid
EXIT_CODE: 0 (all three)

## Summary

- Pull request: #748
- Head SHA: 74ae7b5eb95a3da422f8789bea5cc66668b15e79 (branch rebased onto main by the coordinator)
- `CI` workflow run 36367250815: conclusion `success`, headSha 74ae7b5eb95a3da422f8789bea5cc66668b15e79
- "Publish Extension to VS Code Marketplace" run 36367250424 (PR packaging check): all jobs pass
- `gh pr checks 748`: 19 pass, 0 fail, 0 pending
- windows-latest Pester job `poshqc / PowerShell QC`: pass (13m15s)
- mergeStateStatus: CLEAN

## Prior failure and fix

- On the earlier head f5d06476 the `poshqc / PowerShell QC` job failed with 35 Pester failures caused by
  a module-scope import defect.
- The defect was fixed by commit 9aca1ec6 ("fix(722): pass the conflict relation to the scheduling
  layer explicitly").
- Coordinator local verification: a fresh-process Pester run of tests/scripts/claude-lib/blast-radius
  reported 560 passed, 0 failed, 1 skipped (the intentional #452 'Tolerance branch' placeholder).

## gh pr checks 748 (head 74ae7b5e)

```text
Extension Tests (ubuntu-latest)	pass	31s	run 36367250424
Extension Tests (windows-latest)	pass	1m3s	run 36367250424
NPM Audit Gate / npm audit (.)	pass	19s	run 36367250815
NPM Audit Gate / npm audit (extensions/drm-copilot)	pass	16s	run 36367250815
NPM Audit Gate / npm audit (packages/mcp-server)	pass	13s	run 36367250815
Publish to Marketplace	pass	33s	run 36367250424
build-check / Build Package	pass	51s	run 36367250815
docs-validation / Documentation Validation	pass	8s	run 36367250815
drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	pass	35s	run 36367250815
drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	pass	1m10s	run 36367250815
poshqc / PowerShell QC	pass	13m15s	run 36367250815
quality-checks7 / Code Quality & Tests (3.10)	pass	4m51s	run 36367250815
quality-checks7 / Code Quality & Tests (3.11)	pass	4m33s	run 36367250815
quality-checks7 / Code Quality & Tests (3.12)	pass	4m23s	run 36367250815
quality-checks7 / Code Quality & Tests (3.13)	pass	3m10s	run 36367250815
root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	pass	35s	run 36367250815
root-typescript-tests / Root TypeScript Tests (windows-latest)	pass	1m14s	run 36367250815
security-scan / Security Scanning	pass	40s	run 36367250815
shell-coverage / Shell Coverage (Bats + kcov)	pass	8m15s	run 36367250815
```

## Result

AC-38 acceptance met: every run for head 74ae7b5e completed with conclusion success, no check is
pending or failing, and the windows-latest Pester job passes.
