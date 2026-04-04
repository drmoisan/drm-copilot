# 2026-03-21-bundle-sync-agents — Atomic Plan

- Issue: #113
- Work Mode: full-feature
- Plan File: `c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-21-bundle-sync-agents-113\plan.2026-03-21T20-41.md`
- Last Updated: 2026-04-03T00-00
- Status: Planned

## Overview

Expose `sync-agents-from-instructions` through the VS Code extension, make the PowerShell generator discovery-based and deterministic, keep the bundled PowerShell copy aligned with the repo-root script, and update any rewrite-catalog surfaces that should point pushed-down content at the new live command. The execution path must preserve the repository-local PowerShell entrypoint while adding deterministic validation, multi-language evidence capture, and final coverage closure for TypeScript, PowerShell, and Python.

## Requirements Inputs

- Issue: `docs/features/active/2026-03-21-bundle-sync-agents-113/issue.md`
- Spec: `docs/features/active/2026-03-21-bundle-sync-agents-113/spec.md`
- User story: `docs/features/active/2026-03-21-bundle-sync-agents-113/user-story.md`
- Research: `docs/features/active/2026-03-21-bundle-sync-agents-113/research.md`

## Evidence Locations

- Baseline evidence: `evidence/baseline/`
- Regression evidence: `evidence/regression-testing/`
- Other evidence: `evidence/other/`
- QA evidence: `evidence/qa-gates/`

## Preflight Contract

DIRECTIVE: PREFLIGHT VALIDATION ONLY

- Required target plan path: `c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-21-bundle-sync-agents-113\plan.2026-03-21T20-41.md`
- Required preflight validator: `atomic_executor`
- Required final preflight signal: `PREFLIGHT: ALL CLEAR`
- Revision rule: update this exact plan file in place for every preflight revision; do not create sibling `plan.*.md` files.
- Execution gate: Phase 0 may begin only after validation-only preflight reports `PREFLIGHT: ALL CLEAR` for this exact plan path.

### Phase 0 — Context & Baseline Capture

- [x] [P0-T1] Read `.github/copilot-instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/copilot-instructions.md` was read before later Phase 0 tasks proceed.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/general-code-change.instructions.md` was read after `.github/copilot-instructions.md` and before later Phase 0 tasks proceed.
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/general-unit-test.instructions.md` was read after `.github/instructions/general-code-change.instructions.md` and before later Phase 0 tasks proceed.
- [x] [P0-T4] Read `.github/instructions/typescript-code-change.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/typescript-code-change.instructions.md` was read after `.github/instructions/general-unit-test.instructions.md` and before later TypeScript Phase 0 tasks proceed.
- [x] [P0-T5] Read `.github/instructions/typescript-unit-test.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/typescript-unit-test.instructions.md` was read after `.github/instructions/typescript-code-change.instructions.md` and before later TypeScript Phase 0 tasks proceed.
- [x] [P0-T6] Read `.github/instructions/powershell-code-change.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/powershell-code-change.instructions.md` was read after the TypeScript policy files and before later PowerShell Phase 0 tasks proceed.
- [x] [P0-T7] Read `.github/instructions/powershell-unit-test.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/powershell-unit-test.instructions.md` was read after `.github/instructions/powershell-code-change.instructions.md` and before later PowerShell Phase 0 tasks proceed.
- [x] [P0-T8] Read `.github/instructions/python-code-change.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/python-code-change.instructions.md` was read after the PowerShell policy files and before later Python Phase 0 tasks proceed.
- [x] [P0-T9] Read `.github/instructions/python-unit-test.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/python-unit-test.instructions.md` was read after `.github/instructions/python-code-change.instructions.md` and before later Python Phase 0 tasks proceed.
- [x] [P0-T10] Read `.github/instructions/python-suppressions.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/python-suppressions.instructions.md` was read after `.github/instructions/python-unit-test.instructions.md` and before later Python Phase 0 tasks proceed.
- [x] [P0-T11] Read `.github/instructions/self-explanatory-code-commenting.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/self-explanatory-code-commenting.instructions.md` was read after `.github/instructions/python-suppressions.instructions.md` and before later Python Phase 0 tasks proceed.
- [x] [P0-T12] Read `.github/instructions/codexer.instructions.md`
  - Acceptance: execution notes or evidence explicitly confirm `.github/instructions/codexer.instructions.md` was read after `.github/instructions/self-explanatory-code-commenting.instructions.md` and before later Phase 0 tasks proceed.
