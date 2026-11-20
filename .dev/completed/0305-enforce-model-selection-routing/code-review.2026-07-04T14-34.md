# Code Review: enforce-model-selection-routing (Issue #305)

**Review Date:** 2026-07-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-04-enforce-model-selection-routing-305`
**Feature Folder Selection Rule:** Suffix `-305` matches the branch issue number; scoping docs (`spec.md`, `plan.md`) are the material changed docs.
**Base Branch:** `main` @ `f530d0e3ae7c5d0974b72cf0956e862dd94041c5`
**Head Branch:** `bug/enforce-model-selection-routing` @ `3f62485b1fc59f21b42c7bc5c40ea9422533ff6a`
**Review Type:** Initial review

**Template provenance:** MCP `resolve_policy_audit_template_asset` (`code-review-template`) was unavailable in this environment; constructed from `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`.

---

## Executive Summary

The change enforces the previously documented-but-unenforced model-selection procedure. It adds a `require_model_routing` existence gate to the orchestrator-state validator (new sibling delegate `_orchestrator_state_model_routing_gate.py`), a `--require-model-routing` CLI flag, a PreToolUse presence-deterrent hook (`enforce-model-routing-receipt.ps1`), a `MODEL_ROUTING_BLOCKED:` completion-gate reason, documented resume reconciliation in the orchestrate SKILL and orchestrator agent, `model:` frontmatter floors on 13 agents, and a TypeScript MCP existence check. The implementation is well-factored, reuses the reference formulas rather than reimplementing them, and preserves backward compatibility through a default-off, flag-gated code path.

**What changed:** Python validator core (+21/-16) plus a 300-line gate delegate and 889 lines of new Python tests; one new and one edited PowerShell hook plus 193 lines of Pester tests; TypeScript MCP surface threading (`requireModelRouting`) plus a 113-line `validateModelRoutingExistence` port and a 134-line test; 13 agent frontmatter edits; settings.json/pack-manifest wiring; and byte-identical `.claude/**` bundle mirrors.

**Top 3 risks:**
1. `extensions/drm-copilot/src/repo-automation-service.ts` now exceeds the hard 500-line file limit (502 lines), a policy violation introduced by this change.
2. No TypeScript coverage artifact is produced (no coverage script wired), so changed-line coverage on the TS additions is unverifiable against the 85%/75% thresholds.
3. Agent-only (not per-(agent,phase)) correlation in the existence gate is an accepted minimum-granularity design; a single receipt per agent satisfies the gate even across multiple phases at different bands. This is documented in the spec Risks section, not a defect.

**PR readiness recommendation:** **Needs Revision** — the functional design is sound and Python/PowerShell scopes are green, but two policy-mandated blocking findings (file-size limit and absent TS coverage artifact) must be cleared first.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/repo-automation-service.ts` | whole file (502 lines) | File exceeds the hard 500-line limit; baseline was 497, this change added +5 lines (threading `requireModelRouting`), crossing the limit. | Extract a helper (e.g., the request-shaping block around lines 448–469) into a sibling module to bring the file under 500 lines. | `general-code-change.md` states no production file may exceed 500 lines; feature-review treats this as blocking. | `wc -l` = 502; `git show <base>:…` = 497; diff `+5/-0`. |
| Blocker | `extensions/drm-copilot` (TS project) | coverage tooling | No TypeScript coverage artifact exists (`coverage/lcov.info` absent; no `test:coverage`/`collectCoverage` wired). Coverage verification is mandatory for every language with changed files. | Wire a Jest coverage script + lcov reporter, run it, and confirm ≥85% line / ≥75% branch on changed TS code; commit the artifact. | Mandatory-coverage rule and the workflow's absent-artifact FAIL trigger. TS has changed production files (`orchestrator-state-core.ts` +113, MCP surface). | `evidence/qa-gates/typescript-qa.md` reports tests only, no coverage; artifact search returned ABSENT. |
| Info | `scripts/dev_tools/validate_orchestrator_state.py` | 500 lines | File is exactly at the 500-line limit after the change (compliant, not exceeding), by design per spec (new logic pushed into the delegate). | None; monitor future additions. | Confirms the spec's file-size boundary decision held. | `wc -l` = 500. |
| Info | `scripts/dev_tools/validate_orchestrator_state.py` | `STEP_STATUS_KEYS` | DRY refactor extracts the duplicated step-status tuple into a module constant used in both the general and completion checks. | None; positive change. | Reduces duplication without behavior change; covered by existing tests. | diff hunk 2. |
| Info | `.claude/hooks/enforce-model-routing-receipt.ps1` | 168–170 | Dot-source guard returns before the entrypoint, enabling seam-based testing without disk I/O. | None. | Good testability pattern consistent with repo PowerShell seam guidance. | file inspection. |

No Major or Minor findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well
- The existence gate is isolated in a dedicated delegate with a complete module docstring, an `__all__` export surface, and per-function docstrings and intent comments. It fires only when at least one delegating agent is derivable, cleanly preserving backward compatibility for delegation-free checkpoints.
- The gate delegates per-entry correctness to the existing `_validate_model_routing_receipts` and `_validate_complexity_assessments`, so `resolve_delegation_model` and `compute_complexity_floor` are never reimplemented. Verified by grep.
- The validator integration is a strictly additive `if require_model_routing:` branch appended after the existing checks, so plain / `require_complete` / `require_pr_creation_ready` paths are byte-identical (regression-covered by `test_validate_orchestrator_state_model_routing_backcompat.py`).

#### Typing and API notes
- New keyword is keyword-only with a `False` default, mirroring `require_pr_creation_ready`. `cast(...)` is used narrowly at untyped dict/list boundaries; Pyright EXIT 0. No new broad `Any` surface.

#### Error handling and logging
- Errors are appended as checkpoint-context-prefixed strings and returned; the gate never mutates its input. Sorting of missing agents/phases (`sorted(..., key=repr)`) yields deterministic error ordering.

### TypeScript implementation audit

#### What changed well
- `validateModelRoutingExistence` implements exactly the scoped existence check (delegated-agent set ⊆ receipt-agent set) and is gated behind `options.requireModelRouting === true`, consistent with the documented non-goal of full per-receipt parity.

#### Type safety and maintainability
- The MCP parameter is threaded as an optional `readonly requireModelRouting?: boolean` through the service interface and tool input types; no suppressions introduced. The maintainability concern is the 500-line overflow in `repo-automation-service.ts` (Blocker above), not the routing logic itself.

#### Error handling and logging
- Existence errors reuse the same message shape as the Python validator, keeping the two layers consistent.

### PowerShell implementation audit

#### What changed well
- The new PreToolUse hook enforces presence only (it cannot see the delegate's `model`), gates exactly the Agent-tool delegate set, and allows through non-delegating input and malformed JSON gracefully. The completion-hook edit routes model-routing failures to `MODEL_ROUTING_BLOCKED:` while falling back to `ROUTING_CONTRACT_BLOCKED:` for generic failures, distinguished by matching `model_routing_receipts|complexity_assessments` in the error text.

#### API and safety notes
- Advanced functions with `[CmdletBinding()]`, typed params, and `[OutputType]`; PoshQC analyze clean. The single subprocess call now carries both `--require-complete` and `--require-model-routing`, avoiding a second process spawn.

#### Error handling and logging
- Entrypoint wraps the decision in try/catch with `Write-Error` + `exit 1`; success path emits the JSON decision and `exit 0`.

---

## Test Quality Audit

Automated evidence is strong for Python and PowerShell and functionally present for TypeScript; the gap is the missing TS coverage metric.

### Reviewed test and QA artifacts
- `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_gate.py` (460 lines) — covers strict-mode missing-entry, present-and-consistent, present-but-model-mismatch, missing-phase assessment, `next_step`-triggered requirement, namespaced/malformed entries, and non-list arrays. High-quality scenario matrix.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_backcompat.py` (259 lines) — asserts byte-identical results for plain / `require_complete` / `require_pr_creation_ready`, with and without the arrays present.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py` (170 lines) — CLI flag forwarding and flag independence.
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` (102 lines) and `validate-orchestrator-output.model-routing.Tests.ps1` (91 lines) — hook allow/deny paths and block-reason routing.
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.model-routing.test.ts` (134 lines) — TS existence-check behavior.
- `evidence/qa-gates/*.md` — format/lint/type/test/coverage gate records (Python + PowerShell coverage present; TS coverage absent).

### Quality assessment prompts
- **Determinism:** No wall-clock/RNG/network/temp-file usage in the changed tests.
- **Isolation:** Each test exercises one behavior with a purpose-built fixture.
- **Speed:** Pure in-memory validation; suites complete quickly (1293 Python, 495 Pester, 1473 Jest all pass).
- **Diagnostics:** Assertions match on specific error substrings (e.g., `"missing a receipt for delegated agent: atomic-executor"`), giving actionable failures.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials/tokens introduced in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | PowerShell subprocess uses fixed `python -m …` args with the `$Invoker` seam; no string interpolation of untrusted input into commands. |
| Input validation at boundaries | ✅ PASS | Gate treats non-list/malformed entries defensively; hook handles empty/malformed JSON via allow-through. |
| Error handling remains explicit | ✅ PASS | Explicit error-string accumulation (Python) and try/catch with `exit 1` (PowerShell entrypoint). |
| Configuration / path handling is safe | ✅ PASS | Checkpoint path is a fixed default resolved behind a mockable seam; `Test-Path -LiteralPath`. |

---

## Research Log

No external research required. Verdicts are grounded in the branch diff, the feature-folder evidence artifacts, repository policy rules, and direct toolchain/file inspection.

---

## Verdict

The implementation is a sound, well-tested, backward-compatible enforcement layer that correctly reuses the reference formulas and maintains byte-identical bundle mirrors. It is not ready for normal PR flow as-is because of two policy-mandated blocking findings: `repo-automation-service.ts` exceeds the 500-line file limit, and the TypeScript scope has no coverage artifact despite having changed production files. After a small extraction to restore the file-size limit and wiring/running TypeScript coverage to confirm the thresholds on changed lines, the change should be ready. This conclusion is consistent with the Findings Table and the Needs Revision recommendation above.
