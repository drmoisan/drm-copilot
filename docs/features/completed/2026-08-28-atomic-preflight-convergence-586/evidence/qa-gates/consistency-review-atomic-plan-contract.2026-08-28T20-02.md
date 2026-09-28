# QA Gate — Internal-Consistency Review, `atomic-plan-contract/SKILL.md` (Issue #586)

Timestamp: 2026-08-28T22-10

Task: [P2-T3]
Reviewer: atomic-executor
Files Reviewed: `.claude/skills/atomic-plan-contract/SKILL.md` (post-change, 247 lines), read end to end

Contradictions Found: 0

## Command — post-change heading list

Command: git grep -n "^## " -- .claude/skills/atomic-plan-contract/SKILL.md

EXIT_CODE: 0

Output Summary:

The command printed 18 entries. This is the 17 baseline headings transcribed in the [P0-T3] artifact plus `## Planner Adversarial Self-Review (Mandatory)` added by [P1-T1]. Entries as printed, with line numbers:

```
10:## When to Use This Skill
17:## Canonical Plan Format
24:## Short-Path Minimal Plan Contract
53:## Minimal-Audit Directive Contract (Small Path)
69:## Phase-0-Only Execution Contract (Small Path)
79:## Phase 0 Requirements
92:## Non-Overridable Evidence Path Clause
107:## Coverage Evidence Contract (Mandatory when policy requires coverage)
119:## Final QA Loop (Required for Code/Test Changes)
131:## No-SKIPPED Rule for Planned Command Tasks
138:## Expect-Fail Test Tasks
142:## Planner Adversarial Self-Review (Mandatory)
156:## Preflight Validation (Planner ↔ Executor)
180:## Validator Gate (Mandatory)
192:## Wrap-Tolerant Assertion Authoring (Mandatory)
212:## Plan-Path Continuity Contract (Mandatory)
222:## Mode source precedence (Mandatory)
234:## Mode-Specific Mandatory Plan Gates
```

## Checks Performed — literal-to-section derivation

Each literal's line number was obtained with `git grep -n -F <literal> -- .claude/skills/atomic-plan-contract/SKILL.md`. The owning section is the last entry in the heading list above whose line number is smaller than the literal's line number. That derivation is mechanical and reproducible from the two printed outputs.

| # | Literal | Written by | Literal line | Owning `## ` section (last smaller heading) | Required section | Match |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `**Re-derive every citation in this pass.**` | [P1-T2] | 148 | `## Planner Adversarial Self-Review (Mandatory)` (142) | `## Planner Adversarial Self-Review (Mandatory)` | yes |
| 2 | `**Re-check the sibling region.**` | [P1-T3] | 149 | `## Planner Adversarial Self-Review (Mandatory)` (142) | `## Planner Adversarial Self-Review (Mandatory)` | yes |
| 3 | `SELF-REVIEW: RE-DERIVED THIS PASS` | [P1-T4] | 153 | `## Planner Adversarial Self-Review (Mandatory)` (142) | `## Planner Adversarial Self-Review (Mandatory)` | yes |
| 4 | `**Review the entire plan in one pass.**` | [P1-T5] | 168 | `## Preflight Validation (Planner ↔ Executor)` (156) | `## Preflight Validation (Planner ↔ Executor)` | yes |
| 5 | `**Enumerate every defect found.**` | [P1-T6] | 169 | `## Preflight Validation (Planner ↔ Executor)` (156) | `## Preflight Validation (Planner ↔ Executor)` | yes |
| 6 | `**Check the delta against its own rule.**` | [P1-T7] | 170 | `## Preflight Validation (Planner ↔ Executor)` (156) | `## Preflight Validation (Planner ↔ Executor)` | yes |
| 7 | `**Two-round target.**` | [P1-T8] | 171 | `## Preflight Validation (Planner ↔ Executor)` (156) | `## Preflight Validation (Planner ↔ Executor)` | yes |
| 8 | `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` | [P1-T9] | 175 | `## Preflight Validation (Planner ↔ Executor)` (156) | `## Preflight Validation (Planner ↔ Executor)` | yes |

All eight literals fall under their required section: the first three under `## Planner Adversarial Self-Review (Mandatory)` and the last five under `## Preflight Validation (Planner ↔ Executor)`. No literal was recorded under another section, so no corrective move was required.

## Per-Heading Consistency Verdicts

One verdict per `## ` heading in the post-change file. Each verdict states whether that section contradicts the text added by [P1-T1] through [P1-T9].

