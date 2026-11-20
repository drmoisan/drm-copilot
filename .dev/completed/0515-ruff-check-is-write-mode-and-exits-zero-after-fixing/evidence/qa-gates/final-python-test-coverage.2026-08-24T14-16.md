# Final QA Gate — Python Tests and Coverage (P4-T4)

Timestamp: 2026-08-24T14-16

Task: [P4-T4]
Issue: #515
Stage: Toolchain stage 5 of 7 (unit tests), final QA loop, **pass 2**, coverage-enabled.

Command: `poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`

EXIT_CODE: 0

## Pass context — the pass-1 failure and its disposition

This is pass 2 of the Phase 4 loop. Pass 1 of this stage failed:

```text
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
================= 1 failed, 4115 passed, 5 skipped in 23.12s ==================
```

```text
E  AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

That failure is **filed issue #510**
(`docs/features/potential/promoted/2026-08-19-claude-resource-parity-enumerates-gitignored-state.md`).
The push-down parity walk enumerates the repository `.claude/**` tree with
`Path.rglob("*")` and does not read `.gitignore`, so a gitignored, session-scoped
batch-budget state file under `.claude/state/` is enumerated and reported as missing from
the distribution bundle. The filed issue's own Steps to Reproduce step 4 gives the remedy:
delete the state file and re-run.

The failure is not attributable to this plan's diff:

- The test's inputs are files under `.claude/**` and under the bundled resources tree.
  This plan's diff writes `pyproject.toml` and
  `tests/scripts/dev_tools/test_ruff_config_alignment.py`; neither is under `.claude/`.
- The triggering file was created by session tooling at 13:53, after the P0-T6 baseline
  run at 13:52 recorded 4112 passed and 0 failed against the same test.
- The file is gitignored at `.gitignore:68` (`.claude/state/`). Removing it left
  `git status --porcelain` byte-identical, confirming it is not a repository file and does
  not appear in this plan's diff.

Fixing issue #510 itself would require writing
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, which is outside
this plan's two-file scope lock and was not attempted. The gitignored state file was
removed and the loop was restarted from P4-T1 per this phase's restart rule.

## Test counts (pass 2)

```text
====================== 4116 passed, 5 skipped in 21.15s =======================
```

- Passed: **4116**
- Failed: **0**
- Errors: **0**
- Skipped: 5
- Exit code: **0**

The passed count reconciles exactly against the baseline: 4112 at P0-T6 plus the 4 tests
added by this plan's new module equals 4116, with no test lost and none newly failing.
The five skips are the same pre-existing, module-declared parametrized cases recorded at
P0-T6, all from `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`; they
are unrelated to this plan's scope and are neither failures nor errors.

## Coverage — numeric totals computed from `artifacts/python/coverage.json`

The `totals` block, verbatim:

```json
{"covered_lines": 13841, "num_statements": 14946, "percent_covered": 90.61949500880799, "percent_covered_display": "91", "missing_lines": 1105, "excluded_lines": 432, "percent_statements_covered": 92.60671751639235, "percent_statements_covered_display": "93", "num_branches": 5490, "num_partial_branches": 558, "covered_branches": 4678, "missing_branches": 812, "percent_branches_covered": 85.20947176684882, "percent_branches_covered_display": "85"}
```

Derived figures, computed exactly as this task specifies:

| Figure | Formula from `totals` | Operands | Value |
| --- | --- | --- | --- |
| **Total line coverage** | `covered_lines / num_statements` | 13841 / 14946 | **92.6067 %** |
| **Total branch coverage** | `covered_branches / num_branches` | 4678 / 5490 | **85.2095 %** |

Both are above the `.claude/rules/quality-tiers.md` thresholds: line 92.6067 % >= 85 %,
branch 85.2095 % >= 75 %.

## Term report `TOTAL` row (combined figure — NOT the line percent and NOT the branch percent)

Verbatim final row of the `term-missing` report:

```text
TOTAL                                                               14946   1105   5490    558    91%
```

That trailing **91 %** is coverage.py's combined `percent_covered` (90.6195 %, displayed as
91), which blends statements and branches into a single ratio. It is recorded here **only**
as the labelled combined figure and is deliberately not used as either headline number.
The line figure is 92.6067 % and the branch figure is 85.2095 %; both differ from 91 %,
which is why this task requires the JSON report rather than the term report.

## Artifact-location note

`artifacts/python/coverage.json` is tool output, not evidence. `artifacts/` is gitignored
at `.gitignore:6`, so writing it added no entry to any working-tree status snapshot and did
not perturb the P4-T2 or P4-T6 snapshot comparisons or the P5-T1 write-target union.

Output Summary: **4116 passed, 0 failed, 0 errors, 5 pre-existing declared skips; exit code
0. Total line coverage 92.6067 % (13841/14946). Total branch coverage 85.2095 %
(4678/5490). Term-report combined `TOTAL` row = 91 %, recorded as the combined figure
only.** Against the P0-T6 baseline of 92.6067 % line and 85.1913 % branch, line coverage is
unchanged and branch coverage rose marginally; the signed deltas are computed and verdicted
at P4-T5.
