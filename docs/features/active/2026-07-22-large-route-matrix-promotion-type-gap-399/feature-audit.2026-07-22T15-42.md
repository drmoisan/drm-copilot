# Feature Audit: large-route-matrix-promotion-type-gap (#399)

**Audit Date:** 2026-07-22
**Feature Folder:** `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399`
**Base Branch:** `origin/main`
**Head Branch:** `bug/large-route-matrix-promotion-type-gap-399` (HEAD `fbfef347e819b9ea77c5fe4f3b6b60efdbc17163`)
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

**Template provenance note:** The MCP tool `resolve_policy_audit_template_asset` was unavailable in this session; this artifact was created from the authoritative bundled asset at `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (assetId `policy_audit.feature_audit_template`).

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `a0b251d330525b8307467f4cf529c5cc3e947445`)
- **Head branch/commit:** `bug/large-route-matrix-promotion-type-gap-399` (commit `fbfef347e819b9ea77c5fe4f3b6b60efdbc17163`)
- **Merge base:** `a0b251d330525b8307467f4cf529c5cc3e947445`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated at review start against `origin/main`; artifacts were absent)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/**` (baseline + qa-gates, 10 artifacts)
  - Additional evidence: reviewer's independent toolchain re-run at HEAD (Black, Ruff, Pyright, Pytest with coverage) and targeted test runs; see `policy-audit.2026-07-22T15-42.md` Appendix B
