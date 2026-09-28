# R1 Repo-Wide LINE Coverage Delta and Threshold Verification (cycle 1)

- Timestamp: 2026-09-17T14:02:35Z
- Command: `Get-Content -LiteralPath 'evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md'` and `Get-Content -LiteralPath 'evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md'`
- EXIT_CODE: 0

## Output Summary

- Prior baseline repo-wide LINE coverage percentage (`evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md`, covered=8914, missed=422): `95.48`
- New repo-wide LINE coverage percentage (`evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md`, `[P1-T4]`, covered=9155, missed=424): `95.57`
- Signed delta (new minus prior baseline): `95.57 - 95.48 = +0.09`
- `WorktreeResolution.psm1` LINE percentage: `98.59`
- `WorktreeTargetResolution.psm1` LINE percentage: `100.00`

Threshold results (all against `85.00`):

- Repo-wide LINE percentage `95.57` >= `85.00`: **PASS**
- `WorktreeResolution.psm1` LINE percentage `98.59` >= `85.00`: **PASS**
- `WorktreeTargetResolution.psm1` LINE percentage `100.00` >= `85.00`: **PASS**

All three stated results use the literal numeric values recorded by `[P1-T4]`, not an estimate. The
prior baseline was measured without the two new modules in its denominator (per
`evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md`); the new figure is measured with both
new modules in the repo-wide denominator, per the repo-wide self-hosted run performed in `[P1-T1]`.
