# Acceptance Criteria Status — issue #672, remediation cycle 1

Timestamp: 2026-09-17T13-56

Task: `[P4-T12]` of `remediation-plan.2026-09-17T12-29.md`

Emitted as required at completion by `.claude/skills/acceptance-criteria-tracking/SKILL.md`.

## Source resolution

Work mode: `full-bug`. Per the AC source resolution table in
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves to **`spec.md` only**. No
`user-story.md` is expected or required for this mode, and none was consulted.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`
- Total AC items: **38**
- Checked off (delivered): **37**
- Remaining (unchecked): **1**
- Items remaining:
  - Criterion 37, `spec.md` line 668, verbatim:
    `The PowerShell toolchain (`run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test`) completes with zero format drift, zero analyzer findings, and zero test failures in a single pass, restarting from the first step after any failure or auto-fix.`

## Counting method

The total is the count of `- [ ]` and `- [x]` list items between the `## Acceptance Criteria` heading at
`spec.md` line **600** and the `## Risks & Mitigations` heading at line **671**. Both heading positions were
measured against the file rather than assumed.

The count was taken with `String.StartsWith('- [ ]')` and `String.StartsWith('- [x]')`, a literal comparison.
PowerShell's `-like` operator is **not** usable here: it treats `[` and `]` as a character-class delimiter, so
the pattern `- [ ]*` matches a dash followed by two spaces and returns a false zero. That false zero was
observed and corrected during `[P0-T8]`, and the correction is recorded in
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/ac-reversion.2026-09-17T13-56.md`.

Checked plus remaining: 37 + 1 = **38**, equal to the total.

## Criterion numbering, confirmed against five anchors

| criterion | measured `spec.md` line | anchor | state |
| --- | --- | --- | --- |
| 6 | 616 | the marker-is-broken-branch criterion, PARTIAL at review | `- [x]` |
| 10 | 626 | the own-folder / session-root-cwd row, PARTIAL at review | `- [x]` |
| 24 | 646 | F1 consumption | `- [x]` |
| 27 | 652 | behaviour-preserving move | `- [x]` |
| 30 | 655 | the R4-item-2 deferral | `- [x]` |
| 37 | 668 | the toolchain criterion left unchecked | `- [ ]` |

## Changes this remediation made to the checkbox state

| criterion | state at review | after `[P0-T8]` | after `[P4-T11]` |
| --- | --- | --- | --- |
| 6 | `- [x]`, evaluated PARTIAL | `- [ ]` | **`- [x]`** |
| 10 | `- [x]`, evaluated PARTIAL | `- [ ]` | **`- [x]`** |

Both were reverted to unchecked before re-delivery, because
`.claude/skills/acceptance-criteria-tracking/SKILL.md` requires an item evaluated PARTIAL to be left
unchecked, and both were re-checked only after the new regression rows passed in `[P4-T3]`. Each is supported
by a fail-before / pass-after pair: the rows failed against the unmodified hook in `[P1-T7]` and pass against
the changed hook in `[P2-T8]` and `[P4-T3]`.

No other criterion's checkbox state was changed by this remediation, and **no criterion's text was changed at
all**. The anchored diff recorded by `[P4-T11]`,
`git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- <spec.md>`, produces no output, which is the proof that
the file's prose is byte-identical to the pre-remediation committed text.

## Why criterion 37 remains unchecked

Criterion 37 requires the toolchain to complete with **zero test failures** in a single pass. The measured
repository-wide state is 2 failures, both environment-coupled and both present at the `[P0-T6]` pre-change
baseline:

1. a node in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` whose `name` contains
   `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, which is wall-clock and
   receipt-dependent and reads the real orchestrator checkpoint through an unmocked
   `Get-PrAuthorCheckpointContent` seam;
2. a node in the Codex PreToolUse integration suite whose `name` contains
   `allows every registered handler for every tool name its own matcher admits`, which reads ambient
   epic-checkpoint state.

Neither is in this remediation's change set — `[P4-T6]` measured zero occurrences of `enforce-pr-author-skill`
and of `.codex/` in both the anchored changed-file diff and the porcelain status — and the plan's deviation
protocol forbids editing either suite or their hooks. The criterion is therefore left unchecked rather than
satisfied by an out-of-scope edit or by relaxing its wording, and it is not re-worded.

The three other zero-conditions of criterion 37 **were** met: zero format drift (`[P4-T1]`, identical before
and after captures), zero analyzer findings (`[P4-T2]`, whole-tree count 0 and seven per-file zeros), and the
loop completing in a single pass with no step failing and no tracked file changed (`[P4-T10]`). Only the
zero-test-failures condition is unmet, and only for the two inherited causes above.

Acceptance: the total is 38, the checked and remaining counts sum to 38, the remaining count is 1, and the
single remaining item is criterion 37, quoted verbatim. Satisfied.