- [x] [P0-T13] Record the mandatory policy-read order in `evidence/baseline/phase0-instructions-read.md`
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, `Files Read:`, `Work Mode: full-feature`, `Requirements Sources:`, and `Target Plan Path: c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-21-bundle-sync-agents-113\plan.2026-03-21T20-41.md`; its `Files Read:` list includes the files from [P0-T1] through [P0-T12] in that exact order.
- [x] [P0-T14] Record the feature requirements snapshot in `evidence/baseline/requirements-snapshot.md`
  - Acceptance: `evidence/baseline/requirements-snapshot.md` exists and contains the headings `Objective:`, `Constraints Preserved:`, `PowerShell Surfaces:`, `TypeScript Surfaces:`, `Python Rewrite Surfaces:`, `Determinism Requirements:`, and `Documentation Targets:`.
- [x] [P0-T15] Capture the extension format baseline with `npm --prefix extensions/drm-copilot run format`
  - Acceptance: a file matching `evidence/baseline/typescript-format.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T16] Capture the extension lint baseline with `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: a file matching `evidence/baseline/typescript-lint.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T17] Capture the extension typecheck baseline with `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: a file matching `evidence/baseline/typescript-typecheck.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T18] Capture the extension coverage baseline with `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance: a file matching `evidence/baseline/typescript-test.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headlines for lines, statements, functions, and branches.
- [x] [P0-T19] Capture the PowerShell format baseline with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: a file matching `evidence/baseline/powershell-format.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T20] Capture the PowerShell analyze baseline with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: a file matching `evidence/baseline/powershell-analyze.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T21] Capture the PowerShell coverage baseline with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: a file matching `evidence/baseline/powershell-test.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage extracted from `artifacts/pester/powershell-coverage.xml` or `artifacts/pester/powershell-coverage.koverage.xml`.
- [x] [P0-T22] Capture the root Python format baseline with `poetry run black .`
  - Acceptance: a file matching `evidence/baseline/python-format.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T23] Capture the root Python lint baseline with `poetry run ruff check`
  - Acceptance: a file matching `evidence/baseline/python-lint.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T24] Capture the root Python typecheck baseline with `poetry run pyright`
  - Acceptance: a file matching `evidence/baseline/python-typecheck.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T25] Capture the root Python coverage baseline with `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
  - Acceptance: a file matching `evidence/baseline/python-test.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric total coverage plus numeric coverage for `scripts/dev_tools`.
- [x] [P0-T26] Record the multi-language baseline coverage matrix in `evidence/baseline/multi-language-coverage-baseline.md`
  - Acceptance: `evidence/baseline/multi-language-coverage-baseline.md` exists and contains the headings `TypeScript Baseline Coverage:`, `PowerShell Baseline Coverage:`, `Python Baseline Coverage:`, and `Artifact References:` with numeric values for each language.

### Phase 1 — PowerShell Discovery Regression Tests

- [x] [P1-T1] [expect-fail] Add Pester test in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` for `Get-AgentContent throws when .github/copilot-instructions.md is missing`
  - Acceptance: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` contains a test whose name includes `Get-AgentContent throws when .github/copilot-instructions.md is missing`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` is expected to fail while writing a file matching `evidence/regression-testing/sync-agents-missing-preamble-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P1-T2] [expect-fail] Add Pester test in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` for `Get-DiscoveredInstructionFiles throws when no supported instruction files are discovered`
  - Acceptance: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` contains a test whose name includes `Get-DiscoveredInstructionFiles throws when no supported instruction files are discovered`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` is expected to fail while writing a file matching `evidence/regression-testing/sync-agents-no-discovery-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P1-T3] [expect-fail] Add Pester test in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` for `Get-DiscoveredInstructionFiles sorts normalized relative paths ordinally`
  - Acceptance: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` contains a test whose name includes `Get-DiscoveredInstructionFiles sorts normalized relative paths ordinally`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` is expected to fail while writing a file matching `evidence/regression-testing/sync-agents-deterministic-order-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P1-T4] [expect-fail] Add Pester test in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` for `Get-AgentContent includes a newly added .instructions.md file without a section allowlist update`
  - Acceptance: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` contains a test whose name includes `Get-AgentContent includes a newly added .instructions.md file without a section allowlist update`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` is expected to fail while writing a file matching `evidence/regression-testing/sync-agents-auto-include-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P1-T5] [expect-fail] Add Pester test in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` for `Invoke-SyncAgentInstruction produces identical content on repeated runs when inputs are unchanged`
  - Acceptance: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` contains a test whose name includes `Invoke-SyncAgentInstruction produces identical content on repeated runs when inputs are unchanged`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` is expected to fail while writing a file matching `evidence/regression-testing/sync-agents-idempotent-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

### Phase 2 — Root PowerShell Discovery Implementation

- [x] [P2-T1] Add deterministic instruction discovery to `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Acceptance: `scripts/dev-tools/sync-agents-from-instructions.ps1` contains a helper that discovers `*.instructions.md` under `.github/`, normalizes each path relative to the repo root, and sorts those normalized paths with ordinal comparison.
- [x] [P2-T2] Add a missing-preamble guard to `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Acceptance: `scripts/dev-tools/sync-agents-from-instructions.ps1` throws an actionable error when `.github/copilot-instructions.md` is absent before any `AGENTS.md` write occurs.
- [x] [P2-T3] Add a zero-discovery guard to `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Acceptance: `scripts/dev-tools/sync-agents-from-instructions.ps1` throws an actionable error when no supported `*.instructions.md` files are discovered before any `AGENTS.md` write occurs.
- [x] [P2-T4] Replace the fixed section-definition pipeline in `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Acceptance: `scripts/dev-tools/sync-agents-from-instructions.ps1` renders the generated-source note and the aggregated section body from the same discovered file list and no longer depends on a manually maintained section-definition array.
- [x] [P2-T5] Add deterministic section-label fallback logic to `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Acceptance: `scripts/dev-tools/sync-agents-from-instructions.ps1` derives section labels by preferring the first stripped Markdown heading, then frontmatter `name`, then a filename-derived fallback.
- [x] [P2-T6] Preserve the repo-local CLI contract in `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Acceptance: `scripts/dev-tools/sync-agents-from-instructions.ps1` still accepts `-RepoRoot`, still defaults `-RepoRoot` to the repository root when omitted, and still writes only `<RepoRoot>/AGENTS.md` through the existing write path.
- [x] [P2-T7] Run the focused PowerShell sync suite with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"`
  - Acceptance: a file matching `evidence/other/powershell-sync-discovery-green.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"`, `EXIT_CODE: 0`, and `Output Summary:` naming the discovery, failure-mode, and idempotence scenarios.

