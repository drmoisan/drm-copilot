# Coverage Delta — Final QC, Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P8-T10]
Sources: [P8-T4] (`evidence/qa-gates/python-test-final.2026-08-09T00-01.md`), [P8-T7]
(`evidence/qa-gates/powershell-test-final.2026-08-09T00-01.md`), and the cycle-entry floors
consolidated in [P0-T9] (`evidence/remediation-baseline/coverage-floor.2026-08-09T00-01.md`).

Measurement paths, stated per surface so the numbers are comparable:

- Python figures come from `poetry run pytest --cov --cov-branch --cov-report=term-missing`, with exact
  percentages taken from a `poetry run coverage json` export rather than the rounded `TOTAL` row.
- PowerShell figures come from the **repo-root `Invoke-PoshQCTest`** invocation, which resolves
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` from this worktree and measures the full
  48-file denominator. The `mcp__drm-copilot__run_poshqc_test` invocation resolves its runsettings from
  the installed extension bundle and measures a 41-file denominator that omits both drift-gate hooks,
  so its coverage numbers are not used here. Test outcomes were identical between the two.

## Per-Surface Comparison

| Surface | Metric | Cycle-entry ([P0-T9]) | Post-remediation ([P8-T4] / [P8-T7]) | Changed-code coverage | Verdict |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | line / branch | 100.00% (94/94) / 100.00% (32/32) | 100.00% (94/94) / 100.00% (32/32) | 100% — every line changed by [P2-T3] and [P4-T2] is covered | no regression |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | line / branch | 100.00% (66/66) / 100.00% (6/6) | 100.00% (74/74) / 100.00% (10/10) | 100% — all 8 added statements and 4 added branch arcs covered | no regression (larger denominator) |
| `scripts/dev_tools/parallel_drift_halt.py` | line / branch | 100.00% (42/42) / 100.00% (6/6) | 100.00% (42/42) / 100.00% (6/6) | n/a — docstring-only change ([P3-T2]) | no regression |
| `scripts/dev_tools/_parallel_drift_shape.py` | line / branch | 100.00% (40/40) / 100.00% (20/20) | 100.00% (51/51) / 100.00% (26/26) | 100% — all 11 added statements and 6 added branch arcs covered | no regression (larger denominator) |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | line / branch | 100.00% (41/41) / 100.00% (18/18) | 100.00% (41/41) / 100.00% (18/18) | n/a — unchanged | no regression |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | line / branch | 100.00% (44/44) / 100.00% (14/14) | 100.00% (44/44) / 100.00% (14/14) | n/a — unchanged | no regression |
| `scripts/dev_tools/parallel_drift_resolution.py` (created this cycle) | line / branch | absent | 100.00% (15/15) / 100.00% (0/0) | 100% — whole file is new | meets line >= 85% and branch >= 75% |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | line / branch | 97.62% (82/84) / 94.12% (32/34) | 97.62% (82/84) / 94.12% (32/34) | n/a — unmodified by this cycle ([P7-T3]) | no regression |
| Python repo-wide | line / branch | 92.02% / 84.11% | **92.04% (12795/13902) / 84.14% (4296/5106)** | — | improved (+0.02 line, +0.03 branch) |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` + `-helpers.ps1` **union** | line | 96.53% (139/144) | **96.97% (160/165)** | 100% — all 13 added measured lines covered | no regression (+0.44) |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` + `-helpers.ps1` **union** | instruction | 96.57% (197/204) | **97.02% (227/234)** | 100% | no regression (+0.45) |
| PowerShell branch | branch | not emitted | **not emitted** | — | no value invented |
| Python suite | absolute outcome | 3176 passed / 0 failed | **3201 passed / 0 failed** | — | floor cleared by 25 |
| PowerShell suite | absolute outcome | 2080 passed / 1 failed / 9 skipped | **2089 passed / 1 failed / 9 skipped** | — | floor met; failed count unchanged |

## The PowerShell Comparison Is Against the Union, Not Either File Alone

The 96.53% benchmark was captured at `bcf2de15`, when the measured surface was a **single** 144-line
file. Phase 1 split that file, moving 59 measurable lines to
`.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`. Comparing either post-split file alone against
a pre-split single-file benchmark would be an arithmetic error, not a coverage finding, so the
comparison is made against the **union** of the two files.

| File | LINE | INSTRUCTION |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 94.95% (94/99) | 94.53% (121/128) |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | 100.00% (66/66) | 100.00% (106/106) |
| **Union** | **160/165 = 96.97%** | **227/234 = 97.02%** |

Union progression across the cycle: 96.53% (139/144) pre-split, 96.58% (141/146) at [P1-T11], and
**96.97% (160/165)** now. The benchmark is cleared at every stage.

Both files also clear the uniform 85% line-coverage floor **independently**: 94.95% and 100.00%.

The hook's five uncovered lines are the same five as at cycle entry — the dot-source-guarded entrypoint
block, which cannot execute while the Pester suite dot-sources the file. The **count of uncovered lines
did not change** even though the hook gained 12 measured lines across [P5-T2] and [P5-T3] and the
helpers module gained 7 across [P4-T3] and [P5-T1]. Every one of those 19 added measured lines is
covered, which is why the union percentage rose rather than held.

## PowerShell Branch Coverage Is Not Emitted

Neither Pester v5 nor the PoshQC conversion step emits a `BRANCH` counter. The counter types present in
`artifacts/pester/powershell-coverage.xml` are exactly `CLASS`, `INSTRUCTION`, `LINE`, and `METHOD`,
verified by reading the report's counter elements directly. This is the condition recorded as F8-I2 at
the original baseline. INSTRUCTION coverage is the recorded analogue and is reported above.
**No PowerShell branch figure is invented, estimated, or substituted.**

## Absolute Suite-Outcome Rows Compared Against the Plan, Not the Re-Capture

Per the plan's instruction that a degraded re-capture cannot lower the floor, the two absolute rows are
compared against the figures stated in the plan's `## Non-Regression Benchmarks` section:

