# Code Review: Completion helpers missing from the Claude core pack manifest (#984) — Remediation Cycle 1 Exit Re-audit

---

**Review Date:** 2026-10-20
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #984 in the branch name.
**Base Branch:** `main` (merge base `58e5001c5907d74ee24f205690d891b4352fda23`)
**Head Branch:** `bug/completion-helpers-missing-from-core-pack-manifest-984` (committed `a114539915767e4d9f04fe1c8df3b1debb8b11df` plus the uncommitted cycle 1 working-tree change)
**Review Type:** Re-review after remediation cycle 1

---

## Executive Summary

The full branch diff was re-reviewed against the merge base. The committed portion (manifest additions, six hook handler conversions with bundle copies, four Pester suites, Python scanner and closure test, emptied exception sets, CHANGELOG) is unchanged since the prior review (`code-review.2026-10-20T15-34.md`), and the prior assessment of it stands.

Cycle 1 changed one file, `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (+110, -7 relative to `a11453991`). It replaces the `len(scanned) >= 1` floor with two checks per surface, through a new pure helper `_scan_floor_gaps`: a named anchor source must be scanned (`.claude/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-consistency.ps1`), and the scanned set must equal the distinct `.ps1`/`.psm1` entries of the surface's manifests and virtual resources. A helper self-test covers the clean, anchor-absent, and mismatch cases. A narrowed-scan test monkeypatches `Surface.powershell_sources` and asserts the floor then raises. Fail-before evidence shows the narrowed-scan test reporting `DID NOT RAISE` against the old floor. The reviewer re-ran Black, Ruff, and Pyright (clean), the three manifest modules forward and reversed (35 passed each), and the full Python suite (7369 passed, 6 skipped).

The change resolves prior Minor finding 1. Prior Minor finding 2 is accepted unchanged per the cycle inputs.

**What changed (cycle 1):**
`CLAUDE_SCAN_ANCHOR` and `CODEX_SCAN_ANCHOR` constants; `_scan_floor_gaps`; `test_scan_floor_gaps_reports_each_defect`; rewritten `test_scanned_source_floor`; `_narrowed_to` stand-in factory; `test_scanned_source_floor_rejects_narrowed_scan`; `Callable` imported under `TYPE_CHECKING`.

**Top 3 risks:**
1. The narrowed-scan test patches the `Surface` class, so both surfaces are narrowed in every iteration. `pytest.raises` passes as soon as either surface reports a defect. The test proves that the floor rejects a narrowed scan; it does not prove that each surface's row rejects one independently. For example, removing the Codex row from `test_scanned_source_floor` would not fail this test, because the Claude row still raises.
2. The expected set reuses the same `POWERSHELL_SUFFIXES` filter as `Surface.powershell_sources`, so equality detects drift in the method's pack iteration but not a shared change to the suffix tuple. The anchor check covers that case for the anchor's suffix.
3. Command-text closure still matches `.ps1` hooks only (prior Minor finding 2, accepted).

**PR readiness recommendation:** **Go** — no Blocker or Major finding. Commit and push the cycle 1 change; merge remains subject to the S9 CI gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | `test_scanned_source_floor_rejects_narrowed_scan` | `monkeypatch.setattr(Surface, "powershell_sources", ...)` narrows both surfaces at once, so each iteration raises through whichever surface fails first. The per-surface rows are not proven independently. | Narrow only the surface under test (for example, return the real sources when `_surface.bundle_root` differs from the target surface), or compute `_scan_floor_gaps` per surface and assert that the gap messages name the expected label. | A regression that drops one surface's row from the floor would not be detected by this test. | Inspected source; reasoning traced for both iterations: the Claude row raises in each. |
| Info | `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | `test_scanned_source_floor_rejects_narrowed_scan` | The test calls another test function (`test_scanned_source_floor()`) directly. | Optional: extract the per-surface loop into a helper (for example `_floor_gaps_for_surfaces()`) used by both tests. | Calling a test from a test couples the two; a rename or fixture change to one affects the other. | Inspected source. |
| Info | `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | `test_scanned_source_floor`, `expected` | The expected set applies the same suffix filter as `Surface.powershell_sources`. | No change required. | The anchor check supplies the independent signal; equality guards pack-iteration and virtual-resource handling. | Inspected source; `Surface.powershell_sources` lines 117-142. |
| Minor | `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` | `_HOOK_PATH` | Carried from the prior review: command-text closure matches `.(claude|codex)/hooks/<name>.ps1` only. | Extend the pattern if non-PowerShell hooks are registered later. | Accepted unchanged in cycle 1; no non-PowerShell hook is registered today. | `remediation/2026-10-20T15-44/remediation-inputs.md` rationale. |
| Info | `.claude/hooks/enforce-discovery-artifact-gate.ps1` | handler deny | Carried from the prior review: handler deny precedes the `RequiredArtifactReader` fail-open check. | No change required. | Matches spec FR-6. | Prior review. |
| Info | `artifacts/pester/powershell-coverage.xml` | coverage population | Carried from the prior review: bundle copies of the converted hooks are not in the Pester coverage population (pre-existing configuration). | No change required in this item. | Byte-identical mirrors are exercised by mirror-root rows. | Prior review. |

No Blocker or Major findings. Prior Minor finding 1 (`len(scanned) >= 1` floor) is resolved.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_scan_floor_gaps` is pure and reports two independent defects with separate messages, each naming the surface label.
- The expected set is derived from manifest data rather than a constant, so the floor tracks manifest growth without edits.
- The anchors are real core hooks with `$PSScriptRoot` dependencies, chosen from the current manifests per the cycle plan.
- The `Callable` import is under `TYPE_CHECKING`, which resolves the Ruff TC003 finding the executor recorded; with `from __future__ import annotations` the annotation is never evaluated at runtime.

