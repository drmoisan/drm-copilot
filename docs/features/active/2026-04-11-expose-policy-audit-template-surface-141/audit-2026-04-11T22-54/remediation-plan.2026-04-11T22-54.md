# Atomic Remediation Plan — Feature #141 Coverage Evidence Closure

## Overview
This remediation plan is authoritative for closing the remaining review gap recorded in `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/remediation-inputs.2026-04-11T22-54.md`.

Scope is limited to:
- producing deterministic changed/new-code coverage evidence for the modified existing TypeScript production files touched by this feature,
- refreshing the dependent QA disposition artifacts at `evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md` and `evidence/qa-gates/qa-loop-summary.2026-04-11T22-03.md`,
- restoring `user-story.md` acceptance criterion 4 only if the refreshed evidence or an already approved exception supports that outcome.

Out of scope:
- extension production refactors unrelated to coverage proof,
- policy edits or review-criteria weakening,
- renaming or redesigning `resolve_policy_audit_template_asset` or `drmCopilotExtension.resolvePolicyAuditTemplateAsset`,
- new review artifacts beyond the evidence and acceptance-source files required to close this remediation.

Execution must fail closed. If deterministic changed-line isolation cannot be produced from the repo toolchain outputs and no already approved exception can be cited, leave AC-4 unchecked and report remediation still open instead of widening scope.

### Phase 0 — Remediation Baseline Capture
- [x] [P0-T1] Read the required policy and remediation source files in order and persist evidence at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/phase0-remediation-instructions-read.2026-04-11T22-54.md`.
  - Acceptance: The evidence file exists and contains `Timestamp:`, `Policy Order:`, `Work Mode Source: issue.md`, `Resolved Work Mode: full-feature`, and the explicit ordered file list read for this remediation: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/remediation-inputs.2026-04-11T22-54.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/policy-audit.2026-04-11T22-54.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/code-review.2026-04-11T22-54.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/feature-audit.2026-04-11T22-54.md`, `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, and `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`.

- [x] [P0-T2] Record the modified existing TypeScript production files that require changed/new-code proof by running `git diff --name-status HEAD -- extensions/drm-copilot/src` and persist the result at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-remediation-scope.2026-04-11T22-54.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: git diff --name-status HEAD -- extensions/drm-copilot/src`, `EXIT_CODE:`, and `Output Summary:`; it enumerates only `M` entries under `extensions/drm-copilot/src/*.ts` as the proof set for this remediation, explicitly excludes new files and non-production paths from the changed-line proof set, and states that the proof scope is limited to modified existing TypeScript production files.

- [x] [P0-T3] Record the exact changed line ranges for the Phase 0 proof set by running a `git diff --unified=0 HEAD -- <modified-existing-src-ts-files>` command derived from `P0-T2` and persist the result at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-changed-line-inventory.2026-04-11T22-54.md`.
  - Acceptance: The artifact contains `Timestamp:`, the exact `Command:` used, `EXIT_CODE:`, and `Output Summary:`; it records the added or modified line ranges for every file in the proof set exactly as they will be checked against coverage output, and it explains any mismatch between the expected modified files and the actual `P0-T2` proof set.

### Phase 1 — Final TypeScript QA and Coverage-Proof Extraction
- [x] [P1-T1] Re-run final TypeScript formatting from `extensions/drm-copilot/` using `npm run format` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-format.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary:`. If formatting changes any tracked TypeScript file, execution must restart the QA loop from `P1-T1`.

- [x] [P1-T2] Re-run final TypeScript lint from `extensions/drm-copilot/` using `npm run lint` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-lint.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE: 0`, and `Output Summary:`. If lint fails or applies fixes, execution must restart the QA loop from `P1-T1`.

- [x] [P1-T3] Re-run final TypeScript type checking from `extensions/drm-copilot/` using `npm run typecheck` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-typecheck.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`. If type checking fails, execution must restart the QA loop from `P1-T1`.

