# 2026-04-05-general-instructions-first (Plan)

- **Issue:** #122
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-05T13-13
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** minor-audit
- **Directive:** `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`
- **Validation Mode:** `DIRECTIVE: PREFLIGHT VALIDATION ONLY`

## Overview

Fix the PowerShell sync-ordering bug described in Issue #122 with a constrained small-path bugfix. The plan uses `issue.md` as the only requirements source, records Phase 0 baseline evidence with the direct PoshQC commands, and ends with an unconditional final QC loop plus issue status updates.

## Requirement Source

- Sole requirements source: `docs/features/active/2026-04-05-general-instructions-first-122/issue.md`
- Authoritative acceptance-criteria source: the exact `## Acceptance Criteria` section in `issue.md`
- `spec.md` and `user-story.md` do not exist for this minor-audit fix and must not be required by execution or validation

## Small-Path Scope

| File | Role | Planned change |
|---|---|---|
| `scripts/dev-tools/sync-agents-from-instructions.ps1` | Root PowerShell production script | Minimal ordering bugfix |
| `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` | Bundled PowerShell mirror | Byte-identical mirror of the root script |
| `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` | Pester coverage | Ordering regression coverage |
| `AGENTS.md` | Generated output | Regenerated to verify grouped general-first order |

## Toolchain Commands

1. Format: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
2. Analyze: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
3. Test: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

## Evidence Locations

- Baseline: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/`
- Regression testing: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/regression-testing/`
- QA gates: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/qa-gates/`

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `.github/copilot-instructions.md`
	- Acceptance: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/phase0-instructions-read.md` records `.github/copilot-instructions.md` under `Files Read:`.

- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md`
	- Acceptance: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/phase0-instructions-read.md` records `.github/instructions/general-code-change.instructions.md` under `Files Read:`.

- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md`
	- Acceptance: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/phase0-instructions-read.md` records `.github/instructions/general-unit-test.instructions.md` under `Files Read:`.

- [x] [P0-T4] Read `.github/instructions/powershell-code-change.instructions.md`
	- Acceptance: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/phase0-instructions-read.md` records `.github/instructions/powershell-code-change.instructions.md` under `Files Read:`.

- [x] [P0-T5] Read `.github/instructions/powershell-unit-test.instructions.md`
	- Acceptance: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/phase0-instructions-read.md` records `.github/instructions/powershell-unit-test.instructions.md` under `Files Read:`.

- [x] [P0-T6] Write the Phase 0 policy-read artifact to `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/phase0-instructions-read.md`
	- Acceptance: `phase0-instructions-read.md` contains `Timestamp:`, `Policy Order:`, `Files Read:`, `Work Mode: minor-audit`, `AC Source: issue.md -> ## Acceptance Criteria`, `Target Plan Path: c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-04-05-general-instructions-first-122\plan.2026-04-05T13-13.md`, `spec.md: not required`, and `user-story.md: not required`.

- [x] [P0-T7] Run the baseline PoshQC formatter command
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/baseline-poshqc-format.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T8] Run the baseline PoshQC analyzer command
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/baseline-poshqc-analyze.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T9] Run the baseline PoshQC Pester command
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/baseline/baseline-poshqc-test.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Constrained Small-Path Implementation

- [x] [P1-T1] Lock execution scope to `scripts/dev-tools/sync-agents-from-instructions.ps1`, `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`, `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`, `AGENTS.md`, `issue.md`, and evidence artifacts under this feature folder
	- Acceptance: `docs/features/active/2026-04-05-general-instructions-first-122/evidence/qa-gates/scope-lock.2026-04-05T16-20.md` retains the `git status --short --untracked-files=all` output summary for the final minor-audit changed-file set and confirms it is limited to `scripts/dev-tools/sync-agents-from-instructions.ps1`, `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`, `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`, `AGENTS.md`, `docs/features/active/2026-04-05-general-instructions-first-122/issue.md`, `docs/features/active/2026-04-05-general-instructions-first-122/plan.2026-04-05T13-13.md`, and files under `docs/features/active/2026-04-05-general-instructions-first-122/evidence/`; no task in this plan requires `spec.md` or `user-story.md`.

- [x] [P1-T2] [expect-fail] Add a Pester regression scenario in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` that proves basenames starting with `general` must appear before language-specific instruction files in generated `AGENTS.md` output
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/regression-testing/regression-general-first-order.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the recorded `EXIT_CODE:` is non-zero and the summary identifies the new ordering assertion as the failure signal.

- [x] [P1-T3] Update `scripts/dev-tools/sync-agents-from-instructions.ps1` so discovered instruction files whose basenames start with `general` sort before the remaining instruction files while preserving deterministic ordering inside each group
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
	- Acceptance: the regression scenario added in [P1-T2] passes under the command above after this code change is applied.

- [x] [P1-T4] Add a Pester scenario in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` that verifies deterministic ordering is preserved inside the `general` group and inside the remaining language-specific group
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
	- Acceptance: the new scenario asserts the relative order `general-code-change.instructions.md` before `general-unit-test.instructions.md` and `csharp-code-change.instructions.md` before `powershell-code-change.instructions.md` before `python-code-change.instructions.md` before `typescript-code-change.instructions.md`, and the scenario passes under the command above after [P1-T3].

- [x] [P1-T5] Copy `scripts/dev-tools/sync-agents-from-instructions.ps1` byte-for-byte to `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`
	- Acceptance: `(Get-Content -Raw -LiteralPath "extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1") -eq (Get-Content -Raw -LiteralPath "scripts/dev-tools/sync-agents-from-instructions.ps1")` returns `$true`.

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run the final PoshQC formatter command without conditions
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/qa-gates/final-poshqc-format.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P2-T2] Run the final PoshQC analyzer command without conditions
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/qa-gates/final-poshqc-analyze.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P2-T3] Run the final PoshQC Pester command without conditions
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/qa-gates/final-poshqc-test.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the summary reports pass/fail counts and confirms the new ordering scenarios passed.

- [x] [P2-T4] Run the sync script to regenerate `AGENTS.md` without conditions
	- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/sync-agents-from-instructions.ps1`
	- Acceptance: exactly one artifact matching `docs/features/active/2026-04-05-general-instructions-first-122/evidence/qa-gates/final-agents-regeneration.*.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the summary states that generated `AGENTS.md` lists `general-code-change.instructions.md` and `general-unit-test.instructions.md` before language-specific instruction files and that the corresponding sections follow the same grouped order.

- [x] [P2-T5] Repeat [P2-T1] through [P2-T4] from [P2-T1] if any command fails or changes files
	- Acceptance: one clean consecutive iteration completes with zero non-zero exit codes and no formatter-induced file changes remaining.

- [x] [P2-T6] Update `docs/features/active/2026-04-05-general-instructions-first-122/issue.md` after evidence-backed verification
	- Acceptance: `issue.md` updates only the `## Acceptance Criteria` checkboxes, the relevant `## Proposed Fix / Validation Ideas` checkboxes, and `- Last Updated:`; each checkbox changed to `[x]` has corresponding evidence from [P1-T2] through [P2-T5], and any unmet checkbox remains `[ ]`.
