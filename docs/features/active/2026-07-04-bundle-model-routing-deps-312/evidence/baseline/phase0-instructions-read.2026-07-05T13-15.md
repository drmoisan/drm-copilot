# Phase 0 Instructions Read — Issue #312

Timestamp: 2026-07-05T13-15

Policy Order: The required policy reading order per `.claude/skills/policy-compliance-order/SKILL.md`
and plan task [P0-T1] was followed. CLAUDE.md is not present at the repository root; its absence is
recorded here rather than treated as a failure (non-blocking preflight observation).

Files read (in required order):
1. CLAUDE.md — ABSENT at repo root (no standing-instructions file exists in this worktree). Recorded, not a failure.
2. .claude/rules/general-code-change.md — cross-language code-change policy (500-line limit, toolchain loop, fail-fast).
3. .claude/rules/general-unit-test.md — cross-language unit-test policy (coverage >= 85% line / >= 75% branch, test-location mirror, no temp files).
4. .claude/rules/powershell.md — PowerShell toolchain (PoshQC format -> analyze -> Pester), advanced functions, approved verbs, 500-line limit.
5. .claude/rules/python.md — Python toolchain (black -> ruff -> pyright -> pytest), strong typing.
6. .claude/rules/python-suppressions.md — suppression authorization policy.
7. .claude/rules/self-explanatory-code-commenting.md — docstring/comment requirements (comment-based help analog for PS).
8. .claude/rules/quality-tiers.md — T1-T4 rigor tiers; uniform coverage thresholds.
9. .claude/rules/orchestrator-state.md — orchestrator-state invariants (complexity/model-routing receipts recompute floors/models via the Python references).

Additional skills read:
- .claude/skills/atomic-plan-contract/SKILL.md — plan format, Phase 0 evidence, final QA loop, coverage evidence contract.
- .claude/skills/evidence-and-timestamp-conventions/SKILL.md — canonical evidence locations, ISO-8601 timestamps, machine-checkable artifact schema.

Reference source files reviewed for parity porting:
- scripts/dev_tools/compute_complexity_floor.py (lines 49-108) — Python reference for Get-ComplexityFloor.
- scripts/dev_tools/resolve_delegation_model.py (lines 49-140) — Python reference for Resolve-DelegationModel.
- tests/scripts/dev_tools/test_compute_complexity_floor.py — pytest cases to translate.
- tests/scripts/dev_tools/test_resolve_delegation_model.py — pytest cases to translate.
- config/orchestration-routing.json (lines 146-167) — authoritative model_policy / model_budget source for the parity test.

Output Summary: All nine policy files were read in the required order (CLAUDE.md absent, recorded).
Both supporting skills and the parity reference sources were read. Phase 0 policy-read prerequisites satisfied.
