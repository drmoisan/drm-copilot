# Code Review: handoff test independence from archived active directory (#765)

**Review Date:** 2026-09-28
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765`
**Feature Folder Selection Rule:** Folder named in the review request; suffix matches issue 765.
**Base Branch:** `main` (origin/main 5d0b93a0b0a15633b42559827fd7459d65c0b671)
**Head Branch:** `bug/handoff-test-depends-on-archived-active-dir-765` (a760a7c139aedc53c7c290bd6ab5a30ce3a2e302)
**Review Type:** Initial review

---

## Executive Summary

The branch changes one line in `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` and adds feature documentation and evidence files. No production file changed. Evidence reviewed: the diff, the resolver source, the QA-gate evidence, and a reviewer re-run of the module (13 passed).

**What changed:**
In `test_plan_directory_rediscovery_blocks_before_write`, the argument `"docs/features/active"` is replaced with `FIXTURES.relative_to(ROOT).as_posix()`. `resolve_pinned_plan_path` resolves with `strict=True`, so the removed argument raised `FileNotFoundError` once PR #759 archived the active feature folders. The new argument is a tracked directory that resolves and then fails the `is_file()` check with `HandoffContractError`.

**Top 3 risks:**
1. The assertion has no `match=`, so it cannot distinguish rejection at the `is_file()` check from any other `HandoffContractError` (pre-existing).
2. CI status for the fix PR was not available at review time.
3. No further risk identified.

**PR readiness recommendation:** **Go** — a minimal test-only change that removes the mutable-directory dependency and passes the toolchain.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | `test_plan_directory_rediscovery_blocks_before_write` | Argument now uses the tracked `FIXTURES` directory | None | Removes dependency on `docs/features/active/` | Diff a760a7c1; independence-grep evidence |
| Nit | `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | `pytest.raises(HandoffContractError)` in the same test | No `match=` on the assertion | Optionally add `match="must name one existing file"` in a later change | Pins the rejection to the intended branch | `orchestration_handoff_contract_support.py:52-53` |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Reuses the module constant `FIXTURES`; no new import or helper.
- Keeps the `pytest.raises` block and the `deny_write_boundaries` fixture unchanged.

#### Typing and API notes

- No new public Python API surface was added. Test signature is unchanged.

#### Error handling and logging

- The specific `HandoffContractError` is asserted; no broad catch, no logging change.

---

## Test Quality Audit

The affected module passes 13 of 13 tests on reviewer re-run. Coverage of the exercised production module is 43% before and after, so no regression; the change touches no production line.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` — the changed test; rejects a directory plan path.
- `evidence/regression-testing/independence-grep.2026-09-28T19-35.md` — zero matches for the removed literal, one for the replacement.
- `evidence/regression-testing/fixture-tracked.2026-09-28T19-35.md` — `git ls-files` lists the fixture, so the directory is tracked content.
- `evidence/qa-gates/final-*.2026-09-28T19-35.md` — Black, Ruff, Pyright, and Pytest exit 0.

### Quality assessment prompts

- **Determinism:** the argument is a tracked directory; no clock, network, or randomness.
- **Isolation:** the test targets one behavior.
- **Speed:** 13 tests in 0.05s.
- **Diagnostics:** a non-raising call would fail with pytest "DID NOT RAISE".

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected; one path expression changed. |
| No unsafe subprocess or command construction | N/A | None present. |
| Input validation at boundaries | ✅ PASS | Resolver validates path and rejects directories. |
| Error handling remains explicit | ✅ PASS | `HandoffContractError` asserted. |
| Configuration / path handling is safe | ✅ PASS | Repository-relative POSIX path via `as_posix()`. |

---

## Research Log

No external research was required.

---

## Verdict

The change is ready for normal PR flow. It addresses the root cause, is minimal, and introduces no production change. The only follow-up is optional (`match=` on the assertion), and the fix PR CI result should be confirmed when available. This is consistent with the Findings Table: no Blocker or Major findings.
