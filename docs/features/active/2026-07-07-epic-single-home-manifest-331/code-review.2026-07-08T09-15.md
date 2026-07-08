# Code Review: epic-single-home-manifest (Issue #331)

**Review Date:** 2026-07-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-07-epic-single-home-manifest-331/`
**Feature Folder Selection Rule:** Suffix `-331` matches the canonical issue number and the branch name `feature/epic-single-home-manifest-331`.
**Base Branch:** `main` (merge base `ee65d6e9e99b86bdbd7d00dcc47fc90db39ff56b`)
**Head Branch:** `feature/epic-single-home-manifest-331` @ `732a607d60ea2b9e8072b3cf594caf2b810f1e09`
**Review Type:** Initial review

---

## Executive Summary

The branch implements the single-epic-home layout across two coordinated parity trees plus supporting docs, templates, skill/mirror, push-down, and parity gates. The diff is 65 files, +3516/-341, of which 7 are Python core-logic files and ~4 are TypeScript source files; the remainder are tests, templates, the epic-orchestrate skill and its byte-identical mirror, and feature documentation/evidence.

The implementation is disciplined. New resolution logic (issue_num-keyed dependency resolution, lifecycle-prefix normalization, presence-gated intent validation) is extracted into dedicated sibling modules on both sides (`_epic_orchestrator_state_resolution.py`, `epic-orchestrator-state-resolution.ts`), keeping the host validators under the 500-line limit and providing a single shared resolver reused by every dependency-aware check. All new/changed helpers are additive and key-gated: on the legacy folder-basename shape the resolver is identity and intent validation is a no-op, which is what makes the byte-identical backward-compatibility guarantee credible. The claim is backed by unchanged legacy fixtures and green legacy-regression evidence.

**What changed:**
- Python: new `_epic_orchestrator_state_resolution.py` (+288); `validate_epic_orchestrator_state.py` refactored to consume the shared resolver (+40/-71); epic branch added to `new_active_feature_folder_flow.py` / `_io.py` / `_docs.py`; new + updated tests.
- TypeScript: new `epic-orchestrator-state-resolution.ts` (+287); parity edits to `epic-orchestrator-state-core.ts`, `flow.ts`, `io.ts`, `docs.ts`; new/updated vitest suites.
- Docs/skill: `epic-orchestrate/SKILL.md` + byte-identical mirror updated (path-drift workaround text removed, replaced with issue_num-keyed resolvable-hint phrasing); epic templates add `epic.md` + `epic-status.md`, retire `initiative.md`.

**Top 3 risks:**
1. Backward-compatibility depends on the resolver being exactly identity on legacy keys; this is covered by legacy-regression tests but is the highest-consequence behavior. Verified: legacy fixtures unchanged, regression evidence green.
2. Python↔TS validator parity (error strings must match); covered by `epic-orchestrator-state-core.test.ts` and the parity-validator gate (green).
3. Bundled-mirror byte-identity for the skill; covered by the resource-contract test (green).

**PR readiness recommendation:** **Go** — additive, key-gated, well-tested change with green toolchain and parity gates; no Blocker or Major findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev_tools/new_active_feature_folder_flow.py` | `create_active_folder` (print statements throughout) | CLI flow uses `print()` for user-facing output rather than `logging`. | No change required; consistent with the pre-existing CLI entry-point pattern. | `python.md` discourages ad-hoc print for permanent behavior, but this is a CLI surface where print is the intended output channel and is pre-existing, not introduced here. | Read of flow.py lines 100, 263, 272–292 |
| Info | `scripts/dev_tools/_epic_orchestrator_state_resolution.py` | `resolve_feature_reference` L144-149 | Non-string `depends_on` treated as issue_num with a `try/except TypeError` guard for unhashable values. | Keep. | Explicit, fail-safe handling of malformed input; avoids a crash on an unhashable dependency and reports it as unresolved. | Read of module L112-149 |
| Info | `scripts/dev_tools/validate_epic_orchestrator_state.py` | `_validate_waves_consistency` L344-345 | Two lines slightly exceed typical width but pass Black. | None. | Formatting is Black-clean (reviewer `black --check` exit 0). | Independent black check |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The resolver is a genuinely single shared helper: `build_feature_reference_index` + `resolve_feature_reference` are consumed by `_validate_feature_folder_uniqueness_and_dependencies`, `detect_dependency_cycle`, `_validate_wave_barrier_ordering`, and `_validate_waves_consistency`. This eliminates the triplicated resolution the spec set out to remove and keeps every dependency-aware check on one code path.
- The additive/key-gated design is explicit and testable: `_normalize_folder_hint` returns bare basenames unchanged, so legacy keys resolve identically; `validate_intent_block` returns `[]` when the `intent` key is absent. The docstrings state the byte-identical invariant plainly.
- Extraction into a `_`-prefixed sibling module keeps `validate_epic_orchestrator_state.py` at 457 lines (< 500) and follows the established `_orchestrator_state_*` convention.
- The epic scaffolding branch in `flow.ts`/`flow.py` is minimal and localized: a single `if feature_type == "epic"` target-directory branch, with all other types unchanged, matching FR-2's "child scaffolding unchanged" requirement.

