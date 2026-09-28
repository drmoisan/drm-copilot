# Observable PowerShell Test and Coverage Baseline — [P0-T11]

Timestamp: 2026-08-28T12-46

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`, followed by a read of the JaCoCo `LINE` counter of the `sourcefile` element named `BlastRadius.psm1` in the Pester coverage XML under artifacts/pester

EXIT_CODE: 0

ExpectedExitCode: 0

The self-hosted invocation is used in addition to the MCP tool because the MCP result payload carries
only an `ok` flag and a fixed `summary` string and returns no counts and no coverage.

## Verbatim `Tests Passed:` Line

```
Tests Passed: 3837, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

| Category | Count |
| --- | --- |
| Passed | 3837 |
| Failed | 0 |
| Skipped | 9 |
| Inconclusive | 0 |
| NotRun | 0 |

## Verbatim `Covered` Line

```
Covered 94.19% / 0%. 10,563 analyzed Commands in 88 Files.
```

This is the repository-wide combined figure. The second percentage is the target threshold rendering
and is not a per-file value.

## Failing Tests

None. The `Failed:` count is 0, so no test is named with a file and line. The baseline failing set is
the empty set.

## Per-File Line Coverage for the Blast-Radius Module

Read from the JaCoCo `LINE` counter under the `sourcefile` element named `BlastRadius.psm1` in
`artifacts/pester/powershell-coverage.xml`:

```
SOURCEFILE: BlastRadius.psm1
  INSTRUCTION missed=0 covered=165
  LINE missed=0 covered=109
  METHOD missed=0 covered=8
  CLASS missed=0 covered=1
```

| Counter | Missed | Covered | Implied percentage |
| --- | --- | --- | --- |
| LINE | 0 | 109 | 109 / (0 + 109) = **100 percent** |

The baseline line-coverage value for `.claude/lib/blast-radius/BlastRadius.psm1` is therefore **100
percent**, which is at or above the uniform 85 percent line threshold. No branch-coverage value is
recorded because Pester does not measure branch coverage.

## Deviation from Verified Fact 13

The plan's verified fact 13 records a single current Pester failure in the Codex PreToolUse
integration suite, caused by the orchestration checkpoint's route identifier, and describes it as
environmental and checkpoint-dependent. That failure is **not** present in this baseline run: the
`Failed:` count is 0. The fact is recorded here as no longer reproducing in this worktree rather than
silently dropped, because the plan's downstream tasks are calibrated against it.

The consequence carried forward: [P4-T5] and [P6-T8] are judged against a baseline failing count of
**0** and an empty baseline failing set. Their acceptance condition that the failed count be "not
higher than that baseline" therefore requires a failed count of exactly 0, and the clause naming a
pre-existing failing test is not exercised. The baseline passed count is **3837**, so [P4-T5] and
[P6-T8] each require a passed count of exactly **3839**, two higher than this baseline.

Output Summary: `EXIT_CODE: 0` with `ExpectedExitCode: 0`. The verbatim `Tests Passed:` line reports
3837 passed, 0 failed, 9 skipped, 0 inconclusive, and 0 not-run. The verbatim `Covered` line reports
`Covered 94.19% / 0%. 10,563 analyzed Commands in 88 Files.` for the repository as a whole. The
JaCoCo `LINE` counter for the `BlastRadius.psm1` sourcefile records missed 0 and covered 109, which
implies 100 percent line coverage for `.claude/lib/blast-radius/BlastRadius.psm1`. No test failed, so
no failing test is named. The baseline passed count 3837 and the baseline line-coverage value 100
percent are the values against which [P4-T5] and [P6-T8] are judged.
