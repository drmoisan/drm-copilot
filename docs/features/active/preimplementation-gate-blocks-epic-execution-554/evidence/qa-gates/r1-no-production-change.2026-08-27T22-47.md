# Remediation Cycle 1 — Test-Only Scope Invariant

Timestamp: 2026-08-28T00-42
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T11]
Command: `git diff --name-only 34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a` unioned with `git ls-files --others --exclude-standard`, sorted and deduplicated, then filtered
EXIT_CODE: 0

## Base and union composition

Base: `34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a`, the branch head recorded at [P0-T3].

The union is the **branch-head two-dot diff plus the untracked listing**, deliberately and not the
`origin/main...HEAD` three-dot form. The three-dot listing against `origin/main` names ten `.ps1`
paths, including all four gate-hook copies, all four modes-sibling copies, and both extension-resource
mirrors, because those are the branch's own production change from the execution phase. Asserting
"exactly two `.ps1` paths" against that base would be unsatisfiable and would say nothing about what
this remediation cycle did. The two-dot base isolates the remediation cycle's own writes, which is
the invariant this task exists to prove.

The untracked listing is part of the union because a newly created, never-staged file would not
appear in a diff. The two-dot diff against the branch head already observes uncommitted working-tree
changes to tracked files, so only the untracked set has to be added.

## The complete union — 26 paths

Twenty-four Markdown paths under
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/`, comprising the remediation
plan itself and twenty-three evidence artifacts under `evidence/remediation-baseline/` and
`evidence/qa-gates/`, plus the two `.ps1` paths below.

## Exactly two paths ending in `.ps1`

```text
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
```

Count of `.ps1` members of the union: **2**.

| Path | Disposition |
| --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **Edited in Phase 1** (R1, R3). Added by this branch; not a pre-existing suite. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | **Created in Phase 2** (R2, R4). New sibling suite. |

Both are test files under `tests/`. **Zero production `.ps1` files were written.**

## No path under the three forbidden prefixes

A count of union members matching `^(\.claude/hooks/|\.codex/hooks/|extensions/drm-copilot/resources/)`
returns **0**.

| Prefix | Members in the union |
| --- | --- |
| `.claude/hooks/` | **0** |
| `.codex/hooks/` | **0** |
| `extensions/drm-copilot/resources/` | **0** |

## The four `-helpers.ps1` copies are byte-untouched

Zero union members match `helpers.ps1`. Confirmed independently by object hash, comparing each
worktree file against its blob at the merge base `1e991b86d78e4f979922b79268f19ca0e5ab19e3`:

| Copy | Worktree blob | Merge-base blob | Identical |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **Yes** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **Yes** |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **Yes** |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **Yes** |

All four share one blob hash, so all four are byte-identical to each other and to their merge-base
state. This is the proof `spec.md` decision D1 relies on: the issue #539 orchestration-bookkeeping
staging exemption cannot have regressed if the file implementing it is byte-identical to the base.

## The pre-existing Claude mode-resolution suite is byte-untouched

Zero union members match
`claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`. The file the
remediation directive named as the R2 and R4 edit target is therefore **byte-untouched**, which is
the Scope Note outcome and a stronger result than the directive required. Its 494-line state measured
at [P0-T8] is unchanged, and its 83 tests pass in the [P3-T4] run.

Output Summary: The union of the branch-head diff and the untracked listing contains **exactly two
paths ending in `.ps1`** — the Codex mode-resolution suite edited in Phase 1 and the Claude classifier
suite created in Phase 2 — and **zero paths** under `.claude/hooks/`, `.codex/hooks/`, or
`extensions/drm-copilot/resources/`. The four `-helpers.ps1` copies are byte-untouched, confirmed by
identical object hashes against the merge base, and the pre-existing Claude mode-resolution suite is
byte-untouched. Zero production files changed. Exit code 0.
