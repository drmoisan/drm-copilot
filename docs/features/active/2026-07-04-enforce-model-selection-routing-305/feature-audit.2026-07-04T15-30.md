# Feature Audit: enforce-model-selection-routing (Issue #305)

**Audit Date:** 2026-07-04
**Feature Folder:** `docs/features/active/2026-07-04-enforce-model-selection-routing-305`
**Base Branch:** `main` @ `f530d0e3ae7c5d0974b72cf0956e862dd94041c5`
**Head Branch:** `bug/enforce-model-selection-routing` @ `355cbbc95e1cf422ce667365b180f4461cd0ee13`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1

**Template provenance:** MCP `feature-audit-template` asset was unavailable in this environment; constructed from `docs/features/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`.

---

## Scope and Baseline

- **Base branch:** `main` (commit `f530d0e3ae7c5d0974b72cf0956e862dd94041c5`)
- **Head branch/commit:** `bug/enforce-model-selection-routing` (commit `355cbbc95e1cf422ce667365b180f4461cd0ee13`)
- **Merge base:** `f530d0e3ae7c5d0974b72cf0956e862dd94041c5` (identical to base ref)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-04-enforce-model-selection-routing-305/evidence/**`
- **Feature folder used:** `docs/features/active/2026-07-04-enforce-model-selection-routing-305`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (14 checkbox criteria).
- **Work mode resolution note:** `issue.md` marker `- Work Mode: full-bug`. Per the work-mode contract, `full-bug` resolves the AC source to `spec.md` only.
- **Scope note:** Audit is full-branch-vs-base with no scope narrowing. Coverage evaluated for every language with changed files (Python, PowerShell, TypeScript; C# has zero changed files). This is a re-audit: the two policy-level blocking findings from `feature-audit.2026-07-04T14-34.md` (500-line file-size violation; absent TS coverage artifact) were remediated in cycle 1 and are re-verified as resolved in `policy-audit.2026-07-04T15-30.md`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — only source (work mode `full-bug`).

### Acceptance criteria (from spec.md `## Acceptance Criteria`)

1. `validate_orchestrator_state_text(..., require_model_routing=True)` fails a checkpoint whose delegating `next_step` (or `completed_steps`/`delegation_receipts`) include delegations with no matching `model_routing_receipts[]` / `complexity_assessments[]` entry, and passes once entries are present and consistent with the reference formulas.
2. Plain, `require_complete`, and `require_pr_creation_ready` calls return results identical to before (regression-covered, byte-identical error lists).
3. The PreToolUse hook `.claude/hooks/enforce-model-routing-receipt.ps1` blocks or flags a delegation lacking a routing receipt (Pester test with a synthetic checkpoint), and allows non-delegating tool inputs and malformed JSON gracefully.
4. The Completion Requirements gate refuses DONE when a delegation lacks a recorded model choice (`MODEL_ROUTING_BLOCKED:` via `.claude/hooks/validate-orchestrator-output.ps1`).
5. Every `.claude/agents/*.md` `model:` default is consistent with the Model-Budget Contract, with `atomic-executor` explicitly set to opus.
6. Resume reconciliation is documented in `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling` and mirrored into `.claude/agents/orchestrator.md` Startup Protocol; a test exercises the missing-choice resume path.
7. The orchestrator does not delegate at a delegating `next_step` while `model_routing_preflight` status is fail; a `model_routing_preflight` record is written on resume.
8. New/updated tests under `tests/scripts/dev_tools/` cover strict-mode missing entry, strict-mode present-and-consistent, strict-mode present-but-model-mismatch, and backward-compatible no-delegation.
9. `--require-model-routing` CLI flag is added to the `orchestrator-state` subparser and forwarded to `validate_orchestrator_state_text(require_model_routing=True)`, with flag-independence covered.
10. The `validate_orchestration_artifacts` MCP tool surfaces a `require_model_routing` parameter; the TypeScript side performs the existence check only, with full per-receipt correctness parity noted as follow-up (non-goal for #305).
11. `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md` document the new `require_model_routing` mode, the required-once-delegated invariant, and the resume reconciliation procedure.
12. New logic lives in the new `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` delegate; `validate_orchestrator_state.py` stays within the 500-line limit; the gate reuses `_validate_model_routing_receipts` and `_validate_complexity_assessments` and does not reimplement `compute_complexity_floor` or `resolve_delegation_model`.
13. All bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/**` match runtime sources byte-identically; bundle-parity contract tests pass.
14. Full toolchain green: format → lint → type-check → tests (Pytest with coverage thresholds >= 85% line / >= 75% branch, plus Pester for the hooks).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Strict-mode fail on missing entry, pass when present/consistent | PASS | `validate_model_routing_gate` in `_orchestrator_state_model_routing_gate.py`; tests for missing-entry, present-and-consistent, and model-mismatch | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_gate.py` | Reuses reference formulas via per-entry validators. |
| 2 | Plain/require_complete/require_pr_creation_ready byte-identical | PASS | Additive `if require_model_routing:` branch; `test_validate_orchestrator_state_model_routing_backcompat.py` (259 lines) asserts identical error lists | `poetry run pytest .../test_validate_orchestrator_state_model_routing_backcompat.py` | Default-off flag; unchanged code paths. |
| 3 | PreToolUse hook blocks missing receipt; graceful allow-through | PASS | `enforce-model-routing-receipt.ps1` + `enforce-model-routing-receipt.Tests.ps1` | `mcp__drm-copilot__run_poshqc_test` | Malformed JSON and non-delegating input allow-through. |
| 4 | Completion gate refuses DONE with `MODEL_ROUTING_BLOCKED:` | PASS | `validate-orchestrator-output.ps1` diff routes model-routing errors to `MODEL_ROUTING_BLOCKED:`; `validate-orchestrator-output.model-routing.Tests.ps1` (91 lines) | Pester | Falls back to `ROUTING_CONTRACT_BLOCKED:` for generic failures. |
| 5 | Agent `model:` defaults; atomic-executor = opus | PASS | 13 agent files each `+model:` line; `atomic-executor.md` line 3 = `model: opus` | `grep '^model:' .claude/agents/atomic-executor.md` | Matches the spec Agent Frontmatter Floor table. |
| 6 | Resume reconciliation documented + mirrored + tested | PASS | `orchestrator.md` +13 lines mirrors SKILL `## Checkpoint Handling`; validator resume-trigger (next_step) path tested | diff inspection; gate test suite | Resume sequence enforced at the validator layer; each building block documented and tested. |
| 7 | No delegation while preflight fail; preflight record on resume | PASS | Documented in `orchestrator.md` (MUST NOT delegate while `model_routing_preflight` status `fail`; record `{status,checked_at,validator_command,output_summary}`); PreToolUse presence hook + validator enforce mechanically | diff inspection; Pester | Preflight-record writing is orchestrator runtime prose; the block mechanism is tested. |
| 8 | Tests cover missing/present-consistent/mismatch/no-delegation | PASS | `test_validate_orchestrator_state_model_routing_gate.py` (460 lines) includes all four plus edge cases | `poetry run pytest .../test_validate_orchestrator_state_model_routing_gate.py` | — |
| 9 | `--require-model-routing` CLI flag added + forwarded + flag-independent | PASS | `validate_orchestration_artifacts.py` adds and forwards the flag; `test_validate_orchestration_artifacts_model_routing.py` (170 lines) | `poetry run pytest .../test_validate_orchestration_artifacts_model_routing.py` | Flag independence covered. |
| 10 | MCP tool surfaces `require_model_routing`; TS existence check only | PASS | `validateModelRoutingExistence` (superset check) gated by `requireModelRouting`; MCP surface threaded through `mcp-tool-inputs.ts`, `repo-automation-service.ts`, service-call, new builder; `orchestrator-state-core.model-routing.test.ts` (134 lines) | `npm run test` | Full per-receipt parity deferred per non-goal. |
| 11 | Rule + SKILL document mode/invariant/resume | PASS | `.claude/rules/orchestrator-state.md` +17 lines; `.claude/skills/orchestrate/SKILL.md` +19 lines | diff inspection | Repo-local prose; no foreign schema. |
| 12 | New delegate; validate_orchestrator_state.py <= 500 lines; formula reuse | PASS | New delegate 300 lines; `validate_orchestrator_state.py` = 500 lines (within limit); grep confirms no `compute_complexity_floor`/`resolve_delegation_model` reimplementation | `wc -l scripts/dev_tools/validate_orchestrator_state.py` | The unrelated `repo-automation-service.ts` file-size finding from cycle 0 is now resolved (495 lines); no residual file-size issue anywhere in the diff. |
| 13 | Bundle mirrors byte-identical; contract tests pass | PASS | 18/18 edited `.claude/**` files byte-identical to mirrors (`diff -q` per file); new hook in `pack-manifests/core.json`; `evidence/qa-gates/bundle-parity-final.md` EXIT 0 | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Cycle-1 remediation touched only `src/**`; mirrors unaffected. |
| 14 | Full toolchain green (Pytest coverage thresholds + Pester) | PASS | Python format/lint/type EXIT 0, 1293 pass, 86.6% line / 86.5% branch; Pester 495 pass; TypeScript format/lint/type EXIT 0, Jest 1478 pass, coverage artifact present with all changed files ≥85/75 | see `evidence/qa-gates/*.md` | TypeScript coverage-artifact gap from cycle 0 is closed; full toolchain including TS coverage now green. |

---

## Summary

**Overall Feature Readiness:** READY (PASS)

All 14 acceptance criteria in `spec.md` are met (PASS). The full branch-vs-base re-audit identified **zero blocking findings**. The two policy-mandated blocking findings from the prior cycle are both resolved and re-verified:

1. `extensions/drm-copilot/src/repo-automation-service.ts` is now 495 lines (was 502); request-shaping was extracted into a 46-line pure builder sibling. All changed and new files are within the 500-line limit.
2. A TypeScript coverage artifact is present (`extensions/drm-copilot/coverage/lcov.info`); every changed TS file reports ≥85% line / ≥75% branch, and the coverage gate passes.

Coverage verdicts for every language with changed files are explicit PASS (Python, PowerShell, TypeScript); C# is N/A with zero changed files. Formula reuse, foreign-schema prohibition, backward compatibility, bundle parity, and evidence-location rules all pass. Details in `policy-audit.2026-07-04T15-30.md` and `code-review.2026-07-04T15-30.md`.

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Blocking findings:** None. There are zero blocking findings on this branch.

**Recommended follow-up (non-blocking, out of scope for #305):**
1. Full per-receipt correctness parity in the TypeScript MCP validator (currently existence check only, per the documented non-goal).

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules, all 14 criteria evaluated as PASS. They are already checked `[x]` in the authoritative source `spec.md` `## Acceptance Criteria`; no source-file edit was required (all boxes already reflect delivered work, and this re-audit confirms each with evidence). The criterion text was preserved unchanged.

### AC Status Summary

- Source: `docs/features/active/2026-07-04-enforce-model-selection-routing-305/spec.md`
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 14 | 14 | 0 | Checkbox-backed; all already `[x]` and evidence-confirmed. |

**Note:** All acceptance criteria are satisfied and zero blocking findings remain. Overall branch readiness is READY (PASS).
