# Python coverage delta — [P10-T5] (AC-26)

Timestamp: 2026-09-29T20-52
Command: read `files[<key>].summary` and `missing_lines` from `artifacts/python/coverage.json` (written by [P10-T4]) for the three plan modules; read changed line numbers from `git diff -U0 9438bdf5253e10903e2e74eab5cf51df988e0466 -- scripts/dev_tools/push_down_claude_customizations.py`
EXIT_CODE: 0
Output Summary: all three modules are at or above 85% line and 75% branch coverage; the entry point is above its baseline on both measures; zero changed entry-point lines appear in `missing_lines`. PASS.

Anchor note: the diff uses the pinned [P0-T2] anchor SHA, which equals `git merge-base HEAD origin/epic/push-down-payload-correctness-integration` (see ANCHOR_DRIFT in `final-scope-guard.2026-09-29T20-50.md`). #763 did not change this file.

## Per-file values (post-change, from coverage.json)

| File | Lines | Line % | Branches | Branch % | missing_lines |
|---|---|---|---|---|---|
| scripts/dev_tools/push_down_exclusion_manifest.py | 104/104 | 100.00 | 34/34 | 100.00 | [] |
| scripts/dev_tools/push_down_claude_exclusion_filter.py | 99/100 | 99.00 | 15/16 | 93.75 | [330] |
| scripts/dev_tools/push_down_claude_customizations.py | 79/84 | 94.05 | 14/16 | 87.50 | [130, 131, 132, 133, 139] |

## Entry-point baseline comparison

| Measure | Baseline ([P0-T9]) | Post-change | Result |
|---|---|---|---|
| Line | 64/69 = 92.75 | 79/84 = 94.05 | not below baseline |
| Branch | 6/8 = 75.00 | 14/16 = 87.50 | not below baseline |

The two missing branches (`[131, 132]`, `[131, 133]`) are the arms of the pre-existing `dev_tools` import fallback (`except ModuleNotFoundError` at lines 129-139; baseline lines 100-109, shifted by 30 lines), which the plan identifies as uncoverable. Every conditional this plan added to the entry point has both arms exercised.

## Changed entry-point lines versus missing_lines

Changed line ranges on the new side (`git diff -U0` hunk headers): 32-41, 59-63, 73-82, 100-104, 146-148, 158, 160-162, 254, 295, 298, 321, 352-357, 360, 367-371, 492-494.
`missing_lines`: 130, 131, 132, 133, 139. Intersection: empty. Count of changed executable entry-point lines in `missing_lines`: 0.

The one missing line in `push_down_claude_exclusion_filter.py` (330, branch `[329, 330]`) is in a new module and is covered by the per-file thresholds (99.00 / 93.75); the "changed lines" condition in this task is defined over the entry point.
