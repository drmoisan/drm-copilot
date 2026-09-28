# QA Gate — Additive-Only Verification, `atomic-plan-contract/SKILL.md` (Issue #586)

Timestamp: 2026-08-28T22-10

Task: [P2-T1]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
File under verification: `.claude/skills/atomic-plan-contract/SKILL.md`
Comparison ref: `main`

## Command 1 — deletion-count measurement

Command: git diff --numstat main -- .claude/skills/atomic-plan-contract/SKILL.md

EXIT_CODE: 0

Output Summary:

The command printed exactly one row, transcribed verbatim below (the two separators are tab characters):

```
28	0	.claude/skills/atomic-plan-contract/SKILL.md
```

Field breakdown of that row:

| Field | Position | Value |
| --- | --- | --- |
| Added lines | first tab-delimited field | `28` |
| Deleted lines | second tab-delimited field | `0` |
| Path | third tab-delimited field | `.claude/skills/atomic-plan-contract/SKILL.md` |

The deletion count, the second tab-delimited field, is `0`. The additive-only constraint stated in `## Design Constraints Binding Every Phase 1 Task` of the plan holds for this file: no line present in `main` was deleted or reworded.

The `--numstat` deletion column is the measured value rather than a count of diff-body lines beginning with a single `-`. For the record, a naive `grep -c "^-"` over the diff body of this same command returns `1`, and that single match is the `--- a/.claude/skills/atomic-plan-contract/SKILL.md` file header, not a deleted content line. That confirms the plan's stated reason for using the `--numstat` column: a leading-`-` scan is not a reliable deletion measure over a Markdown file composed largely of `- ` bullets.

## Command 2 — added line ranges

Command: git diff main -- .claude/skills/atomic-plan-contract/SKILL.md

EXIT_CODE: 0

Output Summary:

The diff carries two hunks and no deleted content line. Hunk headers as printed:

```
--- a/.claude/skills/atomic-plan-contract/SKILL.md
+++ b/.claude/skills/atomic-plan-contract/SKILL.md
@@ -139,6 +139,20 @@ For command-bearing tasks in approved plans (especially Phase 2 final-QC tasks):
@@ -149,6 +163,20 @@ When validating or handing off plans for execution:
```

Re-run with `-U0` to isolate the added spans exactly:

```
@@ -141,0 +142,14 @@ Any regression test task expected to fail must be tagged with `[expect-fail]` an
@@ -151,0 +166,14 @@ When validating or handing off plans for execution:
```

Added line ranges in the post-change file, which [P2-T5] consumes as its tonality-review scope:

| # | Post-change line range | Lines added | Content added |
| --- | --- | --- | --- |
| 1 | 142–155 | 14 | `## Planner Adversarial Self-Review (Mandatory)` section: heading, opening paragraph, `Rules:` lead-in, the two rule bullets written by [P1-T2] and [P1-T3], and the declaration requirement written by [P1-T4] |
| 2 | 166–179 | 14 | Extensions to `## Preflight Validation (Planner ↔ Executor)`: the `Review depth and reporting rules:` lead-in, the four rule bullets written by [P1-T5] through [P1-T8], and the convergence-signal block written by [P1-T9] |

Total added: 28 lines, matching the first field of the `--numstat` row. The old-side length of both `-U0` hunk headers is `0`, which is the same zero-deletion result reported independently by `--numstat`.

## Verdict

Deletion count against `main`: **0**. Gate passes.
