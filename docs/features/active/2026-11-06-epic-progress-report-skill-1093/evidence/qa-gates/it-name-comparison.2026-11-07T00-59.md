# QA Gate: It-Name Comparison — Issue #1093

Timestamp: 2026-11-07T00-59
Command: sh SCRATCH/issue-1093-itcompare.sh <two merged suites at the merge base> <five relocated and split suites under tests/scripts/claude-skills/epic-progress-report/> (PowerShell 7: the merged suites are read with `git show <merge base of origin/main and HEAD>:<path>`, the relocated suites from the working tree; every `It` name is parsed from the AST and compared as a set)
EXIT_CODE: 0
Output Summary: 106 P0-T3 names; 105 present unchanged in the relocated suites; the only name not present is `defaults the state path under the temporary root and outside the repository`, which maps to `defaults the state path under .claude/state of the repository root`; 31 names are new; no duplicates.

## Inputs

- Base (P0-T3 inventory, `evidence/baseline/it-name-inventory.2026-11-06T23-51.md`): `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` (74) and `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (32), 106 names.
- Current, under `tests/scripts/claude-skills/epic-progress-report/`: `Get-EpicProgressReport.Logic.Tests.ps1` (38), `Get-EpicProgressReport.Metrics.Tests.ps1` (20), `Get-EpicProgressReport.Render.Tests.ps1` (14), `Get-EpicProgressReport.State.Tests.ps1` (31), `Get-EpicProgressReport.Tests.ps1` (33): 136 names. The skill contract suite in the same folder is new and holds none of the P0-T3 names, so it is not part of the comparison.

## P0-T3 names not present in the relocated suites

| P0-T3 name | Mapped to |
|---|---|
| `defaults the state path under the temporary root and outside the repository` | `defaults the state path under .claude/state of the repository root` (State suite; DEC-3 changes the default) |

All other 105 P0-T3 names are present with the same text.

## New names (31)

- Metrics: `prints n/a hrs to no upper bound for zero-rate intervals`; `returns NaN for exactly 2 intervals and a finite value for 3 or more`.
- Render: `prints no NaN or Infinity before the first task completes`.
- State: `defaults the state path under .claude/state of the repository root`; `reads a legacy sample array`; `reads a version-1 document`; `treats blank text as empty state`; `treats unparseable text as empty state`; `treats an unknown version as empty state`; `treats missing fields as absent`; `round-trips integer epoch seconds`; `writes a single sample as an array and skips samples without ts`; `prefers passed values`; `uses stored values`; `resets to now and the current done count`; `keeps a passed start on reset`; `throws without a start and without reset`; `keeps the weekly baseline on reset`; `defaults the baseline done count to 0 without a passed or stored value`; `keeps s13, s11, s9, s7, s5, s3 and s1 of 14 samples`; `reduces 13 samples to 7`; `reduces 2 samples to 1`; `leaves 1 and 0 samples unchanged`; `leaves 4 samples after two applications to 14`; `reproduces the recorded 5-minute to 10-minute example`.
- Entry: `throws before any git call without a passed or stored start`; `uses the stored start when -StartUtc is absent`; `clears stored samples and writes the resolved baseline with -ResetBaseline`; `rewrites the stored samples in pairs with -PairSamples`; `throws before any I/O when -ResetBaseline and -PairSamples are combined`; `prints the Full golden for a legacy four-sample state`.

Duplicates in the current set: 0.
