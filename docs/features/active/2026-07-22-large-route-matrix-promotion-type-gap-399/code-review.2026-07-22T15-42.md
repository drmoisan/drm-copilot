# Code Review: large-route-matrix-promotion-type-gap (#399)

**Review Date:** 2026-07-22
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number (#399) in the branch name.
**Base Branch:** `origin/main` (merge base `a0b251d330525b8307467f4cf529c5cc3e947445`)
**Head Branch:** `bug/large-route-matrix-promotion-type-gap-399` (HEAD `fbfef347e819b9ea77c5fe4f3b6b60efdbc17163`)
**Review Type:** Initial review

**Template provenance note:** The MCP tool `resolve_policy_audit_template_asset` was unavailable in this session; this artifact was created from the authoritative bundled asset at `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (assetId `policy_audit.code_review_template`).

---

## Executive Summary

This branch fixes issue #399, a repo-wide orchestration-tooling defect: `routes.large` in `config/orchestration-routing.json` named two `required_skills` with no corresponding skill file under `.claude/skills/` (`orchestrator-workflow`, `repo-automation-adapter`), and hardcoded the feature-type promotion-entry MCP tool `new_potential_entry` in `required_mcp_tools`, making an honest `--require-complete` pass structurally impossible for any large-route orchestration and doubly impossible for bug-type promotions. The scope is small and disciplined: 4 code files, +190/-5 code lines, exactly matching the plan's constrained file list. Evidence reviewed: full branch diff (`artifacts/pr_context.appendix.txt`), the feature folder's 10 evidence artifacts, and an independent reviewer re-run of the full Python toolchain and targeted tests at HEAD.

**What changed:**
- `config/orchestration-routing.json` + byte-identical bundled mirror: the two dead skill names removed from `routes.large.required_skills` (2 lines each; parity verified by `cmp` and `test_orchestration_routing_config_parity.py`).
- `scripts/dev_tools/_orchestrator_state_routing.py` (+67/-1): new constants `FEATURE_PROMOTION_ENTRY_TOOL` / `BUG_PROMOTION_ENTRY_TOOL` and pure helper `_resolve_promotion_entry_tools(required_mcp_tools, state)`, wired into `validate_routing_contract` so the promotion-entry tool is resolved from the checkpoint's hyphenated `promotion-type` key before both the exact-match check and the receipt-presence loop.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` (+120): `_build_complete_large_bug_state` factory and 4 new tests (bug-type pass, feature-type regression guard, dead-name removal, bug-type rejection).

**Top 3 risks:**
1. The TypeScript mirror validator (`extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`, unchanged on this branch) still lacks promotion-type resolution, so the MCP-tool validation surface will continue rejecting bug-type large-route checkpoints that the authoritative Python validator now accepts (finding F2).
2. `scripts/dev_tools/_orchestrator_state_routing.py` remains over the 500-line cap (593 lines, up from a pre-existing 527), increasing pressure on an already-oversized module (finding F1).
3. The resolution keys off the exact string `"bug"` in the checkpoint's `promotion-type`; any future third promotion type would silently fall back to feature-type expectations. Low risk today (only two types exist) and the fallback is the documented, backward-compatible behavior.

**PR readiness recommendation:** **Go** — zero Blockers; all toolchain stages and thresholds independently verified clean; the two Major findings are follow-up items in unmodified or pre-existing-violation territory, not defects introduced by this diff.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/dev_tools/_orchestrator_state_routing.py` | whole file | Pre-existing 500-line-cap violation worsened: 527 lines at baseline `a0b251d3`, 593 at HEAD (+66). The new helper could have been placed in a sibling `_orchestrator_state_*.py` module per the established pattern. | Split the promotion-tool constants and `_resolve_promotion_entry_tools` into a sibling module (e.g., `_orchestrator_state_promotion_tools.py`) in a follow-up change, or perform a broader split to bring the file under 500 lines. | `general-code-change.md` file-size limit; repository precedent classifies a grown pre-existing violation as Moderate/non-blocking (epic-275 policy audit, finding 4). | `wc -l` at HEAD = 593; `git show a0b251d3:...` piped to `wc -l` = 527. |
| Major | `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` | lines 405-442 (unchanged by this branch) | The TS mirror validator performs the `required_mcp_tools` exact-match and receipt-presence checks without promotion-type resolution. A bug-type large-route checkpoint that passes the fixed Python validator fails this surface with `Checkpoint required_mcp_tools must match routing matrix for route large.` and `Checkpoint missing successful MCP receipt: new_potential_entry.`. The MCP tool `validate_orchestration_artifacts` runs this validator in-process (`validate-orchestration-service-call.ts` → `validateArtifact`). | Open a follow-up issue to port `_resolve_promotion_entry_tools` semantics (and tests) to the TS validator and republish the MCP package so both surfaces agree. | The defect reported in #399 is fixed on the authoritative Python surface (used by the completion hooks), but partially persists on the MCP-tool surface for bug-type promotions; leaving the surfaces divergent invites confusing, surface-dependent validation outcomes. | Direct read of `orchestrator-state-routing.ts` lines 402-442 and `validate-orchestration-service-call.ts`; file absent from `git diff --name-status a0b251d3..fbfef347`. |
| Info | `config/orchestration-routing.json` | `routes.small` / `routes.large` `required_mcp_tools` | The matrix still records the feature-type tool literally; promotion-type awareness lives entirely in the validator. This is the AC-sanctioned option B ("corresponding promotion-type-aware handling in `validate_routing_contract`") and is documented in the module-level comment, but readers of the matrix alone will not see the bug-type substitution. | None required. Optionally note the validator-side resolution in a comment-adjacent doc if the matrix grows more promotion-type-dependent entries. | Discoverability; the docstring and module comment already explain the design. | Diff inspection; issue.md AC2 wording. |

No Blockers. No findings on the diff's own logic, typing, tests, or configuration correctness.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The fix is the smallest change that satisfies the contract: one pure helper, two constants, and a single wiring point, with the resolved list reused for both the exact-match check and the receipt loop so the two checks cannot drift apart (the plan explicitly required this consistency, and the implementation delivers it).
- Backward compatibility is precise and tested: any `promotion-type` other than the exact string `"bug"` (including absent and non-string values) returns `list(required_mcp_tools)` unchanged, so feature-type and legacy checkpoints validate byte-identically to the prior behavior.
- The generic route-agnostic design (substitution applies to any route whose `required_mcp_tools` contains the promotion-entry tool) fixes the same latent defect in `routes.small` without a special case.
- Matrix order is preserved by the substitution comprehension, keeping the exact-match semantics of `_state_list` intact.

#### Typing and API notes

- Full annotations on the new helper (`list[str]`, `dict[str, Any]` matching the module's established checkpoint signature convention; `Any` confined to JSON-shaped input). Pyright reports 0 errors at HEAD. No new public API surface: the helper is `_`-prefixed and internal.
- No suppressions (`# noqa`, `# type: ignore`) added anywhere in the diff. Test-side narrowing uses `cast("list[str]", ...)`, consistent with the file's existing style.

#### Error handling and logging

- No new exception or logging paths; the helper is total over its documented input domain (`Raises: None`, `Side Effects: None`), and validation failures continue to flow through the module's accumulated-error-strings pattern.

---

## Test Quality Audit

The four new tests map one-to-one onto the plan's required cases (a: bug-type pass, b: feature-type regression, c: dead-name removal, d: bug-type rejection — the "optional" case d was delivered). The bug-type factory transforms the existing feature-type baseline rather than duplicating it, mirroring the substitution in `required_mcp_tools`, `mcp_call_receipts`, and `lifecycle_operations` so the checkpoint is truthful end-to-end and deliberately records no fabricated dead-skill receipts. Reviewer re-ran the targeted module (17/17, 0.07s) and the full suite (2073/2073, 8.42s) at HEAD; changed-code coverage is 100% (7/7 statements, 2/2 branches).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` — 4 new tests, AAA structure, literal-error-string assertions; verifies both fixed behaviors and the negative path. No gaps found.
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` — byte-identity guard for the config mirror; passes (independently re-run).
- `evidence/baseline/baseline-pytest.2026-07-22T15-15.md` / `evidence/qa-gates/final-pytest.2026-07-22T15-15.md` — numeric baseline and post-change coverage; reviewer's HEAD run reproduces the post-change TOTAL row exactly (12259/1114/4448/564).
- `evidence/qa-gates/coverage-comparison.2026-07-22T15-15.md` — changed-code coverage derivation (statement/branch delta method); arithmetic independently verified.
- `evidence/qa-gates/final-black|ruff|pyright.2026-07-22T15-15.md` — all EXIT_CODE 0; reviewer reproduced all three clean at HEAD.

### Quality assessment prompts

- **Determinism:** Pure in-memory checkpoint dicts; the only file dependency is the committed routing matrix. No time, randomness, network, or temp files.
- **Isolation:** Each test asserts exactly one contract; factories prevent shared mutable state.
- **Speed:** 0.07s for the targeted module; 8.42s for the full 2073-test suite (reviewer measurement).
- **Diagnostics:** Assertions against the validator's literal error strings mean a failure prints the full actual error list, immediately identifying the divergent expectation.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff contains only config-list edits, validator logic, tests, and docs; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess usage added; Ruff (with security rules) passes clean. |
| Input validation at boundaries | ✅ PASS | The helper defensively handles absent/non-string `promotion-type` via the `!= "bug"` guard, returning a copy (`list(...)`) rather than the caller's list, so no aliasing mutation risk. |
| Error handling remains explicit | ✅ PASS | Validation failures remain explicit accumulated error strings; the bug-type rejection path emits `Checkpoint missing successful MCP receipt: new_potential_bug_entry.` (asserted by test). |
| Configuration / path handling is safe | ✅ PASS | No path handling added; routing matrix path resolution unchanged. Mirror parity byte-verified. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, repository policy rules, the feature folder's evidence artifacts, repository precedent audits (`docs/features/completed/2026-07-02-epic-orchestrate-275/policy-audit.2026-07-02T23-00.md`), and direct inspection of the TypeScript mirror validator and MCP service-call wiring.

---

## Verdict

The change is ready for normal PR flow. It fixes the reported defect with a minimal, well-typed, fully covered validator change and a two-line config removal applied identically to both mirror copies; every toolchain stage was independently reproduced clean at HEAD, and changed-code coverage is 100% with no regression. Two Major, non-blocking follow-ups are recorded: split the over-cap `_orchestrator_state_routing.py` module (a pre-existing violation this branch worsened by +66 lines), and port the promotion-type resolution to the TypeScript mirror validator so the MCP-tool surface stops rejecting bug-type checkpoints the authoritative Python validator accepts. Neither follow-up gates this merge; both should be tracked as issues. This conclusion is consistent with the Findings Table and the **Go** recommendation above.