- [x] [P1-T4] Re-run final TypeScript unit tests with coverage from `extensions/drm-copilot/` using `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` and refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-test-unit.2026-04-11T22-03.md`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values. Execution must use the coverage outputs generated by this task, including `extensions/drm-copilot/coverage/lcov.info`, for subsequent changed-line proof.

- [x] [P1-T5] From `extensions/drm-copilot/`, run one deterministic `node` command that combines `extensions/drm-copilot/coverage/lcov.info` from `P1-T4` with the changed-line inventory from `P0-T3`, then persist the changed-line coverage proof at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md`.
  - Acceptance: The artifact contains `Timestamp:`, the exact `Command:` used, `EXIT_CODE:`, and `Output Summary:`; it lists every modified existing TypeScript production file from `P0-T2`, the exact changed lines from `P0-T3`, covered versus uncovered changed-line counts per file, and the aggregate changed-line coverage disposition. If any changed line cannot be matched to `lcov.info`, the artifact must fail closed by naming the missing file and line numbers and must not report a passing disposition for that file.

- [x] [P1-T6] If `P1-T5` cannot prove changed/new-code coverage as passing, search the feature folder for an already approved exception dossier and record the result at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-exception-search.2026-04-11T22-54.md`.
  - Acceptance: The artifact contains `Timestamp:`, `SearchScope: docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`, `SearchPatterns: *exception*.md`, and `SearchResult:` with matching paths or `none`; if an approved exception is found, the artifact cites the exact file path and approval text; if none is found, the artifact states that remediation must remain open and AC-4 must stay unchecked.

### Phase 2 — Refresh QA Disposition and Acceptance Source
- [x] [P2-T1] Refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md` using the original baseline evidence from `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-test-unit.2026-04-11T22-03.md`, the refreshed `P1-T4` test evidence, the `P1-T5` changed-line proof artifact, and any approved exception located by `P1-T6`.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: derived-from-baseline-ts-test-unit-and-P1-T4/P1-T5/P1-T6`, `EXIT_CODE: 0`, and `Output Summary:`; it cites the baseline coverage headline values, the refreshed post-change coverage headline values, whether headline coverage regressed, and the explicit changed/new-code disposition for each modified existing TypeScript production file. The artifact may report PASS only if `P1-T5` proves the obligation or `P1-T6` cites an already approved exception; otherwise it must continue to state `remediation required`.

- [x] [P2-T2] Refresh `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/qa-loop-summary.2026-04-11T22-03.md` so it reflects the post-remediation QA evidence.
  - Acceptance: The refreshed artifact contains `Timestamp:`, `Command: final-clean-pass-summary`, `EXIT_CODE: 0`, and `Output Summary:`; it records the final clean-pass order `format -> lint -> typecheck -> test`, the rerun count triggered by file changes or failures, the refreshed per-step QA artifact paths from `P1-T1` through `P1-T4`, the refreshed coverage-summary artifact from `P2-T1`, and the changed-line proof artifact from `P1-T5`.

- [x] [P2-T3] Inspect `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md` and restore AC-4 only if `P2-T1` records a satisfied changed/new-code obligation or cites an already approved exception.
  - Acceptance: `user-story.md` acceptance criterion 4 is checked only when `P2-T1` supports that outcome; if `P2-T1` still records `remediation required`, AC-4 remains unchecked and no other acceptance criteria are modified.

## Acceptance Criteria Traceability
- Remediation requirement 1 (close the changed/new-code coverage proof gap): P0-T2, P0-T3, P1-T4, P1-T5, P1-T6, P2-T1
- Remediation requirement 2 (refresh QA disposition artifacts): P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P2-T1, P2-T2
- Remediation requirement 3 (restore AC-4 only after evidence closure): P1-T6, P2-T1, P2-T3

## Preflight Checklist
- [x] Phase headings follow the required `### Phase N — Title` format.
- [x] Task IDs are sequential and phase-aligned.
- [x] The plan updates the provided remediation plan path in place and creates no sibling plan files.
- [x] Phase 0 includes explicit policy-read evidence and a deterministic remediation proof-set inventory.
- [x] The QA loop uses the required TypeScript command order `format -> lint -> typecheck -> test`.
- [x] The plan adds an explicit deterministic changed-line coverage proof step based on repo-generated coverage outputs.
- [x] The plan refreshes the existing QA disposition artifacts in place rather than creating replacement summary files.
- [x] The plan restores AC-4 only after evidence closure or an already approved exception.
- [x] The plan fails closed if no deterministic proof or approved exception exists.
- [x] No unrelated extension refactors, policy edits, or surface redesign tasks are included.
