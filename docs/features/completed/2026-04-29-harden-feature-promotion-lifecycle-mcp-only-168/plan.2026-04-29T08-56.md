# 2026-04-29-harden-feature-promotion-lifecycle-mcp-only - Plan

## Overview

This full-feature plan hardens the root Claude runtime so promotion work uses a single MCP-only agent-session path, direct Bash promotion-script bypass attempts are blocked before execution, and the main orchestration checkpoint contract matches the already-persisted `delegation_receipts.promotion.*` receipt shape. The implementation scope is limited to root `.claude` runtime surfaces, additive validator support in `scripts/dev_tools/validate_orchestration_artifacts.py`, and the related Python and PowerShell tests.

## Authoritative inputs

- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/issue.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`
- `artifacts/research/20260429-harden-feature-promotion-lifecycle-mcp-only-implementation-research.md`

## In-scope files

- `.claude/skills/feature-promotion-lifecycle/SKILL.md`
- `.claude/settings.json`
- `.claude/hooks/enforce-promotion-mcp-only.ps1`
- `.claude/agents/orchestrator.md`
- `scripts/dev_tools/validate_orchestration_artifacts.py`
- `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1`
- `tests/scripts/claude-runtime/claude-settings.Tests.ps1`
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`

## Out-of-scope guardrails

- Do not modify underlying promotion implementations under `scripts/dev_tools/` except additive checkpoint validation support inside `scripts/dev_tools/validate_orchestration_artifacts.py`.
- Do not modify MCP server implementation.
- Remove fallback guidance only from the Claude-side skill surface.
- Do not add mirror-synchronization work outside the root `.claude` runtime tree in this feature.

### Phase 0 — Context & Baseline

- [x] [P0-T1] Record the policy-read order, authoritative inputs, and selected `full-feature` work mode in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/phase0-policy-and-inputs.2026-04-29T08-56.md`
  - Acceptance: The artifact exists under `evidence/baseline/` and contains `Timestamp:`, `Policy Order:`, `Inputs Read:`, `Work Mode: full-feature`, and the exact file paths for `issue.md`, `spec.md`, `user-story.md`, and the research artifact.

- [x] [P0-T2] Capture baseline PowerShell formatting evidence for `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime` with `mcp_drmcopilotext_run_poshqc_format`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/powershell-format.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_format scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T3] Capture baseline PowerShell analyzer evidence for `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime` with `mcp_drmcopilotext_run_poshqc_analyze`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/powershell-analyze.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_analyze scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture baseline PowerShell test and coverage evidence for `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime` with `mcp_drmcopilotext_run_poshqc_test`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/powershell-test.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values parsed from the generated PowerShell coverage output.

- [x] [P0-T5] Capture baseline Python formatting evidence for `scripts/dev_tools/validate_orchestration_artifacts.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, and `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-format.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run black scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture baseline Python lint evidence for `scripts/dev_tools/validate_orchestration_artifacts.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, and `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-lint.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T7] Capture baseline Python type-check evidence with the repo-standard Pyright command
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-typecheck.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:` that names any diagnostics emitted for the touched validator or contract-test files.

- [x] [P0-T8] Capture baseline Python test and coverage evidence for the validator and orchestration contract suites
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-test.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values.

### Phase 1 — Claude runtime contract hardening

- [x] [P1-T1] Update `.claude/skills/feature-promotion-lifecycle/SKILL.md` so the lifecycle requires an MCP tool-availability preflight before any promotion step starts
  - Acceptance: The skill text contains an explicit preflight requirement for the required `drmCopilotExtension` promotion MCP tools before potential-entry creation, issue promotion, or active-folder creation begins.

- [x] [P1-T2] Update `.claude/skills/feature-promotion-lifecycle/SKILL.md` so agent-session promotion guidance names only the MCP execution path and removes the fallback-script subsections
  - Acceptance: The skill no longer contains the fallback subsection headings and no agent-session instruction in the file directs users to `scripts/dev_tools`, `scripts/dev-tools`, or `poetry run python -m scripts` commands.

- [x] [P1-T3] Update `.claude/skills/feature-promotion-lifecycle/SKILL.md` so the lifecycle requires raw receipt capture under `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder`
  - Acceptance: The skill text names all three `delegation_receipts.promotion.*` keys and defines each one as the raw MCP receipt payload captured from the matching promotion operation.

- [x] [P1-T4] Update `.claude/skills/feature-promotion-lifecycle/SKILL.md` so the only remaining non-MCP alternative is one VS Code command-palette note explicitly marked non-authoritative for agent sessions
  - Acceptance: The skill contains exactly one VS Code command-palette note and that note states it is non-authoritative for agent sessions.

- [x] [P1-T5] Update `.claude/agents/orchestrator.md` so the main checkpoint contract documents the `delegation_receipts.promotion.*` receipt namespace for `artifacts/orchestration/orchestrator-state.json`
  - Acceptance: The `Checkpoint Persistence` section names `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder` as persisted raw MCP receipts.

