# Code Review: enforce-model-selection-routing (Issue #305)

**Review Date:** 2026-07-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-04-enforce-model-selection-routing-305`
**Feature Folder Selection Rule:** Suffix `-305` matches the branch issue number; scoping docs (`spec.md`, `plan.md`) are the material changed docs.
**Base Branch:** `main` @ `f530d0e3ae7c5d0974b72cf0956e862dd94041c5`
**Head Branch:** `bug/enforce-model-selection-routing` @ `355cbbc95e1cf422ce667365b180f4461cd0ee13`
**Review Type:** Re-review after remediation cycle 1

**Template provenance:** MCP `resolve_policy_audit_template_asset` (`code-review-template`) was unavailable in this environment; constructed from `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`.

---

## Executive Summary

The change enforces the previously documented-but-unenforced model-selection procedure. It adds a `require_model_routing` existence gate to the orchestrator-state validator (new sibling delegate `_orchestrator_state_model_routing_gate.py`), a `--require-model-routing` CLI flag, a PreToolUse presence-deterrent hook (`enforce-model-routing-receipt.ps1`), a `MODEL_ROUTING_BLOCKED:` completion-gate reason, documented resume reconciliation in the orchestrate SKILL and orchestrator agent, `model:` frontmatter floors on 13 agents, and a TypeScript MCP existence check. The implementation is well-factored, reuses the reference formulas rather than reimplementing them, and preserves backward compatibility through a default-off, flag-gated code path.

This is a re-review after remediation cycle 1. The two blocking findings from `code-review.2026-07-04T14-34.md` are both resolved:

1. `repo-automation-service.ts` is now 495 lines (was 502). The request-shaping block was extracted into a new pure builder `src/lib/validate/build-validate-orchestration-service-call-input.ts` (46 lines) with a full docstring and preserved omit-ternary semantics; behavior is unchanged and the module is covered by a new dedicated test.
2. A TypeScript Jest coverage run is wired (`test:coverage` script, lcov reporter, per-changed-file `coverageThreshold` with no `global` key). The artifact `extensions/drm-copilot/coverage/lcov.info` is present and every changed TS file reports ≥85% line / ≥75% branch.

**What changed (whole diff):** Python validator core (+21/-16) plus a 300-line gate delegate and 889 lines of new Python tests; one new and one edited PowerShell hook plus 193 lines of Pester tests; TypeScript MCP surface threading (`requireModelRouting`), a 113-line `orchestrator-state-core.ts` existence port, a 46-line extracted builder, and 278 lines of new TS tests; Jest coverage wiring; 13 agent frontmatter edits; settings.json/pack-manifest wiring; and byte-identical `.claude/**` bundle mirrors.

**Top risks (residual, non-blocking):**
1. Agent-only (not per-(agent,phase)) correlation in the existence gate is an accepted minimum-granularity design; a single receipt per agent satisfies the gate even across multiple phases at different bands. Documented in the spec Risks section; not a defect.
2. Full per-receipt correctness parity in the TypeScript MCP validator is deferred (existence check only). This is an explicit non-goal for #305; authoritative correctness enforcement stays on the Python path.
3. The `extensions/drm-copilot` package uses Jest rather than the Vitest named in `typescript.md`. Pre-existing package-wide choice, not introduced by this branch.

**PR readiness recommendation:** **Ready.** Both prior blockers are cleared; the full re-review found zero blocking, major, or minor findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `extensions/drm-copilot/src/repo-automation-service.ts` | whole file | Prior Blocker (502 lines) resolved: request-shaping extracted to sibling; file now 495 lines. | None. | Restores the 500-line limit without behavior change. | `wc -l` = 495; new sibling `wc -l` = 46; `evidence/qa-gates/linecount-postchange.md`. |
| Resolved | `extensions/drm-copilot` (TS project) | coverage tooling | Prior Blocker (absent coverage artifact) resolved: `test:coverage` wired; artifact present; changed files ≥85/75. | None. | Satisfies mandatory coverage verification for TS. | `extensions/drm-copilot/coverage/lcov.info` present (405 KB); `evidence/qa-gates/typescript-coverage.md` COVERAGE_GATE: PASS. |
| Info | `extensions/drm-copilot/src/lib/validate/build-validate-orchestration-service-call-input.ts` | 24–46 | Extracted builder is a pure function that preserves the prior inline spread semantics (optional keys omitted when `undefined`), keeping `exactOptionalPropertyTypes` behavior identical. | None; positive change. | Clean separation of request-shaping from the service; independently testable. | file inspection; `build-validate-orchestration-service-call-input.test.ts` (144 lines, 100% line/branch). |
| Info | `scripts/dev_tools/validate_orchestrator_state.py` | 500 lines | File is exactly at the 500-line limit (compliant, not exceeding) by design; new logic pushed into the delegate. | None; monitor future additions. | Confirms the spec's file-size boundary decision held. | `wc -l` = 500. |
| Info | `.claude/hooks/enforce-model-routing-receipt.ps1` | dot-source guard | Dot-source guard returns before the entrypoint, enabling seam-based testing without disk I/O. | None. | Good testability pattern consistent with repo PowerShell seam guidance. | file inspection. |

No Blocker, Major, or Minor findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well
- The existence gate is isolated in a dedicated delegate with a complete module docstring, an `__all__` export surface, and per-function docstrings and intent comments. It fires only when at least one delegating agent is derivable, cleanly preserving backward compatibility for delegation-free checkpoints.
- The gate delegates per-entry correctness to the existing `_validate_model_routing_receipts` and `_validate_complexity_assessments`, so `resolve_delegation_model` and `compute_complexity_floor` are never reimplemented (verified by grep; no `def` reimplementation, only imports of the reused validators).
- The validator integration is a strictly additive `if require_model_routing:` branch appended after the existing checks, so plain / `require_complete` / `require_pr_creation_ready` paths are byte-identical (regression-covered by `test_validate_orchestrator_state_model_routing_backcompat.py`).

#### Typing and API notes
- New keyword is keyword-only with a `False` default, mirroring `require_pr_creation_ready`. `cast(...)` is used narrowly at untyped dict/list boundaries; Pyright EXIT 0. No new broad `Any` surface.

#### Error handling and logging
- Errors are appended as checkpoint-context-prefixed strings and returned; the gate never mutates its input. Deterministic error ordering via `sorted(..., key=repr)`.

### TypeScript implementation audit

#### What changed well
- `validateModelRoutingExistence` implements exactly the scoped existence check (delegated-agent set ⊆ receipt-agent set) and is gated behind `options.requireModelRouting === true`, consistent with the documented non-goal of full per-receipt parity.
- The cycle-1 extraction (`buildValidateOrchestrationServiceCallInput`) is a pure function with an explicit docstring noting the preserved omit-ternary semantics. This both restores the file-size limit and improves separation of request-shaping from the service class.

#### Type safety and maintainability
- The MCP parameter is threaded as an optional `readonly requireModelRouting?: boolean` through the service interface, tool input types, and the new builder; no suppressions introduced (`@ts-ignore` / `@ts-nocheck` / `eslint-disable` grep returned none in changed files).

#### Error handling and logging
- Existence errors reuse the same message shape as the Python validator, keeping the two layers consistent.

### PowerShell implementation audit

#### What changed well
- The new PreToolUse hook enforces presence only (it cannot see the delegate's `model`), gates exactly the Agent-tool delegate set, and allows through non-delegating input and malformed JSON gracefully. The completion-hook edit routes model-routing failures to `MODEL_ROUTING_BLOCKED:` while falling back to `ROUTING_CONTRACT_BLOCKED:` for generic failures, distinguished by matching `model_routing_receipts|complexity_assessments` in the error text.

#### API and safety notes
- Advanced functions with `[CmdletBinding()]`, typed params, and `[OutputType]`; PoshQC analyze clean. The single subprocess call carries both `--require-complete` and `--require-model-routing`, avoiding a second process spawn.

#### Error handling and logging
- Entrypoint wraps the decision in try/catch with `Write-Error` + `exit 1`; success path emits the JSON decision and `exit 0`.

---

## Test Quality Audit

Automated evidence is strong across all three languages; the TS coverage gap from cycle 0 is closed.

### Reviewed test and QA artifacts
- `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_gate.py` (460 lines) — strict-mode missing-entry, present-and-consistent, present-but-model-mismatch, missing-phase assessment, `next_step`-triggered requirement, namespaced/malformed entries, non-list arrays.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_backcompat.py` (259 lines) — byte-identical results for plain / `require_complete` / `require_pr_creation_ready`, with and without the arrays present.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py` (170 lines) — CLI flag forwarding and flag independence.
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` (102 lines) and `validate-orchestrator-output.model-routing.Tests.ps1` (91 lines) — hook allow/deny paths and block-reason routing.
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.model-routing.test.ts` (134 lines) — TS existence-check behavior.
- `extensions/drm-copilot/test/lib/validate/build-validate-orchestration-service-call-input.test.ts` (144 lines) — new builder; exercises all combinations of `requireComplete` / `requireModelRouting` present vs absent (closed the branch-coverage gap noted mid-cycle).
- `evidence/qa-gates/*.md` — format/lint/type/test/coverage gate records; Python, PowerShell, and TypeScript coverage all present.

### Quality assessment prompts
- **Determinism:** No wall-clock/RNG/network/temp-file usage in the changed tests.
- **Isolation:** Each test exercises one behavior with a purpose-built fixture.
- **Speed:** Pure in-memory validation; suites complete quickly (1293 Python, 495 Pester, 1478 Jest all pass).
- **Diagnostics:** Assertions match on specific error substrings, giving actionable failures.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credentials/tokens introduced in the diff. |
| No unsafe subprocess or command construction | PASS | PowerShell subprocess uses fixed `python -m …` args with a seam; no interpolation of untrusted input into commands. |
| Input validation at boundaries | PASS | Gate treats non-list/malformed entries defensively; hook handles empty/malformed JSON via allow-through. |
| Error handling remains explicit | PASS | Explicit error-string accumulation (Python) and try/catch with `exit 1` (PowerShell entrypoint). |
| Configuration / path handling is safe | PASS | Checkpoint path resolved behind a mockable seam; `Test-Path -LiteralPath`. |

---

## Research Log

No external research required. Verdicts are grounded in the branch diff, the feature-folder evidence artifacts, repository policy rules, and direct toolchain/file inspection.

---

## Verdict

The implementation is a sound, well-tested, backward-compatible enforcement layer that correctly reuses the reference formulas and maintains byte-identical bundle mirrors. Both blocking findings from the prior review are resolved and re-verified: `repo-automation-service.ts` is under the 500-line limit via a clean pure-function extraction, and the TypeScript scope now produces a coverage artifact showing every changed file at or above the thresholds. The full re-review found zero blocking, major, or minor findings. The change is ready for normal PR flow.
