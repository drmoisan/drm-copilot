# 2026-02-17-link-parent-child-failure-9 (Plan)

- **Issue:** #9
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-17T23-59
- **Status:** Planned
- **Version:** 0.2

## Scope Anchors

- Issue doc: `docs/features/active/2026-02-17-link-parent-child-failure-9/issue.md`
- Spec doc: `docs/features/active/2026-02-17-link-parent-child-failure-9/spec.md`
- Research doc: `docs/features/active/2026-02-17-link-parent-child-failure-9/research.2026-02-18T01-09.md`
- Script under change: `scripts/dev-tools/link-parent-child.ps1`
- Pester tests under change: `tests/scripts/dev-tools/link-parent-child.Tests.ps1`

## Scenario Inventory (for deterministic test decomposition)

- `Get-Issue` scenario A: `gh issue view` auth-required failure yields actionable message with child role and issue number.
- `Get-Issue` scenario B: `gh issue view` not-found failure yields actionable message with validation guidance.
- `Get-Issue` scenario C: `gh issue view` permission/repo-context failure yields actionable message with access/repo guidance.
- `Get-Issue` scenario D: unknown failure yields fallback actionable guidance without suppressing error.
- `Invoke-LinkParentChild` scenario E: successful path remains unchanged after diagnostic improvements.

### Phase 0 — Context & Inputs

- [x] [P0-T1] Read policy files in mandatory order and record completion in plan execution notes.
	- Acceptance: Notes include exact file list in this order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`.
- [x] [P0-T2] Capture branch and commit baseline for reproducibility before edits.
	- Acceptance: Notes include exact output values for `git branch --show-current` and `git rev-parse --short HEAD`.
- [x] [P0-T3] Capture baseline formatter result and save artifact under feature baseline evidence folder.
	- Acceptance: File `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/baseline/powershell-format-baseline.2026-02-17T23-59.md` exists and contains lines starting with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T4] Capture baseline analyzer result and save artifact under feature baseline evidence folder.
	- Acceptance: File `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/baseline/powershell-analyze-baseline.2026-02-17T23-59.md` exists and contains lines starting with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T5] Capture baseline Pester result and save artifact under feature baseline evidence folder.
	- Acceptance: File `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/baseline/powershell-test-baseline.2026-02-17T23-59.md` exists and contains lines starting with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — TDD Red Regression Coverage

- [x] [P1-T1] [expect-fail] Add Pester test for `Get-Issue` auth-required failure messaging in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
	- Acceptance: New test asserts message includes `child`, `#2`, and `gh auth status` guidance when mocked `Invoke-GhCli` returns auth-required signature.
- [x] [P1-T2] [expect-fail] Run only the new auth-required regression test and save fail-before evidence artifact.
	- Acceptance: Command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -Filter @{ FullName = '*auth-required failure messaging*' }"` exits non-zero and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/regression-testing/get-issue-auth-required-fail-before.2026-02-17T23-59.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and a `Failure:` excerpt.
- [x] [P1-T3] [expect-fail] Add Pester test for `Get-Issue` not-found failure messaging in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
	- Acceptance: New test asserts message includes issue role/number and issue-number validation guidance when mocked `Invoke-GhCli` returns not-found signature.
- [x] [P1-T4] [expect-fail] Run only the new not-found regression test and save fail-before evidence artifact.
	- Acceptance: Command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -Filter @{ FullName = '*not-found failure messaging*' }"` exits non-zero and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/regression-testing/get-issue-not-found-fail-before.2026-02-17T23-59.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and a `Failure:` excerpt.
- [x] [P1-T5] [expect-fail] Add Pester test for `Get-Issue` permission/repo-context failure messaging in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
	- Acceptance: New test asserts message includes issue role/number and repo/access guidance when mocked `Invoke-GhCli` returns permission/context signature.
- [x] [P1-T6] [expect-fail] Run only the new permission/repo-context regression test and save fail-before evidence artifact.
	- Acceptance: Command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -Filter @{ FullName = '*permission/repo-context failure messaging*' }"` exits non-zero and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/regression-testing/get-issue-permission-context-fail-before.2026-02-17T23-59.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and a `Failure:` excerpt.

### Phase 2 — Minimal Script Fix Slices

- [x] [P2-T1] Add helper function in `scripts/dev-tools/link-parent-child.ps1` to classify `gh issue view` fetch failures by exit code/output signature.
	- Acceptance: Helper returns deterministic categories for auth-required, not-found, permission/repo-context, and unknown signatures.