### Phase 3 — Bundled Parity and Extension Command Regression Tests

- [x] [P3-T1] [expect-fail] Add Pester test in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` for `Bundled sync-agents template matches the repo-root script exactly`
  - Acceptance: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` contains a test whose name includes `Bundled sync-agents template matches the repo-root script exactly`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` is expected to fail while writing a file matching `evidence/regression-testing/sync-agents-template-parity-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P3-T2] [expect-fail] Add Jest test in `extensions/drm-copilot/test/extension.test.ts` for `activate registers drmCopilotExtension.syncAgentsFromInstructions`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a test whose name includes `activate registers drmCopilotExtension.syncAgentsFromInstructions`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts --testNamePattern="activate registers drmCopilotExtension.syncAgentsFromInstructions"` is expected to fail while writing a file matching `evidence/regression-testing/extension-sync-agents-registration-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P3-T3] [expect-fail] Add Jest test in `extensions/drm-copilot/test/extension.integration.test.ts` for `syncAgentsFromInstructions runs the bundled PowerShell template against the active workspace root`
  - Acceptance: `extensions/drm-copilot/test/extension.integration.test.ts` contains a test whose name includes `syncAgentsFromInstructions runs the bundled PowerShell template against the active workspace root`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.integration.test.ts --testNamePattern="syncAgentsFromInstructions runs the bundled PowerShell template against the active workspace root"` is expected to fail while writing a file matching `evidence/regression-testing/extension-sync-agents-execution-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

### Phase 4 — Bundled Parity and Extension Command Implementation

- [ ] [P4-T1] Create `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`
  - Acceptance: `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` exists and matches `scripts/dev-tools/sync-agents-from-instructions.ps1` exactly.