- **Python: floor 3176 passed.** Observed **3201 passed, 0 failed**. Cleared by 25. The 25 added tests
  are 3 resolution seam tests, 2 halt-exclusion tests, and 20 timestamp-contract cases. No previously
  passing test fails.
- **PowerShell: floor 2080 passed / 1 failed / 9 skipped.** Observed **2089 passed / 1 failed / 9
  skipped**. Passed rose by 9 from the tests this cycle added; skipped unchanged; **failed unchanged at
  1**, and it is the same named pre-existing case
  (`enforce-pr-author-skill.Tests.ps1:142`). Failed-count delta: **0**.

In this cycle the [P0-T9] re-capture reproduced both plan figures exactly, so the two reference points
coincide and no divergence between them had to be reconciled.

## Verdict

**No benchmark regressed.** Specifically:

- The six pre-existing new Python modules remain at **100% line and 100% branch**. Two of them
  (`parallel_drift_detection_cli.py`, `_parallel_drift_shape.py`) hold 100% on a **larger** measured
  denominator than at cycle entry, so the figure is not preserved by leaving code untested.
- Every module created this cycle meets line >= 85% and branch >= 75%: the one new Python module,
  `scripts/dev_tools/parallel_drift_resolution.py`, is at **100% line** and reports 100% branch on a
  legitimately zero branch denominator (both functions are straight-line; the figure is reported rather
  than invented). The one new PowerShell module,
  `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`, is at **100% line and 100% instruction**.
- `.claude/hooks/enforce-parallel-drift-gate.ps1` and its new sibling each meet line >= 85%
  (94.95% and 100.00%), and their union clears the 96.53% single-file benchmark at 96.97%.
- Python repo-wide line and branch coverage both **rose**.
- `validate_parallel_orchestrator_state.py` holds its 97.62% / 94.12% figure exactly, consistent with
  [P7-T3]'s finding that the file is unmodified by this cycle.
