# Full Python Suite Baseline (P0-T34)

Timestamp: 2026-10-01T21-23
Task: P0-T34
Sequence: reset (both kinds), `.claude/state` listing, then pytest, run in one shell invocation with no Write or Edit in between.

## Step 1 — Batch-budget reset (both kinds, OD-484-2)

Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6)
Command: foreach ($k in @('python','powershell')) { $f=@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue); "$k removed=$($f.Count) " + (($f | ForEach-Object Name) -join ','); $f | Remove-Item -Force; "$k remaining=$(@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue).Count)" }
Output:

```
python removed=0 
python remaining=0
powershell removed=0 
powershell remaining=0
```

`.claude/state` listing (`Get-ChildItem -LiteralPath .claude/state -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object Name`): empty.

## Step 2 — Full suite

Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing
EXIT_CODE: 0

## Output Summary:

- Reset lines: `python remaining=0`, `powershell remaining=0`.
- Final line: `6029 passed, 6 skipped in 85.40s (0:01:25)`
- Passed 6029, failed 0, skipped 6.
- Failing node IDs: none.
- TOTAL row:

```
Name                                                                  Stmts   Miss Branch BrPart  Cover   Missing
TOTAL                                                                 17144   1117   6174    574    92%
```

- Skipped (6):
  - `tests/scripts/dev_tools/test_blast_radius_regression_452.py:483` (Issue #722 tolerance layer absent)
  - `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` x5 (manifest_m1_empty_frontmatter, manifest_m1_missing_opening_fence, manifest_m1_non_mapping_frontmatter, manifest_m1_unterminated_fence, manifest_m1_yaml_parse_failure: no accessor expectation declared)
