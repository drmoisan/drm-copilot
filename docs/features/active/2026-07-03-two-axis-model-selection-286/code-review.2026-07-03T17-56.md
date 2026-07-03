# Code Review: two-axis-model-selection (Issue #286)

**Review Date:** 2026-07-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-03-two-axis-model-selection-286`
**Feature Folder Selection Rule:** Suffix `-286` matches the issue number in the branch name `feature/two-axis-model-selection-286`.
**Base Branch:** `main` @ `9a5de0c549327f2e47521cae51d2514e8b28b54b`
**Head Branch:** `feature/two-axis-model-selection-286` @ `e2d47f6d610fcbeca97d57a24603168a167b87ec`
**Review Type:** Post-remediation re-review (remediation cycle 1 exit) after cherry-pick onto current `main`.

---

## Executive Summary

This change adds a two-axis model-selection mechanism to the orchestration runtime. It keeps the file-count-driven `route` strictly separate from a judgment-based `complexity_band` that alone drives the delegation model tier. The implementation comprises two pure Python reference formulas (`compute_complexity_floor`, `resolve_delegation_model`), two additive checkpoint validators wired through a key-gated loop in `validate_orchestrator_state_text`, a `model_policy`/`model_budget` config block, two new small-tier delegation agents (`commit-message` haiku, `human-exception-runbook` sonnet), orchestrator allowlist/settings authorization, and documentation edits to the `orchestrate`/`epic-orchestrate` skills and the `orchestrator-state.md` rule. All eight bundled mirror files are byte-identical to their repo-root sources.

**What changed:** 52 files, +3161/-19. Nine Python files (five source, four test) are the only changed programming-language files; the rest are JSON config (plus mirror), Markdown docs/skills/agents, and feature evidence. The Python toolchain (Black, Ruff, Pyright, Pytest+coverage) is green on fresh execution against the current base. All four new modules are at 100% line and branch coverage.

**Top 3 risks:**
1. Documented parity gap: the live MCP `validate_orchestration_artifacts` tool is a TypeScript port not updated here, so malformed complexity/routing arrays are enforced only on the Python path until a tracked follow-up ports the validators (spec DD-1 / Risks). Non-blocking and intentional.
2. `model:` values `haiku`/`sonnet` for the two new agents rely on runtime frontmatter acceptance; a smoke-check is recorded in evidence (`agent-frontmatter-smoke-check.md`). Non-blocking.
3. The reference implementations are not wired into a runtime call path (by design; applied by judgment and documented in skills). Correct per Out of Scope, but means enforcement of correct usage depends on orchestrator discipline plus the checkpoint validators.

**PR readiness recommendation:** **Go** — The change is additive, fully tested, policy-compliant, and green on a fresh toolchain run against the current base. No Blocker or Major findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev_tools/resolve_delegation_model.py` | docstring `Raises:` | `resolve_delegation_model` documents `KeyError` on an out-of-enum `band`; the model-routing validator guards the band enum before calling, so the raise is unreachable from the validator path. | No change required; the guard in `_validate_one_receipt` is correct and the docstring accurately states the contract for direct callers. | Confirms fail-fast behavior is intentional and safely bounded. | `_orchestrator_state_model_routing.py` band-enum guard at `_validate_one_receipt`; `resolve_delegation_model.py` docstring. |
| Info | `extensions/drm-copilot/src/lib/validate/*` | n/a (not in diff) | TypeScript MCP port not updated; malformed new arrays are enforced only on the Python path until a follow-up. | Track the follow-up issue as recorded in spec Risks. | Documented, intentional scope boundary; not a defect in this diff. | spec.md DD-1 and Risks. |
| Info | `.claude/agents/commit-message.md`, `human-exception-runbook.md` | frontmatter `model:` | New `model:` tiers `haiku`/`sonnet` have no prior precedent in the agent corpus. | Retain the recorded smoke-check evidence. | Runtime acceptance is environment-dependent; evidence mitigates. | `evidence/other/agent-frontmatter-smoke-check.md`. |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The two reference formulas are genuinely pure: no file reads, no mutation, deterministic, with constants that mirror the `model_policy` config block one-to-one. `compute_complexity_floor` encodes the never-exceed-C3 invariant structurally via `min(highest_rank, index("C3"))`, so C4 is unreachable by construction rather than by a runtime check that could be forgotten.
- The validators follow the established `human_interaction` additive precedent exactly: a shared `optional_key_validators` tuple iterated with an `if key in state_map` gate. This keeps backward compatibility structural (absent key -> zero errors) and puts all four additive blocks on one uniform code path.
- Splitting the two validators into `_orchestrator_state_complexity.py` and `_orchestrator_state_model_routing.py` keeps `validate_orchestrator_state.py` within the 500-line limit and keeps each concern cohesive. The `__all__` re-export of the `_`-prefixed helpers is a deliberate, documented cross-module boundary rather than accidental private usage.
- Error accumulation is complete: each validator iterates all entries and returns one error string per violated invariant instead of stopping at the first failure, which yields actionable, checkpoint-context-prefixed messages.

