# The Single Intended Assertion Reversal (issue #545)

Timestamp: 2026-09-07T11-52

Task: [P1-T12]

Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`

EXIT_CODE: 0

## Scope of this record

Exactly **two** `It` blocks reverse their expected decision in this change, one on each side. They
are the same scenario expressed in the two runtimes' idioms. No other existing assertion in either
decision suite changed.

## Reversal 1 — Claude side

| Field | Value |
| --- | --- |
| File path | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` |
| Line at authoring time | 246 |
| Describe | `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539)` |
| Context | `issue #539 residual whole-command-text behaviour (D3 and D8)` |
| `It` name (unchanged) | `denies a message-body payload that merely contains the staging literal` |
| Expected decision before | `deny` |
| Expected decision after | `allow` |
| Task that made the change | [P1-T8] |

## Reversal 2 — Codex side

| Field | Value |
| --- | --- |
| File path | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` |
| Line at authoring time | 250 |
| Describe | `Codex enforce-orchestration-preimplementation-gate command exemption (issue #539)` |
| Context | `issue #539 residual whole-command-text behaviour (D3 and D8)` |
| `It` name (unchanged) | `denies a message-body payload that merely contains the staging literal` |
| Expected decision before | `deny` |
| Expected decision after | `allow` |
| Task that made the change | [P1-T10] |

The two `It` names are identical, which is the intended cross-runtime correspondence.

## Why this reversal is correct rather than a weakened assertion

The reversed case drives a heredoc whose body quotes the staging invocation in prose and whose
destination is a **file**:

```
cat <<'NOTE' > docs/features/epics/2026-08-24-sample-epic/notes.md
Run git add docs/features/epics/2026-08-24-sample-epic/epic.md once the scaffold lands.
NOTE
```

`cat` is not a member of the wrapper carve-out set, so under issue #545 the heredoc body is masked
and the line is a mention rather than an invocation. The shell writes the text to a file; it never
executes a staging command. Issue #539 D8 declined to narrow the trigger, which is why the case
asserted deny; issue #545 narrows what text the byte-unchanged patterns are evaluated against, which
supersedes that outcome.

## The paired deny case added on each side, so the reversal is not a fail-open change

One new `It` was added immediately after each reversal, carrying the **identical** heredoc body and
differing only in its destination:

```
bash <<'NOTE'
git add docs/features/epics/2026-08-24-sample-epic/epic.md
NOTE
```

| Side | New `It` name | Expected | Result against the unfixed hook |
| --- | --- | --- | --- |
| Claude | `denies the same heredoc body when it feeds a shell wrapper instead of a file` | `deny` | **PASS** |
| Codex | `denies the same heredoc body when it feeds a shell wrapper instead of a file` | `deny` | **PASS** |

`bash` **is** a member of the wrapper carve-out set, so that segment scans raw, the body stays visible
to the trigger, and the staging command it carries is genuinely executed. The pair therefore
establishes that the reversal turns on whether the body executes, not on whether the text is present.

## No other existing assertion in either decision suite changed

Evidence, from the two fail-before runs:

| Suite | Cases before | Cases after | Failed after | Passed after |
| --- | --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 58 | 59 | 1 | 58 |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 58 | 59 | 1 | 58 |

On each side the case count rose by exactly one, and exactly one case fails. Were any other
assertion disturbed, either the count would differ or a second case would fail.

The diff of each file, filtered to lines containing `It '` or `Should -Be`, contains exactly three
changed lines: the one reversed expectation, the new `It` declaration, and the new case's
expectation. The remaining diff lines are the rewritten rationale comment, which [P1-T8] and [P1-T10]
require, and the new case's body.

One companion line was removed alongside each reversed expectation:
`$decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'`.
That removal is part of reversing the expected decision rather than a separate assertion change: an
allow decision carries no `permissionDecisionReason`, so retaining the line would assert against a
property the expected outcome does not have.

Assertions explicitly confirmed still passing, unmodified, on both sides: the issue #539 D4
fail-closed rule-table deny cases for rows 1 through 19 — including rows **14a, 14b, 14c, and 14d**,
the chained relocating denials — the orchestration-tree staging exemption allow cases, and the mixed
pathspec deny cases.

Output Summary: Exactly **two** `It` blocks reverse, one per side, both named `denies a message-body
payload that merely contains the staging literal`: Claude at
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
line 246, and Codex at
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
line 250. Both change their expected decision from `deny` to `allow`. **No other existing assertion in
either decision suite changed**, evidenced by each suite going from 58 to 59 cases with exactly one
failing case. One new wrapper-destination deny case was added per side and passes against the unfixed
hook.