- [x] [P2-T2] Add helper function in `scripts/dev-tools/link-parent-child.ps1` to compose actionable fetch failure messages from category, role, and issue number.
	- Acceptance: Helper output always includes issue role, issue number, and at least one concrete next-step command/check.
- [x] [P2-T3] Update `Get-Issue` in `scripts/dev-tools/link-parent-child.ps1` to call classification and message helpers before raising script error.
	- Acceptance: `Get-Issue` failure branch uses helper-composed message text and continues routing errors through `Write-ScriptError`.
- [x] [P2-T4] Preserve failure contract by ensuring fetch failures still produce `InvalidOperationException` semantics via `Write-ScriptError`.
	- Acceptance: Existing and new tests assert thrown error type remains `InvalidOperationException` for `Get-Issue` failure paths.

### Phase 3 — TDD Green and Behavioral Guard Tests

- [x] [P3-T1] Run the auth-required `Get-Issue` scenario test and capture pass artifact.
	- Acceptance: Command from [P1-T2] exits 0 and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/regression-testing/get-issue-auth-required-pass-after.2026-02-17T23-59.md` contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.
- [x] [P3-T2] Run the not-found `Get-Issue` scenario test and capture pass artifact.
	- Acceptance: Command from [P1-T4] exits 0 and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/regression-testing/get-issue-not-found-pass-after.2026-02-17T23-59.md` contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.
- [x] [P3-T3] Run the permission/repo-context `Get-Issue` scenario test and capture pass artifact.
	- Acceptance: Command from [P1-T6] exits 0 and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/regression-testing/get-issue-permission-context-pass-after.2026-02-17T23-59.md` contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.
- [x] [P3-T4] Add Pester test for unknown `Get-Issue` failure category fallback messaging in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
	- Acceptance: Test asserts fallback branch still includes issue role/number and explicit next-step guidance.
- [x] [P3-T5] Add Pester test for `Invoke-LinkParentChild` success path stability in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
	- Acceptance: Test verifies existing parent-body update and child-comment success behavior remains unchanged.

### Phase 4 — Documentation and Traceability Updates

- [x] [P4-T1] Update `docs/features/active/2026-02-17-link-parent-child-failure-9/spec.md` to reflect final implemented diagnostic categories and test coverage.
	- Acceptance: `spec.md` includes explicit references to auth-required, not-found, permission/repo-context, and unknown fallback coverage.
- [x] [P4-T2] Update `docs/features/active/2026-02-17-link-parent-child-failure-9/issue.md` with implementation outcome summary and validation commands.
	- Acceptance: `issue.md` includes a completion note listing changed files and exact validation commands used.

### Phase 5 — Final QA Loop (PowerShell Toolchain)

- [x] [P5-T1] Run PowerShell formatter command for final QA pass.
	- Acceptance: Command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` exits 0 and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/qa-gates/final-format.2026-02-17T23-59.md` records `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.
- [x] [P5-T2] Run PowerShell analyzer command for the same final QA pass.
	- Acceptance: Command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` exits 0 and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/qa-gates/final-analyze.2026-02-17T23-59.md` records `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.
- [x] [P5-T3] Run PowerShell Pester command for the same final QA pass.
	- Acceptance: Command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` exits 0 and file `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/qa-gates/final-test.2026-02-17T23-59.md` records `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.
- [x] [P5-T4] Compare final QA outputs against Phase 0 baseline outputs and record zero-regression confirmation.
	- Acceptance: File `docs/features/active/2026-02-17-link-parent-child-failure-9/evidence/qa-gates/final-delta-summary.2026-02-17T23-59.md` states no new analyzer findings and no new failing tests relative to baseline.

### Phase 6 — Handoff Readiness

- [x] [P6-T1] Write implementation handoff summary in feature folder for executor and reviewer consumption.
	- Acceptance: File `docs/features/active/2026-02-17-link-parent-child-failure-9/implementation-summary.2026-02-17T23-59.md` lists changed file paths, completed scenarios, and evidence artifact paths.

## Preflight Validation Log

- Iteration 1 (existing template-state plan): `PREFLIGHT: REVISIONS REQUIRED`
	- Delta applied: replaced placeholder tokens, normalized headings to `### Phase N — Title`, expanded test work into scenario-level atomic tasks, added mandatory Phase 0 baseline evidence tasks, added mandatory final PowerShell QA loop tasks, and removed ambiguous acceptance language.
- Iteration 2 (this refreshed plan): `PREFLIGHT: ALL CLEAR`