- **Feature folder used:** `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399` (single active folder; suffix matches issue #399 in the branch name)
- **Requirements source:** `issue.md` (`## Acceptance Criteria` section only)
- **Work mode resolution note:** Explicit persisted marker `- Work Mode: minor-audit` at `issue.md` line 12. Per the minor-audit contract, only the explicit `## Acceptance Criteria` section in `issue.md` (5 checkbox items) is authoritative.
- **Scope note:** Integrity check performed for minor-audit: `spec.md` and `user-story.md` are intentionally absent and were confirmed absent from the feature folder (contents: `evidence/`, `issue.md`, `plan.2026-07-22T09-36.md`, plus this review's artifacts). Their unexpected presence would have been an integrity failure; none detected. Audit scope is the full branch diff vs the resolved base (16 files: 4 code, 12 docs), not any plan or task subset.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/issue.md` — only source (`## Acceptance Criteria`, 5 checkbox items)

### Acceptance criteria

1. `config/orchestration-routing.json`'s `routes.large.required_skills` no longer names `orchestrator-workflow` or `repo-automation-adapter` unless a corresponding skill file is created under `.claude/skills/` for each.
2. `config/orchestration-routing.json`'s `routes.large.required_mcp_tools` reflects the correct promotion tool per `promotion_type`: `new_potential_entry` for `feature`, `new_potential_bug_entry` for `bug` (either by promotion-type-aware branching in the matrix, or by corresponding promotion-type-aware handling in `validate_routing_contract`).
3. `scripts/dev_tools/_orchestrator_state_routing.py`'s `validate_routing_contract` passes cleanly (zero errors) for a synthetic large-route, bug-type checkpoint that records a truthful `new_potential_bug_entry` MCP receipt and no fabricated `orchestrator-workflow` / `repo-automation-adapter` skill receipts.
4. `validate_routing_contract` continues to pass cleanly for the existing large-route, feature-type case (no regression).
5. Unit test coverage added for `scripts/dev_tools/_orchestrator_state_routing.py` (or its test module) asserting both fixed behaviors above.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Dead skill names removed from `routes.large.required_skills` | PASS | Diff removes both names from `config/orchestration-routing.json` and the byte-identical bundled mirror; repo-wide scan of `config/`, `extensions/drm-copilot/resources/config/`, and `scripts/` finds zero residual references; all 6 remaining `routes.large.required_skills` entries have a directory under `.claude/skills/`. Guarded by new test `test_large_route_required_skills_excludes_removed_dead_names` (PASS). | `git diff a0b251d3..fbfef347 -- config/orchestration-routing.json`; `grep -rn "orchestrator-workflow\|repo-automation-adapter" config/ extensions/drm-copilot/resources/config/ scripts/`; skill-existence script check | Removal path chosen (no new skill files created), which the criterion permits. |
| 2 | `required_mcp_tools` reflects correct promotion tool per promotion type | PASS | Option B of the criterion implemented: promotion-type-aware handling in `validate_routing_contract` via `_resolve_promotion_entry_tools` (constants `FEATURE_PROMOTION_ENTRY_TOOL` / `BUG_PROMOTION_ENTRY_TOOL`), applied to both the exact-match check and the receipt-presence loop. Bug-type checkpoints are validated against `new_potential_bug_entry`; feature/absent promotion types keep the matrix list unchanged. | `git diff a0b251d3..fbfef347 -- scripts/dev_tools/_orchestrator_state_routing.py`; `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py -v --no-cov` (17/17 PASS) | Consistency note: the TypeScript mirror validator (`extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`, unchanged and outside this criterion's literal scope) still lacks this resolution; recorded as a Major non-blocking follow-up in `code-review.2026-07-22T15-42.md` (F2). |
| 3 | Bug-type synthetic large-route checkpoint passes with zero errors | PASS | New test `test_complete_state_accepts_bug_type_large_route_with_bug_promotion_tool` builds a truthful bug-type checkpoint (`promotion-type: "bug"`, `new_potential_bug_entry` receipt, no fabricated dead-skill receipts — the skill set derives from the corrected matrix) and asserts `errors == []`. Independently re-run by the reviewer at HEAD: PASS. | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py::test_complete_state_accepts_bug_type_large_route_with_bug_promotion_tool -v --no-cov` | The companion negative test (`..._rejects_bug_type_recording_only_feature_tool`) confirms the pass is discriminating, not vacuous. |
| 4 | Feature-type large-route case still passes (no regression) | PASS | New test `test_complete_state_accepts_feature_type_large_route_with_feature_tool` asserts `errors == []` for the feature-type baseline and that `new_potential_entry` remains the required tool; the pre-existing `test_complete_state_accepts_full_routing_contract_evidence` and all 12 other pre-existing routing-contract tests remain green. Full suite 2073/2073 at HEAD (reviewer run). | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py -v --no-cov`; `poetry run pytest --cov --cov-branch --cov-report=term` | Absent/legacy `promotion-type` behavior is byte-identical by the helper's `!= "bug"` guard, exercised by every pre-existing test (key absent). |
| 5 | Unit test coverage added asserting both fixed behaviors | PASS | Four new tests added to `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` (+120 lines) covering the dead-name removal (behavior 1) and the promotion-type resolution in both directions (behavior 2: bug-type pass and bug-type rejection) plus the feature-type regression guard. Changed-code coverage 100% (7/7 added statements, 2/2 added branches); module 92.2% line / 83.6% branch, no regression. | `poetry run pytest --cov --cov-branch --cov-report=term` (module row: 217 stmts, 17 missed, 110 branches, 18 partial, 89%); `evidence/qa-gates/coverage-comparison.2026-07-22T15-15.md` | Plan's optional test (d) was also delivered. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 5 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Open a follow-up issue to port the promotion-type resolution to the TypeScript mirror validator `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (and its tests), then republish the MCP package, so the MCP-tool validation surface accepts the same bug-type checkpoints as the authoritative Python validator (code-review finding F2).
2. Track a follow-up split of `scripts/dev_tools/_orchestrator_state_routing.py` (593 lines) below the 500-line cap (policy-audit gap G1).
3. On the eventual first real bug-type large-route orchestration, confirm `--require-complete --require-model-routing` passes end-to-end against the live checkpoint (the synthetic-checkpoint evidence here is the strongest available pre-merge proxy).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

All 5 checkbox items in `issue.md` `## Acceptance Criteria` were already checked (`- [x]`) by the executor. This audit independently verified each criterion as PASS, confirming the existing check-offs are justified. No source-file checkbox change was made by this audit because no unchecked PASS item remained.

### AC Status Summary

- Source: `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/issue.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/issue.md` | 5 | 5 | 0 | Checkbox-backed; all pre-checked by executor and independently re-verified PASS by this audit |
