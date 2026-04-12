# Atomic Remediation Plan — Feature #141 Coverage-Proof Closure

## Overview
This remediation plan is authoritative for the `2026-04-11T23-23` re-review of `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`.

Scope is limited to:
- closing the remaining changed/new-code coverage-proof gap for the modified existing TypeScript production files,
- refreshing the dependent QA disposition artifacts after the proof result changes,
- restoring `AC-4` in `user-story.md` only if the refreshed proof passes or an already approved exception is cited.

Out of scope:
- additive feature work unrelated to coverage-proof closure,
- refactors outside the files already implicated by the failing proof,
- policy edits, review-rule weakening, or undocumented proof exclusions,
- marking `AC-4` complete without evidence-backed support.

Execution must fail closed. If the changed/new-code proof still cannot pass after targeted remediation and no already approved exception is found, the final evidence must continue to report `remediation required` and `AC-4` must remain unchecked.

### Phase 0 — Remediation Baseline Capture
- [x] [P0-T1] Read the required policy, feature, and remediation source files in order and persist evidence at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/phase0-remediation-instructions-read.2026-04-11T23-23.md`.
  - Acceptance: The evidence file exists and contains `Timestamp:`, `Policy Order:`, `Work Mode Source: issue.md`, `Resolved Work Mode: full-feature`, and the explicit ordered file list read for this remediation: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/issue.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/spec.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/remediation-inputs.2026-04-11T23-23.md`, `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/remediation-plan.2026-04-11T22-54.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/policy-audit.2026-04-11T23-23.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/code-review.2026-04-11T23-23.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/feature-audit.2026-04-11T23-23.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md`, and `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md`.

- [x] [P0-T2] Capture the current failing coverage-proof inventory at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-gap-baseline.2026-04-11T23-23.md` by extracting the unresolved file and line findings from `ts-coverage-summary.2026-04-11T22-03.md`, `ts-changed-existing-source-coverage.2026-04-11T22-54.md`, and the affected source files.
  - Acceptance: The artifact contains `Timestamp:`, `Sources:`, and `Output Summary:`; it lists the current failing files `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tools.ts`, and `extensions/drm-copilot/src/workflow-command-arguments.ts`; it preserves the exact failing line numbers or ranges already recorded by the current proof; and it classifies each unresolved entry as `uncovered` or `unmatched`.

- [x] [P0-T3] Capture the TypeScript baseline formatting result by running `npm run format` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-format.2026-04-11T23-23.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture the TypeScript baseline lint result by running `npm run lint` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-lint.2026-04-11T23-23.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture the TypeScript baseline type-check result by running `npm run typecheck` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-typecheck.2026-04-11T23-23.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture the TypeScript baseline unit-test and coverage result by running `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-test-unit.2026-04-11T23-23.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE:`, and `Output Summary:` with numeric baseline coverage headline values.

- [x] [P0-T7] Re-run the exact deterministic changed-line proof command currently recorded in `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md` against the `coverage/lcov.info` produced by `P0-T6`, then write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-proof-baseline.2026-04-11T23-23.md`.
  - Acceptance: The artifact contains `Timestamp:`, the exact `Command:` executed, `EXIT_CODE:`, and `Output Summary:`; it records the per-file changed-line proof disposition for the three currently failing modified existing TypeScript production files; and it explicitly names any delta from `P0-T2`.

### Phase 1 — Close the Coverage-Proof Gap
- [x] [P1-T1] Create `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-proof-basis.2026-04-11T23-23.md` that classifies each unresolved line from `P0-T2` and `P0-T7` as either `executable coverage obligation` or `non-instrumented structural line`.
  - Acceptance: The artifact contains `Timestamp:`, `Sources:`, and `Output Summary:`; it enumerates every unresolved line from `P0-T2`; it cites the exact source-file line text or construct for each entry; and it cites whether the corresponding line exists in the `lcov.info` line map captured by `P0-T7`.

- [x] [P1-T2] Update the focused Jest coverage for `extensions/drm-copilot/src/mcp-tool-inputs.ts` by expanding `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` until the `resolvePolicyAuditTemplateAssetToolInput` entry path recorded at lines `240-245` in `P0-T2` is executed.
  - Acceptance: The modified test file contains assertions that invoke `resolvePolicyAuditTemplateAssetToolInput` through the entry path identified in `P0-T2`, and the focused coverage run in `P1-T5` reports no remaining uncovered executable lines for `extensions/drm-copilot/src/mcp-tool-inputs.ts`.

- [x] [P1-T3] Update the focused Jest coverage for `extensions/drm-copilot/src/workflow-command-arguments.ts` by expanding `extensions/drm-copilot/test/workflow-command-arguments.test.ts` until the executable uncovered lines recorded in `P0-T2` for `validatePolicyAuditTemplateAssetSelector`, `normalizeWorkspaceDestinationPath`, and `resolvePolicyAuditTemplateAssetInvocation` are executed.
  - Acceptance: The modified test file contains assertions that exercise the unresolved executable paths identified in `P0-T2`, and the focused coverage run in `P1-T5` reports no remaining uncovered executable lines for `extensions/drm-copilot/src/workflow-command-arguments.ts`.

