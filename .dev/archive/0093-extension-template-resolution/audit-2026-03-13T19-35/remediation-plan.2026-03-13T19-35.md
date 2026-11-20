---
title: "Remediation Plan: 2026-03-12-extension-template-resolution-93 (2026-03-13T19-35)"
issue: "#93"
parent: "none"
owner: "drmoisan"
last_updated: "2026-03-13T19-35"
status: "Planned"
status_color: "blue"
version: "2.0"
work_mode: "minor-audit"
mode_source: "docs/features/active/2026-03-12-extension-template-resolution-93/issue.md"
requirements_source: "docs/features/active/2026-03-12-extension-template-resolution-93/remediation-inputs.2026-03-13T19-35.md"
acceptance_source: "docs/features/active/2026-03-12-extension-template-resolution-93/issue.md"
research_source: "docs/features/active/2026-03-12-extension-template-resolution-93/evidence/other/delegated-implementation-handoff.md"
plan_path: "docs/features/active/2026-03-12-extension-template-resolution-93/remediation-plan.2026-03-13T19-35.md"
preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
preflight_expected_signals:
	- "PREFLIGHT: ALL CLEAR"
	- "PREFLIGHT: REVISIONS REQUIRED"
---

# Remediation Plan: 2026-03-12-extension-template-resolution-93 (2026-03-13T19-35)

- **Issue:** #93
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-13T19-35
- **Status:** Planned
- **Version:** 2.0
- **Work Mode:** minor-audit
- **Requirements source:** `docs/features/active/2026-03-12-extension-template-resolution-93/remediation-inputs.2026-03-13T19-35.md`
- **Acceptance source:** `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`

## Overview

**Status Badge:** [Planned | blue]

This remediation plan closes the remaining minor-audit gaps for issue `#93` without widening scope beyond the files named in `remediation-inputs.2026-03-13T19-35.md`. The plan adds the missing `drmCopilotExtension.newPotentialEntry` template-less-workspace integration scenario, remediates Python helper docstrings in the canonical script plus bundled mirror, and performs required baseline plus final sync updates in `issue.md` and `plan.2026-03-12T19-08.md`.

## Required References

