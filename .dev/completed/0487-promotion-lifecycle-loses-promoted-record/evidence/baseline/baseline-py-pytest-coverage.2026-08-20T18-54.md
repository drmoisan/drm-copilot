# Baseline — Python Tests and Coverage (Pytest) [P0-T19] and Defect-Assertion Confirmation [P0-T20]

Timestamp: 2026-08-20T18-54

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 0

Coverage-target note: the command uses the bare `--cov` form configured by the repository, not a `--cov=<path>.py` form. A filesystem-path `--cov` target collects no data and would produce a gate that cannot fail; it was not used here and is not used at P7-T9.

## Raw Output (relevant lines)

```
TOTAL                                                               14923   1105   5480    559    91%
====================== 4059 passed, 5 skipped in 22.76s =======================
```

Per-file row for the production file changed in Phase 4:

```
scripts\dev_tools\new_active_feature_folder_flow.py                   135     12     52      6    90%   73->76, 94, 262->274, 279, 281->292, 285->292, 356-373
```

## Output Summary [P0-T19]

**PASS.** Test counts: **4059 passed, 0 failed, 5 skipped** in 22.76s.

Numeric `TOTAL` coverage figures:

| Metric | Statements | Missing | Branches | Partial | Reported |
| --- | --- | --- | --- | --- | --- |
| TOTAL row | 14923 | 1105 | 5480 | 559 | **91%** |

Derived from the same TOTAL row:

- **Line coverage: 92.60%** — (14923 − 1105) / 14923 = 13818 / 14923.
- **Branch coverage: 89.80%** — (5480 − 559) / 5480 = 4921 / 5480.
- The `91%` figure printed in the TOTAL column is coverage.py's combined statement-plus-branch percentage under `--cov-branch`: (13818 + 4921) / (14923 + 5480) = 18739 / 20403 = 91.84%, truncated to 91%.

Both uniform thresholds are met at baseline: line 92.60% >= 85% and branch 89.80% >= 75%.

Baseline per-file figure for the one Python production file this change modifies, `scripts/dev_tools/new_active_feature_folder_flow.py`: 135 statements, 12 missing, 52 branches, 6 partial, **90%** combined. Derived line coverage 91.11% ((135 − 12) / 135); derived branch coverage 88.46% ((52 − 6) / 52). Missing regions at baseline: `73->76, 94, 262->274, 279, 281->292, 285->292, 356-373`. These figures are the comparison basis for P7-T11.

## Defect-Assertion Confirmation [P0-T20]

Both defect-codifying assertions are confirmed present at their cited anchors **before any change**:

1. **`tests/scripts/dev_tools/test_new_active_feature_folder.py:333`** — `assert potential_path not in fs.files`

   Verified by `sed -n '330,336p'` on that file. Line 333 reads exactly `    assert potential_path not in fs.files`, sitting between `assert result.potential_issue_path == expected_folder / "issue.md"` (line 332) and `assert fs.exists(expected_folder / "user-story.md")` (line 334). The assertion is on a single line and is not interpolated.

2. **`tests/scripts/dev_tools/test_new_active_feature_folder_part4.py:284`** — `assert active_file not in fs.files`

   Verified by `sed -n '281,287p'` on that file. Line 284 reads exactly `    assert active_file not in fs.files`, immediately following `assert result.potential_issue_path == expected_folder / "issue.md"` (line 283) and preceding the blank lines before `_auto_resolve_rejects_non_promoted_or_non_markdown_active_file`. The assertion is on a single line and is not interpolated.

Both assertions currently codify the defect (they assert the source is REMOVED). P1-T8 and P1-T9 invert them to assert retention; P4-T8 confirms the inverted assertions pass after the Phase 4 fix.
