# Code Review: Hook coverage attribution gaps (#936)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936`
**Base Branch:** `origin/main`
**Head Branch:** `bug/hook-coverage-attribution-gaps-936` (`d30a6625a`)

**Total blocking findings: 0.**

---

## Executive Summary

The change adds one documentation paragraph to the `.DESCRIPTION` block of each of two Pester test files. The reviewer read the full `git diff origin/main...HEAD -- tests/`: 21 lines added, 0 removed, all inside the existing comment-help block before the closing `#>`. No `Describe`, `It`, `Mock`, or assertion line is touched.

The note content is accurate against the evidence. The FailClosed note names modes.ps1 line 41 and the `OrchestrationFeatureFolderResolutionImportFailure` assertion. The Decision note names epic-scope lines 183, 190, 191, 206, 207, 209 and ES-D1/ES-D2. The scoped coverage run attributes lines 41, 206, and 207 (`ci=1`) and the unscoped run did not, which supports the stated cause as a hypothesis. The notes call the cause "likely", which matches the evidence strength.

**Top 3 risks:**
1. The Pester 5.x breakpoint-mode cause is a hypothesis supported by a scoped-versus-unscoped contrast, not a confirmed root cause. The header wording is appropriately hedged. The coordinator filed the `UseBreakpoints=$false` change separately.
2. The Decision header states that "other Codex suites reach lines 183, 190, and 191". The reviewer did not independently re-verify this claim. It does not affect behavior.
3. Attribution remains absent in the unscoped CI run until the follow-up lands; AC-5 documents this as the known exception.

**PR readiness recommendation:** Ready. Open the PR and complete AC-5 from the PR's `poshqc-test-results` artifact.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (Non-blocking) | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` | header, "other Codex suites reach lines 183, 190, and 191" | Claim not independently re-verified by the reviewer. | Optional: confirm when the follow-up investigates attribution. | Documentation-only statement; no behavior depends on it. | `git diff origin/main...HEAD -- tests/` |
| Info (Non-blocking) | `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/research/` | two 195-line research files | Duplicate content under a timestamped and a non-timestamped name. | Optional: keep one. | Documentation only. | `git diff --stat` |

## Review Dimensions

- Correctness: no executable change; header text consistent with evidence.
- Design and readability: notes are placed in comment-help `.DESCRIPTION`, which the analyzer and formatter accept (format unchanged, analyze ok).
- Tests: targeted rows pass (H2 codex 2/2, ES-D1, ES-D2); full run 10376 testcases, 0 failed.
- Size: 90 and 108 lines, under the 500-line limit.
- Tonality: factual, hedged, no figurative language.
