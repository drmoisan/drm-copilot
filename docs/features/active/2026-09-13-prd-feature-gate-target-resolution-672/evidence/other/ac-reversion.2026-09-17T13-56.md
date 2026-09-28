# Acceptance-criteria reversion before re-delivery

Timestamp: 2026-09-17T13-56

Task: `[P0-T8]` of `remediation-plan.2026-09-17T12-29.md`
Acceptance-criteria source:
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, section
`## Acceptance Criteria`.

Rationale: `.claude/skills/acceptance-criteria-tracking/SKILL.md` requires an item evaluated PARTIAL to be
left unchecked. The feature review evaluated criteria 6 and 10 PARTIAL, so both are reverted to `- [ ]` before
re-delivery and are re-checked only at `[P4-T11]`, on the evidence of the new regression rows passing.

Command:

- `Select-String -SimpleMatch -Pattern '- [ ] The missing/malformed-marker branch is reached only when' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'`
- `Select-String -SimpleMatch -Pattern '- [ ] Row — own folder named, cwd modelled as the session root' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'`
- the same two searches in their `- [x]` form, to confirm the checked spelling is now absent
- the item count between the two headings, computed with a literal prefix comparison
- `git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` and the same with `--numstat`

EXIT_CODE: 0 for every command.

Output Summary:

## Before and after checkbox states

| criterion | `spec.md` line | state before `[P0-T8]` | state after `[P0-T8]` |
| --- | --- | --- | --- |
| 6 | 616 | `- [x]` | **`- [ ]`** |
| 10 | 626 | `- [x]` | **`- [ ]`** |

Criterion 37 at line 668 was already `- [ ]` before this task and remains `- [ ]`. It was not re-worded.
Criterion 30 at line 655 remains `- [x]` per the deferral recorded by `[P0-T7]`.

## Acceptance searches

| search | match count | match line |
| --- | --- | --- |
| `- [ ] The missing/malformed-marker branch is reached only when` | **1** | 616 |
| `- [ ] Row — own folder named, cwd modelled as the session root` | **1** | 626 |
| `- [x] The missing/malformed-marker branch is reached only when` | **0** | n/a |
| `- [x] Row — own folder named, cwd modelled as the session root` | **0** | n/a |

Both required searches return exactly one match. The em-dash in the criterion-10 token is the character the
file carries; the token was constructed in the verifying script as `[char]0x2014` so the source of that
character is unambiguous rather than dependent on console rendering, and the match at line 626 confirms it.

## Item count between the two headings

- `## Acceptance Criteria` heading found at line **600**.
- `## Risks & Mitigations` heading found at line **671**.
- Items in the slice between them: unchecked **3**, checked **35**, **total 38**.

The total is still 38, so no item was added, removed, or reformatted. The three unchecked items are criteria
6, 10, and 37.

Note on the counting method, recorded because a first attempt produced a false zero. PowerShell's `-like`
operator treats `[` and `]` as a character-class delimiter, so the pattern `- [ ]*` matches a dash, a space,
and a further space rather than a literal checkbox, and it returned a count of 0 against a file that plainly
contains such items. The count above was produced with `String.StartsWith('- [ ]')` and
`String.StartsWith('- [x]')`, which perform a literal comparison. The `Select-String -SimpleMatch` searches
in the table above were never affected, because `-SimpleMatch` is already a literal comparison.

## Criterion numbering, re-confirmed against five anchors

Counting the 38 list items in file order reproduces every anchor the plan's preamble names, which confirms the
numbering used throughout this remediation:

| criterion | measured file line | plan's stated line | state |
| --- | --- | --- | --- |
| 6 | 616 | 616 | `- [ ]` |
| 10 | 626 | 626 | `- [ ]` |
| 24 (F1 consumption) | 646 | 646 | `- [x]` |
| 27 (behaviour-preserving move) | 652 | — | `- [x]` |
| 30 (the R4-item-2 deferral) | 655 | 655 | `- [x]` |
| 37 (the toolchain criterion) | 668 | 668 | `- [ ]` |

## Anchored diff against `$baselineHead`

`git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- <spec.md>` reports `--numstat` of **2 added, 2
removed**, in two hunks. Each hunk changes exactly one line, and on each the only differing characters are
inside the checkbox: `- [x]` becomes `- [ ]`. Every other character on both lines, including the em-dash and
the trailing prose, is unchanged, and no other line in the file is touched.

Git emitted the advisory `warning: in the working copy of '<spec.md>', CRLF will be replaced by LF the next
time Git touches it`. That is a line-ending advisory about the file as committed and is not a difference this
edit introduced; it is recorded so a later reader does not attribute it to the reversion.

## Consequence for `[P4-T11]`

`[P4-T11]` re-checks both lines and then asserts that
`git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- <spec.md>` produces **no output**. The post-reversion
state recorded in this artifact reads `- [ ]` for both lines, which is what makes that empty diff a real
transition rather than an untouched baseline: the file must pass through the reverted state and return to the
committed text on exactly those two characters.

Acceptance: both required searches return exactly one match; the item total between the two headings is still
38; and the before and after checkbox states of both lines are recorded above. Satisfied.
