# Python Test and Coverage — Final QC, Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P8-T4]

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Output Summary

- Outcome: **3201 passed**, 0 failed, 0 errored, 0 skipped.
- Repo-wide: **92.04% line (12795/13902)**, **84.14% branch (4296/5106)**. Exact figures were taken
  from a `poetry run coverage json` export rather than from the rounded `TOTAL` row of the
  `term-missing` table, which reports a single combined `90%` when `--cov-branch` is active.
- The bundled-mirror test
  `test_push_down_claude_resource_contracts.py :: test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
  which failed at [P4-T7] and [P5-T6] because the mirror was stale, now **passes**: [P7-T1]
  re-established byte-identical mirroring after the last content change to the two drift-gate `.ps1`
  files and to SKILL.md.

### Suite-outcome comparison against the floor

| Reference | Passed | Failed |
| --- | --- | --- |
| Plan `## Non-Regression Benchmarks` floor | 3176 | 0 |
| [P0-T9] cycle-entry re-capture | 3176 | 0 |
| [P3-T9] end of Phase 3 | 3181 | 0 |
| **This run** | **3201** | **0** |

The floor is **cleared by 25 tests** and no previously passing test fails. The 25 added tests are:
three resolution seam tests ([P2-T5], [P2-T6], [P2-T7]), two halt-exclusion tests ([P3-T5], [P3-T6]),
and twenty timestamp-contract cases ([P4-T4]'s parametrized matrix plus its two focused tests, and
[P4-T5]'s `default_timestamp` binding test) in the new file
`tests/scripts/dev_tools/test_parallel_drift_timestamps.py`.

### Per-file line and branch coverage, all seven in-scope production modules

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | **100.00% (94/94)** | **100.00% (32/32)** |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | **100.00% (74/74)** | **100.00% (10/10)** |
| `scripts/dev_tools/parallel_drift_halt.py` | **100.00% (42/42)** | **100.00% (6/6)** |
| `scripts/dev_tools/parallel_drift_resolution.py` | **100.00% (15/15)** | **100.00% (0/0)** |
| `scripts/dev_tools/_parallel_drift_shape.py` | **100.00% (51/51)** | **100.00% (26/26)** |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | **100.00% (41/41)** | **100.00% (18/18)** |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | **100.00% (44/44)** | **100.00% (14/14)** |

All seven are at 100% line and 100% branch. `parallel_drift_resolution.py` reports a branch
denominator of zero because both of its functions are straight-line; the figure is reported as 100%
on a zero denominator rather than invented.

Two modules grew their measured denominator this cycle and remain fully covered, so the 100% figure is
on a larger surface rather than an unchanged one:

- `_parallel_drift_shape.py`: statements 40 to **51**, branches 20 to **26**, with [P4-T1]'s
  `CANONICAL_TIMESTAMP_RE` and `is_later_canonical_timestamp`.
- `parallel_drift_detection_cli.py`: statements 66 to **74**, branches 6 to **10**, with [P2-T4]'s
  `observed_radius` payload key and [P3-T1]'s drifting-item exclusion. Every added branch arc is
  exercised; no zero-candidate branch was written, so no unreachable arc exists.

The adjacent validator that F8 dispatches from holds its cycle-entry figure exactly:

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 97.62% (82/84) | 94.12% (32/34) |
