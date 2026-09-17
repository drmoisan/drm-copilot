# Acceptance Criteria Status Summary

Timestamp: 2026-09-17T12-11

- Source: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, section `## Acceptance Criteria` (the sole acceptance-criteria source for this `full-bug` feature; `issue.md` and `user-story.md` are not acceptance-criteria sources here, and `user-story.md` is intentionally absent)
- Total AC items: **38**, counted as the `- [ ]`/`- [x]` lines between the `## Acceptance Criteria` heading and the `## Risks & Mitigations` heading
- Checked off (delivered and verified): **37**
- Remaining (unchecked): **1**
- 37 + 1 = 38

## Item remaining

> The PowerShell toolchain (`run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test`) completes with zero format drift, zero analyzer findings, and zero test failures in a single pass, restarting from the first step after any failure or auto-fix.

Three of the four clauses are met and recorded in `evidence/qa-gates/final-qc-loop.2026-09-17T12-01.md`: the final pass had zero format drift (two identical, empty `git status --porcelain` captures around the formatter), zero analyzer findings (the zero-findings literal quoted from captured output, with all seven per-file counts at 0), and the loop did restart from the first step after each change, twice.

The clause not met is **zero test failures**. The repository-wide Pester run reports `failures = 2` in every run of this feature, including the pre-change baseline captured before any modification (`evidence/baseline/baseline-poshqc-test.2026-09-17T10-34.md`). The two failing nodes are:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`, in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, where `enforce-epic-wave-barrier.ps1` denies with `EPIC_WAVE_BARRIER_BLOCKED: '672' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint`

Neither lies in this feature's file set. The first is a case in a suite this change does not touch; the second denies from ambient epic-checkpoint state in this worktree rather than from any file this plan changed. Remediating either would be work outside this plan's scope, and the second is orchestration state this session is directed not to modify. The failure set at the end of the loop is byte-identical to the failure set recorded before the first modification, so this change introduced no test failure.

Every other criterion is checked off against a named plan task and a named evidence artifact; the mapping is recorded in the execution report.
