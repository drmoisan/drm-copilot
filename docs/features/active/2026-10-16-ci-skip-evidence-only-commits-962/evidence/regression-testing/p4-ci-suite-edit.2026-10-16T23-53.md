# ci.yml gating and A2 decision (P4-T7)

Timestamp: 2026-10-16T23-53
Command: git diff --numstat HEAD -- tests/scripts/workflows/CiWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: ci.yml edited per G7: the `changes` (Change scope) and `full-run-marker` (CI full run) jobs are inserted directly after `jobs:`; the six required-context callers carry `needs: changes`, `if: ${{ !cancelled() }}`, and `run-heavy: ${{ needs.changes.outputs.code != 'false' }}`; `root-typescript-tests` and `npm-audit-gate` carry `needs: changes` and the code-not-false job condition; `docs-validation` is unchanged; the `on:` block is unchanged (verified by P4-T14). The latest edit-points artifact records `A2-APPLICABLE: no`, so the suite is not edited and numstat prints nothing. No PD-9 fix was needed.

A2 not applicable on this HEAD

## numstat output (tests/scripts/workflows/CiWorkflow.Tests.ps1)

```
```

(empty: the suite is unchanged)

## Supplementary: git diff --numstat HEAD -- .github/workflows (EXIT_CODE: 0)

```
18	0	.github/workflows/_build-check.yml
17	0	.github/workflows/_drm-copilot-extension-tests.yml
22	0	.github/workflows/_poshqc.yml
27	2	.github/workflows/_quality-checks.yml
21	1	.github/workflows/_security-scan.yml
20	1	.github/workflows/_shell-coverage.yml
70	0	.github/workflows/ci.yml
```
