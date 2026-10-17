# P10-T1 Coverage Comparison

Timestamp: 2026-10-10T00-26
Command: none - comparison of recorded values
EXIT_CODE: 0
Output Summary:
- Verdict: PASS (no negative PowerShell or Python delta; both PowerShell per-file values >= 85; UNCOVERED_CHANGED NONE)
- Inputs: P0-T16 evidence/baseline/python-coverage-values.2026-10-09T22-55.md; P9-T11 evidence/qa-gates/python-coverage-values.2026-10-10T00-15.md; P0-T21 evidence/baseline/powershell-coverage-values.2026-10-09T23-09.md (OPS-2); P9-T13 evidence/qa-gates/powershell-coverage-values.2026-10-10T00-22.md (OPS-2); P0-T26 evidence/baseline/jest-coverage.2026-10-09T23-11.md; P9-T14 evidence/qa-gates/jest-coverage.2026-10-10T00-23.md

## PowerShell (CI-sourced, OPS-2, baseline and final)

Source note: both the baseline and the final PowerShell figures are CI-sourced under OPS-2. Baseline: poshqc-test-results artifact of main CI run 38017407907 (PowerShell inputs identical to BASE_SHA). Final: poshqc-test-results artifact of branch CI run 38022356096 (tree-equivalent to HEAD for the PowerShell paths, per P9-T13 check 1). The MCP-runner figure (96.41, 127 source files) is non-authoritative and not used.

- BASE_PS_LINE: 88.0 (CI-sourced, OPS-2; SOURCEFILES 178)
- FINAL_PS_LINE: 88.63 (CI-sourced, OPS-2; SOURCEFILES 179)
- PowerShell repo line delta: +0.63
- BASE_HOOK_COV: 49.52 (CI-sourced, OPS-2)
- FINAL_HOOK_COV: 95.28 (CI-sourced, OPS-2)
- FINAL_HOOK_CHANGED_LINES: CHANGED_LINES 20 EXECUTABLE_CHANGED 7 UNCOVERED_CHANGED NONE
- FINAL_HELPER_COV: 100.0 (CI-sourced, OPS-2)
- New/changed-code coverage: .claude/hooks/feature-review-coverage-thresholds.ps1 100.0 (new file, whole-file value); .claude/hooks/validate-feature-review-coverage.ps1 95.28 file, changed lines UNCOVERED_CHANGED NONE
- Per-file floor check: 100.0 >= 85 and 95.28 >= 85. Met. PowerShell has no branch gate.

## Python

- BASE_PY_LINE: 93.68
- FINAL_PY_LINE: 93.68
- Python line delta: 0.00
- BASE_PY_BRANCH: 87.1
- FINAL_PY_BRANCH: 87.1
- Python branch delta: 0.00
- New/changed-code coverage: N/A - no production Python line changed

## TypeScript

- BASE_TS_LINES: 97.23
- FINAL_TS_LINES: 97.23
- BASE_TS_BRANCHES: 92.01
- FINAL_TS_BRANCHES: 92.01
- New/changed-code coverage: N/A - no TypeScript file changes

## Bash

- N/A - .codex/ is outside the kcov include roots (pre-existing, follow-up)

## Verdict

- No negative PowerShell delta (+0.63) and no negative Python delta (0.00 line, 0.00 branch).
- No per-file value below 85 (helper 100.0, hook 95.28).
- FINAL_HOOK_CHANGED_LINES UNCOVERED_CHANGED value is NONE.
- Verdict: PASS (not REMEDIATION-REQUIRED); AC-13 is not blocked by coverage.
