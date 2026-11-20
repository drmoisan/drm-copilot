# Code Review: canonical-evidence-locations-non-overridable (#158)

**Review Date:** 2026-04-25T15-45
**Reviewer:** feature_code_review_agent
**Feature Folder:** `docs/features/active/2026-04-25-canonical-evidence-locations-non-overridable-158`
**Base Branch:** development
**Head Branch:** feature/canonical-evidence-locations-non-overridable-158
**Review Type:** Initial review (post-implementation)

---

## Executive Summary

Feature #158 adds non-overridable enforcement of canonical evidence paths across four independent layers: skill-level canonical-authority pointers (9 files), agent-level invariant sections (12 files), a PreToolUse hook (`enforce-evidence-locations.ps1`), and a standalone Python validator (`validate_evidence_locations.py`). All changed files are in the working tree (uncommitted). All formal acceptance criteria from `spec.md` and `user-story.md` are met.

**What changed:**
Nine `.claude/skills/*.md` files updated with canonical path references and authority-pointer lines. Twelve `.claude/agents/*.md` files updated with `## Evidence Location Invariant` sections. `.claude/settings.json` updated with hook registration. Two new files: `enforce-evidence-locations.ps1` (hook, 175 lines) and `validate_evidence_locations.py` (validator, 110 lines). Two new test files: `enforce-evidence-locations.Tests.ps1` (5 Pester tests) and `test_validate_evidence_locations.py` (6 pytest tests). One unrelated working-tree change: `.github/agents/orchestrator.agent.md` model-line removal.

