# [P7-T1] / [P7-T2] [expect-fail] Gap 2 PowerShell fail-before

Timestamp: 2026-08-08T16-05
Tasks: [P7-T1] (inversion), [P7-T2] (matrix, appended below)

Both runs were taken against the unmodified `Test-EntryOverlap` in
`.claude/lib/blast-radius/BlastRadiusGlob.psm1`. [P7-T3] and [P7-T4] have not yet been applied.

Command (both runs):

```
pwsh -NoProfile -Command "$c = New-PesterConfiguration; $c.Run.Path = 'tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1'; $c.Output.Verbosity = 'Detailed'; $c.Run.PassThru = $true; Invoke-Pester -Configuration $c"
```

## [P7-T1] — the inverted `It`

EXIT_CODE: 1

Output Summary: `Tests Passed: 34, Failed: 1`. The single failure is the inverted block:

```
[-] treats a directory entry as overlapping a file beneath it 22ms
    Expected $true, but got $false.
```

The block previously at `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1:309-316`
read `It 'does not treat a directory entry as overlapping a file beneath it'` and asserted
`$overlap | Should -BeFalse`, encoding the Gap 2 defect as intended behaviour. It is now
`It 'treats a directory entry as overlapping a file beneath it'` asserting `Should -BeTrue`, with
a rationale comment citing issue #452 and the `Test-PathSubsumed` alignment.

No `It` asserting the old behaviour remains: `grep -c "does not treat a directory entry"` returns
`0` for that file.

This is the first of the two authorized assertion inversions named in `spec.md` invariant 3
(lines 214-218). The second is `BlastRadius.Tests.ps1:248-262`, inverted at [P5-T5].

## [P7-T2] — the remaining ten-case matrix (appended)

EXIT_CODE: 1

Output Summary: `Tests Passed: 38, Failed: 7`. The ten cases were added as two Pester
`It ... -TestCases @(...)` data tables in a new
`Context 'Directory containment, added by issue #452'` inside the existing
`Describe 'Test-EntryOverlap'` block. Each case asserts both argument orders, so ten cases cover
twenty evaluations.

Six `$true` cases, all failing against the unmodified relation:

| `EntryA` | `EntryB` | Expected | Actual |
| --- | --- | --- | --- |
| `scripts/dev_tools` | `scripts/dev_tools/a.py` | `$true` | `$false` |
| `scripts/dev_tools/` | `scripts/dev_tools/a.py` | `$true` | `$false` |
| `docs` | `docs/features/active/x/spec.md` | `$true` | `$false` |
| `scripts/dev_tools` | `scripts/dev_tools/**` | `$true` | `$false` |
| `scripts/dev_tools` | `scripts/dev_tools/*.py` | `$true` | `$false` |
| `scripts/dev_tools` | `scripts/*/a.py` | `$true` | `$false` |

Four `$false` regression guards, all passing against the unmodified relation:

| `EntryA` | `EntryB` | Expected | Actual |
| --- | --- | --- | --- |
| `scripts/dev_tools` | `scripts/dev_toolsX/a.py` | `$false` | `$false` |
| `scripts/dev_tools/a.py` | `scripts/dev_tools/b.py` | `$false` | `$false` |
| `docs/features/active/alpha` | `docs/features/active/beta/**` | `$false` | `$false` |
| `scripts/a.py` | `tests/**` | `$false` | `$false` |

The ten input pairs match the Python cases in
`tests/scripts/dev_tools/test_blast_radius_conflicts.py` one for one: the six `$true` pairs are
`OVERLAPPING_ENTRY_PAIRS` from [P6-T1] and the four `$false` pairs are `DISJOINT_ENTRY_PAIRS`
from [P6-T2].

## File size

`tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1` is 435 lines after both edits,
at or below the 500-line limit. The conditional split into
`tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Overlap.Tests.ps1` described in [P7-T2] was
therefore not required and was not performed; no new test file was created, and no manifest,
runsettings, or pack-manifest change was needed.

Output Summary: seven failures against the unmodified `Test-EntryOverlap` — the [P7-T1] inverted
`It` plus the six [P7-T2] `$true` cases — with the four `$false` regression guards already
passing. The containing file is 435 lines, so no sibling test file was created.
