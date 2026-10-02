# Baseline actionlint for _poshqc.yml (P0-T19)

Timestamp: 2026-10-01T16-13

Status: BLOCKED-OPERATOR-RUN (blocker B1)

The plan command `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` was not run. The binding operator decision of 2026-10-01 (Option A) prohibits running pwsh in any form in this session. Operator command:

```
pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml
```

## Supplementary evidence (not a substitute for the wrapper)

Command: actionlint .github/workflows/_poshqc.yml
EXIT_CODE: 0
Output Summary: no output; actionlint 1.7.11 (binary on PATH) reported no finding for the baseline workflow.
