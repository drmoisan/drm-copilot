# Phase 0 Instructions Read (Issue #1011, Remediation Cycle 1)

Timestamp: 2026-10-31T02-40
Plan: remediation-plan.2026-10-31T02-17.md, task P0-T1
Policy Order: CLAUDE.md, then general code change, general unit test, quality tiers, language rule (PowerShell), plan acceptance gates, execution-environment brief, evidence and timestamp conventions, then the remediation inputs, code review, and spec of the feature folder.

## Files read, in order

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md` (applies only when `quality-tiers.yml` exists; coverage defaults 85% line apply to PowerShell, no branch gate)
5. `.claude/rules/powershell.md`
6. `.claude/rules/plan-acceptance-gates.md`
7. `.claude/skills/execution-environment/SKILL.md`
8. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
9. `FEATURE/remediation-inputs.2026-10-31T02-17.md`
10. `FEATURE/code-review.2026-10-31T02-17.md`
11. `FEATURE/spec.md` (`## Acceptance Criteria`, AC-01 to AC-18, all checked at cycle start)

## Constraints carried into execution

- No write under `.claude/lib/worktree-resolution/`, `.codex/`, `.github/agents/`, `.claude/rules/`, `.github/instructions/`, or any pack manifest.
- Protected functions in `HELPERS` stay unchanged; only `Resolve-PrAuthorWorktreeTarget` and `ConvertFrom-PrAuthorHookTargetResult` change.
- `HELPERS` stays at or below 500 lines; tests create no temporary files and start no process.
- Evidence under `FEATURE/evidence/<kind>/` with UTC write-time stamps; scratch recorded as `SCRATCH`.