| # | Heading | Verdict |
| --- | --- | --- |
| 1 | `## When to Use This Skill` | No contradiction. It scopes the skill to creating, validating, and executing atomic plans. The added planner self-review pass and the added preflight review-depth rules both fall inside that scope and add no use outside it. |
| 2 | `## Canonical Plan Format` | No contradiction. It governs phase headings, task-ID form, and the validator precondition. The added text governs review conduct and handoff signal lines and changes no format rule. |
| 3 | `## Short-Path Minimal Plan Contract` | No contradiction. Its four blocks state artifact and field requirements. The added text imposes no artifact requirement and removes none. |
| 4 | `## Minimal-Audit Directive Contract (Small Path)` | No contradiction. Its final bullet requires the planner to return `plan-path` and the final preflight signal. That bullet states a minimum return set, not an exhaustive one, so the additional `SELF-REVIEW:` declaration and the additional `CONVERGENCE:` line extend the return rather than conflicting with it. |
| 5 | `## Phase-0-Only Execution Contract (Small Path)` | No contradiction. It keys on preflight all-clear before Phase 0 delegation. `PREFLIGHT: ALL CLEAR` remains the clearing signal and its meaning is unchanged by the added text. |
| 6 | `## Phase 0 Requirements` | No contradiction. It governs policy reads and baseline artifact fields. No added line touches either. |
| 7 | `## Non-Overridable Evidence Path Clause` | No contradiction. It states that a plan naming a non-canonical evidence path fails preflight validation. The added exhaustive-pass rule makes that failure more likely to be detected in the first round and does not weaken the clause. |
| 8 | `## Coverage Evidence Contract (Mandatory when policy requires coverage)` | No contradiction. It governs coverage capture tasks. No added line touches coverage. |
| 9 | `## Final QA Loop (Required for Code/Test Changes)` | No contradiction. It governs toolchain ordering and rerun behavior. No added line touches the toolchain loop. |
| 10 | `## No-SKIPPED Rule for Planned Command Tasks` | No contradiction. It prohibits `EXIT_CODE: SKIPPED` as a passing outcome. No added line creates a skip path. |
| 11 | `## Expect-Fail Test Tasks` | No contradiction. It governs `[expect-fail]` tagging. No added line touches it. The new section is inserted immediately after it and does not modify it. |
| 12 | `## Planner Adversarial Self-Review (Mandatory)` | No contradiction, and internally consistent. The opening paragraph requires one pass before any handoff on initial authoring and on every revision round; the two rules scope that pass to re-derived citations and their sibling regions; the declaration requirement admits exactly two signal values, one of which halts the handoff. No statement in the section permits a handoff without one of the two signals. |
| 13 | `## Preflight Validation (Planner ↔ Executor)` | No contradiction, and internally consistent. The pre-existing bullet `Require one of the exact signals:` enumerates two `PREFLIGHT:` values; the added closing paragraph states explicitly that the convergence line is a second required line accompanying that signal and not a third value of that two-value set, so the enumeration remains correct as written. The pre-existing instruction to repeat validation until all clear is a loop-termination statement; the added `**Two-round target.**` bullet states a target and a mechanism for meeting it, not a hard cap, so the two coexist. The pre-existing instruction to stop and report blocked state rather than self-approve is consistent with the `SELF-REVIEW: BLOCKED` semantics defined in section 12. |
| 14 | `## Validator Gate (Mandatory)` | No contradiction. It governs the MCP validator call and the G1–G9 acceptance-gate channels. The added preflight rules are executor-side review conduct and neither replace nor bypass the validator gate. |
| 15 | `## Wrap-Tolerant Assertion Authoring (Mandatory)` | No contradiction. Its existing bullet requiring an author to observe a command's success-case output before asserting over that output is directionally the same obligation as `**Re-derive every citation in this pass.**`, applied to command output rather than to line citations. Neither weakens the other and neither restates the other. |
| 16 | `## Plan-Path Continuity Contract (Mandatory)` | No contradiction. It requires the planner to revise the same plan file in place across preflight iterations. The added self-review pass is required per revision round, which is compatible with in-place revision and does not require a new file. |
| 17 | `## Mode source precedence (Mandatory)` | No contradiction. It resolves work mode from the `issue.md` marker. No added line touches mode resolution. |
| 18 | `## Mode-Specific Mandatory Plan Gates` | No contradiction. It states per-mode document-set and fail-closed obligations. No added line touches them. |

Contradictions Found: 0. No enumerated contradiction list is required.

## Out-of-Scope Tensions

The following are tensions with files outside the two target files. Per the [P2-T3] acceptance condition they are not counted in `Contradictions Found:` and do not block check-off. They are escalated per the plan's `## Open Questions / Notes` section.

1. `.claude/agents/atomic-executor.md` describes preflight as "format and structure validation only," which is in tension with the content-level review the extended `## Preflight Validation (Planner ↔ Executor)` section now requires. That file is out of scope per `issue.md` `## Constraints & Risks` and was not edited.
2. `.claude/agents/atomic-executor.md` states "Return exactly one of:" before the two `PREFLIGHT:` signals, while [P1-T9] requires every preflight return to additionally carry a `CONVERGENCE:` line. That file is out of scope and was not edited.
3. `.claude/agents/orchestrator.md` states the three-value `final_status` enumeration twice, at line 104 as `clear`, `changes_requested`, or `pending`, and at line 144 as `{clear, changes_requested, pending}`. [P1-T12] adds `blocked_preflight_iteration_limit` as a fourth value in the other target file. That agent file and its bundled mirror are out of scope and were not edited.

## Verdict

`Contradictions Found: 0`. All eight literals resolve to their required sections. Gate passes.
