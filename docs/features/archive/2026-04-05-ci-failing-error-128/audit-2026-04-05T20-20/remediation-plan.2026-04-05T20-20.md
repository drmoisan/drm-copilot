# 2026-04-05-ci-failing-error-128 - Remediation Plan

- **Issue:** 128
- **Owner:** drmoisan
- **Last Updated:** 2026-04-05T20-20
- **Status:** Planned
- **Version:** 1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- TypeScript Suppressions Policy: [`.github/instructions/typescript-suppressions.instructions.md`](../../../../.github/instructions/typescript-suppressions.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

> Review fallback note: this remediation plan was drafted directly in the review environment because no executable atomic-planner command surface was discoverable here. The task structure follows the repository atomic-planner contract.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance & Remediation Baseline
- [x] [P0-T1] Read `.github/copilot-instructions.md`
  - Acceptance: Execution notes confirm the repository tone and response-policy file was read before any implementation work.

- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md`
  - Acceptance: Execution notes confirm the general code-change policy was read before any implementation work.

- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md`
  - Acceptance: Execution notes confirm the general unit-test policy was read before any implementation work.

- [x] [P0-T4] Read `.github/instructions/typescript-code-change.instructions.md`
  - Acceptance: Execution notes confirm the TypeScript code-change policy was read before any implementation work.

- [x] [P0-T5] Read `.github/instructions/typescript-unit-test.instructions.md` and `.github/instructions/typescript-suppressions.instructions.md`
  - Acceptance: Execution notes confirm the TypeScript unit-test and suppression policies were read before any implementation work.

- [x] [P0-T6] Record a Phase 0 instructions-read artifact at `docs/features/active/2026-04-05-ci-failing-error-128/evidence/remediation-baseline/phase0-instructions-read.md`
  - Acceptance: The artifact includes `Timestamp:`, `Policy Order:`, and an explicit `Files Read:` list matching P0-T1 through P0-T5.

- [x] [P0-T7] Confirm remediation scope by reading `docs/features/active/2026-04-05-ci-failing-error-128/remediation-inputs.2026-04-05T20-20.md`, `docs/features/active/2026-04-05-ci-failing-error-128/policy-audit.2026-04-05T20-20.md`, and `docs/features/active/2026-04-05-ci-failing-error-128/code-review.2026-04-05T20-20.md`
  - Acceptance: Execution notes identify the file-size violation in `extensions/drm-copilot/test/extension.test.ts` as the primary remediation target.

- [x] [P0-T8] Run `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location` and capture the baseline result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/remediation-baseline/baseline-prettier-check.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T9] Run `Push-Location extensions/drm-copilot; npm run lint; Pop-Location` and capture the baseline result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/remediation-baseline/baseline-eslint.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T10] Run `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location` and capture the baseline result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/remediation-baseline/baseline-tsc.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T11] Run `Push-Location extensions/drm-copilot; npm run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"; Pop-Location` and capture the baseline regression result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/remediation-baseline/baseline-targeted-regressions.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the four Windows-root POSIX scenarios.

- [x] [P0-T12] Run `Push-Location extensions/drm-copilot; npx jest --coverage --coverageReporters=text-summary --runInBand; Pop-Location` and capture the result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/remediation-baseline/baseline-jest-coverage.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric overall coverage values and the changed production file coverage if available.

- [x] [P0-T13] Record a remediation baseline artifact at `docs/features/active/2026-04-05-ci-failing-error-128/evidence/remediation-baseline/baseline-line-counts.md` capturing the current line counts for `extensions/drm-copilot/test/extension.test.ts` and any planned companion test files
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and the current `918` line count for `extensions/drm-copilot/test/extension.test.ts`.

### Phase 1 — Restructure the Oversized Test Surface
- [x] [P1-T1] Extract or relocate the shared POSIX fresh-module path helper logic from `extensions/drm-copilot/test/extension.test.ts` so the file no longer owns duplicated setup that can be shared safely
  - Acceptance: The duplicated helper logic is defined once in the remediated layout, and the resulting touched files remain strongly named and deterministic.
