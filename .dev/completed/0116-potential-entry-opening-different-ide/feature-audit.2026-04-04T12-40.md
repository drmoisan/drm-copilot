# Feature Audit: potential-entry-opening-different-ide (Issue #116)

## Scope and Baseline

- **Base branch:** `development` (user-specified)
- **Feature folder used:** `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116`
- **Work mode:** `minor-audit`
- **Authoritative requirements source:** `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md`
- **Acceptance-criteria source rule:** Only the explicit `## Acceptance Criteria` section in `issue.md` was used.
- **Integrity checks:**
  - `issue.md` exists and contains `- Work Mode: minor-audit`.
  - `issue.md` contains an explicit `## Acceptance Criteria` section.
  - `spec.md` does not exist.
  - `user-story.md` does not exist.
  - Phase 0 baseline evidence exists under `evidence/baseline/`.

**Evidence sources**
- Primary execution evidence: feature-folder artifacts under `evidence/baseline/`, `evidence/regression-testing/`, `evidence/other/`, and `evidence/qa-gates/`
- Secondary context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`

**Baseline note:** The root PR context artifacts were stale for this review and referenced `feature/mcp-functions`. The folder-local evidence and `evidence/baseline/p0-t3.git-baseline.2026-04-04T12-21.md` were therefore used as the authoritative baseline for this audit run.

## Acceptance Criteria Inventory

Source: `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md`

1. `On Windows, invoking drmCopilotExtension.newPotentialBugEntry ... opens that created file as an editor tab in the originating VS Code or VS Code Insiders window ...`
2. `On Windows, invoking drmCopilotExtension.newActiveFeatureFolder ... opens the generated files in the originating VS Code or VS Code Insiders window ...`
3. `Regression coverage in tests/scripts/dev_tools/test_new_potential_bug_entry.py and tests/scripts/dev_tools/test_new_active_feature_folder.py proves that the affected Python launchers resolve a VS Code CLI executable, pass --reuse-window, prefer code-insiders when the session indicates Insiders, and preserve the existing graceful fallback when no VS Code CLI executable is available`

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| AC-1: `drmCopilotExtension.newPotentialBugEntry` reuses the originating IDE window on Windows | UNVERIFIED | `evidence/other/p1-t3.implementation-summary.2026-04-04T12-29.md` records code-level alignment and explicitly states that live Windows verification was not executed; `evidence/qa-gates/p2-t5.end-state-summary.2026-04-04T12-36.md` repeats the `UNVERIFIED / remediation required` outcome. | **Human/manual Windows verification required:** invoke `drmCopilotExtension.newPotentialBugEntry` from an already-open `drm-copilot-2026-04-02` workspace and confirm the created file opens in the originating VS Code or VS Code Insiders window. | Static and unit-test evidence is insufficient to claim observed same-window behavior. |
| AC-2: `drmCopilotExtension.newActiveFeatureFolder` reuses the originating IDE window on Windows | UNVERIFIED | `evidence/other/p1-t3.implementation-summary.2026-04-04T12-29.md` records code-level alignment and explicitly states that live Windows verification was not executed; `evidence/qa-gates/p2-t5.end-state-summary.2026-04-04T12-36.md` repeats the `UNVERIFIED / remediation required` outcome. | **Human/manual Windows verification required:** invoke `drmCopilotExtension.newActiveFeatureFolder` from the same already-open workspace and confirm the generated files open in the originating VS Code or VS Code Insiders window. | The reviewed evidence shows intended behavior, but not observed end-user behavior. |
| AC-3: Regression coverage proves CLI resolution, `--reuse-window`, Insiders preference, and graceful fallback | PASS | Red run: `evidence/regression-testing/p1-t1.red-pytest.2026-04-04T12-26.md`; green run: `evidence/regression-testing/p1-t2.targeted-pytest.2026-04-04T12-29.md`; implementation summary: `evidence/other/p1-t3.implementation-summary.2026-04-04T12-29.md`; full QC: `evidence/qa-gates/p2-t4.pytest-coverage.2026-04-04T12-36.md`. | `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py -q` | The targeted red/green evidence satisfies the regression-proof requirement for the affected launcher logic. |

## Summary

**Overall feature readiness:** **NEEDS REVISION**

**Top gaps preventing PASS**
1. No live Windows verification evidence exists for AC-1.
2. No live Windows verification evidence exists for AC-2.
3. The end-state summary still records changed/new-code coverage as `remediation required` because the changed lines were not isolated deterministically.

**Recommended follow-up verification steps**
1. Run the two live Windows workflows from an existing VS Code or VS Code Insiders session and record a timestamped verification artifact.
2. Produce a deterministic changed/new-code coverage artifact for the four launcher files and the two targeted pytest modules.
3. Refresh the end-state summary after the two gaps above are closed.

## Acceptance Criteria Check-Off

No acceptance-criteria source edits were required during this review.
- AC-3 was already checked off in `issue.md` and remains supported by evidence.
- AC-1 and AC-2 remain unchecked because they are still `UNVERIFIED`.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md`
- Total AC items: 3
- Checked off (delivered): 1
- Remaining (unchecked): 2
- Items remaining:
  - `On Windows, invoking drmCopilotExtension.newPotentialBugEntry from an already-open drm-copilot-2026-04-02 workspace ... opens that created file as an editor tab in the originating VS Code or VS Code Insiders window ...`
  - `On Windows, invoking drmCopilotExtension.newActiveFeatureFolder from the same already-open workspace ... opens the generated files in the originating VS Code or VS Code Insiders window ...`
