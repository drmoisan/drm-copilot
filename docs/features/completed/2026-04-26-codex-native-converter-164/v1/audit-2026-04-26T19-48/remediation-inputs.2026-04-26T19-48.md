# Remediation Inputs: codex-native-converter residual blocker (#164)

- **Feature Folder:** `docs/features/active/2026-04-26-codex-native-converter-164`
- **Source Review Artifacts:**
  - `docs/features/active/2026-04-26-codex-native-converter-164/policy-audit.2026-04-26T19-48.md`
  - `docs/features/active/2026-04-26-codex-native-converter-164/code-review.2026-04-26T19-48.md`
  - `docs/features/active/2026-04-26-codex-native-converter-164/feature-audit.2026-04-26T19-48.md`
- **Base Branch:** `development`
- **Head Branch:** `feature/codex-native-converter-164`
- **Review Timestamp:** `2026-04-26T19-48`

## Trigger Summary

The post-remediation review confirmed that the original blockers on `extensions/drm-copilot/src/extension.ts` and `extensions/drm-copilot/src/repo-automation-service.ts` are resolved. One residual blocker remains: `extensions/drm-copilot/src/repo-automation-command-registration.ts` is 513 lines and still violates the repository-wide 500-line production-file limit.

Feature acceptance criteria remain PASS. This remediation loop is limited to structural policy compliance and regression-safe verification of the TypeScript wrapper layer.

## Enumerated Fix List

1. **Reduce `repo-automation-command-registration.ts` below the 500-line production-file limit.**
   - **File path(s):** `extensions/drm-copilot/src/repo-automation-command-registration.ts` plus any new focused helper modules created under `extensions/drm-copilot/src/`
   - **Expected behavior:** The registration logic must be decomposed into smaller cohesive modules while preserving the exported registration surface and the existing command identifiers.
   - **Verification commands:**
     - `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-command-registration.ts' | Measure-Object -Line).Lines"`
     - `npm --prefix extensions/drm-copilot run lint`
     - `npm --prefix extensions/drm-copilot run typecheck`
     - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`

2. **Preserve interactive workflow behavior and service wiring.**
   - **File path(s):** `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/src/repo-automation-command-registration.ts`, any newly extracted registration helpers, and `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
   - **Expected behavior:** Command IDs, prompt flow, direct-versus-interactive invocation behavior, and bundled service delegation must remain unchanged.
   - **Verification commands:**
     - `npm --prefix extensions/drm-copilot run typecheck`
     - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`

3. **Refresh review evidence after the code split.**
   - **File path(s):** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, new review artifacts, and any new remediation evidence files
   - **Expected behavior:** PR context must target explicit base branch `development`, and the rerun review must document the new branch state.
   - **Verification commands:**
     - `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
     - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit <path>`
     - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review <path>`
     - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit <path>`

## Do Not Do

- Do not reopen or rewrite already passing feature acceptance criteria.
- Do not weaken the 500-line policy, add suppressions, or convert the blocker into a documentation-only exception.
- Do not change public command IDs or the `runCodexNativeConverter` service contract.
- Do not broaden the remediation into unrelated Python or feature-behavior refactors.
- Do not skip the post-change TypeScript QA rerun or the refreshed review artifacts.

## Success Condition

This remediation is complete only when `repo-automation-command-registration.ts` is at or below 500 lines, the relevant TypeScript QA commands pass, refreshed review artifacts exist and validate, and the resulting policy audit no longer reports a structural module-size failure.
