# Remediation Inputs: potential-to-issue-missing-label

**Timestamp:** 2026-04-05T14-05  
**Feature folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`  
**Authoritative requirements source:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`

## Required Fixes

1. **Apply the missing-label recovery logic to the actual extension runtime path**
   - **Files:**
     - `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`
     - Inspect `extensions/drm-copilot/resources/templates/potential_to_issue.py` and leave its wrapper contract unchanged unless required for the runtime fix
   - **Location:** The bundled script’s issue-create block immediately after `_emit(f"Creating issue: ...")`.
   - **Expected behavior:** When `promotion_type == "feature"` and gh returns `could not add label: 'feature' not found`, the bundled runtime must ensure the `feature` label exists and retry `issue_create` exactly once. The existing-label path must continue to pass through the selected `feature` label unchanged.
   - **Acceptance criteria covered:** AC1 and AC2.
   - **Verification commands:**
     - Add focused verification for the bundled runtime path, then run that focused test command.
     - Re-run `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` if root tests are also touched.

2. **Add focused regression coverage for the runtime path actually used by `drmCopilotExtension.potentialToIssue`**
   - **Files:**
     - Preferred: the narrowest existing test home that can verify the bundled path, such as extension command tests under `extensions/drm-copilot/test/` and/or focused Python coverage for the bundled script under the repo’s existing Python test layout.
   - **Location:** Add tests for both scenarios:
     - missing-label recovery on the bundled runtime path
     - existing-label single-create path on the bundled runtime path
   - **Expected behavior:** The red/green proof must show the issue scenario failing before the runtime-path fix and passing after it for the implementation actually executed by the extension.
   - **Acceptance criteria covered:** AC1, AC2, and AC3.
   - **Verification commands:**
     - Python: the focused pytest command that exercises the relevant runtime-path tests
     - If TypeScript extension tests are added or touched: `npm --prefix extensions/drm-copilot run format`, `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, `npm --prefix extensions/drm-copilot run test:unit`

3. **Regenerate evidence and acceptance summary only after the true runtime path passes**
   - **Files:**
     - `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/regression-testing/*`
     - `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/qa-gates/*`
     - `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`
   - **Expected behavior:** Red/green artifacts and final QC artifacts must reflect the actual runtime-path fix. Only then may AC1 and AC3 be checked back to `[x]`.
   - **Acceptance criteria covered:** AC1 and AC3.
   - **Verification commands:**
     - Re-run the red/green focused regression commands for the corrected runtime path
     - Re-run the final QC loop for all impacted files/toolchains

4. **Preserve small-path intent without weakening the requirements**
   - **Files:** planning and evidence artifacts in the active feature folder
   - **Expected behavior:** Keep `issue.md` as the sole requirements source, keep `spec.md` and `user-story.md` absent, and do not redefine AC1 to mean only the root helper module.
   - **Acceptance criteria covered:** All.
   - **Verification commands:**
     - Confirm `spec.md` absent
     - Confirm `user-story.md` absent
     - Confirm the final feature audit evaluates against `issue.md` only

## Do Not Do

- Do not weaken the requirement by treating the root `scripts/dev_tools/potential_to_issue.py` path as sufficient when the issue is explicitly about `drmCopilotExtension.potentialToIssue`.
- Do not re-check AC1 or AC3 in `issue.md` until bundled runtime-path evidence exists.
- Do not introduce `spec.md`, `user-story.md`, or `research.md`; this remains a `minor-audit` workflow.
- Do not broaden the fix into unrelated promotion-mode refactors.
- Do not skip the final toolchain loop for any newly touched language area.

## Acceptance Criteria Not Yet Met

1. **AC1 not met:** `Promoting a potential entry as feature succeeds when the repository does not already contain a feature label.`
   - **Minimum change required:** Implement and verify missing-label recovery in the bundled extension runtime path.

2. **AC3 not met:** `Focused regression coverage proves the missing-label scenario fails before the fix and passes after the fix.`
   - **Minimum change required:** Add or update focused bundled-path verification so the fail-before and pass-after evidence covers the actual extension-executed implementation.

## Reviewer Notes

- The root Python QC loop is currently clean.
- The blocker is correctness drift between the root script and the bundled runtime script used by the extension.
- The acceptance checklist in `issue.md` has already been reconciled to match the current evidence state.
