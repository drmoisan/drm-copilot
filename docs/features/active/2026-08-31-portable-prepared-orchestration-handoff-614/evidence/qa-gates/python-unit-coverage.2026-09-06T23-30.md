# Python Unit Test and Coverage Gate — Issue #614 Remediation

Timestamp: 2026-09-07T02-30
Cycle: 2026-09-06T23-30
Task: [P4-T4]
Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

## 1. Test counts

```
====================== 4390 passed, 5 skipped in 19.69s =======================
```

Passed: 4390. Failed: 0. Skipped: 5.

## 2. `TOTAL` row, exactly as printed

```
TOTAL                                                               15772   1121   5740    578    91%
```

## 3. `scripts/dev_tools/orchestration_handoff_adapters.py` row, exactly as printed

```
scripts\dev_tools\orchestration_handoff_adapters.py                   128      0     22      0   100%
```

The `Name` column uses the platform separator, as stated in P0-T7. The `Missing` column is
empty and therefore contains none of 196, 198, 202, 210, or 215.

## 4. `.claude/state/` precondition observations (section 1.4)

Before, `git status --porcelain=v1 --untracked-files=all -- .claude`:

```
```

Before, `Get-ChildItem -LiteralPath .claude/state -Recurse -File -ErrorAction SilentlyContinue`:

```
```

After, `git status --porcelain=v1 --untracked-files=all -- .claude`:

```
```

After, `Get-ChildItem -LiteralPath .claude/state -Recurse -File -ErrorAction SilentlyContinue`:

```
```

The two `git status` observations are byte-identical, both being no rows. No file appeared
under `.claude/state/` during the run, so no removal was required.

## 5. Comparison against P0-T7

| Measure | P0-T7 baseline | P4-T4 | Requirement | Met |
|---|---|---|---|---|
| Passed | 4384 | 4390 | at least 4384 + 6 = 4390 | yes |
| Failed | 0 | 0 | zero | yes |
| `TOTAL` combined `Cover` | 91% | 91% | at least 91% | yes |
| `TOTAL` missed statements | 1126 | 1121 | not a gate; recorded | improved by 5 |
| `TOTAL` partial branches | 583 | 578 | not a gate; recorded | improved by 5 |
| Adapters module `Missing` | 196, 198, 202, 210, 215 | empty | none of those five | yes |
| Adapters module coverage | 93% | 100% | not a gate; recorded | improved by 7 points |
| `.claude` status before and after | identical, empty | identical, empty | byte-identical | yes |

The six added tests are the five parametrizations of
`test_projection_facts_diverging_from_the_envelope_are_rejected` and
`test_failure_precedence_matches_the_shared_registry`.

Output Summary: The full Python suite exits 0 with 4390 passed, 0 failed, and 5 skipped —
exactly six more passing tests than the baseline. Combined coverage holds at 91% with five
fewer missed statements and five fewer partial branches. The five projection-guard lines
are covered and the `.claude` precondition holds.