**Top 3 risks:**
1. The pre-existing pytest failure (`test_mirrored_orchestrator_agents_match_root_direct_command_contracts`) causes pytest to exit with code 1, making it ambiguous whether all toolchain steps truly pass. This failure is documented at baseline and is unrelated to this feature.
2. The `.github/agents/orchestrator.agent.md` model-line removal is an out-of-scope working-tree change that may cause confusion if committed together with feature #158 work.
3. The `test_validate_evidence_locations.py` file has 6 test cases, which is below the informal ≥7 review check (though it exceeds the spec's formal 2-case minimum).

**PR readiness recommendation:** **Conditional Go** — All formal AC items are met, all new code passes the full toolchain, and no new test failures were introduced. Three minor items should be addressed before or shortly after merge.

---

## Scope

All new and modified files in the working tree relative to `development` (all changes are uncommitted):

**New files:**
- `.claude/hooks/enforce-evidence-locations.ps1`
- `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`
- `scripts/dev_tools/validate_evidence_locations.py`
- `tests/scripts/dev_tools/test_validate_evidence_locations.py`

**Modified files (Markdown/config):**
- `.claude/agents/*.md` — 12 files
- `.claude/skills/*.md` — 9 files
- `.claude/settings.json`
- `.github/agents/orchestrator.agent.md` _(out of scope — unrelated change)_

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_validate_evidence_locations.py` | All tests | 6 test cases present; informal review check specified ≥7; spec.md requires only 2. | Add 1 test covering a second forbidden prefix (e.g., `artifacts/qa-gates/`) to close the gap. | Validates the suggestion-mapping logic for additional entries in `_FORBIDDEN_PREFIX_TO_CANONICAL`. | `poetry run pytest test_validate_evidence_locations.py -v` → 6 passed |
| Minor | `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py` | `test_mirrored_orchestrator_agents_match_root_direct_command_contracts` | Pre-existing failing test. Failing at baseline (EXIT_CODE 1, 993 passed, 1 failed) and at final QA (999 passed, 1 failed). Not introduced by this feature. | Track as a separate defect. | The pytest process exits non-zero, which technically means the toolchain step does not produce a clean pass. | `evidence/baseline/python-pytest-baseline.md`, `evidence/qa-gates/python-pytest-final.md` |
| Nit | `docs/features/active/2026-04-25-canonical-evidence-locations-non-overridable-158/spec.md` | Line 188 | Test condition states "blocked path exits 1" but hook correctly exits 0 with JSON decision field per Claude Code protocol. | Correct to: "blocked path outputs `decision = 'block'` with the `EVIDENCE_LOCATION_BLOCKED` reason." | Inaccurate exit-code description may mislead future maintainers. | `read_file` on `spec.md` line 188; `.claude/hooks/enforce-evidence-locations.ps1` exit-code contract |
| Nit | `.github/agents/orchestrator.agent.md` | Model-line removal | Unrelated removal of `model: GPT-5.4 (copilot)` line in the working tree. Out of scope for feature #158. | Commit separately with clear message, or revert if unintentional. | Mixed commits reduce traceability and may complicate bisect. | Working tree `git diff .github/agents/orchestrator.agent.md` |

No Blockers or Major findings.

No blocking (Critical or High) findings. No policy violations.

---

## Detailed Findings

### R-01 — Minor: `test_validate_evidence_locations.py` test count

**File:** `tests/scripts/dev_tools/test_validate_evidence_locations.py`
**Lines:** 1–215

**Observation:** The test file contains 6 test cases. The review request check specified ≥7. The formal spec.md AC states "covers the two required cases (clean tree exits 0; seeded violation exits 1 with canonical replacement printed)." The implementation exceeds the formal AC minimum (6 > 2) and all 6 tests pass. The gap is 1 test relative to the review request's informal threshold.

**Analysis:** The 6 current tests cover:
1. Clean tree — no violations
2. Seeded violation — `artifacts/baselines/seeded.md` triggers violation with correct replacement
3. Directory entry — skipped (not a violation)
4. `relative_to` ValueError — silently skipped
5. `main()` exit 0 on clean input
6. `main()` exit 1 with `VIOLATION:` output

A 7th case that would materially improve coverage: seeded violation from a second forbidden prefix (e.g., `artifacts/qa-gates/`) to verify the canonical mapping for that prefix specifically. This would confirm that all entries in `_FORBIDDEN_PREFIX_TO_CANONICAL` produce the correct suggestion, not only `artifacts/baselines/`.

**Recommendation:** Add one test case covering a second forbidden prefix (e.g., `artifacts/qa-gates/`) and its canonical suggestion (`<FEATURE>/evidence/qa-gates/`). This closes the informal gap and adds legitimate coverage of the suggestion-mapping logic.

---

### R-02 — Minor: Pre-existing test failure

**File:** `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py`
**Test:** `test_mirrored_orchestrator_agents_match_root_direct_command_contracts`

**Observation:** `poetry run pytest` exits with code 1. The failing test is `test_mirrored_orchestrator_agents_match_root_direct_command_contracts`. This failure is present in the baseline evidence (EXIT_CODE: 1, 993 passed, 1 failed) collected before this feature began. Final QA shows 999 passed, 1 failed — the same failure, plus 6 new passing tests. No regression from this feature.

**Analysis:** The `.github/agents/orchestrator.agent.md` model-line removal (see R-04) may be related to this failure (the test validates contract synchronization between orchestrator agent files and their mirrors). If the test validates that the `.github/agents/orchestrator.agent.md` file matches a canonical definition, the unrelated model-line removal may have caused the failure at baseline. Regardless, the failure predates this feature's changes.

**Recommendation:** Investigate the pre-existing failure in a separate defect. Verify whether the failure predates the `.github/agents/orchestrator.agent.md` model-line removal. Document clearly in the commit message that this failure is pre-existing and unrelated to feature #158.

---

### R-03 — Nit: spec.md test condition exit-code description inaccurate

**File:** `docs/features/active/2026-04-25-canonical-evidence-locations-non-overridable-158/spec.md`
**Line:** 188

**Observation:** Line 188 states: "Hook self-test: blocked path exits 1 with correct stderr message."

**Analysis:** The hook's Inputs/Outputs specification (spec.md §2.2.1) and the Claude Code hook protocol both require exit 0 for block decisions with a JSON `{"decision":"block","reason":"..."}` output to stdout. Exit 1 is reserved for hard failures (e.g., malformed JSON). The Pester test at case 1 (`blocks writes to artifacts/baselines/`) validates `$result.decision | Should -Be 'block'` — which is the correct assertion for the actual behavior. The exit-code description in line 188 is therefore inaccurate in the spec document.

**Recommendation:** Correct line 188 of `spec.md` to read: "Hook self-test: blocked path outputs `decision = 'block'` with the `EVIDENCE_LOCATION_BLOCKED` reason." This is a documentation fix; no code change is needed.

---

### R-04 — Nit: Out-of-scope change in working tree

**File:** `.github/agents/orchestrator.agent.md`

**Observation:** The working tree contains a removal of the `model: GPT-5.4 (copilot)` line from `.github/agents/orchestrator.agent.md`. This change is not referenced in any AC, spec, user-story, or plan for feature #158.

**Analysis:** The change is additive-neutral (removing a model override is not harmful) but its inclusion in this feature's commit scope is misleading. It could cause confusion during code review or bisect operations. It is also possibly related to the pre-existing test failure (R-02) if the test validates that orchestrator model declarations are consistent.

**Recommendation:** Commit this change separately from feature #158 with a commit message that explains the rationale (e.g., "remove stale model override from orchestrator agent definition"). Alternatively, revert it if it was not intentional.

---

## Positive Observations

### Python implementation quality

`validate_evidence_locations.py` is well-structured:

- `find_forbidden_paths` is a pure generator with no side effects, making it independently testable.
- The `_FORBIDDEN_PREFIX_TO_CANONICAL` dictionary cleanly maps each forbidden prefix to its canonical replacement, making it easy to extend.
- All public functions are fully type-annotated (`Iterator[tuple[Path, str]]`, `Optional[Path]`) and pass Pyright with 0 errors.
- No new runtime dependencies are required.
- The 100% line coverage achieved by the 6 tests confirms that every branch in the production code is exercised.

```python
# The generator pattern is appropriate here — it separates the walk from the
# reporting, allowing callers to consume violations lazily or collect them all.
def find_forbidden_paths(root: Path) -> Iterator[tuple[Path, str]]:
    ...
```

### PowerShell hook architecture

`enforce-evidence-locations.ps1` follows the established hook pattern seen in `check-python-test-purity.ps1`:

- A dot-source guard enables Pester testing without executing the entrypoint.
- Three pure helper functions separate concerns cleanly: `Test-EvidenceLocationForbidden` (predicate), `Get-EvidenceLocationBlockDecision` (decision builder), `Invoke-EvidenceLocationDecision` (orchestrator).
- The exit-code contract (exit 0 for both allow and block; exit 1 for malformed input) is correct per the Claude Code hook protocol and is consistently documented.
- `ConvertTo-Json -Compress` produces single-line JSON output, which is the correct format for the hook protocol's stdout contract.

### Defense-in-depth completeness

The feature implements four independent enforcement layers:

1. Skill-level: canonical-authority pointer in 9 skill files
2. Agent-level: `## Evidence Location Invariant` in 12 agent files
3. Hook-level: `enforce-evidence-locations.ps1` blocks at tool-call time
4. Validator-level: `validate_evidence_locations.py` for post-hoc tree scanning

Each layer is independently testable and does not depend on the others. A failure of any single layer does not silently allow a violation to pass undetected, because at least one other layer will catch it.

---

## Strongly-Typed Python Assessment

| Category | Finding | Status |
|----------|---------|--------|
| Return types | `find_forbidden_paths` → `Iterator[tuple[Path, str]]`; `main` → `None` | ✅ Explicit |
| Parameter types | `root: Path`, `root: Optional[Path] = None` | ✅ Explicit |
| No implicit `Any` | Pyright 0 errors, 0 warnings | ✅ Confirmed |
| No `type: ignore` | None present | ✅ Confirmed |
| No `noqa` suppressions | None present | ✅ Confirmed |
| Typed test stubs | `MagicMock(spec=Path)` constrains mock to `Path` interface | ✅ Correct |
| Test type imports | `Generator`, `Iterator` not imported but not required (tests don't annotate return types, consistent with test policy) | ✅ Acceptable |

---

## Coverage Assessment

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Python total coverage | 83% | ≥80% | ✅ PASS |
| New Python module (`validate_evidence_locations.py`) | 100% | ≥90% | ✅ PASS |
| PowerShell (hook + tests) | 97% | — | ✅ PASS |
| Coverage delta (post vs baseline) | 83% → 83% (stable) | No regression | ✅ PASS |

---

## Final Assessment

**Recommendation: Conditional Go**

The feature deliverables are complete. All formal AC items from spec.md and user-story.md are met. The two Minor gaps (test count R-01, pre-existing test failure R-02) are documented and neither represents a regression or policy violation introduced by this feature.

**Before closing the feature:**
1. Consider adding one additional test case for a second forbidden prefix (R-01). This is not blocking.
2. Correct the spec.md line 188 wording (R-03). This is a documentation fix.
3. Commit or revert the `.github/agents/orchestrator.agent.md` out-of-scope change separately (R-04). Recommended before merge to keep commit history clean.
4. Track the pre-existing test failure as a separate defect (R-02).
