# Remediation Inputs: bundle-resolve-atomic-plan-prompt-command (#152)

Timestamp: 2026-04-18T17-44
Feature Folder: `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152`
Base Branch: `origin/development`
Head Branch: `feature/bundle-resolve-atomic-plan-prompt-command-152`
Primary Requirements Source: `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/remediation-inputs.2026-04-18T17-44.md`

## Scope Summary

This remediation loop closes one verified runtime blocker, one test-fidelity gap, and the remaining review-readiness gaps recorded by the `2026-04-18T17-44` review artifacts.

Verified blocker summary:
- The extension service currently invokes the bundled atomic-plan wrapper with `--target` and `--workspace`, but the bundled resolver CLI accepts only `--template` and `--target`.
- Direct execution of the bundled wrapper therefore fails with `unrecognized arguments: --workspace ...`, so the feature's primary success path is not working.
- Existing automated tests passed because they asserted mocked spawn arguments and helper behavior, but they did not execute the real wrapper entry point with the production argv contract.

## Enumerated Fix List

1. **Align the bundled runtime contract for `resolveAtomicPlanPrompt` so the command can execute successfully.**
   - Files in scope:
     - `extensions/drm-copilot/src/repo-automation-service.ts`
     - `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py`
     - `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py`
   - Current defect:
     - `resolveAtomicPlanPrompt` passes `--workspace <root>` at runtime, but the bundled resolver parser rejects that argument and exits with code `1`.
   - Expected behavior:
     - The bundled wrapper and resolver accept the exact runtime arguments used by the extension, or the extension stops passing unsupported arguments. The command must resolve the prompt for an eligible plan file and either copy it to the clipboard or print the resolved prompt when clipboard integration is unavailable.
   - Acceptance criteria:
     - Direct invocation with the production argv contract succeeds for an eligible plan file.
     - `drmCopilotExtension.resolveAtomicPlanPrompt` no longer fails with `unrecognized arguments: --workspace`.
   - Verification commands:
     - `python "extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py" --target "docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md" --workspace "C:/Users/DanMoisan/repos/drm-copilot-wt-20260314-224838"`
     - `npm run test:unit -- --runTestsByPath test/extension.resolve-atomic-plan-prompt.test.ts test/repo-automation-service.test.ts`

2. **Raise regression-test fidelity so the real wrapper CLI contract is exercised.**
   - Files in scope:
     - `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts`
     - `extensions/drm-copilot/test/repo-automation-service.test.ts`
     - `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py`
     - `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt_part2.py`
   - Current defect:
     - The existing tests verify helper behavior, mocked spawn arguments, and selected parser branches, but they do not execute the real wrapper entry point with the same argv contract that the extension service emits.
   - Expected behavior:
     - At least one automated test executes the real bundled wrapper with the production `--target` and `--workspace` contract and fails if the CLI rejects those arguments.
   - Acceptance criteria:
     - A regression test fails on the current blocker and passes after the contract is fixed.
     - Review evidence proves command success and failure paths without relying solely on mocked spawn expectations.
   - Verification commands:
     - `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt_part2.py -q`
     - `node run-jest.cjs --runTestsByPath test/extension.resolve-atomic-plan-prompt.test.ts test/repo-automation-service.test.ts`

3. **Close the review gating evidence gap for changed/new-code coverage and refresh QA disposition artifacts.**
   - Files and artifacts in scope:
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/py-coverage-summary.2026-04-17T19-54.md`
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-coverage-summary.2026-04-17T19-54.md`
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/qa-loop-summary.2026-04-17T19-54.md`
     - any new changed-line or changed-scope coverage proof artifacts needed for the TypeScript and Python changes
   - Current defect:
     - Both coverage summary artifacts explicitly record `remediation required` because deterministic changed/new-code coverage was not derived.
   - Expected behavior:
     - The branch either produces reviewer-auditable changed/new-code coverage proof for the in-scope TypeScript and Python changes or records an approved, explicit exception dossier that satisfies the review contract.
   - Acceptance criteria:
     - Coverage disposition artifacts no longer block the review on missing changed/new-code proof.
     - QA summary matches the final evidence set.
   - Verification commands:
     - `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`
     - `poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q`
     - any deterministic changed-line or changed-scope coverage proof command adopted for this feature

4. **Resynchronize feature documentation and acceptance state after the runtime and evidence fixes land.**
   - Files in scope:
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/spec.md`
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/user-story.md`
     - `extensions/drm-copilot/README.md` (if the command remains user-facing)
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md`
   - Current defect:
     - `user-story.md` currently shows all five acceptance criteria checked, but the review found one FAIL and three PARTIAL outcomes. `spec.md` also retains checked items that are not yet supported by verified runtime evidence.
   - Expected behavior:
     - Requirement and plan checkboxes reflect the corrected evidence only after the runtime path and QA artifacts are updated. Any user-facing README content for the new command should match the shipped behavior.
   - Acceptance criteria:
     - Requirement sources and the original plan file are synchronized to the final delivered state.
     - Any exposed user documentation matches the corrected command behavior.
   - Verification actions:
     - inspect `spec.md`, `user-story.md`, `plan.2026-04-17T19-54.md`, and `extensions/drm-copilot/README.md` after the implementation and QA refresh

## Verified Open Blockers

- `extensions/drm-copilot/src/repo-automation-service.ts`
- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py`
- `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/regression-testing/review-resolve-atomic-plan-prompt-direct-cli.2026-04-18T17-44.md`
- `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-coverage-summary.2026-04-17T19-54.md`
- `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/py-coverage-summary.2026-04-17T19-54.md`

## Required Context Package

- Original feature plan: `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md`
- Review artifacts:
  - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/policy-audit.2026-04-18T17-44.md`
  - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/code-review.2026-04-18T17-44.md`
  - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/feature-audit.2026-04-18T17-44.md`
- PR context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`

## Do Not Do

- Do not widen scope into unrelated command-surface or MCP refactors.
- Do not weaken coverage gates or review criteria to force a PASS outcome.
- Do not remove `--workspace` from one layer without making the runtime contract deterministic and test-covered end to end.
- Do not mark acceptance criteria or plan tasks complete until refreshed runtime and QA evidence supports them.
- Do not modify repository policy documents.
