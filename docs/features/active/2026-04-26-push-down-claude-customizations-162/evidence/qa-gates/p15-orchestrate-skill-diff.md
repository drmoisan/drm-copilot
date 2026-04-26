# P15 Orchestrate Skill Diff

**Phase**: 15 — Part C: Update orchestrate skill  
**Timestamp**: 2026-04-27T00:00:00Z  
**Plan**: docs/features/active/2026-04-26-push-down-claude-customizations-162/plan.2026-04-26T13-49.md

---

## P15-T7: Git Diff

| Field | Value |
|-------|-------|
| Timestamp | 2026-04-27T00:00:00Z |
| Command | `git diff -- .claude/skills/orchestrate/SKILL.md` |
| EXIT_CODE | 0 |
| Output Summary | 53 lines added, 0 lines deleted. Additions only — no existing lines were removed. |

### New sections added:

1. **`## Pre-Feature-Review Commit`** — Instructs the orchestrator to stage all changes (`git add -A`), invoke `commit-message` skill, commit with generated message, and only then proceed to `feature-review` delegation.

2. **`## Post-Review Outcome Evaluation`** — Instructs the orchestrator to locate `remediation-inputs.<timestamp>.md`, count `BLOCKING`/`Severity: Blocking` lines, and route to remediation loop or PR creation gate accordingly.

3. **`## Remediation Loop (R1–R5)`** — Defines the five-step bounded loop (R1: remediation planning, R2: preflight clearance, R3: execution, Pre-R4 commit, R4: re-audit, R5: loop-exit decision) with a termination guard at `remediation_pass == 3` recording `step6_status: "blocked_remediation_loop_limit"`.

4. **`## Issue Number Consistency`** — Defines derivation of `issue_num` from active feature folder name, mandates injection into every subagent delegation prompt, and specifies rejection protocol for mismatched issue numbers.

5. **`## PR Creation Gate`** — States the four conditions that must all be true simultaneously before PR creation: zero blocking findings, AC artifact pass, toolchain pass, `next_step == S8_create_pr`.
