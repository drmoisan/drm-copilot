# Feature Audit: orchestration-enforcement-hardening (Issue #253) — R4

## Scope and Baseline

- **Base branch (resolved):** `origin/main`
- **Merge-base SHA:** `1ea8d87c5ffb9daf671eb33bc22b6d56be4d0ec6`
- **Head SHA:** `05a44de0706e5535a665ef3894f9a5c5aad79c3c`
- **Range audited:** `1ea8d87..05a44de` (two commits: `ebd4293` hardening + `05a44de` AC8 reconciliation)
- **Work mode (from issue.md):** `full-feature`
- **AC sources (per work mode):** `spec.md` (AC1–AC8) and `user-story.md` (AC1–AC7). AC8 exists only in `spec.md`; `user-story.md` and `issue.md` enumerate AC1–AC7.
- **Audit type:** Evidence-verification re-audit (R4) of the full branch diff after the additive AC8 commit.

The audit covers the complete branch diff, not any plan/task subset. No scope narrowing was attempted by the caller.

## Acceptance Criteria Inventory

From `spec.md` (authoritative for full-feature, includes AC8):

1. AC1 — routing-contract validator wired into the SubagentStop gate via injectable subprocess seam; blocks DONE with `ROUTING_CONTRACT_BLOCKED: ...` on routing error; allows when clean.
2. AC2 — `enforce-completion-consistency.ps1` rejects sentinel/invalid `issue-num` and `feature-folder` with named errors via testable helpers.
3. AC3 — Edit-tool completion patches validated by read-then-validate against on-disk checkpoint; allows on missing file or non-matching patch.
4. AC4 — `"232"` literal removed from both PowerShell hooks; `ISSUE_232`/`ISSUE_232_BRANCH` removed from `validate_orchestrator_state.py`; `pr_gate` required only when route `requires_pr_gate` is true.
5. AC5 — `validate_route_membership` rejects unknown route/`path_selected` (including `direct_powershell_engineer_remediation`); phase-completeness verified at completion.
6. AC6 — both routing JSON files contain only real agent names and remain byte-identical (parity test passes).
7. AC7 — all four quality toolchains pass with no coverage regression; existing tests continue to pass.
8. AC8 — `large` route's `required_mcp_tools` lists only orchestrator-permitted tools; `collect_commit_context` removed from both routing JSON files; a fully-exercised large-route checkpoint passes `validate_routing_contract` with no unsatisfiable receipt; parity and routing-contract tests pass.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 | PASS | `Invoke-RoutingContractValidation` in `validate-orchestrator-output.ps1` with `$Invoker` seam (default real CLI call) inserted in `Invoke-OrchestratorOutputValidation` after the human-interaction check; returns `ROUTING_CONTRACT_BLOCKED: <text>` on `HasErrors`. Pester subprocess block/allow tests pass (95 hook tests green). |
| AC2 | PASS | `Test-IsValidIssueNum` (`^\d+$`, rejects sentinel set) and `Test-IsValidFeatureFolder` (`docs/features/active/` prefix + non-empty suffix, optional `FolderExistsCheck`) in `enforce-completion-helpers.ps1`, called from `enforce-completion-consistency.ps1`. Sentinel-rejection matrix tests pass. |
| AC3 | PASS | `Resolve-EditedCheckpointContent` reads on-disk checkpoint via injectable `CheckpointReader`, applies `old_string`→`new_string` in memory, returns `$null` (allow) on no-old_string / missing-file / non-matching patch. Read-then-validate tests pass. |
| AC4 | PASS | `grep "232"` on both PowerShell hooks: no matches (exit 1). `grep "ISSUE_232\|232"` on `validate_orchestrator_state.py`: no matches. `route_requires_pr_gate` drives `pr_gate` from matrix `requires_pr_gate is True`. |
| AC5 | PASS | `validate_route_membership` returns single-element error for missing/malformed/unknown route id; empty for known route. `validate_phase_completeness` gated under `require_complete`. Unknown-route rejection tests pass. |
| AC6 | PASS | `diff` exit 0 and matching SHA256 (`d29b3a64...720`) on both routing JSON files. Agent names are `feature-review` and `pr-author` (real agents). `test_orchestration_routing_config_parity.py` passes. |
| AC7 | PASS | Black (clean), Ruff (clean), Pyright (0 errors), Pytest (51 pass); PSScriptAnalyzer (no Warning/Error), Pester (95 pass). Coverage meets thresholds for all changed files (see policy audit Section 5). No regression: all changed files exceed thresholds with margin. |
| AC8 | PASS | `collect_commit_context` absent from both routing JSON files (`grep` exit 1) and absent from `.claude/settings.json` orchestrator allow list (allow list has `collect_pr_context`, `validate_orchestration_artifacts`, lifecycle + PoshQC tools, not `collect_commit_context`). Routing-contract positive test builds a complete large-route state from the live matrix (`required_mcp_tools` read generically) and asserts empty error list — confirming no unsatisfiable receipt. Parity test passes. |

All eight acceptance criteria evaluate PASS.

## Summary

All AC1–AC8 are satisfied with direct evidence from the branch diff, the toolchain runs, the coverage artifacts, and the byte-identical parity verification. The R4 delta (commit `05a44de`) is the AC8 removal of `collect_commit_context`; it is correct, minimal, and verified both against the orchestrator allow list and against the routing-contract positive test. No blocking or partial findings exist in the policy audit or code review. Remediation is not required.

PR readiness recommendation: GO.

## Acceptance Criteria Check-off

- AC1–AC7 were already checked `[x]` in `spec.md`, `issue.md`, and `user-story.md`; this audit confirms those check-offs remain accurate (all PASS).
- AC8 evaluated PASS. AC8 exists only in `spec.md` and was previously unchecked `[ ]`; this reviewer checks it off to `[x]` in `spec.md` per `acceptance-criteria-tracking`. (AC8 is not present in `issue.md` or `user-story.md`, so no check-off is applicable there.)

### Acceptance Criteria Status
- Source: `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/spec.md` (AC1–AC8) and `user-story.md` (AC1–AC7)
- Total AC items (spec.md): 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: none
