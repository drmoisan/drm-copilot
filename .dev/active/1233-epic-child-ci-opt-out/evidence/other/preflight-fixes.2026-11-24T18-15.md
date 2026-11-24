# Preflight Fixes: remediation cycle 2 (#1233)

Timestamp: 2026-11-24T18-15
Plan: .dev/active/1233-epic-child-ci-opt-out/remediation-plan.2026-11-24T17-59.md
Mode: single-pass preflight, design check against `remediation-inputs.2026-11-24T17-50.md` (F2, the whitespace-set Minor, the orchestrator note).
Validation after fixes: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` EXIT_CODE 0 ("plan validation passed"); MCP `validate_orchestration_artifacts` (plan) ok.

## Fixes (task text only; no task added, removed, or reordered)

1. [P1-T2] citation correction: "`_orchestrator_state_route_gates` output" named a module, not a function. Now names `_validate_completion_ci_gate` in `scripts/dev_tools/validate_orchestrator_state.py` and `validate_completion_pr_gate` in `scripts/dev_tools/_orchestrator_state_route_gates.py`.
2. [P1-T2] task-ordering clarification: the task's Jest selection contains the two new rows, which fail by design until P1-T4. Added a line stating that P1-T3 runs that selection as the fail-before record and that this task check records the static steps only. The acceptance condition is unchanged.
3. [P1-T4] stale count: `orchestrator-state-core.completion.test.ts` has eleven pre-existing `it` rows, not seven. Disposition (unchanged) is the same.
4. [P1-T4] existing-test search completeness: the search terms also match `orchestrator-state-issue-adoption.test.ts` (a `verified_at: null` row on an `issue_adoption` record, which `missingObjectKeys` does not read) and `test/lib/push-down/claude-config-carriage.test.ts` and `config-carriage.test-helpers.ts` (`requires_pr_gate` routing configuration). Added both, with disposition unchanged.
5. [P1-T6] stale fact: the review artifacts of 2026-11-24T17-50 and the S7 and U7 reversals are already committed in the branch's latest commit, so they are no longer listed as uncommitted. The commit scope is otherwise unchanged.
6. [P1-T6] revert-step consistency: step 1 of the 0015 revert steps deletes `orchestrator-state-child-ci.test.ts`, so step 6 cannot run it. Step 6 now adds only `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts`.
7. [P1-T8] citation correction: the non-writing `-WriteFile` format seam belongs to P0-T1 of `plan.2026-11-23T22-42.md`, not to the prior remediation plan's P0-T1.
8. [P1-T8] baseline citation: this cycle's Phase 0 has no PowerShell step. P1-T8 now cites the lexicographically greatest `r1-powershell-static.*.md` under `evidence/remediation-baseline/`, whose repository-wide format, analyzer, and leak-scan steps cover the contract test file. The zero-findings acceptance is unchanged.
9. [P1-T12] wording: "an agent source" now names the paths `.claude/agents/`, `.codex/agents/`, and `scripts/harness-generation/sources/agents/`, so the Codex skills under `.agents/skills/` that the branch already edits are not read as agent sources. The assertion is unchanged.
