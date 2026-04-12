# 2026-03-14-potential-to-issue-auto-resolve-prompts (Minimal-Audit Plan)

- **Issue:** `#98`
- **Requirements Source:** `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/issue.md`
- **Work Mode:** `minor-audit`
- **Plan Path:** `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/plan.2026-03-14T11-37.md`
- **Directive:** `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`
- **Last Updated:** `2026-03-14T11-37`

Overview: Fix the destination-workspace `drm-copilot: Potential To Issue` flow described in `issue.md` by capturing the current extension baseline, adding focused failing Jest coverage for active-editor auto-resolution plus the two follow-up prompts, applying the smallest extension-local change inside constrained targets, and finishing with one clean unconditional extension QA pass. `issue.md` is the sole requirements source for this plan.

### Phase 0 — Baseline capture

- [x] [P0-T1] Record required policy reads in `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/baseline/phase0-instructions-read.md`
	- Preconditions: `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/issue.md` remains the sole requirements source for this minor-audit plan.
	- Acceptance: The artifact exists and contains `Timestamp:`, `Policy Order:`, and these exact paths in order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`.

- [x] [P0-T2] Run the baseline extension format command `npm --prefix extensions/drm-copilot run format` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/baseline/p0-t2-format.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T3] Run the baseline extension lint command `npm --prefix extensions/drm-copilot run lint` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/baseline/p0-t3-lint.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Run the baseline extension typecheck command `npm --prefix extensions/drm-copilot run typecheck` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/baseline/p0-t4-typecheck.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Run the baseline extension unit-test command `npm --prefix extensions/drm-copilot run test:unit` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/baseline/p0-t5-test.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Record the constrained small-path targets in `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/baseline/p0-t6-constrained-targets.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Constrained Target: extensions/drm-copilot/src/extension.ts`, `Constrained Target: extensions/drm-copilot/test/extension.potential-to-issue.test.ts`, and `Reason:` lines that quote the `Suspected Cause / Notes` and `Proposed Fix / Validation Ideas` sections from `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/issue.md`.

### Phase 1 — Constrained small-path implementation

- [x] [P1-T1] Record the constrained small-path handoff in `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/other/p1-t1-small-path-handoff.yyyy-MM-ddTHH-mm.md`
	- Preconditions: `[P0-T6]` identifies the constrained target list.
	- Acceptance: The artifact exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/issue.md`, `Constrained Target: extensions/drm-copilot/src/extension.ts`, `Constrained Target: extensions/drm-copilot/test/extension.potential-to-issue.test.ts`, and `OutOfScope: Any non-extension-local file change requires a new justification artifact before editing.`.

- [x] [P1-T2] [expect-fail] Add a Jest regression test in the constrained test target from `[P1-T1]` for `drmCopilotExtension.potentialToIssue` reusing the active `docs/features/potential/*.md` editor path before any file-picker fallback
	- Preconditions: `[P1-T1]` recorded the constrained handoff.
	- Acceptance: The constrained test target from `[P1-T1]` contains one new `it(` block whose assertions require the active potential editor path to be passed as `--potential-path` and require `showOpenDialogMock` not to be called when that active path is valid.

- [x] [P1-T3] [expect-fail] Add a Jest regression test in the constrained test target from `[P1-T1]` for the promotion-type quick pick still appearing after active-editor auto-resolution
	- Preconditions: `[P1-T1]` recorded the constrained handoff.
	- Acceptance: The constrained test target from `[P1-T1]` contains one new `it(` block whose assertions require one `showQuickPickMock` selection to feed the spawned `--promotion-type` argument after the active editor path is reused.

- [x] [P1-T4] [expect-fail] Add a Jest regression test in the constrained test target from `[P1-T1]` for the work-mode quick pick still appearing after active-editor auto-resolution
	- Preconditions: `[P1-T1]` recorded the constrained handoff.
	- Acceptance: The constrained test target from `[P1-T1]` contains one new `it(` block whose assertions require the follow-up `showQuickPickMock` selection to feed the spawned `--work-mode` argument after the active editor path is reused.

- [x] [P1-T5] [expect-fail] Run `npm --prefix extensions/drm-copilot run test:unit` and save the failing regression evidence to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/regression-testing/p1-t5-potential-to-issue.expect-fail.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE:` with a non-zero value, and `Failure:` lines that name at least one of the new active-editor auto-resolve, promotion-type quick-pick, or work-mode quick-pick scenarios.

- [x] [P1-T6] Apply the minimal extension-local production change inside the constrained targets from `[P1-T1]` so the command resolves a valid active `docs/features/potential/*.md` file before any file-picker fallback
	- Acceptance: No production file outside the constrained targets from `[P1-T1]` is modified, and the constrained production target contains an active-editor resolution branch that reaches the spawned `--potential-path` argument before any reachable `showOpenDialog(` fallback for a valid active potential file.

- [x] [P1-T7] Preserve the promotion-type quick pick after active-editor auto-resolution inside the constrained targets from `[P1-T1]`
	- Acceptance: The constrained production target still contains a `showQuickPick(` call whose selected value is forwarded to the spawned `--promotion-type` argument after the active-editor resolution branch.

- [x] [P1-T8] Preserve the work-mode quick pick after active-editor auto-resolution inside the constrained targets from `[P1-T1]`
	- Acceptance: The constrained production target still contains a `showQuickPick(` call whose selected value is forwarded to the spawned `--work-mode` argument after the active-editor resolution branch.

- [x] [P1-T9] Keep the file-picker fallback when no valid active potential markdown file is resolved inside the constrained targets from `[P1-T1]`
	- Acceptance: The constrained production target still contains a `showOpenDialog(` path that is reachable only after the active-editor potential-file check fails.

- [x] [P1-T10] Run `npm --prefix extensions/drm-copilot run test:unit` and save the passing targeted verification evidence to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/regression-testing/p1-t10-potential-to-issue.pass.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE: 0`, and `Output Summary:` that names the active-editor auto-resolve, promotion-type quick-pick, work-mode quick-pick, and picker-fallback scenarios as passed.

- [x] [P1-T11] Record the reduced small-audit handoff in `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/other/p1-t11-reduced-audit-handoff.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Verified Artifact: docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/regression-testing/p1-t10-potential-to-issue.pass.yyyy-MM-ddTHH-mm.md`, and `Ready For Phase 2: true`.

### Phase 2 — Final QC loop

- [x] [P2-T1] Run the final extension format command `npm --prefix extensions/drm-copilot run format` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t1-format.yyyy-MM-ddTHH-mm.md`; if this command changes files or exits non-zero, resume the QC loop from `[P2-T1]` after corrections
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T2] Run the final extension lint command `npm --prefix extensions/drm-copilot run lint` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t2-lint.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T3] Run the final extension typecheck command `npm --prefix extensions/drm-copilot run typecheck` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t3-typecheck.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T4] Run the final extension unit-test command `npm --prefix extensions/drm-copilot run test:unit` and save the result to `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t4-test.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T5] Record the clean-pass QC summary in `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t5-clean-pass-summary.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `FinalPass: clean`, `Artifact: docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t1-format.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t2-lint.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t3-typecheck.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/qa-gates/p2-t4-test.yyyy-MM-ddTHH-mm.md`, and the exact sentence `No Phase 2 command task was skipped.`.
