# Coverage Comparison (P2-T15)

Timestamp: 2026-10-12T16-32
Task: P2-T15

## Python (scripts.dev_tools.generate_codex_agent_variants)
PY_BASE_PCT=89 (P0-T7, `evidence/baseline/python-coverage.2026-10-11T09-44.md`)
PY_POST_PCT=89 (P2-T8, `evidence/qa-gates/final-python-coverage.2026-10-11T09-44.md`)
PY_CHANGED_LINES=N/A (0 changed production Python lines, P2-T13)
PYTHON: PASS (PY_POST_PCT 89 is at least 85 and at least PY_BASE_PCT 89)

## PowerShell (.claude/lib/ci-gate/Invoke-CiGateParser.ps1)
PS_BASE_REF_PCT=97.83 (P0-T12)
PS_POST_PCT=PENDING-CI (P2-T14)
PS_CHANGED_EXECUTABLE_LINES=0
POWERSHELL: PENDING-CI (AC-9)

## Overall
Overall coverage verdict: PENDING-CI. It is not PASS while AC-9 is pending.