#### Typing and API notes

- Pyright reports 0 errors on the changed file. `_narrowed_to` returns `Callable[[Surface], dict[str, list[str]]]`, matching the replaced method's signature. No production API changed.

#### Error handling and logging

- `assert gaps == []` prints the complete gap list on failure, so a narrowed scan names every absent source.

### TypeScript implementation audit

#### What changed well

- No TypeScript change in cycle 1. The prior assessment of `claude-pack-manifest-completeness.test.ts` stands.

#### Type safety and maintainability

- Unchanged: `coreManifestPaths` narrows `unknown` JSON with a type guard; no `any`.

#### Error handling and logging

- Unchanged.

### PowerShell implementation audit

#### What changed well

- No PowerShell change in cycle 1. The prior assessment of the six handler conversions stands: two lines per hook, scope dependencies still deny every call, in-scope paths fail closed.

#### API and safety notes

- Unchanged: no function signatures changed; PSScriptAnalyzer 0 findings.

#### Error handling and logging

- Unchanged.

---

## Test Quality Audit

The cycle 1 tests were run by the reviewer forward and in reversed order. The fail-before artifact shows the narrowed-scan test failing for the intended reason against the old floor.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` — cycle 1 additions reviewed in full; 35 passed across the three manifest modules.
- `evidence/regression-testing/fail-before-floor.2026-10-20T15-48.md` — `EXIT_CODE: 1`, `ExpectedExitCode: 1`, "DID NOT RAISE".
- `evidence/regression-testing/pass-after-floor.2026-10-20T15-49.md` — 35 passed (baseline 33).
- `evidence/regression-testing/python-reversed-order-remediation.2026-10-20T15-51.md` — 35 passed in reversed module order.
- `evidence/qa-gates/remediation-format.2026-10-20T15-51.md`, `remediation-lint`, `remediation-types`, `remediation-tests`, `remediation-file-size` — clean; file 450 lines.
- `evidence/qa-gates/self-review.2026-10-20T15-51.md` — 0 FAIL rows.

### Quality assessment prompts

- **Determinism:** committed manifests and in-memory sets only.
- **Isolation:** `monkeypatch.undo()` per iteration and fixture teardown restore the class method. See the Minor finding on per-surface independence.
- **Speed:** 0.48s for the three modules.
- **Diagnostics:** messages name the surface, the anchor, the counts, and the absent and additional members.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | PASS | No subprocess in cycle 1. |
| Input validation at boundaries | PASS | Unchanged from the prior review. |
| Error handling remains explicit | PASS | Unchanged; cycle 1 is test-only. |
| Configuration / path handling is safe | PASS | Anchors are POSIX relative paths with no drive letter. |
| No host paths in committed artifacts | PASS | Added-line scan of `git diff 58e5001c5` for `C:/Users`, `C:\Users`, `/home/`, `AppData`: no matches. |

---

## Research Log

No external research was required. The review relied on the branch diff, the cycle 1 inputs and plan, the cycle 1 evidence, and repository policy files.

---

## Verdict

The branch is ready for the normal PR flow once the cycle 1 change is committed and pushed. Cycle 1 resolves the prior Minor finding on the non-vacuity floor with a data-derived equality check and a named anchor per surface, backed by fail-before evidence. One new Minor finding (the narrowed-scan test does not isolate the two surfaces) and two Info observations are non-blocking and can be addressed at the author's discretion. Merge remains subject to the orchestrator's S9 CI green gate on the final PR head.
