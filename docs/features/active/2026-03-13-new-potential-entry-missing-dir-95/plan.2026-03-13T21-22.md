# 2026-03-13-new-potential-entry-missing-dir (Minimal-Audit Plan)

- **Issue:** `#95`
- **Requirements Source:** `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/issue.md`
- **Work Mode:** `minor-audit`
- **Plan Path:** `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/plan.2026-03-13T21-22.md`
- **Directive:** `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`
- **Last Updated:** `2026-03-13T21-22`

Overview: Fix the two `new-potential-entry.ps1` defects described in `issue.md` by proving the current baseline, adding failing regression coverage first, applying the smallest matching PowerShell changes in both production copies, and finishing with one clean unconditional PowerShell QC pass.

### Phase 0 — Baseline capture

- [x] [P0-T1] Record required policy reads in `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/baseline/phase0-instructions-read.md`
	- Preconditions: `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/issue.md` remains the sole requirements source for this minor-audit plan.
	- Acceptance: The artifact exists and contains `Timestamp:`, `Policy Order:`, and these exact paths in order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`.

- [x] [P0-T2] Run the baseline PowerShell format command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and save the result to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/baseline/p0-t2-format.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T3] Run the baseline PowerShell lint command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` and save the result to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/baseline/p0-t3-analyze.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Run the baseline PowerShell test command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and save the result to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/baseline/p0-t4-test.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture baseline structural counts and the current `Invoke-VSCodeOpen` signatures for `scripts/dev-tools/new-potential-entry.ps1` and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` in `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/baseline/p0-t5-structure-scan.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `File: scripts/dev-tools/new-potential-entry.ps1`, `File: extensions/drm-copilot/resources/templates/new-potential-entry.ps1`, `CopyItemTargetCount:`, `DirectoryGuardCount:`, `StartProcessCount:`, `ReuseWindowCount:`, and `Invoke-VSCodeOpen Signature:`.

- [x] [P1-T1] [expect-fail] Add a Pester regression test in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` that asserts both production scripts contain the parent-directory guard block before `Copy-Item $template $target -Force`
	- Preconditions: `[P0-T5]` recorded the baseline structure for both production scripts.
	- Acceptance: `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` contains one new `It` case that reads both production scripts and checks for `Split-Path -Parent $target`, `Test-Path $targetDir`, and `New-Item -ItemType Directory -Path $targetDir -Force | Out-Null` before `Copy-Item $template $target -Force`.

- [x] [P1-T2] [expect-fail] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"` after `[P1-T1]` and save the failing evidence to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/regression-testing/p1-t2-directory-guard.expect-fail.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"`, `EXIT_CODE:` with a non-zero value, and `Failure:` naming the new directory-guard regression test.

- [x] [P1-T3] [expect-fail] Add a Pester regression test in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` that asserts both production scripts include `--reuse-window` inside `Invoke-VSCodeOpen` and include at least one explicit Insiders detection marker beyond `TERM_PROGRAM_VERSION`
	- Preconditions: `[P0-T5]` recorded the current `Invoke-VSCodeOpen` signatures for both production scripts.
	- Acceptance: `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` contains one new `It` case that reads both production scripts and checks for `--reuse-window` plus either `VSCODE_IPC_HOOK_CLI` or a parent-process-name probe for `insiders` inside `Invoke-VSCodeOpen`.

- [x] [P1-T4] [expect-fail] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"` after `[P1-T3]` and save the failing evidence to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/regression-testing/p1-t4-vscode-open.expect-fail.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"`, `EXIT_CODE:` with a non-zero value, and `Failure:` naming the new `Invoke-VSCodeOpen` regression test.

- [x] [P1-T5] Insert the parent-directory guard block immediately before `Copy-Item $template $target -Force` in `scripts/dev-tools/new-potential-entry.ps1`
	- Acceptance: `scripts/dev-tools/new-potential-entry.ps1` contains `Split-Path -Parent $target`, `Test-Path $targetDir`, and `New-Item -ItemType Directory -Path $targetDir -Force | Out-Null` directly before `Copy-Item $template $target -Force`.

- [x] [P1-T6] Insert the parent-directory guard block immediately before `Copy-Item $template $target -Force` in `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`
	- Acceptance: `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` contains `Split-Path -Parent $target`, `Test-Path $targetDir`, and `New-Item -ItemType Directory -Path $targetDir -Force | Out-Null` directly before `Copy-Item $template $target -Force`.

- [x] [P1-T7] Replace the `Start-Process`-based editor launch in `scripts/dev-tools/new-potential-entry.ps1` with direct CLI invocation that reuses the active window and broadens Insiders detection
	- Acceptance: Inside `Invoke-VSCodeOpen`, the file contains `--reuse-window`, contains `VSCODE_IPC_HOOK_CLI` or a parent-process-name probe for `insiders`, and does not contain `Start-Process`.

- [x] [P1-T8] Replace the `Start-Process`-based editor launch in `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` with direct CLI invocation that reuses the active window and broadens Insiders detection
	- Acceptance: Inside `Invoke-VSCodeOpen`, the file contains `--reuse-window`, contains `VSCODE_IPC_HOOK_CLI` or a parent-process-name probe for `insiders`, and does not contain `Start-Process`.

- [x] [P1-T9] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"` after `[P1-T5]` and `[P1-T6]` and save the passing directory-guard evidence to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/regression-testing/p1-t9-directory-guard.pass.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"`, `EXIT_CODE: 0`, and `Output Summary:` naming the directory-guard regression test as passed.

- [x] [P1-T10] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"` after `[P1-T7]` and `[P1-T8]` and save the passing `Invoke-VSCodeOpen` evidence to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/regression-testing/p1-t10-vscode-open.pass.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"`, `EXIT_CODE: 0`, and `Output Summary:` naming the `Invoke-VSCodeOpen` regression test as passed.

### Phase 2 — Final QC loop

- [x] [P2-T1] Run the final PowerShell format command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and save the result to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/qa-gates/p2-t1-format.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T2] Run the final PowerShell lint command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` and save the result to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/qa-gates/p2-t2-analyze.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T3] Record the unconditional PowerShell type-check step as policy-driven not applicable in `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/qa-gates/p2-t3-typecheck-not-applicable.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: N/A (PowerShell type checking not applicable per .github/instructions/powershell-code-change.instructions.md)`, `EXIT_CODE: 0`, and the exact sentence `Type checking is not applicable for PowerShell; skip to testing.`.

- [x] [P2-T4] Run the final PowerShell test command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and save the result to `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/qa-gates/p2-t4-test.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T5] Record the clean-pass QC summary in `docs/features/active/2026-03-13-new-potential-entry-missing-dir-95/evidence/qa-gates/p2-t5-clean-pass-summary.yyyy-MM-ddTHH-mm.md`
	- Acceptance: The artifact exists and lists the exact artifact paths produced by `[P2-T1]`, `[P2-T2]`, `[P2-T3]`, and `[P2-T4]`, states `FinalPass: clean`, and states that no Phase 2 command task was skipped.