#### Typing and API notes

- Full type annotations throughout; `Literal` aliases for `ComplexityBand` and `FablePolicy`. `Any` appears only in `cast(...)` narrowing of opaque parsed JSON, which is the correct pattern for validator input. Pyright reports 0 errors.
- Public surface is minimal and keyword-free by design (small positional pure functions returning typed dicts matching the receipt shape). No breaking change to `validate_orchestrator_state_text`'s signature; the new behavior is purely additive.

#### Error handling and logging

- Validators never raise on malformed content; they return `list[str]`. This is verified by non-list and non-object entry tests. `resolve_delegation_model` fails fast with `KeyError` on an out-of-enum band for direct callers, but the validator guards the enum first, so the checkpoint path cannot trigger it.
- No `print`; no broad `except`. Consistent with `python.md`.

---

## Test Quality Audit

The test suite for this feature is thorough and behavior-focused. It covers positive flows (well-formed receipts validate clean), negative flows (each invariant violation asserts a specific error string), edge cases (empty signals -> C1, many floor signals still clamp to C3), and backward compatibility (checkpoints lacking the new arrays validate unchanged). Notably, `test_resolve_delegation_model.py` reads the `preferred_overlay.agents` list directly from `config/orchestration-routing.json`, so the code-vs-config agreement is itself under test rather than duplicated by hand.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_compute_complexity_floor.py` — floor guards, max-of-multiple, no-signal C1, never-exceed-C3, determinism. 100% coverage of the module.
- `tests/scripts/dev_tools/test_resolve_delegation_model.py` — base table, available, disabled clamp with provenance, preferred overlay scope, non-overlay invariance, determinism, config cross-check. 100% coverage.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` — enum/floor/ordering/rationale invariants, fail-closed shapes, backward-compat. 100% coverage.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py` — model equality, disabled-mode no-fable and clamp-provenance, backward-compat. 100% coverage.
- `evidence/qa-gates/final-pytest-coverage.md` and regenerated `artifacts/python/lcov.info` — corroborate the figures independently confirmed this run.
- `evidence/regression-testing/route-not-model-input.md`, `determinism-and-floor-invariants.md`, `backward-compat-checkpoints.md` — targeted regression evidence.

### Quality assessment prompts

- **Determinism:** Pure functions; explicit determinism tests; no clock/RNG/network/tempfile.
- **Isolation:** One behavior per test; parametrized band matrices.
- **Speed:** Full suite ~6.9s; new-module subset 33 tests in 0.23s.
- **Diagnostics:** Assertions compare exact error strings and resolved dict fields, so a failure names the exact invariant.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; only band/model literals and config text. |
| No unsafe subprocess or command construction | PASS | No subprocess in the changed Python; `commit-message` agent tools are read-only `Bash(git log *)`/`Bash(git diff *)`. |
| Input validation at boundaries | PASS | Validators treat all checkpoint input as untrusted, guard shape/enum before use, and fail closed. |
| Error handling remains explicit | PASS | No broad `except`; validators accumulate literal errors and never raise. |
| Configuration / path handling is safe | PASS | Pure functions read no files; config parity enforced by byte-identity contract. |

---

## Research Log

No external research required. All evidence derives from the branch diff, fresh toolchain execution, the feature evidence tree, and the repository policy rules.

---

## Verdict

The change is ready for normal PR flow. It is a cohesive, additive feature with pure, well-documented reference implementations, backward-compatible key-gated validators, byte-identical bundle mirrors, and comprehensive tests at 100% coverage on the new modules. The Python toolchain is green on a fresh run against the current base (`9a5de0c`). The only carried-forward items are documented, intentional scope boundaries (TypeScript-port parity gap and the un-wired reference formulas), each recorded as follow-ups and none constituting a defect in this diff. Recommendation: **Go**, zero blocking findings.
