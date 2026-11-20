# Code Review: potential-to-issue-missing-label

## Executive Summary

The working-tree implementation adds a narrowly scoped missing-label recovery path to the root Python script `scripts/dev_tools/potential_to_issue.py` and backs it with focused root pytest coverage in `tests/scripts/dev_tools/test_potential_to_issue.py`. The constrained root Python quality gates pass cleanly.

This branch is **not ready for PR/merge**. The reviewed bug report is about `drmCopilotExtension.potentialToIssue`, but the extension command still executes `extensions/drm-copilot/resources/templates/potential_to_issue.py`, which imports and runs `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`. That bundled runtime script does not contain the new `ensure_label` logic or retry branch, so the user-facing command path remains broken for the primary missing-label scenario.

**Top 3 risks:**
1. The primary fix exists only in the root script, not in the bundled runtime script used by the extension.
2. Regression tests prove the root helper path only and do not cover the actual bundled runtime path.
3. The refreshed PR-context summary shows no committed branch delta because the implementation is still only in the working tree, which reduces review traceability.

**Go/No-Go recommendation:** No-Go.

**Feature folder selection rule:** The review used the user-specified folder `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`, which matches branch suffix `123` and `issue.md` Issue `#123`.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/repo-automation-service.ts`; `extensions/drm-copilot/resources/templates/potential_to_issue.py`; `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` | Service dispatch sets `bundledRelativePath: "resources/templates/potential_to_issue.py"`; template wrapper imports `dev_tools.potential_to_issue`; bundled script issue-create block immediately after `_emit(f"Creating issue...")` | The extension still runs a bundled Python implementation that lacks the missing-label recovery logic added to the root script. | Apply the same recovery logic to the bundled runtime script, or refactor the extension to execute a single authoritative implementation. Re-verify the extension path after the change. | The acceptance criteria are written against `drmCopilotExtension.potentialToIssue`, not against the root helper module in isolation. | Code inspection of the service, wrapper, and bundled script; absence of `ensure_label`, `FEATURE_LABEL_COLOR`, and `_is_missing_label_failure` in the bundled script; root script contains them. |
| Major | `tests/scripts/dev_tools/test_potential_to_issue.py` | New regression tests `test_promote_potential_feature_missing_label_recovers_and_moves_file` and `test_promote_potential_feature_existing_label_uses_single_issue_create_attempt` | The new tests validate only `scripts.dev_tools.potential_to_issue`, so they do not prove the bundled runtime path used by the extension has been fixed. | Add focused coverage for the bundled runtime script or an extension-level test that exercises `drmCopilotExtension.potentialToIssue` through the bundled Python path. | Current green evidence can only establish correctness for the root module. The actual shipped entrypoint still delegates elsewhere. | `p1-t3.red-pytest.2026-04-05T13-57.md`, `p1-t5.green-pytest.2026-04-05T13-58.md`, reviewer pytest rerun, and extension command wiring inspection. |
| Major | `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md` | `## Acceptance Criteria` | Two acceptance criteria were checked off before the runtime-path evidence supported them. | Keep only verified criteria checked. Regenerate the evidence after the bundled-path remediation and then re-check any satisfied items. | Acceptance-criteria state is part of the review contract for `minor-audit`; premature checkoff obscures delivery status. | The review corrected criterion 1 and criterion 3 back to unchecked after finding the bundled runtime gap. |
| Minor | Repository state | Refreshed `artifacts/pr_context.summary.txt` shows `Range: HEAD..HEAD` | Because the change remains uncommitted, the canonical PR-context diff is empty and cannot anchor the implementation delta by itself. | Commit the reviewed changes before opening the PR so the canonical PR-context artifacts can describe the real branch delta. | Traceability is weaker when the feature exists only in the working tree. | Refreshed PR-context summary and appendix; reviewer supplemental `git diff origin/development -- ...` output. |

## Typed Python Audit

### Strengths

- The root Python change remains strongly typed and Pyright-clean.
- No new `Any`, broad `type: ignore`, or `noqa` expansion was introduced beyond existing pre-authorized subprocess suppressions.
- Protocol-based seams (`GhClient`, `FileSystem`) continue to support isolated testing cleanly.
- The new helper `_is_missing_label_failure` and `ensure_label` method are narrowly scoped and easy to reason about.
- Exception handling remains explicit: `PromotionError`, `FileNotFoundError`, and `subprocess.SubprocessError` are the only caught boundary exceptions.

### Concerns

- The repository now contains two materially different Python implementations of the same promotion workflow: the root module and the bundled extension resource copy. That duplication creates a correctness drift risk that has already surfaced in this review.
- The bundled copy is also typed Python, but it is not receiving the same change or corresponding tests in this branch.

### Type and API Assessment

| Check | Result | Notes |
|---|---|---|
| No new `Any` | Pass | None introduced in the root change. |
| No type weakening | Pass | Pyright passed with `0 errors, 0 warnings, 0 informations`. |
| Precise interfaces | Pass | Protocol usage remains appropriate. |
| Error handling typed | Pass | No naked `except` added in the root path. |
| Logging / messaging | Pass | Existing emitter callback pattern preserved. |
| Public API clarity | Pass | Root docstrings remain present and specific. |
| Cross-copy consistency | Fail | Bundled runtime copy is missing the new API surface and logic. |

## Test Quality Audit

- **Deterministic:** Pass. The root regression tests use fake gh results and fake filesystem state only.
- **Isolated:** Pass. No network, `gh`, or filesystem side effects escape the test module.
- **Fast:** Pass. Reviewer rerun completed in 0.10s for 28 targeted tests.
- **Failure messages:** Pass. The red-run artifact clearly shows the failed assertion and the output fragment `could not add label: 'feature' not found`.
- **Coverage expectation:** Fail for feature readiness. Root-module coverage is 90%, but the actual bundled runtime path lacks corresponding coverage.

## Security and Correctness Checks

- No secrets or token-like literals were introduced in the reviewed root change.
- Subprocess calls in the root script still use a resolved `gh` executable path and existing narrow suppressions.
- Input validation remains explicit for promotion type, work mode, authentication, and missing files.
- Correctness remains blocked by runtime-path divergence, not by a security issue.

## Research Log

No external research was required. The review used repository code inspection only on 2026-04-05.

## Recommendation

**Blocked**

Do not open or merge a PR for this branch until the bundled extension runtime path is updated and re-verified. After remediation, rerun the focused Python QC loop and add bundled-path verification so the acceptance criteria reflect the actual command behavior.
