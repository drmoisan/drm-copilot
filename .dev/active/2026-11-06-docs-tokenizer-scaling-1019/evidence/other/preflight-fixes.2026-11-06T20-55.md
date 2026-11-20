# Preflight Fixes - Issue 1019, Remediation Cycle 1 Resume

Timestamp: 2026-11-06T20-55
Plan: docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/remediation-plan.2026-11-06T18-47.md

Scope: single-pass preflight of [P2-T1] through [P2-T6] at resume. The orchestrator directed a commit after each task, which overrides the Ownership sentence in `## Conventions` on that one point. Both fixes below follow from that directive and keep the meaning of the assertion.

## Fixes

1. [P2-T6], stale premise: the text said the work of the cycle is uncommitted. It now says the work is partly committed and partly in the working tree. The comparison named by the task, `git diff MERGE_BASE` plus `git status --porcelain`, is unchanged.
2. [P2-T6], vacuous comparator: [P1-T3] compares the `## Acceptance Criteria` section of `issue.md` with the version at `HEAD`. The `issue.md` edit is now committed, so `HEAD` carries the edit and that comparison could not fail. [P2-T6] now names the comparator by derivation: the first parent of the commit whose subject begins `wip(docs): save tokenizer remediation cycle 1`, which is the `HEAD` of the cycle start. The asserted value, an unchanged section during this cycle, is the same.