- [x] [P1-T2] Reorganize `extensions/drm-copilot/test/extension.test.ts` into policy-compliant file sizes without removing the existing command behavior coverage
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` and every newly touched or created companion/helper test file are each `<= 500` lines after the reorganization.
- [x] [P1-T3] Update `extensions/drm-copilot/test/repo-automation-service.test.ts` and any new companion test file(s) to consume the remediated helper/layout while preserving the four Windows-root POSIX regression scenarios exactly as currently named
  - Acceptance: The scenarios `helloPython preserves C:/extension on POSIX hosts`, `helloPowerShell preserves C:/extension on POSIX hosts`, `collectCommitContext preserves C:/extension on POSIX hosts`, and `newPotentialEntry preserves C:/extension on POSIX hosts` still exist with the same path expectations.
- [x] [P1-T4] Verify the remediated touched-file set stays within the approved behavior scope: no production file changes, `extensions/drm-copilot/src/command-runtime.ts` remains unchanged from the current fix, no acceptance-criteria text changes, and no added policy suppressions beyond pre-authorized patterns
  - Acceptance: A scope-check artifact confirms the final touched file set, confirms no production files changed, and confirms every touched test/helper file is `<= 500` lines.

### Phase 2 — Verification and Evidence Refresh
- [x] [P2-T1] Run `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location` and capture the result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/final-qa/final-prettier-check.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming formatting is clean.

- [x] [P2-T2] Run `Push-Location extensions/drm-copilot; npm run lint; Pop-Location` and capture the result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/final-qa/final-eslint.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` with no blocking ESLint diagnostics.

- [x] [P2-T3] Run `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location` and capture the result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/final-qa/final-tsc.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` with no blocking TSC diagnostics.

- [x] [P2-T4] Run `Push-Location extensions/drm-copilot; npm run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"; Pop-Location` and capture the result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/final-qa/final-targeted-regressions.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming all four Windows-root POSIX scenarios as passing.

- [x] [P2-T5] Run `Push-Location extensions/drm-copilot; npx jest --coverage --coverageReporters=text-summary --runInBand; Pop-Location` and capture the result in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/final-qa/final-jest-coverage.md`
  - Acceptance: The artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-remediation coverage values sufficient to verify the repo thresholds remain satisfied.

- [x] [P2-T6] Record a final scope-check artifact at `docs/features/active/2026-04-05-ci-failing-error-128/evidence/final-qa/final-scope-and-line-counts.md`
  - Acceptance: The artifact confirms the final touched file set, records the final line counts for every touched test file, explicitly confirms every touched test/helper file is `<= 500` lines, confirms no production files changed and `extensions/drm-copilot/src/command-runtime.ts` remains unchanged from the current fix, and confirms the four Windows-root POSIX regression scenarios remain exactly as named.

- [x] [P2-T7] Refresh `docs/features/active/2026-04-05-ci-failing-error-128/policy-audit.*.md` and `docs/features/active/2026-04-05-ci-failing-error-128/code-review.*.md` (or replace them with newer timestamped artifacts) so the review output references the remediated file layout and final verification evidence
  - Acceptance: Updated review artifacts no longer report a touched file over 500 lines and conclude the branch is PR-ready if no other issues remain.

## Test Plan

- Unit: focused Windows-root POSIX regressions for `helloPython`, `helloPowerShell`, `collectCommitContext`, and `newPotentialEntry`
- Integration: full `extensions/drm-copilot` Jest suite
- Manual/CLI: non-mutating Prettier check, ESLint, TSC, and line-count verification of all touched test files

## Open Questions / Notes

- Preserve the reduced-audit contract: `issue.md` remains the sole acceptance-criteria source, and `spec.md` / `user-story.md` remain absent.
- If the remediation requires new test files, update the scope evidence and refreshed review artifacts to reflect the final touched-file list.
