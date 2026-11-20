# Code Review: orchestration-enforcement-hardening (Issue #253) — R4

**Review Date:** 2026-06-26
**Base:** `origin/main` @ merge-base `1ea8d87`
**Head:** `05a44de`
**Range:** `1ea8d87..05a44de` (commits `ebd4293` + `05a44de`)
**Reviewer scope:** full branch diff vs merge-base (both commits)

## Executive Summary

The branch implements orchestration-enforcement Gaps 1–5 and the routing-matrix agent-name reconciliation (commit `ebd4293`), then removes `collect_commit_context` from the `large` route's `required_mcp_tools` to satisfy AC8 (commit `05a44de`). The implementation follows the spec's design: pure Python validator functions returning error lists, PowerShell hooks delegating routing logic to the authoritative Python validator through injectable subprocess seams, helpers extracted to a dedicated file to respect the 500-line limit, and byte-identical bundled mirrors.

Code quality is high. New functions carry complete docstrings/comment-based help, use parameter validation and type annotations, and isolate I/O behind injectable seams to keep core logic testable. The toolchain is clean across Black, Ruff, Pyright, Pytest, PSScriptAnalyzer, and Pester. Coverage meets thresholds for every changed file. The two routing JSON files are byte-identical (matching SHA256), and the four PowerShell hooks are byte-identical to their bundled mirrors.

No blocking or major findings. Two informational observations are recorded below. The AC8 change is minimal and correct: the removed tool is confirmed absent from the orchestrator allow list, and the routing-contract positive test (which reads `required_mcp_tools` generically) passes, confirming a fully-exercised large-route checkpoint no longer requires an unsatisfiable receipt.

Recommendation: GO. No remediation required.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Info | `scripts/dev_tools/_orchestrator_state_routing.py` | `MANDATORY_ROUTE_PHASES` (module constant) | Phase-completeness is enforced only for the `small` route; `large` and `remediation` impose no mandatory-phase set, by design for backward compatibility. | Confirm this is intended; if `large` should require its own canonical phases, add them in a follow-up. | The constant's comment states routes absent from the map impose no requirement; this is a deliberate backward-compat choice, not a defect. | Module diff lines for `MANDATORY_ROUTE_PHASES`; spec.md Gap 5 scope. |
| Info | `artifacts/python/lcov.info` (metric) | repo-wide Python branch coverage | Repo-wide Python branch coverage is exactly 75.0%, at the floor with no margin. | Monitor; a future test removal could drop below threshold. Not caused by this branch — per-changed-file branch coverage carries margin (82.4%, 92.7%). | Threshold is `>= 75%`; 75.0% passes but leaves no headroom. | `artifacts/python/lcov.info` parse: branch 2326/3102 = 75.0%. |
| Info | `config/orchestration-routing.json` + mirror | `large.required_mcp_tools` | AC8 removal of `collect_commit_context` is correct and minimal; no validation logic changed. | None. | The tool is real but absent from `.claude/settings.json` orchestrator allow list and not invoked by any orchestrator skill, so requiring its receipt made the large-route contract unsatisfiable. | `grep collect_commit_context` on both JSON files and `.claude/settings.json` (absent in all three); routing-contract positive test passes. |

## Detailed Observations

- **Seam design (AC1, AC3):** `Invoke-RoutingContractValidation` accepts an `$Invoker` scriptblock defaulting to the real `python -m scripts.dev_tools.validate_orchestration_artifacts ... --require-complete` call; tests inject a mock. `Resolve-EditedCheckpointContent` accepts a `$CheckpointReader` seam and correctly returns `$null` (allow) when there is no `old_string`, the file does not exist, or the `old_string` is not present on disk. Both follow the established `ConvertFrom-CheckpointJson` seam pattern. The hook applies the patch in memory only; no on-disk mutation.
- **Sentinel rejection (AC2):** `Test-IsValidIssueNum` requires `^\d+$` and rejects the sentinel set; `Test-IsValidFeatureFolder` requires the `docs/features/active/` prefix plus a non-empty suffix and supports an optional `FolderExistsCheck` seam. Both are testable predicates extracted into `enforce-completion-helpers.ps1`.
- **De-#232 generalization (AC4):** No `232` literal remains in either PowerShell hook, and `ISSUE_232`/`ISSUE_232_BRANCH` are removed from `validate_orchestrator_state.py`. The PR-gate requirement is now driven by `route_requires_pr_gate`, which reads `requires_pr_gate is True` from the matrix.
- **Route membership / phase completeness (AC5):** `validate_route_membership` returns a single-element error list for a missing/malformed/unknown route id (covering `direct_powershell_engineer_remediation`) and an empty list for known routes. `validate_phase_completeness` is gated under `require_complete`.
- **Purity:** The new Python functions return error lists and perform no `sys.exit` or disk writes beyond an optional matrix load behind a default parameter. This matches the spec's invariant that validator functions are pure with respect to their inputs.

## Acceptance Criteria Coverage (code-level)

AC1–AC8 are all evidenced at the code level. See `feature-audit.2026-06-26T20-10.md` for the formal per-AC evaluation and check-off.
