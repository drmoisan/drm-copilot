# Code Review: potential-to-issue-missing-label

## Executive Summary

This remediation re-audit confirms that the actual extension command path is now fixed. `extensions/drm-copilot/src/repo-automation-service.ts` still dispatches `resources/templates/potential_to_issue.py`, the wrapper still imports bundled `dev_tools.potential_to_issue`, and the bundled runtime now contains the missing-label recovery branch required by `issue.md`. The saved red/green remediation evidence and the fresh bundled-runtime pytest rerun both support that conclusion.

The branch is **not yet ready for PR/merge**. The remaining blocker is policy compliance, not feature correctness: the focused coverage run for `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` is only 65%, which is below the repository’s stated 90% target for new or modified code.

**Top 3 risks:**
1. Bundled-runtime coverage is 65%, so the current remediation does not satisfy the repo coverage requirement for modified code.
2. The repo still maintains both a root implementation and a bundled runtime copy of the same workflow, which preserves future drift risk.
3. PR-context artifacts remain weak as a diff source until the working-tree changes are committed.

**Go/No-Go recommendation:** No-Go.

**Feature folder selection rule:** The review used the user-specified folder `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`, which matches issue `#123` and the active branch suffix.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`; `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py` | Fresh coverage run; missing lines reported at `72-75, 80-89, 92-109, 112-122, 125-134, 137-144, 166, 169, 172, 175, 178-179, 182, 185-186, 197, 221, 223, 230, 236, 240, 250-251, 257-258, 262-276, 287-291, 319, 336-341, 377-400, 404-418` | The bundled runtime is behaviorally fixed but only 65% covered, so the remediation remains below the repo coverage threshold. | Add focused tests for the uncovered bundled-runtime branches, or refactor dead or duplicated branches so the changed module reaches at least 90% focused coverage. Re-run the same coverage command afterward. | Merge readiness is blocked by policy, not by failing behavior. The current evidence proves correctness for the main scenario but not sufficient coverage depth. | Fresh command: `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing` -> `6 passed`, `65%` coverage. |
| Major | `scripts/dev_tools/potential_to_issue.py`; `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` | Duplicate workflow implementations | The branch still ships two Python implementations of the same promotion workflow. They are currently aligned for the missing-label fix, but the duplicate structure remains a drift hazard. | In follow-up work, consider converging the root and bundled implementations on a single authoritative source or an enforced mirror workflow. | The prior defect existed because the first fix landed only in the root script. The re-audit confirms the duplication risk still exists even though the immediate bug is fixed. | Root and bundled runtime code inspection; remediation delta note `evidence/other/remediation.runtime-delta-note.2026-04-05T14-15.md`. |
| Minor | Branch state | Refreshed `artifacts/pr_context.summary.txt` still shows `Range: HEAD..HEAD` | Canonical PR-context artifacts cannot yet describe the implementation delta because the changes remain uncommitted in the working tree. | Commit the reviewed changes before the next review pass so PR-context artifacts can serve as complete baseline-diff evidence. | Review traceability is weaker when all evidence must come from the working tree plus local feature artifacts. | Fresh PR-context refresh command and refreshed `artifacts/pr_context.summary.txt`. |

## Typed Python Audit

### Strengths

- Both the bundled runtime and the root companion implementation remain Pyright-clean.
- No new `Any`, broad `type: ignore`, or non-authorized suppressions were introduced.
- Protocol seams (`GhClient`, `FileSystem`) remain precise and support isolated testing.
- The remediation is narrowly scoped: `ensure_label`, `_is_missing_label_failure`, and the single-retry recovery branch preserve explicit control flow.
- Boundary exception handling remains explicit and unchanged in style.

### Concerns

- The repository still duplicates the promotion workflow across the root script and the bundled runtime copy.
- The bundled test module currently covers the primary behavior but leaves many branches untested, which is the main remaining policy gap.

### Type and API Assessment

| Check | Result | Notes |
|---|---|---|
| No new `Any` | Pass | None introduced in the remediation path. |
| No type weakening | Pass | Fresh Pyright rerun reported `0 errors, 0 warnings, 0 informations`. |
| Precise interfaces | Pass | Protocol usage remains appropriate in both implementations. |
| Error handling typed | Pass | No naked `except` blocks were added. |
| Logging / messaging | Pass | The existing emitter callback pattern remains intact. |
| Public API clarity | Pass | Runtime helper and test docstrings remain clear. |
| Cross-copy consistency | Pass for this defect; risk remains | The missing-label logic is now mirrored, but the duplicate design still requires maintenance discipline. |

## Test Quality Audit

- **Deterministic:** Pass. All tests use in-memory fakes only.
- **Isolated:** Pass. No network, `gh`, or real filesystem side effects escape the test boundary.
- **Fast:** Pass. Fresh reruns completed in 0.06s for the bundled runtime module and 0.10s for the root companion module.
- **Failure messages:** Pass. The saved red remediation artifact clearly shows the failing assertion and the emitted missing-label output.
- **Coverage expectation:** Fail. The bundled runtime module is only 65% covered in the fresh focused run.

## Security and Correctness Checks

- No secrets or credential-like literals were introduced.
- Subprocess usage remains guarded by resolved executable-path handling and existing narrow suppressions.
- Input validation remains explicit for promotion type, work mode, authentication, and missing files.
- Correctness of the actual extension path now appears satisfied for the issue requirements; the remaining blocker is test coverage depth.

## Research Log

No external research was required. The review used repository code inspection and live local verification only on 2026-04-05.

## Recommendation

**Needs revision**

Do not open or merge a PR for this branch yet. First raise bundled-runtime coverage to at least 90% for `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`, then rerun the focused Python QC loop and refresh the review artifacts.
