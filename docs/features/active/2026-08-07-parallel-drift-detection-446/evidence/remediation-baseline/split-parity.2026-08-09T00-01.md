# Phase 1 Split Parity — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P1-T11]
Purpose: prove that Phase 1's pure move plus wiring changed no behaviour, deleted no test, and cost
no coverage.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`

EXIT_CODE: 1

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Supplementary Command (per-file PowerShell coverage against the repository's declared 48-file
denominator; see the [P0-T8] artifact's `## Coverage-Denominator Divergence` section):
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

Supplementary EXIT_CODE: 1 (same single pre-existing failure)

## Output Summary

### Python — passed count and per-module coverage

- **3176 passed**, 0 failed, 0 errored, 0 skipped. The P0-T5 count was **3176**, so the post-split
  count is greater than or equal to it and there are **zero new failures**. The count is unchanged
  because Phase 1 moved tests between files rather than adding or removing any.
- Repo-wide: 92.02% line (12761/13868), 84.11% branch (4286/5096) — identical to the [P0-T5]
  baseline.
- The six pre-existing new drift modules are still at 100% line and 100% branch:

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | 100.00% (94/94) | 100.00% (32/32) |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 100.00% (66/66) | 100.00% (6/6) |
| `scripts/dev_tools/parallel_drift_halt.py` | 100.00% (42/42) | 100.00% (6/6) |
| `scripts/dev_tools/_parallel_drift_shape.py` | 100.00% (40/40) | 100.00% (20/20) |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | 100.00% (41/41) | 100.00% (18/18) |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | 100.00% (44/44) | 100.00% (14/14) |

### PowerShell — failed count and per-file coverage

- Pester counts: **2090 tests, 2080 passed, 1 failed, 9 skipped**. The [P0-T8] failed count was
  **1**; the post-split failed count is **1**, so it is unchanged. The single failure is the same
  pre-existing case, `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` at line 142. No new
  failure was introduced.
- Report-level: LINE 94.97% (3716/3913), INSTRUCTION 94.60% (5083/5373). No `BRANCH` counter is
  emitted; the counter types present are exactly `CLASS`, `INSTRUCTION`, `LINE`, `METHOD`.
- Per-file LINE coverage of the two drift-gate PowerShell files, each at or above 85%:

| File | LINE | INSTRUCTION |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | **94.25% (82/87)** | 93.69% (104/111) |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | **100.00% (59/59)** | 100.00% (95/95) |

### Recorded consequence of the split for the hook's per-file figure

The hook's per-file LINE coverage moved from 96.53% (139/144) before the split to 94.25% (82/87)
after it. This is an arithmetic consequence of the split, not a loss of tested behaviour:

- The five uncovered lines are the same five as before — the dot-source-guarded entrypoint block,
  which cannot execute while the suite dot-sources the file. The count of uncovered lines did not
  change.
- The measured denominator for that file shrank from 144 to 87 because 59 measurable lines moved to
  the sibling module, so the same five uncovered lines are now a larger fraction of a smaller file.
- Taken together, the two files now cover **141 of 146** measurable lines (96.58%), marginally above
  the pre-split 139 of 144 (96.53%). The two added lines are the dot-source pair, both covered.
- Both files independently satisfy the uniform line-coverage floor of 85%, which is what [P1-T11]
  requires. Phase 8's comparison against the 96.53% benchmark must be read against the union of the
  two files, because the benchmark was captured when the measured surface was a single file.

## Split Accounting (no test deleted, no fixture duplicated)

| Surface | Before | After | Check |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 500 lines | 306 lines | 194 lines headroom |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | absent | 249 lines | 251 lines headroom |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 500 lines, 47 `It` blocks | 322 lines, 31 `It` blocks | 178 lines headroom |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` | absent | 209 lines, 16 `It` blocks | 291 lines headroom |
| Sum of `It` blocks across the two Pester suites | 47 | 31 + 16 = **47** | equal |
| Expanded Pester test cases across the two suites | 59 | 59 | equal |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` | 487 lines, 20 `def test_` | 399 lines, 18 `def test_` | 101 lines headroom |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py` | absent | 61 lines, 2 `def test_` | 439 lines headroom |
| `tests/scripts/dev_tools/parallel_drift_test_support.py` | 119 lines | 187 lines | 313 lines headroom |
| Union of `def test_` names across the two Python CLI test files | 20 | 20, set-identical by `diff` | equal |

The seven moved PowerShell helper functions were verified byte-identical to their pre-move text by
diffing the pre-split hook's lines 145-348 against the new module's lines 46-249; the diff is empty.
The hook's remaining decision-path functions and entrypoint block were verified byte-identical the
same way, in two ranges.

## Deviation Recorded — shared fixture names

[P1-T9]'s acceptance names the three relocated fixtures `_in_flight`, `_checkpoint`, and `_evaluate`.
Relocating them into `parallel_drift_test_support.py` under those names produced nine Pyright errors:
`reportPrivateUsage` at each of the six import sites (a private name imported outside its declaring
module) and `reportUnusedFunction` at each of the three definitions. Pyright is a mandatory gate with
zero permitted errors, and `reportPrivateUsage` has no pre-authorized suppression in
`.claude/rules/python-suppressions.md`.

The fixtures were therefore renamed to the public forms `in_flight`, `checkpoint`, and `evaluate`,
matching the naming convention already used by that module's existing shared fixtures `radius`,
`item`, and `event`. The substance of the acceptance criterion is preserved exactly: each of the
three fixtures is defined **exactly once**, in `parallel_drift_test_support.py`, and imported by both
`test_parallel_drift_detection_cli.py` and `test_parallel_drift_detection_cli_halt.py`; no fixture is
duplicated across the two test files. Only the identifiers differ from the plan's wording.
