# Criterion 24 — no local re-implementation, re-asserted after the Phase 2 edits

Timestamp: 2026-09-17T13-56

Task: `[P2-T4]` of `remediation-plan.2026-09-17T12-29.md`

This is the verification task `[P0-T7]` names for **R3**. With the pre-filter deleted by `[P2-T2]`, the hook
holds no local decision about which calls are eligible for derivation, and this task measures that property
rather than asserting it.

Criterion 24 (`spec.md` line 646) requires that neither delivered production file contains worktree-discovery
logic — `git worktree`, `Get-Location`, `$PWD`, or a `Resolve-Path`-derived root — and that neither defines its
own ambiguity code literal. The ambiguity-code half is measured by `[P2-T3]`; the four worktree-discovery
tokens are measured here.

Command, run once per token:
`Select-String -SimpleMatch -Pattern '<token>' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1','.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'`

and once per token against the control file the delivery plan fixed for it.

EXIT_CODE: 0 for every invocation.

Output Summary:

| # | token | count across both target files | control file | control count | control match lines | verdict |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `git worktree` | **0** | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | **5** | 3, 7, 145, 147, 414 | **OK** |
| 2 | `Get-Location` | **0** | `.claude/hooks/persist-session-id.ps1` | **1** | 161 | **OK** |
| 3 | `$PWD` | **0** | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | **2** | 75, 291 | **OK** |
| 4 | `Resolve-Path` | **0** | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | **2** | 9, 10 | **OK** |

All four target counts are **0**. All four control counts are **non-zero**.

The controls are what make the four zeros real assertions rather than searches for tokens that appear nowhere
in the repository. Each control is a tracked file in which the same token demonstrably occurs, so a zero
against the two target files is evidence about the target files and not about the search.

Control row 2 is the one the round-1 preflight delta D8 addressed: the task previously named a fifth token,
`New-Item`, which had no asserted counterpart. With that stray token dropped, `Get-Location` occurring once in
`.claude/hooks/persist-session-id.ps1` keeps this control non-zero, which the measurement above confirms at
line 161.

## Why the property still holds after the Phase 2 edits

`[P2-T2]` deleted the pre-filter and rewrote a `.DESCRIPTION` paragraph. `[P2-T3]` rewrote a
`.DESCRIPTION` resolution-order block. `[P2-T5]` rewrites one sentence of the helpers sibling's file-level
`.DESCRIPTION`. None of those edits adds executable code to either file, and the deletion removes the only
local eligibility decision either file held. The two files continue to consume target derivation, path
normalisation, and the ambiguity reason code from F1's `.claude/lib/` module through the established
`Import-Module` form.

Acceptance: all four target counts are 0 and all four control counts are non-zero, recorded above as
integers. Satisfied.
