# Deviation Record — `Get-ReconciliationReport` — R5 (M3)

Timestamp: 2026-08-26T03-58

Note on filename stamp: the remediation plan fixes every evidence filename for this cycle at the
stamp `2026-08-26T02-36`, matching the remediation-inputs stamp, because the plan's acceptance
conditions assert exact filenames. This execution ran later the same night, so the actual execution
stamp `2026-08-26T03-58` is recorded in the `Timestamp:` field above rather than in the filename.
The same substitution convention was used by the Phase 0 through Phase 3 artifacts of this cycle and
by the sibling record `evidence/other/marketplace-check-deferral.2026-08-26T02-05.md`.

Command: none. This is a recorded design decision, not a command result. This task changes no code.

EXIT_CODE: not applicable — no command was executed for this record.

## The function and its location

Function: **`Get-ReconciliationReport`**

Location: **`scripts/dev-tools/Invoke-ReleaseReconciliation.ps1`**, lines 113 through 158.

It is a pure function taking a tag-version string collection and a published-version string
collection and returning a `[pscustomobject]` carrying `UnpublishedVersion`, `Message`, and
`ExitCode`. It performs no external call, reads no file, and touches no network.

## What the deviation is

Task **P5-T1 of the original plan** (`plan.2026-08-24T08-39.md`, line 175) specified the contents of
`scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` as exactly two things:

1. the pure function `Get-UnpublishedTagVersion`, which returns the versions present in the tag set
   and absent from the published set; and
2. a dot-source guard, so the entry-point block does not execute when the file is dot-sourced.

`Get-ReconciliationReport` is neither of those. It is a third element, not named by that task and not
named anywhere else in the feature folder. The feature review recorded the search that established
this:

- SearchScope: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/`
  (recursive)
- SearchPatterns: `Get-ReconciliationReport` -> 0 files; `deviation` under `evidence/` -> 0 files
- SearchResult: none

The implementation therefore introduced a function the plan did not specify. That is the deviation
this record exists to make visible. No code is changed by this record; the function is correct and is
retained.

## Why the deviation was required

The extraction is directly required by the **Coverage Exclusion Policy** in
`.claude/rules/general-unit-test.md`, which states verbatim:

> The correct response to a file that contains untestable lines is to refactor it — extract all logic into host-neutral, testable modules and leave only the thinnest possible wiring in the host-bound entry point. The entry point's uncovered lines then represent a real and visible cost in the coverage metric, which creates ongoing pressure to keep those files minimal.

The entry-point block of `Invoke-ReleaseReconciliation.ps1` is host-bound: it runs only when the
script is invoked rather than dot-sourced, and under the repository's test-purity rules it cannot be
executed by a unit test. Before the extraction, the message composition and the exit-code decision
lived inside that block, so both were untestable by construction.

The policy names exactly one permitted response to that situation, and it is not exclusion. It is
refactoring: move the logic into host-neutral testable code and leave only wiring behind.
`Get-ReconciliationReport` is that move. After it, the entry-point block is three statements of pure
wiring — call the function, write its message, exit with its code — and every decision it used to
make is a pure function that the offline Pester suite exercises directly.

The function's own comment-based help records this rationale in place, stating that it exists so the
entry-point block "is nothing but wiring".

## The coverage measurement

Per-file line coverage for `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1`:

| Point in time | Line coverage |
|---|---|
| Before the extraction | **70.83 percent** |
| After the extraction | **88.89 percent** |

Both figures are recorded here as the historical before-and-after of the extraction, taken from the
feature-review record of finding M3.

The improvement was obtained by **making logic testable, not by excluding anything**. No entry was
added to any coverage exclusion list, and no line was removed from the coverage denominator. The
file's remaining uncovered lines are the host-bound entry-point block itself, which is precisely the
"real and visible cost" the quoted policy sentence intends to leave standing.

## Output Summary

The implementation deviated from original-plan task P5-T1 by adding a third element,
`Get-ReconciliationReport`, to `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1`, where that task
named only `Get-UnpublishedTagVersion` and the dot-source guard. The function appeared in zero files
across the feature folder before this record. The deviation was required by the Coverage Exclusion
Policy in `.claude/rules/general-unit-test.md`, whose governing sentence — "The correct response to a
file that contains untestable lines is to refactor it — extract all logic into host-neutral, testable
modules and leave only the thinnest possible wiring in the host-bound entry point." — permits
refactoring and prohibits exclusion as the response to untestable lines. The extraction raised the
file's per-file line coverage from 70.83 percent to 88.89 percent by making the message composition
and the exit-code decision testable, with no coverage exclusion added and no line removed from the
denominator. The function is retained; this record changes no code.
