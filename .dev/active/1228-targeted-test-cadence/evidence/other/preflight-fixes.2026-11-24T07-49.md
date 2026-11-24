# Preflight Fixes - Remediation Plan Cycle 1 (Issue #1228), R2 preflight

Timestamp: 2026-11-24T07-49
Plan: .dev/active/1228-targeted-test-cadence/remediation-plan.2026-11-24T07-15.md
Pre-fix plan copy: SCRATCH/issue-1228-plan-snapshot-r2.md

Every fix below edits task text or preamble prose only. No task was added, removed, or reordered, and no acceptance condition changes what it asserts.

## Fixes

1. [P1-T2] | pinned-token disposition precision (validator-blind) | Added `governing repo-wide threshold` to the keep list for the Claude half. The token is asserted in `.claude/agents/feature-review.md` and its bundle by `test_review_agent_copy_uses_governing_thresholds` in `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, and its only occurrence is the step 3 bullet that the task rewrites. The task already listed that test as unchanged with "pinned tokens kept"; the fix names the token so the rewrite keeps it.
2. [P1-T3] | tool route literal | "the launcher Jest suite" named as the launcher `jest-extension` suite (the suite in `config/test-execution-policy.json` whose working directory is `extensions/drm-copilot`), with files selected through `--testPathPatterns`, because a positional path after the launcher suite is not run.
3. [P1-T3] | evidence observation for an already-required copy | The task check records that `git hash-object` of `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` and of its bundle copy are equal. The task already requires a byte-for-byte copy; no contract test compares that pair.
4. [P1-T4] | literal-formatting (no check mode) | "the PoshQC format check ... report zero findings" restated as `Invoke-PoshQCFormat` logging no `Formatted:` line for the file with its hash unchanged, and PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` reporting zero findings. `Invoke-PoshQCFormat` has no check mode, so the original wording named a value with no source; the assertion (zero format and analyzer findings) is unchanged.
5. [P1-T6] | tool route literal | "the launcher Jest suites over the union test paths" named as one launcher `jest-extension` run over the union Jest files selected with `--testPathPatterns`.
6. `## Pre-Mortem` / Mirror parity | citation correction | The bullet listed contract tests as proof of parity for every copy; none byte-compares the policy-audit template pair. The bullet now names the [P1-T3] `git hash-object` observation for that pair.