- [x] [P1-T4] Refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-changed-line-inventory.2026-04-11T22-54.md` so the executable proof set excludes only the lines classified as `non-instrumented structural line` in `P1-T1`.
  - Acceptance: The refreshed artifact preserves all executable changed lines in scope; any excluded line is listed explicitly with its file path, line number, and rationale; `extensions/drm-copilot/src/mcp-tools.ts` lines `525-531` are excluded only if `P1-T1` documents them as non-instrumented structural lines; and no exclusion is added without an explicit citation back to `P1-T1`.

- [x] [P1-T5] Run the focused coverage-enabled regression suites from `extensions/drm-copilot/` using `node run-jest.cjs --runTestsByPath test/mcp-tool-inputs.test.ts test/mcp-server.test.ts test/workflow-command-arguments.test.ts --coverage --coverageReporters=text-summary --coverageReporters=json-summary` and persist `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-coverage-proof-targeted.2026-04-11T23-23.md`.
  - Acceptance: The artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the suites that passed; the command produces a fresh `coverage/lcov.info`; and the artifact states whether the targeted run removed the executable uncovered lines identified in `P0-T2`.

### Phase 2 — Final TypeScript QA Loop and Proof Refresh
- [x] [P2-T1] Run final TypeScript formatting from `extensions/drm-copilot/` using `npm run format` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-format.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary:`. If formatting changes tracked files, execution must restart the QA loop from `P2-T1`.

- [x] [P2-T2] Run final TypeScript lint from `extensions/drm-copilot/` using `npm run lint` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-lint.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE: 0`, and `Output Summary:`. If lint fails or applies fixes, execution must restart the QA loop from `P2-T1`.

- [x] [P2-T3] Run final TypeScript type checking from `extensions/drm-copilot/` using `npm run typecheck` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-typecheck.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`. If type checking fails, execution must restart the QA loop from `P2-T1`.

- [x] [P2-T4] Run final TypeScript unit tests with coverage from `extensions/drm-copilot/` using `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-test-unit.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values. The `coverage/lcov.info` generated by this task is the only coverage file used for the final changed-line proof.

- [x] [P2-T5] Re-run the exact deterministic changed-line proof command currently recorded in `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md` against the `coverage/lcov.info` produced by `P2-T4`, using the refreshed proof inventory from `P1-T4`, and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md` in place.
  - Acceptance: The refreshed artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE:`, and `Output Summary:`; it lists every modified existing TypeScript production file still in scope; it records covered versus uncovered versus unmatched executable changed lines per file; and it reports `PASS` only if every executable changed line in scope is covered.

- [ ] [P2-T6] If `P2-T5` does not report `PASS`, search `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/` for an already approved exception dossier and persist the result at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-exception-search.2026-04-11T23-23.md`.
  - Acceptance: The artifact contains `Timestamp:`, `SearchScope: docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`, `SearchPatterns: *exception*.md`, and `SearchResult:` with matching paths or `none`; if an approved exception is found, the artifact cites the exact file path and approval text; if none is found, the artifact states that remediation remains open and `AC-4` must stay unchecked.

### Phase 3 — Refresh Dependent QA Evidence
- [x] [P3-T1] Refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md` using the original baseline evidence from `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-test-unit.2026-04-11T22-03.md`, the refreshed `P2-T4` test evidence, the final proof artifact from `P2-T5`, and any approved exception captured by `P2-T6`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: derived-from-baseline-ts-test-unit-and-P2-T4/P2-T5/P2-T6`, `EXIT_CODE: 0`, and `Output Summary:`; it cites baseline and refreshed post-change headline coverage values; it records the final changed/new-code disposition for each modified existing TypeScript production file; and it reports `remediation required` unless `P2-T5` passes or `P2-T6` cites an already approved exception.

- [x] [P3-T2] Refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/qa-loop-summary.2026-04-11T22-03.md` so it reflects the final post-remediation QA evidence.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: final-clean-pass-summary`, `EXIT_CODE: 0`, and `Output Summary:`; it records the final clean-pass order `format -> lint -> typecheck -> test`, the rerun count triggered by file changes or failures, the refreshed per-step QA artifact paths from `P2-T1` through `P2-T4`, the refreshed coverage-summary artifact from `P3-T1`, and the final changed-line proof artifact from `P2-T5`.

- [x] [P3-T3] Inspect `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md` and restore acceptance criterion 4 only if `P3-T1` records a satisfied changed/new-code obligation or cites an already approved exception.
  - Acceptance: `user-story.md` acceptance criterion 4 is checked only when `P3-T1` supports that outcome; if `P3-T1` still records `remediation required`, AC-4 remains unchecked and no other acceptance criteria are modified.

## Acceptance Criteria Traceability
- Remediation requirement 1 (close the changed/new-code coverage proof gap): P0-T2, P0-T7, P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P2-T5, P2-T6, P3-T1
- Remediation requirement 2 (refresh QA disposition artifacts): P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P3-T1, P3-T2
- Remediation requirement 3 (restore AC-4 only after proof closure or approved exception): P2-T6, P3-T1, P3-T3

## Preflight Checklist
- [x] Phase headings follow the required `### Phase N — Title` format.
- [x] Task IDs are sequential and phase-aligned.
- [x] The plan updates the provided remediation plan path in place and creates no sibling plan files.
- [x] Phase 0 includes explicit policy-read evidence and TypeScript baseline command artifacts.
- [x] The implementation scope is limited to the changed/new-code coverage-proof gap and dependent QA evidence refresh.
- [x] The plan distinguishes executable uncovered lines from unmatched non-instrumented structural lines before any proof exclusions are applied.
- [x] The final QA loop uses the required TypeScript command order `format -> lint -> typecheck -> test`.
- [x] The final proof task fails closed unless every executable changed line is covered or an already approved exception is cited.
- [x] The plan refreshes the existing QA disposition artifacts in place rather than creating replacement summary files.
- [x] The plan restores `AC-4` only after evidence closure or an approved exception.
- [x] No placeholder tokens or bucket tasks remain.