#### Typing and API notes

- All new/changed functions carry complete type hints and Google-style docstrings (Args/Returns/Raises/Side Effects). `Any` appears only for untyped JSON payloads and is isolated with `cast(...)`. Pyright is clean (evidence exit 0).
- No new public API surface beyond the additive helpers; the validator's external contract (`validate_epic_orchestrator_state_text`) signature is unchanged.

#### Error handling and logging

- JSON parse failures and non-object roots return specific error strings rather than raising. Unresolved references and enum violations append literal, checkpoint-context-prefixed messages consistent with the sibling validator idiom. No broad `except` blocks introduced.

### TypeScript implementation audit

#### What changed well

- The TS resolution port (`epic-orchestrator-state-resolution.ts`, +287) mirrors the Python resolver and is covered by 30 port/resolution tests. The parity suite asserts identical error strings, which is the correct guard for the Python↔TS co-authoritative contract.
- The scaffolding edits (`flow.ts`, `io.ts`, `docs.ts`) are small and symmetric with the Python side; no test hard-codes `active/` for the epic path (per FR-2).

#### Type safety and maintainability

- Changed TS files remain well under the 500-line limit (max `flow.ts` 444). Coverage is high (resolution.ts 96.2% line / 89.3% branch; docs.ts 100%). No new suppressions observed in the reviewed diff.

#### Error handling and logging

- Validation returns error-string arrays; boundary checks (object shape, enum membership, list-of-strings) match the Python presence-gated invariants.

### PowerShell / C# implementation audit

Not applicable — no changed files in these languages.

---

## Test Quality Audit

Automated verification is comprehensive and temp-file-free, consistent with `general-unit-test.md` and the spec's Test Requirements.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (+195) — issue_num keying, active/completed hint resolution, presence-gated intent positives/negatives/absent, and legacy byte-identical regression. In-memory JSON fixtures; no temp files.
- `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py` (+31/-28) — epic-path scaffolding assertions using filesystem fakes; asserts no `active/` epic folder and no `initiative.md`.
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (+152) — Python↔TS parity for new and legacy cases.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/{flow,io,docs}.test.ts` — epic scaffolding on the TS side.
- `evidence/regression-testing/py-validator-legacy.2026-07-07T21-08.md` and `py-wave-computation-legacy.2026-07-07T21-08.md` — legacy regression, exit 0 (byte-identical proof).
- `evidence/qa-gates/coverage-delta.2026-07-07T21-08.md` — cross-checked against reviewer-parsed lcov; consistent.

### Quality assessment prompts

- **Determinism:** Pure in-memory validation and filesystem fakes; no clock/RNG/network/temp-file usage.
- **Isolation:** Each test targets a single validator invariant or one scaffolding behavior.
- **Speed:** Unit-level; full Python suite 1309 tests, TS 1568 tests recorded as passing.
- **Diagnostics:** Validator emits literal, context-prefixed error strings, so assertion failures identify the exact invariant.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials/tokens introduced. |
| No unsafe subprocess or command construction | ✅ PASS | New logic is pure in-memory; no subprocess added in changed files. |
| Input validation at boundaries | ✅ PASS | JSON root/shape validated; enum and list-of-strings checks; unhashable dependency guarded. |
| Error handling remains explicit | ✅ PASS | Specific errors returned; no broad catch-all; no silent ignores. |
| Configuration / path handling is safe | ✅ PASS | Epic target dir derived from `build_folder_slug` under the workspace tree; lifecycle-prefix stripping is bounded to a fixed prefix tuple. |

---

## Research Log

No external research required. All findings derive from diff inspection, the PR-context artifacts, the feature evidence tree, direct lcov parsing, and repository policy rules.

---

## Verdict

The change is ready for normal PR flow. It is additive and key-gated, the shared resolver removes the drift the feature targets, typing/docstring/file-size policies are satisfied, and the test suite plus parity gates and legacy regression provide credible backward-compatibility evidence. The only findings are Info-level (a pre-existing CLI print pattern and benign style observations). This conclusion is consistent with the Findings Table and the Go readiness recommendation above.