- Copilot instructions: [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
- General coding standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General unit test policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python code change policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python unit test policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Python intent-first docstring policy: [`.github/instructions/self-explanatory-code-commenting.instructions.md`](../../../../.github/instructions/self-explanatory-code-commenting.instructions.md)
- TypeScript code change policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript unit test policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Authoritative remediation inputs: [`remediation-inputs.2026-03-13T19-35.md`](./remediation-inputs.2026-03-13T19-35.md)
- Authoritative acceptance checklist: [`issue.md`](./issue.md)
- Existing feature plan to resync: [`plan.2026-03-12T19-08.md`](./plan.2026-03-12T19-08.md)
- Implementation research handoff: [`evidence/other/delegated-implementation-handoff.md`](./evidence/other/delegated-implementation-handoff.md)

**Policy order is mandatory:** `.github/copilot-instructions.md` → `general-code-change.instructions.md` → `general-unit-test.instructions.md` → language-specific policies for Python and TypeScript in scope.

## Requirements Traceability

| ID | Source | Deterministic requirement | Covered By |
|---|---|---|---|
| REQ-001 | `remediation-inputs.2026-03-13T19-35.md` item 1; `issue.md` criterion 4 | Add an automated integration scenario in `extensions/drm-copilot/test/extension.integration.test.ts` that runs `drmCopilotExtension.newPotentialEntry` in a workspace without `docs/features/templates/`, succeeds, and proves the bundled `extensions/drm-copilot/resources/feature-templates/potential/template.md` path is used. | `P1-T1`, `P2-T1`, `P2-T3`, `P2-T4`, `P2-T5`, `P2-T6`, `P2-T13`, `P2-T14` |
| REQ-002 | `remediation-inputs.2026-03-13T19-35.md` item 2 | Add contract docstrings to `validate_short_name`, `default_git_config_lookup`, `default_env_lookup`, `get_author`, `render_content`, `create_bug_entry`, `parse_args`, and `main` in `scripts/dev_tools/new_potential_bug_entry.py`. | `P1-T2`, `P1-T3`, `P1-T4`, `P1-T5`, `P1-T6`, `P1-T7`, `P1-T8`, `P1-T9`, `P1-T10`, `P2-T2`, `P2-T7`, `P2-T8`, `P2-T9`, `P2-T10`, `P2-T11`, `P2-T12`, `P2-T14` |
| REQ-003 | `remediation-inputs.2026-03-13T19-35.md` item 2 | Mirror the same eight contract docstrings into `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` while preserving bundled-script parity. | `P1-T2`, `P1-T3`, `P1-T4`, `P1-T5`, `P1-T6`, `P1-T7`, `P1-T8`, `P1-T9`, `P1-T10`, `P2-T2`, `P2-T7`, `P2-T8`, `P2-T9`, `P2-T10`, `P2-T11`, `P2-T12`, `P2-T14` |
| REQ-004 | `remediation-inputs.2026-03-13T19-35.md` item 3 | Sync `issue.md` immediately after remediation-plan creation without checking unmet acceptance criteria. | `P0-T3` |
| REQ-005 | `remediation-inputs.2026-03-13T19-35.md` item 3 | Sync `plan.2026-03-12T19-08.md` immediately after remediation-plan creation without marking unresolved remediation work complete. | `P0-T4` |
| REQ-006 | `remediation-inputs.2026-03-13T19-35.md` item 3 | Sync `issue.md` after remediation verification; check criterion 4 only if the new integration evidence exists and passes. | `P2-T13` |
| REQ-007 | `remediation-inputs.2026-03-13T19-35.md` item 3 | Sync `plan.2026-03-12T19-08.md` after remediation verification; check off only tasks backed by fresh evidence on disk. | `P2-T14` |

## Constraints

| ID | Deterministic constraint |
|---|---|
| CON-001 | When scope conflicts exist, `remediation-inputs.2026-03-13T19-35.md` overrides review summaries and prior handoff notes; the `- Work Mode: minor-audit` marker in `issue.md` remains authoritative for mode selection. |
| CON-002 | Do not edit unrelated `.github/agents`, `.github/skills`, prompt files, or customization files; remediation file scope is limited to `extensions/drm-copilot/test/extension.integration.test.ts`, `scripts/dev_tools/new_potential_bug_entry.py`, `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`, `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`, `docs/features/active/2026-03-12-extension-template-resolution-93/plan.2026-03-12T19-08.md`, and evidence artifacts created by this plan. |
| CON-003 | Reuse `docs/features/active/2026-03-12-extension-template-resolution-93/remediation-plan.2026-03-13T19-35.md` for every planning revision; do not create sibling remediation-plan files during this cycle. |
| SEC-001 | The new integration test must remain deterministic and isolated: no temporary files, no network calls, no live VS Code extension host, and no external processes beyond the existing mocked `node:child_process` boundary in `extensions/drm-copilot/test/extension.integration.test.ts`. |

## QC Toolchain

| Language | Baseline commands | Final QA commands |
|---|---|---|
| TypeScript | `npm --prefix extensions/drm-copilot run format`<br>`npm --prefix extensions/drm-copilot run lint`<br>`npm --prefix extensions/drm-copilot run typecheck`<br>`npm --prefix extensions/drm-copilot run test:unit -- --coverage` | `npm --prefix extensions/drm-copilot run format`<br>`npm --prefix extensions/drm-copilot run lint`<br>`npm --prefix extensions/drm-copilot run typecheck`<br>`npm --prefix extensions/drm-copilot run test:unit -- --coverage` |
| Python | `poetry run black --check .`<br>`poetry run ruff check`<br>`poetry run pyright`<br>`poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | `poetry run black .`<br>`poetry run black --check .`<br>`poetry run ruff check`<br>`poetry run pyright`<br>`poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Inputs

- [x] [P0-T1] Record remediation policy order plus scope fence in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/other/remediation-policy-order.2026-03-13T19-35.md`
	- Tags: `CON-001`, `CON-002`, `CON-003`, `SEC-001`
	- Preconditions: `issue.md` contains `- Work Mode: minor-audit`; this remediation plan file exists at the path in front matter.
	- Acceptance: the artifact exists and contains `Timestamp: 2026-03-13T19-35`, `Policy Order:`, the exact ordered file list from the Required References section, `Requirements Precedence: remediation-inputs.2026-03-13T19-35.md`, `Allowed Files:`, `Blocked Files: .github/agents/**, .github/skills/**, .github/prompts/**, extensions/drm-copilot/resources/customizations/**`, and `Result: READY`.

- [x] [P0-T2] Record remediation baseline scope in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/other/remediation-scope-gate.2026-03-13T19-35.md`
	- Tags: `CON-001`, `CON-002`
	- Preconditions: [P0-T1]
	- Acceptance: the artifact exists and contains `Timestamp: 2026-03-13T19-35`, `Requirements Source: docs/features/active/2026-03-12-extension-template-resolution-93/remediation-inputs.2026-03-13T19-35.md`, `Acceptance Source: docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`, `Research Source: docs/features/active/2026-03-12-extension-template-resolution-93/evidence/other/delegated-implementation-handoff.md`, `SearchScope: docs/features/active/2026-03-12-extension-template-resolution-93`, `SearchPatterns: spec.md, user-story.md`, `SearchResult: none`, and `Result: PASS`.

- [x] [P0-T3] Sync `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md` immediately after remediation-plan creation
	- Tags: `REQ-004`
	- Preconditions: [P0-T2]
	- Acceptance: `issue.md` contains the exact string `Remediation plan: \`remediation-plan.2026-03-13T19-35.md\`` in the most recent sync summary text, and the exact line `- [ ] Integration test: run new-potential-entry in workspace without docs/features/templates/ → should succeed using bundled templates` remains unchecked.

- [x] [P0-T4] Sync `docs/features/active/2026-03-12-extension-template-resolution-93/plan.2026-03-12T19-08.md` immediately after remediation-plan creation
	- Tags: `REQ-005`
	- Preconditions: [P0-T2]
	- Acceptance: `plan.2026-03-12T19-08.md` contains the exact string `Remediation follow-up: \`remediation-plan.2026-03-13T19-35.md\`` in a newly added status note, and no new `[x]` markers are added for unresolved remediation work.

- [x] [P0-T5] Capture TypeScript formatting baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-ts-format-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P0-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T6] Capture TypeScript lint baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-ts-lint-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P0-T5]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T7] Capture TypeScript type-check baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-ts-typecheck-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P0-T6]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T8] Capture TypeScript coverage baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-ts-test-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P0-T7]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage headline values.

- [x] [P0-T9] Capture Python formatting baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-python-format-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P0-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T10] Capture Python lint baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-python-lint-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P0-T9]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T11] Capture Python type-check baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-python-typecheck-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P0-T10]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T12] Capture Python coverage baseline in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/baseline/remediation-python-test-baseline.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage headline values.

### Phase 1 — Remediation Implementation

- [x] [P1-T1] Add the missing `newPotentialEntry` integration scenario to `extensions/drm-copilot/test/extension.integration.test.ts`
	- Tags: `REQ-001`, `SEC-001`
	- Preconditions: [P0-T8]
	- Acceptance: `extensions/drm-copilot/test/extension.integration.test.ts` contains a new test block named `it("newPotentialEntry succeeds in a workspace without docs/features/templates using bundled templates", async () => {` inside `describe("drm-copilot integration behavior")`; the test invokes `handlerFor("drmCopilotExtension.newPotentialEntry")()`, sets `workspaceFoldersState` to a workspace path that omits `docs/features/templates`, asserts the spawned argument list contains `-TemplateRoot` followed by `C:/extension/resources/feature-templates`, asserts the script path ends with `resources/templates/new-potential-entry.ps1`, asserts `options.cwd` equals the template-less workspace path, and asserts no spawned argument contains `/docs/features/templates/`.

- [x] [P1-T2] Mirror the `validate_short_name` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P0-T12]
	- Acceptance: both `scripts/dev_tools/new_potential_bug_entry.py` and `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` contain a docstring on `validate_short_name` whose first sentence is `Validate that a short name matches the repository kebab-case contract.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T3] Mirror the `default_git_config_lookup` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T2]
	- Acceptance: both target files contain a docstring on `default_git_config_lookup` whose first sentence is `Resolve a Git configuration value without failing when Git is unavailable.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T4] Mirror the `default_env_lookup` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T3]
	- Acceptance: both target files contain a docstring on `default_env_lookup` whose first sentence is `Return a non-blank environment variable value when one is defined.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T5] Mirror the `get_author` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T4]
	- Acceptance: both target files contain a docstring on `get_author` whose first sentence is `Resolve the author name from Git configuration before falling back to USERNAME.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T6] Mirror the `render_content` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T5]
	- Acceptance: both target files contain a docstring on `render_content` whose first sentence is `Apply bug-entry placeholder substitutions to the copied markdown template.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T7] Mirror the `create_bug_entry` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T6]
	- Acceptance: both target files contain a docstring on `create_bug_entry` whose first sentence is `Create a potential bug markdown file from the selected template root.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T8] Mirror the `parse_args` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T7]
	- Acceptance: both target files contain a docstring on `parse_args` whose first sentence is `Parse CLI arguments for the potential bug entry workflow.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T9] Mirror the `main` contract docstring across both Python bug-entry scripts
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T8]
	- Acceptance: both target files contain a docstring on `main` whose first sentence is `Execute the CLI boundary for potential bug entry creation.` and whose body includes the exact section labels `Purpose:`, `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.

- [x] [P1-T10] Keep the bundled mirror aligned with the canonical Python script outside `_resolve_workspace`
	- Tags: `REQ-002`, `REQ-003`, `CON-002`
	- Preconditions: [P1-T9]
	- Acceptance: the only intentional text difference between `scripts/dev_tools/new_potential_bug_entry.py` and `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` remains the `_resolve_workspace` implementation; every updated docstring block for `validate_short_name`, `default_git_config_lookup`, `default_env_lookup`, `get_author`, `render_content`, `create_bug_entry`, `parse_args`, and `main` is byte-identical across both files.

### Phase 2 — Final QA & Sync

- [x] [P2-T1] Run the targeted `newPotentialEntry` integration scenario and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/regression-testing/new-potential-entry-template-less-workspace.2026-03-13T19-35.md`
	- Tags: `REQ-001`, `SEC-001`
	- Preconditions: [P1-T1]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage --runTestsByPath test/extension.integration.test.ts -t "newPotentialEntry succeeds in a workspace without docs/features/templates using bundled templates"`, `EXIT_CODE: 0`, and `Output Summary:` containing the exact test name.

- [x] [P2-T2] Record Python docstring parity evidence in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-python-docstring-parity.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P1-T10]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Compared Files: scripts/dev_tools/new_potential_bug_entry.py | extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`, eight lines in the form `Function: <name> | Result: MATCH` for `validate_short_name`, `default_git_config_lookup`, `default_env_lookup`, `get_author`, `render_content`, `create_bug_entry`, `parse_args`, and `main`, plus `Allowed Difference: _resolve_workspace only`.

- [x] [P2-T3] Run the TypeScript formatter final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-ts-format-final.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P2-T1], [P2-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T4] Run the TypeScript lint final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-ts-lint-final.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P2-T3]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T5] Run the TypeScript type-check final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-ts-typecheck-final.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P2-T4]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T6] Run the TypeScript coverage test final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-ts-test-final.2026-03-13T19-35.md`
	- Tags: `REQ-001`
	- Preconditions: [P2-T5]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values.

- [x] [P2-T7] Run the Python formatter final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-python-format-final.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P2-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T8] Run the Python format verification pass from the remediation inputs and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-python-format-check-final.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P2-T7]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T9] Run the Python lint final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-python-lint-final.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P2-T8]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T10] Run the Python type-check final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-python-typecheck-final.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P2-T9]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T11] Run the Python coverage test final pass and persist `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-python-test-final.2026-03-13T19-35.md`
	- Tags: `REQ-002`, `REQ-003`
	- Preconditions: [P2-T10]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values.

- [x] [P2-T12] Verify remediation coverage deltas plus QA-loop closure in `docs/features/active/2026-03-12-extension-template-resolution-93/evidence/qa-gates/remediation-coverage-delta-verification.2026-03-13T19-35.md`
	- Tags: `REQ-001`, `REQ-002`, `REQ-003`
	- Preconditions: [P2-T6], [P2-T11]
	- Acceptance: the artifact exists and contains `Timestamp:`, `TypeScript Baseline Coverage:`, `TypeScript Post-Change Coverage:`, `TypeScript New/Changed-Code Coverage:`, `Python Baseline Coverage:`, `Python Post-Change Coverage:`, `Python New/Changed-Code Coverage:`, `Restart Required: NO`, and `Result: PASS`; if any final QA command changes files or fails before the clean pass, the executor must restart from [P2-T3] for TypeScript or [P2-T7] for Python before completing this task.

- [x] [P2-T13] Sync `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md` after remediation verification
	- Tags: `REQ-006`
	- Preconditions: [P2-T1], [P2-T12]
	- Acceptance: `issue.md` changes criterion 4 under `## Proposed Fix / Validation Ideas` from `[ ]` to `[x]` only when both `evidence/regression-testing/new-potential-entry-template-less-workspace.2026-03-13T19-35.md` and `evidence/qa-gates/remediation-ts-test-final.2026-03-13T19-35.md` contain `EXIT_CODE: 0`; otherwise the exact criterion line remains unchecked. The most recent sync summary text must also contain `Fresh remediation evidence: new-potential-entry-template-less-workspace.2026-03-13T19-35.md`.

- [x] [P2-T14] Sync `docs/features/active/2026-03-12-extension-template-resolution-93/plan.2026-03-12T19-08.md` after remediation verification
	- Tags: `REQ-007`
	- Preconditions: [P2-T12], [P2-T13]
	- Acceptance: `plan.2026-03-12T19-08.md` contains the exact string `Remediation verification complete: remediation-plan.2026-03-13T19-35.md`, and only the remediation-related checklist items backed by the new evidence artifacts created by [P2-T1] through [P2-T13] are marked complete.

## Test Plan

- TypeScript targeted verification: `npm --prefix extensions/drm-copilot run test:unit -- --coverage --runTestsByPath test/extension.integration.test.ts -t "newPotentialEntry succeeds in a workspace without docs/features/templates using bundled templates"`
- TypeScript full QA: `npm --prefix extensions/drm-copilot run format`, `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
- Python full QA: `poetry run black .`, `poetry run black --check .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- Isolation rule: no temporary-file fixtures, no network, and no live extension-host execution are permitted for the new Jest scenario.

## Open Questions / Notes

- No `.env` file is required for this remediation scope.
- PowerShell is intentionally out of scope for this remediation plan because the remediation inputs name only TypeScript integration coverage, Python docstrings, and status-sync updates.
- Executor preflight directive for the downstream handoff is `DIRECTIVE: PREFLIGHT VALIDATION ONLY`.
- The only acceptable downstream validation signals are `PREFLIGHT: ALL CLEAR` and `PREFLIGHT: REVISIONS REQUIRED`.
