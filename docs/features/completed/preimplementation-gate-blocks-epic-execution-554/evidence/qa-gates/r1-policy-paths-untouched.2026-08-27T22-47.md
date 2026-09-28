# Remediation Cycle 1 — Policy-Path Invariant

Timestamp: 2026-08-28T00-43
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T12]
Command: `git diff --name-only 1e991b86d78e4f979922b79268f19ca0e5ab19e3` unioned with `git ls-files --others --exclude-standard`, sorted and deduplicated, then counted against the three forbidden prefixes
EXIT_CODE: 0

## Base and union composition

Base: `1e991b86d78e4f979922b79268f19ca0e5ab19e3`, the merge base recorded at [P0-T3].

This task uses the **merge base**, not the branch head, because the invariant is about the whole
branch and not only about this remediation cycle: no file under the three policy prefixes may be
written by the branch at all. Using the branch head would prove only that this cycle added no such
file, leaving an earlier phase's write unobserved.

The untracked listing is part of the union so that a newly created, never-staged file under one of
those three prefixes is observed. The two-dot diff against the merge base already observes
uncommitted working-tree changes to tracked files, so only the untracked set has to be added.

Union size: **94 paths**.

## Counts against the three forbidden prefixes

| Prefix | Members in the union |
| --- | --- |
| `.claude/rules/` | **0** |
| `.claude/skills/` | **0** |
| `.github/` | **0** |

**No path in the union begins with any of the three prefixes.**

The `.github/` count of zero covers both `.github/instructions/` and the top-level
`.github/copilot-instructions.md`, which is the broader form the plan specifies and which is stricter
than checking the two named paths individually.

## Why the invariant binds

`CLAUDE.md` line 29 names `.github/copilot-instructions.md` and `.github/instructions/` as the
canonical policy source and states "Do not modify them." `.claude/skills/policy-compliance-order/SKILL.md`
restates the constraint as a hard baseline: "Do NOT modify policy documents under `.claude/rules/` or
`.github/instructions/`." `spec.md` §DECLARED BLAST RADIUS statement **(b)** makes the same claim for
this feature — "No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, and no
`.github/copilot-instructions.md`, is written by this feature" — and `spec.md` §Scope & Non-Goals
records that if any part of the fix appeared to require such an edit, that would be "a blocker to be
raised, not a task to be performed."

The epic kickoff contract gap identified in decision D3 is the one place the feature was tempted
toward a `SKILL.md` edit. It was not made: the gap is recommended for a separate issue and is
recorded under `evidence/other/` instead.

## Corresponding acceptance criterion

This measurement satisfies the `spec.md` acceptance criterion "No file whose path begins with
`.claude/rules/`, `.claude/skills/`, or `.github/` appears in `git diff --name-only` against the merge
base", which was already checked before this remediation cycle and remains satisfied. The union form
used here is strictly stronger than the criterion's diff-only form, because it additionally observes
untracked files.

Output Summary: The union of the merge-base diff and the untracked listing contains **94 paths** and
**zero** beginning with `.claude/rules/`, **zero** beginning with `.claude/skills/`, and **zero**
beginning with `.github/`. The policy-path invariant holds for the whole branch, not merely for this
remediation cycle. Exit code 0.