- [ ] [P4-T2] Contribute `drmCopilotExtension.syncAgentsFromInstructions` in `extensions/drm-copilot/package.json`
  - Acceptance: `extensions/drm-copilot/package.json` contains command ID `drmCopilotExtension.syncAgentsFromInstructions` with title `drm-copilot: Sync AGENTS.md from Instructions` under `contributes.commands`.
- [ ] [P4-T3] Register `drmCopilotExtension.syncAgentsFromInstructions` in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` registers `drmCopilotExtension.syncAgentsFromInstructions` with `vscode.commands.registerCommand` and adds the resulting disposable to `context.subscriptions`.
- [ ] [P4-T4] Route the new command through the bundled PowerShell execution model in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` resolves `workspaceRoot` with `getWorkspaceRoot()`, invokes `executeBundledScript` with `runtimeKind: "powershell"`, uses bundled path `resources/templates/sync-agents-from-instructions.ps1`, and forwards `args: ["-RepoRoot", workspaceRoot]`.
- [ ] [P4-T5] Run the focused extension sync suite with `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/extension.integration.test.ts --testNamePattern="syncAgentsFromInstructions|activate registers drmCopilotExtension.syncAgentsFromInstructions"`
  - Acceptance: a file matching `evidence/other/extension-sync-agents-green.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/extension.integration.test.ts --testNamePattern="syncAgentsFromInstructions|activate registers drmCopilotExtension.syncAgentsFromInstructions"`, `EXIT_CODE: 0`, and `Output Summary:` naming the registration and bundled-execution scenarios.

### Phase 5 — Rewrite Catalog Alignment