- [x] [P1-T6] Add a Python contract test scenario in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` that verifies `.claude/skills/feature-promotion-lifecycle/SKILL.md` contains the required MCP preflight wording
  - Acceptance: A new `test_` function in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` asserts the required MCP preflight fragments are present in `.claude/skills/feature-promotion-lifecycle/SKILL.md`.

- [x] [P1-T7] Add a Python contract test scenario in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` that verifies `.claude/skills/feature-promotion-lifecycle/SKILL.md` contains the required raw receipt-capture wording
  - Acceptance: A new `test_` function in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` asserts the `delegation_receipts.promotion.potential_entry`, `.issue`, and `.feature_folder` fragments are present in `.claude/skills/feature-promotion-lifecycle/SKILL.md`.

- [x] [P1-T8] Add a Python contract test scenario in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` that verifies `.claude/skills/feature-promotion-lifecycle/SKILL.md` excludes the banned fallback/script strings
  - Acceptance: A new `test_` function in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` asserts `.claude/skills/feature-promotion-lifecycle/SKILL.md` contains no matches for `Fallback`, `fallback`, `dev_tools`, `dev-tools`, or `poetry run python -m scripts`.

- [x] [P1-T9] Add a Python contract test scenario in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` that verifies the skill retains one non-authoritative VS Code note
  - Acceptance: A new `test_` function in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` asserts there is exactly one VS Code command-palette note and that it is marked non-authoritative for agent sessions.

- [x] [P1-T10] Add a Python contract test scenario in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` that verifies `.claude/agents/orchestrator.md` documents the promotion receipt namespace
  - Acceptance: A new `test_` function in `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` asserts `.claude/agents/orchestrator.md` contains the three `delegation_receipts.promotion.*` receipt-field fragments.

### Phase 2 — PowerShell promotion-bypass guardrail

- [x] [P2-T1] Add `.claude/hooks/enforce-promotion-mcp-only.ps1` to parse `CLAUDE_TOOL_INPUT`, detect the four forbidden promotion-script tokens, and emit structured allow or block JSON decisions
  - Acceptance: `.claude/hooks/enforce-promotion-mcp-only.ps1` exists, supports dot-sourcing for tests, reads `CLAUDE_TOOL_INPUT`, and returns a structured allow or block decision without mutating the attempted Bash command.

- [x] [P2-T2] Update `.claude/settings.json` so the `PreToolUse` Bash hook chain registers `.claude/hooks/enforce-promotion-mcp-only.ps1` alongside the existing `.claude/hooks/validate-bash.ps1`
  - Acceptance: `.claude/settings.json` contains a `PreToolUse` Bash hook entry for `.claude/hooks/enforce-promotion-mcp-only.ps1` and retains the existing `.claude/hooks/validate-bash.ps1` registration.

- [x] [P2-T3] Add a Pester scenario in `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` that verifies benign Bash commands are allowed
  - Acceptance: `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` contains an `It` block that feeds a benign Bash command through `.claude/hooks/enforce-promotion-mcp-only.ps1` and asserts an allow decision with the non-blocking exit path.

- [x] [P2-T4] Add a Pester scenario in `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` that blocks `new-potential-entry.ps1`
  - Acceptance: `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` contains an `It` block that feeds a Bash command containing `new-potential-entry.ps1` through `.claude/hooks/enforce-promotion-mcp-only.ps1` and asserts the exact repository-defined deny message.

- [x] [P2-T5] Add a Pester scenario in `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` that blocks `new_potential_bug_entry`
  - Acceptance: `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` contains an `It` block that feeds a Bash command containing `new_potential_bug_entry` through `.claude/hooks/enforce-promotion-mcp-only.ps1` and asserts the exact repository-defined deny message.

- [x] [P2-T6] Add a Pester scenario in `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` that blocks `potential_to_issue`
  - Acceptance: `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` contains an `It` block that feeds a Bash command containing `potential_to_issue` through `.claude/hooks/enforce-promotion-mcp-only.ps1` and asserts the exact repository-defined deny message.

- [x] [P2-T7] Add a Pester scenario in `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` that blocks `new_active_feature_folder`
  - Acceptance: `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` contains an `It` block that feeds a Bash command containing `new_active_feature_folder` through `.claude/hooks/enforce-promotion-mcp-only.ps1` and asserts the exact repository-defined deny message.

- [x] [P2-T8] Add a Pester scenario in `tests/scripts/claude-runtime/claude-settings.Tests.ps1` that verifies the Bash hook chain includes both the existing validator and the new promotion guard
  - Acceptance: `tests/scripts/claude-runtime/claude-settings.Tests.ps1` contains an `It` block that asserts `.claude/settings.json` includes `.claude/hooks/validate-bash.ps1` and `.claude/hooks/enforce-promotion-mcp-only.ps1` in the `PreToolUse` Bash hook chain.

### Phase 3 — Additive orchestration-state validator support

- [x] [P3-T1] Update `scripts/dev_tools/validate_orchestration_artifacts.py` so `delegation_receipts` accepts either the legacy list shape or an object namespace
  - Acceptance: `validate_orchestrator_state_text` accepts checkpoints whose `delegation_receipts` value is either a list of legacy receipts or an object namespace instead of failing with `delegation_receipts must be a list`.

- [x] [P3-T2] Update `scripts/dev_tools/validate_orchestration_artifacts.py` so the object namespace accepts only the documented `promotion` container and the `potential_entry`, `issue`, and `feature_folder` receipt keys without normalizing raw payloads
  - Acceptance: The validator accepts `delegation_receipts.promotion.potential_entry`, `.issue`, and `.feature_folder` as raw receipt payloads and rejects undocumented nested keys under `delegation_receipts.promotion`.

- [x] [P3-T3] Add a Python test scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` that verifies the legacy list-based `delegation_receipts` shape still passes
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` contains a `test_` function that validates the existing list-based builder payload without errors.

- [x] [P3-T4] Add a Python test scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` that verifies the nested `delegation_receipts.promotion` namespace passes
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` contains a `test_` function that validates a checkpoint using `delegation_receipts.promotion.potential_entry`, `.issue`, and `.feature_folder` without errors.

- [x] [P3-T5] Add a Python test scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` that rejects non-container `delegation_receipts` values
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` contains a `test_` function that verifies a scalar `delegation_receipts` value still fails validation.

- [x] [P3-T6] Add a Python test scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` that rejects undocumented promotion receipt keys
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` contains a `test_` function that verifies `delegation_receipts.promotion.extra_key` fails validation.

### Phase 4 — Final QA and acceptance closure

Repeat `[P4-T1]` through `[P4-T3]` from `[P4-T1]` if any PowerShell QA step changes files or fails. Repeat `[P4-T5]` through `[P4-T8]` from `[P4-T5]` if any Python QA step changes files or fails.

- [x] [P4-T1] Run the final PowerShell formatting pass for `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-format.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_format scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T2] Run the final PowerShell analyzer pass for `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-analyze.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_analyze scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T3] Run the final PowerShell test and coverage pass for `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-test.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, `EXIT_CODE:`, and `Output Summary:` with numeric post-change coverage headline values.

