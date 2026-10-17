# actionlint for _poshqc.yml after the Linux job (P3-T3)

Timestamp: 2026-10-01T16-37

Status: BLOCKED-OPERATOR-RUN (blocker B2)

The plan command `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` was not run; the binding operator decision of 2026-10-01 (Option A) prohibits running pwsh in this session. Operator command:

```
pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml
```

## Supplementary evidence (not a substitute for the wrapper)

Command: actionlint .github/workflows/_poshqc.yml
EXIT_CODE: 0
Output Summary: no output; actionlint 1.7.11 (binary on PATH) reported no finding for the workflow with the `poshqc-linux-hooks` job appended.

P3-T1 acceptance: `grep -c -F 'poshqc-linux-hooks:' .github/workflows/_poshqc.yml` printed `1`; `grep -c -F 'name: poshqc-linux-hook-test-results' .github/workflows/_poshqc.yml` printed `1`.
