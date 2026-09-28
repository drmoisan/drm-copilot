# File-Size Headroom at Cycle Entry — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P0-T10]
HEAD: `bcf2de15`

Command: `wc -l` over the nine paths listed in the plan's `## File-Size Facts at Cycle Entry` table,
run from the worktree root

EXIT_CODE: 0

Output Summary: All nine files measured on disk. Every measured line count equals the value the plan
states, so the plan's file-size table is accurate at cycle entry. Two files are at exactly 500 lines
with zero headroom (`.claude/hooks/enforce-parallel-drift-gate.ps1` and its Pester suite), which is
why Phase 1's split is sequenced before every behavioural fix. The cap is 500 lines; 500 does not
exceed the cap, so no file is currently in violation.

## Measured Line Counts and Headroom Against the 500-Line Cap

| File | Measured lines | Headroom | Plan's stated value | Match |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 500 | 0 | 500 | yes |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 500 | 0 | 500 | yes |
| `scripts/dev_tools/parallel_drift_detection.py` | 494 | 6 | 494 | yes |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` | 487 | 13 | 487 | yes |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 412 | 88 | 412 | yes |
| `tests/scripts/dev_tools/test_parallel_drift_detection.py` | 454 | 46 | 454 | yes |
| `scripts/dev_tools/parallel_drift_halt.py` | 283 | 217 | 283 | yes |
| `scripts/dev_tools/_parallel_drift_shape.py` | 241 | 259 | 241 | yes |
| `tests/scripts/dev_tools/parallel_drift_test_support.py` | 119 | 381 | 119 | yes |

## Raw Output

```
   500 .claude/hooks/enforce-parallel-drift-gate.ps1
   500 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
   494 scripts/dev_tools/parallel_drift_detection.py
   487 tests/scripts/dev_tools/test_parallel_drift_detection_cli.py
   412 scripts/dev_tools/parallel_drift_detection_cli.py
   454 tests/scripts/dev_tools/test_parallel_drift_detection.py
   283 scripts/dev_tools/parallel_drift_halt.py
   241 scripts/dev_tools/_parallel_drift_shape.py
   119 tests/scripts/dev_tools/parallel_drift_test_support.py
  3490 total
```