- [ ] [P5-T1] [expect-fail] Add pytest `tests/scripts/dev_tools/test_push_down_copilot_customizations.py::test_sync_agents_script_reference_rewrites_to_live_command`
  - Acceptance: `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` contains `test_sync_agents_script_reference_rewrites_to_live_command`, and `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k test_sync_agents_script_reference_rewrites_to_live_command` is expected to fail while writing a file matching `evidence/regression-testing/rewrite-sync-agents-command-red.*.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.
- [ ] [P5-T2] Update `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` for the sync-agents live command
  - Acceptance: `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` contains `drmCopilotExtension.syncAgentsFromInstructions` and rewrites raw `sync-agents-from-instructions.ps1` references to the live command text.
- [ ] [P5-T3] Sync `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py` to the updated root rewrite catalog
  - Acceptance: `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py` exists and matches `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` exactly.
- [ ] [P5-T4] Run the focused rewrite-catalog suite with `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py -k "sync_agents_script_reference_rewrites_to_live_command or mirror"`
  - Acceptance: a file matching `evidence/other/rewrite-sync-agents-green.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py -k "sync_agents_script_reference_rewrites_to_live_command or mirror"`, `EXIT_CODE: 0`, and `Output Summary:` naming the live-command rewrite scenario plus the root-versus-bundle mirror check.

### Phase 6 — Documentation Updates

- [ ] [P6-T1] Update the root command-surface documentation in `README.md`
  - Acceptance: `README.md` contains `drmCopilotExtension.syncAgentsFromInstructions` and describes that the command regenerates `AGENTS.md` from the destination workspace’s discovered `.github` instruction files.
- [ ] [P6-T2] Update the extension command-surface documentation in `extensions/drm-copilot/README.md`
  - Acceptance: `extensions/drm-copilot/README.md` contains `drm-copilot: Sync AGENTS.md from Instructions` and describes that the bundled PowerShell script runs against the active workspace root.

### Phase 7 — Final QA & Coverage Closure

If any command-bearing task in this phase changes non-evidence files or exits non-zero, restart Phase 7 from [P7-T1]. Evidence-writing tasks [P7-T5], [P7-T9], [P7-T14], and [P7-T15] do not trigger a restart solely because they create or update their required evidence artifacts.

- [ ] [P7-T1] Run `npm --prefix extensions/drm-copilot run format` and store the final result in `evidence/qa-gates/typescript-format.*.md`
  - Acceptance: a file matching `evidence/qa-gates/typescript-format.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T2] Run `npm --prefix extensions/drm-copilot run lint` and store the final result in `evidence/qa-gates/typescript-lint.*.md`
  - Acceptance: a file matching `evidence/qa-gates/typescript-lint.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T3] Run `npm --prefix extensions/drm-copilot run typecheck` and store the final result in `evidence/qa-gates/typescript-typecheck.*.md`
  - Acceptance: a file matching `evidence/qa-gates/typescript-typecheck.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T4] Run `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` and store the final result in `evidence/qa-gates/typescript-test.*.md`
  - Acceptance: a file matching `evidence/qa-gates/typescript-test.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage headlines for lines, statements, functions, and branches.
- [ ] [P7-T5] Record the TypeScript coverage delta in `evidence/qa-gates/typescript-coverage-delta.*.md`
  - Acceptance: a file matching `evidence/qa-gates/typescript-coverage-delta.*.md` exists and contains `Baseline Lines Coverage:`, `Final Lines Coverage:`, `Baseline Branches Coverage:`, `Final Branches Coverage:`, `Changed/New Lines Coverage:`, `Changed/New Branches Coverage:`, `Threshold Check:`, and `No planned command task skipped: true`.
- [ ] [P7-T6] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and store the final result in `evidence/qa-gates/powershell-format.*.md`
  - Acceptance: a file matching `evidence/qa-gates/powershell-format.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T7] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` and store the final result in `evidence/qa-gates/powershell-analyze.*.md`
  - Acceptance: a file matching `evidence/qa-gates/powershell-analyze.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T8] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and store the final result in `evidence/qa-gates/powershell-test.*.md`
  - Acceptance: a file matching `evidence/qa-gates/powershell-test.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage extracted from `artifacts/pester/powershell-coverage.xml` or `artifacts/pester/powershell-coverage.koverage.xml`.
- [ ] [P7-T9] Record the PowerShell coverage delta in `evidence/qa-gates/powershell-coverage-delta.*.md`
  - Acceptance: a file matching `evidence/qa-gates/powershell-coverage-delta.*.md` exists and contains `Baseline Coverage:`, `Final Coverage:`, `Changed/New PowerShell Coverage:`, `Threshold Check:`, `Coverage Source Artifact:`, and `No planned command task skipped: true`.
- [ ] [P7-T10] Run `poetry run black .` and store the final result in `evidence/qa-gates/python-format.*.md`
  - Acceptance: a file matching `evidence/qa-gates/python-format.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T11] Run `poetry run ruff check` and store the final result in `evidence/qa-gates/python-lint.*.md`
  - Acceptance: a file matching `evidence/qa-gates/python-lint.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T12] Run `poetry run pyright` and store the final result in `evidence/qa-gates/python-typecheck.*.md`
  - Acceptance: a file matching `evidence/qa-gates/python-typecheck.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P7-T13] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store the final result in `evidence/qa-gates/python-test.*.md`
  - Acceptance: a file matching `evidence/qa-gates/python-test.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric total coverage plus numeric coverage for `scripts/dev_tools`.
- [ ] [P7-T14] Record the Python coverage delta in `evidence/qa-gates/python-coverage-delta.*.md`
  - Acceptance: a file matching `evidence/qa-gates/python-coverage-delta.*.md` exists and contains `Baseline Total Coverage:`, `Final Total Coverage:`, `Baseline scripts/dev_tools Coverage:`, `Final scripts/dev_tools Coverage:`, `Changed/New Python Coverage:`, `Threshold Check:`, and `No planned command task skipped: true`.
- [ ] [P7-T15] Record the final multi-language delivery summary in `evidence/qa-gates/bundle-sync-agents-summary.*.md`
  - Acceptance: a file matching `evidence/qa-gates/bundle-sync-agents-summary.*.md` exists and contains the headings `Changed PowerShell Files:`, `Changed TypeScript Files:`, `Changed Python Files:`, `Bundled Parity Verified:`, `Rewrite Catalog Updated:`, `Documentation Updated:`, and `Coverage Artifacts:`.

## Planner Self-Check

- Work mode resolves from `issue.md` as `full-feature`.
- Phase 0 includes policy-read evidence and baseline capture for TypeScript, PowerShell, and Python.
- Discovery-based PowerShell behavior is covered by scenario-specific red tests before implementation tasks modify the generator.
- Bundled template parity, extension command contribution, command registration, and bundled execution each have explicit regression coverage.
- Rewrite-catalog alignment is included because pushed-down content can surface the new live command.
- Final QA includes formatting, linting, typechecking where applicable, coverage-bearing test commands, and per-language coverage delta artifacts.
- No placeholder text remains in this plan.
