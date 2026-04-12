# Remediation Inputs: 2026-04-05-ci-failing-error-128

## Required Fixes

1. **Bring the touched test file back under the repository 500-line limit**
   - **Files / locations:**
     - `extensions/drm-copilot/test/extension.test.ts` (file-wide; current size 918 lines)
     - Any new or updated companion test utility/module created to support the split or extraction
   - **Current problem:** The reviewed bug fix added 120 lines to `extensions/drm-copilot/test/extension.test.ts`, leaving a touched test file far above the repository’s 500-line limit.
   - **Expected behavior:** The extension command tests remain functionally equivalent, including the new POSIX-host Windows-root regression scenarios, while every touched file complies with the 500-line limit.
   - **Minimum acceptable outcome:**
     - Keep the scenarios named exactly:
       - `helloPython preserves C:/extension on POSIX hosts`
       - `helloPowerShell preserves C:/extension on POSIX hosts`
       - `collectCommitContext preserves C:/extension on POSIX hosts`
       - `newPotentialEntry preserves C:/extension on POSIX hosts`
     - Preserve the current assertions that bundled paths resolve under `C:/extension/resources/templates/`.
     - Reduce `extensions/drm-copilot/test/extension.test.ts` to `<= 500` lines.
     - Ensure any additional touched test file or helper file is also `<= 500` lines.
   - **Verification commands:**
     - `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location`
     - `Push-Location extensions/drm-copilot; npm run lint; Pop-Location`
     - `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location`
     - `Push-Location extensions/drm-copilot; npm run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"; Pop-Location`
     - `Push-Location extensions/drm-copilot; npm run test:unit; Pop-Location`

2. **Refresh the review evidence after the structural test remediation**
   - **Files / locations:**
     - `docs/features/active/2026-04-05-ci-failing-error-128/evidence/qa-gates/*`
     - `docs/features/active/2026-04-05-ci-failing-error-128/evidence/other/*` when file paths or scope evidence change
     - `docs/features/active/2026-04-05-ci-failing-error-128/policy-audit.*.md`
     - `docs/features/active/2026-04-05-ci-failing-error-128/code-review.*.md`
   - **Expected behavior:** Evidence and review artifacts reflect the final remediated file layout and verification results.
   - **Minimum acceptable outcome:**
     - Regenerate or replace any evidence artifact whose file-path references or verification results are invalidated by the remediation.
     - Preserve the reduced-audit structure: no `spec.md`, no `user-story.md`, and `issue.md` remains the sole AC source.
   - **Verification commands:** reuse the commands listed in Fix 1 plus `poetry run python -m scripts.dev_tools.pr_context.collector --base development` if PR-context artifacts need refresh.

## Do Not Do

- Do not weaken or waive the repository 500-line file policy.
- Do not remove or rename the four regression scenarios listed above.
- Do not broaden the production-code change beyond `extensions/drm-copilot/src/command-runtime.ts` unless a new plan explicitly authorizes it.
- Do not delete the red/green regression evidence without replacing it with equivalent or stronger evidence.
- Do not infer acceptance criteria from anywhere other than `issue.md#acceptance-criteria`.
- Do not introduce broad lint or type suppressions to avoid structural remediation.

## Acceptance Criteria Still Outstanding

**None.** All three feature acceptance criteria are satisfied. Remediation is required for policy compliance and PR readiness, not because feature behavior is incomplete.

## Minimum Change Needed for Completion

The smallest acceptable remediation is a structural reorganization of the touched extension command test coverage so that `extensions/drm-copilot/test/extension.test.ts` and any newly touched companion files are each `<= 500` lines while preserving the current production fix, the four Windows-root POSIX regressions, and the green final verification results.