- [x] [P4-T4] Write the PowerShell coverage comparison artifact for the final QA pass
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-coverage-comparison.2026-04-29T08-56.md` exists and contains `Baseline Coverage:`, `Post-Change Coverage:`, `New/Changed-code Coverage:`, `Disposition:`, and evidence references to the baseline and final PowerShell test artifacts; if a numeric new or changed-code value cannot be derived, `Disposition:` is `BLOCKED` instead of `PASS`.

- [x] [P4-T5] Run the final Python formatting pass for the validator and its contract-test files
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-format.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run black scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T6] Run the final Python Ruff pass for the validator and its contract-test files
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-lint.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T7] Run the final repo-standard Python Pyright pass
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-typecheck.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:` that reports the final Pyright status for the touched validator and contract-test files.

- [x] [P4-T8] Run the final Python pytest and coverage pass for the validator and orchestration contract suites
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-test.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE:`, and `Output Summary:` with numeric post-change coverage headline values.

- [x] [P4-T9] Write the Python coverage comparison artifact for the final QA pass
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-coverage-comparison.2026-04-29T08-56.md` exists and contains `Baseline Coverage:`, `Post-Change Coverage:`, `New/Changed-code Coverage:`, `Disposition:`, and evidence references to the baseline and final Python test artifacts; if a numeric new or changed-code value cannot be derived, `Disposition:` is `BLOCKED` instead of `PASS`.

- [x] [P4-T10] Run the banned-string verification against `.claude/skills/feature-promotion-lifecycle/SKILL.md` and record the zero-match result
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/skill-banned-string-grep.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: pwsh -NoProfile -Command "Select-String -Path '.claude/skills/feature-promotion-lifecycle/SKILL.md' -Pattern 'Fallback','fallback','dev_tools','dev-tools','poetry run python -m scripts' -SimpleMatch"`, `EXIT_CODE:`, and `Output Summary:` confirming zero matches.

- [x] [P4-T11] Run the live orchestrator-state validator against `artifacts/orchestration/orchestrator-state.json` and record the result
  - Acceptance: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/orchestrator-state-validation.2026-04-29T08-56.md` exists and contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json`, `EXIT_CODE:`, and `Output Summary:` confirming the current nested `delegation_receipts.promotion.*` checkpoint shape passes validation.

- [x] [P4-T12] Check off the delivered acceptance criteria in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`
  - Acceptance: Only the `- [ ]` items satisfied by the completed work in the `spec.md` acceptance-criteria section are changed to `- [x]`, and no acceptance-criteria text is edited.

- [x] [P4-T13] Check off the delivered acceptance criteria in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`
  - Acceptance: Only the `- [ ]` items satisfied by the completed work in the `user-story.md` acceptance-criteria section are changed to `- [x]`, and no acceptance-criteria text is edited.
