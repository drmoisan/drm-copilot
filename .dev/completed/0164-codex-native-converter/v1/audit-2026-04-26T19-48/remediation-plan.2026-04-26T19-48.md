# codex-native-converter residual blocker - Plan

- **Issue:** #164
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-26T19-48
- **Status:** Draft
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Remediation Inputs: [`remediation-inputs.2026-04-26T19-48.md`](./remediation-inputs.2026-04-26T19-48.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance, Context, and Baseline Evidence
- [x] [P0-T1] Read `.github/copilot-instructions.md` and record the read order in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-48.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Policy Order: 1`, and an explicit entry for `.github/copilot-instructions.md`.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and record the read order in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-48.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Policy Order: 1-2`, and explicit ordered entries for `.github/copilot-instructions.md` and `.github/instructions/general-code-change.instructions.md`.
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` and record the read order in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-48.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Policy Order: 1-3`, and explicit ordered entries for the first three required policy files.
- [x] [P0-T4] Read `.github/instructions/typescript-code-change.instructions.md` and record the read order in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-48.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Policy Order: 1-4`, and explicit ordered entries for the first four required policy files.
- [x] [P0-T5] Read `.github/instructions/typescript-unit-test.instructions.md` and finalize the ordered policy-read artifact in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-48.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Policy Order: 1-5`, and explicit ordered entries for all five required policy files.
- [x] [P0-T6] Confirm the remediation scope by reading `remediation-inputs.2026-04-26T19-48.md`, `policy-audit.2026-04-26T19-48.md`, and `code-review.2026-04-26T19-48.md` before changing code.
  - Acceptance: The executor summary explicitly states that only the residual `repo-automation-command-registration.ts` blocker remains in scope.
- [x] [P0-T7] Record the baseline line count for `extensions/drm-copilot/src/repo-automation-command-registration.ts` in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-repo-automation-command-registration-lines.2026-04-26T19-48.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-command-registration.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and `Output Summary: 513`.
- [x] [P0-T8] Capture the baseline TypeScript formatter status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-2-typescript-format.2026-04-26T19-48.md` using `npm --prefix extensions/drm-copilot run format`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T9] Capture the baseline TypeScript lint status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-2-typescript-lint.2026-04-26T19-48.md` using `npm --prefix extensions/drm-copilot run lint`.
  - Acceptance: The artifact records the exact command, exit code, and a concise output summary.
- [x] [P0-T10] Capture the baseline TypeScript type-check status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-2-typescript-typecheck.2026-04-26T19-48.md` using `npm --prefix extensions/drm-copilot run typecheck`.
  - Acceptance: The artifact records the exact command, exit code, and a concise output summary.
- [x] [P0-T11] Capture the baseline TypeScript test-and-coverage status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-2-typescript-test-coverage.2026-04-26T19-48.md` using `npm --prefix extensions/drm-copilot run test:unit -- --coverage`.
  - Acceptance: The artifact records the exact command, exit code, and the coverage headline values.

### Phase 1 — Registration-Module Decomposition
- [x] [P1-T1] Identify the cohesive command families inside `extensions/drm-copilot/src/repo-automation-command-registration.ts` and document the intended split boundaries in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/other/remediation-2-command-registration-split-boundary.2026-04-26T19-48.md`.
  - Acceptance: The design note groups the current registrations into at least two smaller helper surfaces and explains why the split preserves behavior.
- [x] [P1-T2] Extract one focused command family from `extensions/drm-copilot/src/repo-automation-command-registration.ts` into a new helper module under `extensions/drm-copilot/src/` without changing command IDs or prompt behavior.
  - Acceptance: The extracted helper has a single clear responsibility and the original file shrinks materially.
- [x] [P1-T3] Extract the remaining oversized concern set into one or more additional focused modules so the original registration coordinator file becomes a thin assembly layer.
  - Acceptance: `repo-automation-command-registration.ts` no longer contains the full body of every interactive registration path.
- [x] [P1-T4] Update imports and the exported `registerRepoAutomationCommands` composition so extension activation behavior remains unchanged.
  - Acceptance: `extensions/drm-copilot/src/extension.ts` still registers the same repo-automation commands through the same public helper export.
- [x] [P1-T5] Update or extend `extensions/drm-copilot/test/extension.workflow-commands.test.ts` or adjacent focused tests only as needed to lock in the preserved behavior of the extracted modules.
  - Acceptance: Tests cover any newly factored prompt-flow or registration helpers that would otherwise be unverified.
- [x] [P1-T6] Record the post-split line count for `extensions/drm-copilot/src/repo-automation-command-registration.ts` in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/other/remediation-repo-automation-command-registration-lines-after.2026-04-26T19-48.md`.
  - Acceptance: The artifact records a numeric `Output Summary:` that is `<= 500`.

### Phase 2 — TypeScript QA Loop
- [x] [P2-T1] Run the repository TypeScript formatter command and capture the result in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-2-typescript-format.2026-04-26T19-48.md`.
  - Acceptance: The artifact records the exact formatter command used and whether any files were changed.
- [x] [P2-T2] Run the repository TypeScript lint command and capture the result in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-2-typescript-lint.2026-04-26T19-48.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0`.
- [x] [P2-T3] Run the repository TypeScript type-check command and capture the result in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-2-typescript-typecheck.2026-04-26T19-48.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0`.
- [x] [P2-T4] Run the repository TypeScript test-and-coverage command and capture the result in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-2-typescript-test-coverage.2026-04-26T19-48.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0` and coverage at or above 90% for all touched production files.
- [x] [P2-T5] If any QA step changes files or fails, restart the loop from Phase 2 Task 1 until a single clean pass exists.
  - Acceptance: The executor report explicitly states the number of iterations required for the final clean pass.

### Phase 3 — PR Context Refresh and Review Rerun
- [x] [P3-T1] Refresh PR context against explicit base `development` and capture the outcome in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-2-pr-context-status.2026-04-26T19-48.md`.
  - Acceptance: The artifact records whether the rerun reviewed a commit range or working-tree appendix and names the resolved base and head commits.
- [x] [P3-T2] Regenerate `policy-audit`, `code-review`, and `feature-audit` artifacts after the split using the refreshed evidence.
  - Acceptance: New timestamped review artifacts exist in the active feature folder and reference explicit base `development`.
- [x] [P3-T3] Validate the regenerated review artifacts with `scripts.dev_tools.validate_orchestration_artifacts`.
  - Acceptance: Validation passes for the new `policy-audit`, `code-review`, and `feature-audit` files.
- [x] [P3-T4] Write a concise final remediation verdict artifact at `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-2-final-verdict.2026-04-26T19-48.md`.
  - Acceptance: The artifact states whether the residual blocker is closed and whether another remediation loop is required.

## Test Plan

- Unit: `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
- Integration: Reuse the package-wide Jest suite as the wrapper-layer regression gate; no new external integration surface is required for this narrow structural split.
- Manual/CLI: `poetry run python -m scripts.dev_tools.pr_context.collector --base development`; line-count verification via PowerShell.
- Coverage evidence: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-2-typescript-test-coverage.2026-04-26T19-48.md` and `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-2-typescript-test-coverage.2026-04-26T19-48.md`

## Open Questions / Notes

- Keep remediation scope limited to the residual TypeScript structural blocker.
- Preserve all already-passing feature acceptance criteria and do not reopen Python feature implementation work.
- If the command-registration file cannot be decomposed cleanly while preserving behavior, document the exact constraint with evidence instead of weakening the policy requirement.
