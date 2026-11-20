# Acceptance criteria 6 and 10 re-checked after re-delivery

Timestamp: 2026-09-17T13-56

Task: `[P4-T11]` of `remediation-plan.2026-09-17T12-29.md`
Acceptance-criteria source:
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, section
`## Acceptance Criteria`.

Command:

- `Select-String -SimpleMatch -Pattern '- [x] The missing/malformed-marker branch is reached only when' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'`
- `Select-String -SimpleMatch -Pattern '- [x] Row — own folder named, cwd modelled as the session root' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'`
- `git merge-base --is-ancestor 1b150689c2d6bbda848ae10ec92e4ccc018a5560 HEAD`
- `git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`

EXIT_CODE: 0

- both `Select-String` invocations: 0
- `git merge-base --is-ancestor`: **0**, so the anchor precondition holds and the halt branch stated in
  `[P1-T5]` is not taken
- `git diff`: 0

Output Summary:

## The two acceptance searches

| search | match count | match line | required |
| --- | --- | --- | --- |
| `- [x] The missing/malformed-marker branch is reached only when` | **1** | 616 | exactly one |
| `- [x] Row — own folder named, cwd modelled as the session root` | **1** | 626 | exactly one |

Both quoted criterion texts carry `spec.md`'s exact spelling, including the em-dash in the criterion-10 token.
The token was constructed in the verifying script as `[char]0x2014` so the character's identity does not depend
on console rendering, and the match at line 626 confirms it.

## The transition is real, not an untouched baseline

The `[P0-T8]` artifact
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/ac-reversion.2026-09-17T13-56.md`
records the post-reversion state of both lines as **`- [ ]`**, measured with the same two searches in their
`- [ ]` form, each returning exactly one match at lines 616 and 626, and with the `- [x]` form returning zero
at that point.

The file therefore passed through the reverted state and returned to the checked state on exactly those two
characters. That is what makes the two searches above a genuine transition rather than a reading of the
baseline.

## Anchored diff — empty

`git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- <spec.md>` produced **no output**. Measured output line
count: **0**.

The empty diff is the proof of two things at once:

1. the `[P0-T8]` reversion was undone on exactly those two lines, since any residual `- [ ]` would appear as a
   hunk; and
2. **no criterion's prose changed**, since any wording edit anywhere in the file would also appear.

Git emitted the advisory `warning: in the working copy of '<spec.md>', CRLF will be replaced by LF the next
time Git touches it` on stderr. That is a line-ending advisory about the committed file and is not diff
output; the captured stdout was empty, which is the measured value recorded above.

## Evidence the re-check rests on

| criterion | line | re-checked on the evidence of | recorded in |
| --- | --- | --- | --- |
| 6 | 616 | `denies with the ambiguity reason when a repo-relative citation places in no worktree` matching exactly one node with no child `failure` in `[P4-T3]`, together with the delivered row `denies with the ambiguity reason when the folder is absent from the target root` | `evidence/qa-gates/final-qc-test.2026-09-17T13-56.md` |
| 10 | 626 | `allows a repo-relative citation placed in the item worktree` matching exactly one node with no child `failure` in `[P4-T3]` | `evidence/qa-gates/final-qc-test.2026-09-17T13-56.md` |

Both rows failed against the unmodified hook in `[P1-T7]` and pass against the changed hook in `[P2-T8]` and
`[P4-T3]`, so each criterion is supported by a fail-before / pass-after pair rather than by a single passing
run. The criterion-6 row's `[P1-T7]` failure message showed the hook producing the marker-is-broken reason,
which is precisely the misleading remedy criterion 6 forbids.

## Criteria deliberately left as they are

- **Criterion 37 (line 668) stays unchecked and was not re-worded.** Measured state: `- [ ]`. The PowerShell
  toolchain still does not reach a zero-failure pass in this worktree, because of the two environment-coupled
  failures recorded in the plan's failure-baseline section: a wall-clock and receipt-dependent node in
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, and a node reading ambient epic-checkpoint
  state in the Codex PreToolUse integration suite. Neither is in this remediation's change set, as `[P4-T6]`
  confirms, and neither may be edited by this plan.
- **Criterion 30 (line 655) stays checked and was not re-worded**, per the deferral `[P0-T7]` records at
  `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/remediation-scope-decisions.2026-09-17T13-56.md`.
  Measured state: `- [x]`.

## Item count

Total items between the `## Acceptance Criteria` heading at line 600 and the `## Risks & Mitigations` heading
at line 671: **38**. Checked: **37**. Unchecked: **1**, being criterion 37.

Acceptance: both searches return exactly one match; the `[P0-T8]` artifact is named and its recorded
post-reversion state reads `- [ ]` for both lines; and the anchored diff produces no output. Satisfied.
