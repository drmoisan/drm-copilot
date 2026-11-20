# Cycle-Entry Coverage Floor — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P0-T9]
HEAD: `bcf2de15`
Sources: the numbers captured in [P0-T5]
(`evidence/remediation-baseline/python-test-baseline.2026-08-09T00-01.md`) and [P0-T8]
(`evidence/remediation-baseline/powershell-test-baseline.2026-08-09T00-01.md`).

## Benchmark-Versus-Observed Table

One row per benchmark listed in the plan's `## Non-Regression Benchmarks` section.

| Surface | Metric | Stated benchmark | Observed this cycle | Match |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | line / branch | 100.00% (94/94) / 100.00% (32/32) | 100.00% (94/94) / 100.00% (32/32) | yes |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | line / branch | 100.00% (66/66) / 100.00% (6/6) | 100.00% (66/66) / 100.00% (6/6) | yes |
| `scripts/dev_tools/parallel_drift_halt.py` | line / branch | 100.00% (42/42) / 100.00% (6/6) | 100.00% (42/42) / 100.00% (6/6) | yes |
| `scripts/dev_tools/_parallel_drift_shape.py` | line / branch | 100.00% (40/40) / 100.00% (20/20) | 100.00% (40/40) / 100.00% (20/20) | yes |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | line / branch | 100.00% (41/41) / 100.00% (18/18) | 100.00% (41/41) / 100.00% (18/18) | yes |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | line / branch | 100.00% (44/44) / 100.00% (14/14) | 100.00% (44/44) / 100.00% (14/14) | yes |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | line / branch | 97.62% (82/84) / 94.12% (32/34) | 97.62% (82/84) / 94.12% (32/34) | yes |
| Python repo-wide | line / branch | 92.02% / 84.11% | 92.02% (12761/13868) / 84.11% (4286/5096) | yes |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | line | 96.53% (139 covered, 5 missed) | 96.53% (139 covered, 5 missed, 144 total) | yes |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | instruction | 96.57% (197 covered, 7 missed) | 96.57% (197 covered, 7 missed, 204 total) | yes |
| Python suite | absolute test outcome | 3176 passed | 3176 passed, 0 failed, 0 skipped | yes |
| PowerShell suite | absolute test outcome | 2080 passed / 1 failed / 9 skipped | 2080 passed / 1 failed / 9 skipped | yes |

Verdict: **every observed value matches its stated benchmark.** The cycle-entry re-capture reproduces
the plan's `## Non-Regression Benchmarks` table exactly, including both absolute suite-outcome rows.

## Discrepancy Records

No benchmark row differs from its stated value, so no row requires a `Discrepancy:` line for a
numeric mismatch. Two conditions are recorded for completeness because they affect how the figures
were obtained rather than what they are:

Discrepancy: none on any benchmark row. Both absolute suite-outcome rows reproduced exactly
(Python 3176 passed; PowerShell 2080 passed / 1 failed / 9 skipped), so the floor is unchanged and
Phase 8 compares against the figures stated in the plan, which equal the figures observed here.

Discrepancy (measurement path, not a benchmark value): the PowerShell per-file and report-level
coverage figures above were obtained from a repo-root `Invoke-PoshQCTest` invocation, because the
`mcp__drm-copilot__run_poshqc_test` invocation resolves its runsettings from the installed extension
bundle and therefore measures a 41-file denominator that omits
`.claude/hooks/enforce-parallel-drift-gate.ps1` and the five `.claude/lib/blast-radius/*.psm1`
modules. The full analysis is in the [P0-T8] artifact's `## Coverage-Denominator Divergence`
section. Test outcomes were identical between the two invocations. The benchmark figures in the plan,
not any re-captured value, remain the floor for Phase 8; this note records only that the PowerShell
per-file figure must be read from a 47-file-denominator report for the comparison to be meaningful.

## Floor Restatement for Phase 8

The following are the floors Phase 8 compares against. They are the plan's stated benchmarks, which
this re-capture confirmed rather than reset:

- All six pre-existing new Python drift modules: 100% line and 100% branch. No regression permitted.
- `scripts/dev_tools/validate_parallel_orchestrator_state.py`: 97.62% line / 94.12% branch.
- Python repo-wide: 92.02% line / 84.11% branch.
- `.claude/hooks/enforce-parallel-drift-gate.ps1`: 96.53% line, 96.57% instruction.
- Python suite: 3176 passed. Any module added this cycle raises the expected count; the floor is that
  no previously passing test fails.
- PowerShell suite: 2080 passed / 1 failed / 9 skipped, with the single failure being the named
  pre-existing `enforce-pr-author-skill.Tests.ps1` case.
- Every module created this cycle: line >= 85% and branch >= 75%, with 100% line and branch expected
  for new Python modules, consistent with the surrounding six.
- PowerShell branch coverage: not emitted by the toolchain. No value may be invented.
