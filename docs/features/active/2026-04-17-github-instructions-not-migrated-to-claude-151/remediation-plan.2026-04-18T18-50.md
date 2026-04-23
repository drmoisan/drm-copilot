---
title: "2026-04-17-github-instructions-not-migrated-to-claude-151-remediation"
issue: 151
owner: "atomic_planner"
work_mode: "full-bug"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-20T00-00"
source_of_truth:
	- "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md"
	- "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-inputs.2026-04-18T18-50.md"
review_inputs:
	- "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-18T18-50.md"
	- "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/code-review.2026-04-18T18-50.md"
	- "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/feature-audit.2026-04-18T18-50.md"
plan_path: "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-plan.2026-04-18T18-50.md"
work_mode_source: "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/issue.md"
work_mode_marker: "- Work Mode: full-bug"
---

# Atomic Remediation Plan — Feature #151

## Overview

This plan remediates the feature-vs-base findings recorded in `remediation-inputs.2026-04-18T18-50.md` without reopening delivered feature scope. Because `issue.md` records `- Work Mode: full-bug`, `spec.md` is the only authoritative acceptance-criteria source, `user-story.md` is not required, and final acceptance-criteria status reporting must summarize `spec.md` only.

## Deterministic Inputs

- Repository root: `c:\Users\DanMoisan\repos\drm-copilot`
- Target plan path: `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-plan.2026-04-18T18-50.md`
- Authoritative remediation scope: `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-inputs.2026-04-18T18-50.md`
- Review context:
	- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-18T18-50.md`
	- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/code-review.2026-04-18T18-50.md`
	- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/feature-audit.2026-04-18T18-50.md`
- Acceptance-criteria source:
	- Authoritative file: `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`
	- Non-required file: `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/user-story.md`
	- Final reporting rule: produce an `Acceptance Criteria Status` summary from `spec.md` only; do not add a plan task that edits AC checkboxes.
- Canonical feature evidence root: `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/`
- Deterministic Windows-safe line-count command form: `pwsh -NoProfile -Command "(Get-Content '<path>' | Measure-Object -Line).Lines"`

## In-Scope Remediation Findings

| Ref | Summary |
|---|---|
| R-1 | Restore verifiable Pester coverage for `.claude/hooks/check-python-test-purity.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1`. |
| R-2 | If tests alone do not resolve the PowerShell floor, scope measured PowerShell coverage with an explicit documented decision. |
| R-3 | Reduce `extensions/drm-copilot/src/mcp-tools.ts` to 500 lines or fewer. |
| R-4 | Reduce `extensions/drm-copilot/src/repo-automation-service.ts` to 500 lines or fewer. |
| R-5 | Make Python mirror coverage verifiable by either combined LCOV coverage or documented parity verification. |
| R-6 | Split `extensions/drm-copilot/test/repo-automation-service.test.ts` so every resulting test file is 500 lines or fewer. |
| R-7 | Regenerate missing or stale TypeScript and PowerShell evidence with per-command artifacts. |
| R-8 | Tighten the hard-lock prompt invariant message and extract the default output path constant. |

## Deterministic Constraints

- Do not modify `.github/instructions/*.md` files.
- Do not expand scope beyond R-1 through R-8 from `remediation-inputs.2026-04-18T18-50.md`.
- Every evidence artifact named in this plan must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Every baseline or QA test artifact must record numeric coverage values when coverage policy applies.
- Use these exact TypeScript commands from the repository root:
	- `npm --prefix extensions/drm-copilot exec prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
	- `npm --prefix extensions/drm-copilot run lint`
	- `npm --prefix extensions/drm-copilot run typecheck`
	- `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
- Use these exact Python commands from the repository root:
	- `poetry run black --check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`
	- `poetry run ruff check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`
	- `poetry run pyright`
	- `poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info`
- Use these exact PowerShell MCP contracts:
	- `mcp_drmcopilotext_run_poshqc_format`
	- `mcp_drmcopilotext_run_poshqc_analyze`
	- `mcp_drmcopilotext_run_poshqc_test`
- For final QA, if any language step fails or changes files, restart that language loop from step 1.

### Phase 0 — Context & Baseline Evidence

- [x] [P0-T1] Create the feature evidence directories `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/regression-testing/`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/`, and `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/issue-updates/`.
	- Acceptance: All five directories exist at the exact paths named in this task.

- [x] [P0-T2] Read the required policy and context files in this exact order and write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/phase0-instructions-read.md`: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `.github/instructions/tonality.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/issue.md`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-inputs.2026-04-18T18-50.md`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-18T18-50.md`, `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/code-review.2026-04-18T18-50.md`, and `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/feature-audit.2026-04-18T18-50.md`.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Policy Order:`.
		- The artifact lists each file path in the exact order named in this task, including `.github/instructions/typescript-suppressions.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, and `.github/instructions/self-explanatory-code-commenting.instructions.md` in that revised exact order.

- [x] [P0-T3] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t3.work-mode-and-ac-source.2026-04-18T18-50.md` recording that `issue.md` contains `- Work Mode: full-bug`, that `spec.md` is the only acceptance-criteria source, that `user-story.md` is not required, and that final acceptance reporting must summarize `spec.md` without planning checkbox edits.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains `Resolved Work Mode: full-bug`.
		- The artifact contains `Acceptance Criteria Source: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`.
		- The artifact contains `User Story Required: no`.
		- The artifact contains `Final AC Status Rule: report spec.md counts only; checkbox updates are execution bookkeeping, not planned work`.

- [x] [P0-T4] Capture the baseline TypeScript formatting-check result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t4.typescript-format-check.2026-04-18T18-50.md` by running `npm --prefix extensions/drm-copilot exec prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` from the repository root.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot exec prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T5] Capture the baseline TypeScript lint result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t5.typescript-lint.2026-04-18T18-50.md` by running `npm --prefix extensions/drm-copilot run lint` from the repository root.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T6] Capture the baseline TypeScript type-check result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t6.typescript-typecheck.2026-04-18T18-50.md` by running `npm --prefix extensions/drm-copilot run typecheck` from the repository root.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T7] Capture the baseline TypeScript coverage result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t7.typescript-coverage.2026-04-18T18-50.md` by running `npm --prefix extensions/drm-copilot run test:unit -- --coverage` from the repository root.
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE:`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` includes numeric `mcp-tools.ts Coverage:` and `repo-automation-service.ts Coverage:`.

- [x] [P0-T8] Capture the baseline Python formatting-check result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t8.python-format-check.2026-04-18T18-50.md` by running `poetry run black --check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run black --check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T9] Capture the baseline Python lint result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t9.python-lint.2026-04-18T18-50.md` by running `poetry run ruff check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T10] Capture the baseline Python type-check result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t10.python-typecheck.2026-04-18T18-50.md` by running `poetry run pyright`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T11] Capture the baseline Python coverage result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t11.python-coverage.2026-04-18T18-50.md` by running `poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info`.
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE:`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` states whether `artifacts/python/lcov.info` contains `SF:extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_filesystem.py` and `SF:extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py`.

- [x] [P0-T12] Capture the baseline Claude-hook test inventory in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t12.claude-hook-test-inventory.2026-04-18T18-50.md` by inspecting `.claude/hooks/*.ps1` and `tests/scripts/claude-hooks/*.Tests.ps1`.
	- Acceptance:
		- The artifact contains `Command: inspect .claude/hooks/*.ps1 and tests/scripts/claude-hooks/*.Tests.ps1 via workspace discovery tools`.
		- The artifact contains `EXIT_CODE: 0`.
		- `Output Summary:` lists exact paths for `.claude/hooks/check-python-test-purity.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`.

- [x] [P0-T13] Capture the baseline PowerShell formatting result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t13.powershell-format.2026-04-18T18-50.md` using `mcp_drmcopilotext_run_poshqc_format` for `.claude/hooks` and `tests/scripts/claude-hooks`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_format`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T14] Capture the baseline PowerShell analyzer result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t14.powershell-analyze.2026-04-18T18-50.md` using `mcp_drmcopilotext_run_poshqc_analyze` for `.claude/hooks` and `tests/scripts/claude-hooks`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_analyze`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T15] Capture the baseline PowerShell coverage result in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t15.powershell-coverage.2026-04-18T18-50.md` using `mcp_drmcopilotext_run_poshqc_test`.
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` states whether `artifacts/pester/powershell-coverage.xml` contains `<sourcefile>` entries for `.claude/hooks/check-python-test-purity.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1`.

- [x] [P0-T16] Capture the baseline line count for `extensions/drm-copilot/src/mcp-tools.ts` in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t16.mcp-tools-lines.2026-04-18T18-50.md` with `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/mcp-tools.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/mcp-tools.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and `Output Summary: 568` or another numeric line count captured from the command.

- [x] [P0-T17] Capture the baseline line count for `extensions/drm-copilot/src/repo-automation-service.ts` in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t17.repo-automation-service-lines.2026-04-18T18-50.md` with `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-service.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-service.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and a numeric `Output Summary:`.

- [x] [P0-T18] Capture the baseline line count for `extensions/drm-copilot/test/repo-automation-service.test.ts` in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/baseline/p0-t18.repo-automation-service-test-lines.2026-04-18T18-50.md` with `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/test/repo-automation-service.test.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/test/repo-automation-service.test.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and a numeric `Output Summary:`.

### Phase 1 — PowerShell Coverage Remediation

- [x] [P1-T1] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p1-t1.powershell-coverage-path-decision.2026-04-18T18-50.md` selecting exactly one remediation path: `Selected Path: R-1 only` or `Selected Path: R-1 + R-2`.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains exactly one line beginning `Selected Path:`.
		- The selected value is either `R-1 only` or `R-1 + R-2`.

- [x] [P1-T2] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the safe-content allow scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an `It` block whose text includes `allows safe Python test content`.

- [x] [P1-T3] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the empty-content allow scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an `It` block whose text includes `allows empty content and empty new_string edits`.

- [x] [P1-T4] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the temporary-file pattern block scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an assertion row or dedicated `It` block covering `tempfile`, `NamedTemporaryFile`, `TemporaryDirectory`, `mkstemp`, `mkdtemp`, and `Path("x").touch()`.

- [x] [P1-T5] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the network-pattern block scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an assertion row or dedicated `It` block covering `requests`, `httpx`, `urllib.request`, `socket`, and `http.client`.

- [x] [P1-T6] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the subprocess-pattern block scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an assertion row or dedicated `It` block covering `subprocess`, `os.system`, and `os.popen`.

- [x] [P1-T7] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the `time.sleep` block scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an assertion row or dedicated `It` block covering `time.sleep(1)`.

- [x] [P1-T8] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the database-driver block scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an assertion row or dedicated `It` block covering `psycopg2`, `pymysql`, and `sqlite3.connect("db.sqlite")`.

- [x] [P1-T9] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the malformed-JSON envelope scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an `It` block whose text includes `blocks malformed tool-input JSON with a diagnostic`.

- [x] [P1-T10] Ensure `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` covers the entrypoint block-response scenario for `.claude/hooks/check-python-test-purity.ps1`.
	- Acceptance: The test file contains an `It` block whose text includes `emits a block response from the hook entrypoint`.

- [x] [P1-T11] Ensure `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` covers the allow-under-cap scenario for `.claude/hooks/enforce-python-batch-budget.ps1`.
	- Acceptance: The test file contains `It` blocks whose text includes `allows a new production file under the production cap and records it` and `allows a new test file under the test cap and records it`.

- [x] [P1-T12] Ensure `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` covers the over-budget block scenario for `.claude/hooks/enforce-python-batch-budget.ps1`.
	- Acceptance: The test file contains `It` blocks whose text includes `blocks a new production file when the production cap is full` and `blocks a new test file when the test cap is full`.

- [x] [P1-T13] Ensure `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` covers the repeated-edit state-retention scenario for `.claude/hooks/enforce-python-batch-budget.ps1`.
	- Acceptance: The test file contains an `It` block whose text includes `allows repeated file edits without consuming another slot`.

- [x] [P1-T14] Ensure `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` covers the loaded-state increment scenario for `.claude/hooks/enforce-python-batch-budget.ps1`.
	- Acceptance: The test file contains `It` blocks whose text includes `uses loaded state when evaluating session budget` and `loads existing state through injected state operations`.

- [x] [P1-T15] Ensure `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` covers the malformed-input envelope scenario for `.claude/hooks/enforce-python-batch-budget.ps1`.
	- Acceptance: The test file contains `It` blocks whose text includes `blocks malformed tool-input JSON with a diagnostic before touching state` and `honors entrypoint environment caps while blocking malformed JSON`.

- [x] [P1-T16] Ensure `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` covers the session-write and failure-tolerance scenario for `.claude/hooks/enforce-python-batch-budget.ps1`.
	- Acceptance: The test file contains `It` blocks whose text includes `writes state for valid Python tool input through injected state operations` and `continues when injected state read and write operations fail`.

- [x] [P1-T17] Regenerate PowerShell coverage evidence after the hook-test updates in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p1-t17.powershell-coverage-after-r1.2026-04-18T18-50.md` using `mcp_drmcopilotext_run_poshqc_test`.
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` includes numeric `check-python-test-purity.ps1 Coverage:` and `enforce-python-batch-budget.ps1 Coverage:`.

- [x] [P1-T18] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p1-t1.powershell-coverage-path-decision.2026-04-18T18-50.md` selects `R-1 + R-2`, update the PowerShell coverage-scoping configuration so bootstrap and wrapper scripts are excluded with inline rationale comments.
	- Acceptance:
		- The selected PowerShell configuration file contains exclusion entries for each chosen script.
		- Each new exclusion is accompanied by an inline rationale comment describing why the script is non-testable in normal unit-test execution.

- [x] [P1-T19] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p1-t1.powershell-coverage-path-decision.2026-04-18T18-50.md` selects `R-1 + R-2`, write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/issue-updates/issue-151.2026-04-18T18-50.md` documenting the exact exclusion list for downstream PR or issue posting.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains `Timestamp:`.
		- The artifact contains the exact exclusion list added in [P1-T18].
		- The artifact contains `PostedAs: unknown` or `POSTING BLOCKED`.

- [x] [P1-T20] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p1-t1.powershell-coverage-path-decision.2026-04-18T18-50.md` selects `R-1 + R-2`, regenerate scoped PowerShell coverage evidence in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p1-t20.powershell-coverage-after-r2.2026-04-18T18-50.md` using `mcp_drmcopilotext_run_poshqc_test`.
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` includes numeric `check-python-test-purity.ps1 Coverage:` and `enforce-python-batch-budget.ps1 Coverage:`.

- [x] [P1-T21] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p1-t21.powershell-coverage-verdict.2026-04-18T18-50.md` stating the final PowerShell remediation outcome from either [P1-T17] or [P1-T20].
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains `Coverage Artifact Used:` with exactly one of the paths from [P1-T17] or [P1-T20].
		- The artifact contains numeric `Repo Coverage:`.
		- The artifact contains numeric `check-python-test-purity.ps1 Coverage:` and `enforce-python-batch-budget.ps1 Coverage:`.
		- The artifact contains `Verdict: pass` only if repo-wide coverage is `>= 80` and both hook files are `>= 90`.

### Phase 2 — TypeScript Production Refactor and Dispatch Remediation

- [x] [P2-T1] [expect-fail] Add a Jest regression scenario in `extensions/drm-copilot/test/repo-automation-service.test.ts` asserting `resolveExecuteHardLockPrompt` throws `resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.` when `quiet` is `true` and `output` is omitted, then capture the failing run in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/regression-testing/p2-t1.quiet-without-output-red.2026-04-18T18-50.md` with `npm run test:unit:coverage -- --runTestsByPath extensions/drm-copilot/test/repo-automation-service.test.ts --testNamePattern="resolveExecuteHardLockPrompt rejects quiet without output at the TS layer"`.
	- Acceptance:
		- `extensions/drm-copilot/test/repo-automation-service.test.ts` contains an assertion for the exact string `resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.`.
		- The regression artifact exists at the exact path named in this task.
		- The regression artifact contains `Timestamp:`, `Command: npm run test:unit:coverage -- --runTestsByPath extensions/drm-copilot/test/repo-automation-service.test.ts --testNamePattern="resolveExecuteHardLockPrompt rejects quiet without output at the TS layer"`, and `EXIT_CODE:` with a non-zero integer value.
		- The regression artifact contains `Expected Failure: resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.` and `Observed Failure: resolveExecuteHardLockPrompt: 'quiet' requires 'output' to be set.`.

- [x] [P2-T2] Change the `resolveExecuteHardLockPrompt` invariant error text in `extensions/drm-copilot/src/repo-automation-service.ts` so callers receive `resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.` (depends on [P2-T1]).
	- Acceptance: The exact string `resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.` appears in `extensions/drm-copilot/src/repo-automation-service.ts` and the prior internal-method-name wording does not.

- [x] [P2-T3] [expect-fail] Add a Jest regression scenario in `extensions/drm-copilot/test/mcp-server.test.ts` asserting the `resolve_execute_hard_lock_prompt` dispatcher uses a named default output-path constant for `artifacts/hard_lock_prompt.txt`, then capture the failing run in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/regression-testing/p2-t3.default-output-constant-red.2026-04-18T18-50.md` with `npm run test:unit:coverage -- --runTestsByPath extensions/drm-copilot/test/mcp-server.test.ts --testNamePattern="dispatches resolve_execute_hard_lock_prompt through the shared service with injected output and quiet defaults, and surfaces artifacts"`.
	- Acceptance:
		- `extensions/drm-copilot/test/mcp-server.test.ts` imports or references a named constant for the default output path instead of asserting only an inline literal.
		- The regression artifact exists at the exact path named in this task.
		- The regression artifact contains `Timestamp:`, `Command: npm run test:unit:coverage -- --runTestsByPath extensions/drm-copilot/test/mcp-server.test.ts --testNamePattern="dispatches resolve_execute_hard_lock_prompt through the shared service with injected output and quiet defaults, and surfaces artifacts"`, and `EXIT_CODE:` with a non-zero integer value.
		- The regression artifact contains `Expected Constant Value: artifacts/hard_lock_prompt.txt` and a non-empty `Failure:` excerpt attributable to the missing named constant path.

- [x] [P2-T4] Extract the hard-lock prompt default output path into a named constant at module scope in the module that owns the `resolve_execute_hard_lock_prompt` dispatcher case and replace the inline `artifacts/hard_lock_prompt.txt` literal with that constant (depends on [P2-T3]).
	- Acceptance:
		- The owning dispatcher module contains a module-scope constant whose value is `artifacts/hard_lock_prompt.txt`.
		- The `resolve_execute_hard_lock_prompt` dispatcher path uses that constant instead of an inline string literal.

- [x] [P2-T5] Extract the `resolve_execute_hard_lock_prompt` dispatch body from `extensions/drm-copilot/src/mcp-tools.ts` into a dedicated handler module under `extensions/drm-copilot/src/mcp-handlers/` while preserving the existing public dispatcher API.
	- Acceptance:
		- A new handler module exists under `extensions/drm-copilot/src/mcp-handlers/` for this case.
		- `extensions/drm-copilot/src/mcp-tools.ts` delegates the `resolve_execute_hard_lock_prompt` case to that handler.

- [x] [P2-T6] Extract the collect-context dispatcher cases `collect_commit_context` and `collect_pr_context` from `extensions/drm-copilot/src/mcp-tools.ts` into focused handler module targets under `extensions/drm-copilot/src/mcp-handlers/`.
	- Acceptance:
		- At least one handler module exists under `extensions/drm-copilot/src/mcp-handlers/` for the collect-context cases.
		- `extensions/drm-copilot/src/mcp-tools.ts` delegates the `collect_commit_context` and `collect_pr_context` cases to the extracted handler target and does not keep those case bodies inline.

- [x] [P2-T7] Extract the push-down dispatcher cases `push_down_copilot_customizations` and `push_down_codex_and_agents_customizations` from `extensions/drm-copilot/src/mcp-tools.ts` into focused handler module targets under `extensions/drm-copilot/src/mcp-handlers/`.
	- Acceptance:
		- At least one handler module exists under `extensions/drm-copilot/src/mcp-handlers/` for the push-down cases.
		- `extensions/drm-copilot/src/mcp-tools.ts` delegates the `push_down_copilot_customizations` and `push_down_codex_and_agents_customizations` cases to the extracted handler target and does not keep those case bodies inline.

- [x] [P2-T8] Extract the feature-entry dispatcher cases `new_potential_bug_entry`, `new_potential_entry`, `potential_to_issue`, and `new_active_feature_folder` from `extensions/drm-copilot/src/mcp-tools.ts` into focused handler module targets under `extensions/drm-copilot/src/mcp-handlers/`.
	- Acceptance:
		- At least one handler module exists under `extensions/drm-copilot/src/mcp-handlers/` for the feature-entry cases.
		- `extensions/drm-copilot/src/mcp-tools.ts` delegates the `new_potential_bug_entry`, `new_potential_entry`, `potential_to_issue`, and `new_active_feature_folder` cases to the extracted handler target and does not keep those case bodies inline.

- [x] [P2-T9] Extract the PoshQC dispatcher cases `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`, `run_poshqc_analyze_autofix`, and `run_poshqc_suite` from `extensions/drm-copilot/src/mcp-tools.ts` into focused handler module targets under `extensions/drm-copilot/src/mcp-handlers/`.
	- Acceptance:
		- At least one handler module exists under `extensions/drm-copilot/src/mcp-handlers/` for the PoshQC cases.
		- `extensions/drm-copilot/src/mcp-tools.ts` delegates the `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`, `run_poshqc_analyze_autofix`, and `run_poshqc_suite` cases to the extracted handler target and does not keep those case bodies inline.

- [x] [P2-T10] Extract the template or validation dispatcher cases `resolve_policy_audit_template_asset` and `validate_orchestration_artifacts` from `extensions/drm-copilot/src/mcp-tools.ts` into focused handler module targets under `extensions/drm-copilot/src/mcp-handlers/`.
	- Acceptance:
		- At least one handler module exists under `extensions/drm-copilot/src/mcp-handlers/` for the template or validation cases.
		- `extensions/drm-copilot/src/mcp-tools.ts` delegates the `resolve_policy_audit_template_asset` and `validate_orchestration_artifacts` cases to the extracted handler target and does not keep those case bodies inline.

- [x] [P2-T11] Capture the post-refactor line count for `extensions/drm-copilot/src/mcp-tools.ts` in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p2-t11.mcp-tools-lines.2026-04-18T18-50.md` with `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/mcp-tools.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/mcp-tools.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and a numeric `Output Summary:` that is `<= 500`.

- [x] [P2-T12] Extract the `resolveExecuteHardLockPrompt` argument-assembly site from `extensions/drm-copilot/src/repo-automation-service.ts` into the helper target `extensions/drm-copilot/src/repo-automation-args.ts`.
	- Acceptance:
		- `extensions/drm-copilot/src/repo-automation-args.ts` contains the helper target used for `resolveExecuteHardLockPrompt` argument assembly.
		- `RepoAutomationService.resolveExecuteHardLockPrompt` delegates its argument construction to that helper target.

- [x] [P2-T13] Extract the `newActiveFeatureFolder` argument builder from `extensions/drm-copilot/src/repo-automation-service.ts` into the helper target `extensions/drm-copilot/src/repo-automation-args.ts`.
	- Acceptance:
		- `extensions/drm-copilot/src/repo-automation-args.ts` contains the helper target used for `newActiveFeatureFolder` argument assembly.
		- `RepoAutomationService.newActiveFeatureFolder` delegates its argument construction to that helper target.

- [x] [P2-T14] Extract the `runPoshQcWorkflow` scan-folder and summary argument builder from `extensions/drm-copilot/src/repo-automation-service.ts` into the helper target `extensions/drm-copilot/src/repo-automation-args.ts`.
	- Acceptance:
		- `extensions/drm-copilot/src/repo-automation-args.ts` contains the helper target used for `runPoshQcWorkflow` scan-folder and summary argument assembly.
		- `RepoAutomationService.runPoshQcWorkflow` delegates scan-folder argument construction and summary construction to that helper target.

- [x] [P2-T15] Extract the `validateOrchestrationArtifacts` argument builder from `extensions/drm-copilot/src/repo-automation-service.ts` into the helper target `extensions/drm-copilot/src/repo-automation-args.ts`.
	- Acceptance:
		- `extensions/drm-copilot/src/repo-automation-args.ts` contains the helper target used for `validateOrchestrationArtifacts` argument assembly.
		- `RepoAutomationService.validateOrchestrationArtifacts` delegates its argument construction to that helper target.

- [x] [P2-T16] Capture the post-refactor line count for `extensions/drm-copilot/src/repo-automation-service.ts` in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p2-t16.repo-automation-service-lines.2026-04-18T18-50.md` with `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-service.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-service.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and a numeric `Output Summary:` that is `<= 500`.

### Phase 3 — Python Mirror-Coverage Decision and Remediation

- [x] [P3-T1] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selecting exactly one path: `Selected Path: Option A` or `Selected Path: Option B`.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains exactly one line beginning `Selected Path:`.
		- The selected value is either `Option A` or `Option B`.

- [x] [P3-T2] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option A`, extend the Python coverage configuration so `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_filesystem.py` is included in LCOV output.
	- Acceptance: The active Python coverage configuration explicitly includes `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_filesystem.py` in measured source paths.

- [x] [P3-T3] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option A`, extend the Python coverage configuration so `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` is included in LCOV output.
	- Acceptance: The active Python coverage configuration explicitly includes `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` in measured source paths.

- [x] [P3-T4] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option A`, regenerate Python LCOV evidence in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t4.python-mirror-lcov.2026-04-18T18-50.md` by running `poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info`.
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE:`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` confirms both mirror files appear as `SF:` entries in `artifacts/python/lcov.info`.

- [x] [P3-T5] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option A`, write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t5.python-mirror-coverage-verdict.2026-04-18T18-50.md` verifying numeric mirror coverage from `artifacts/python/lcov.info`.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains numeric coverage values for both mirror files.
		- The artifact contains `Verdict: pass` only if both mirror files are `>= 80`.

- [x] [P3-T6] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option B`, add a `Mirror Verification Model` section to `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md` documenting that the extension-bundled Python mirrors are verified through canonical-copy parity tests.
	- Acceptance: `spec.md` contains a section heading `Mirror Verification Model` and names both mirror paths explicitly.

- [x] [P3-T7] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option B`, add or update the parity test scenario for `push_down_copilot_customizations_filesystem.py` so the bundled mirror and canonical implementation produce equivalent observable output for the same fixture inputs.
	- Acceptance: A Python test file contains assertions comparing canonical and bundled behavior for `push_down_copilot_customizations_filesystem.py` on the same fixture input.

- [x] [P3-T8] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option B`, add or update the parity test scenario for `resolve_hard_lock_prompt.py` so the bundled mirror and canonical implementation produce equivalent observable output for the same fixture inputs.
	- Acceptance: A Python test file contains assertions comparing canonical and bundled behavior for `resolve_hard_lock_prompt.py` on the same fixture input.

- [x] [P3-T9] If `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t1.python-mirror-coverage-decision.2026-04-18T18-50.md` selects `Option B`, capture parity-test evidence in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p3-t9.python-parity-tests.2026-04-18T18-50.md` by running `poetry run pytest tests/extensions/drm_copilot/resources/templates tests/scripts/dev_tools -k "hard_lock_prompt or push_down_copilot_customizations"`.
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: poetry run pytest tests/extensions/drm_copilot/resources/templates tests/scripts/dev_tools -k "hard_lock_prompt or push_down_copilot_customizations"`, `EXIT_CODE:`, and `Output Summary:`.
		- `Output Summary:` names at least one passing parity test for each mirror file.

### Phase 4 — TypeScript Test-File Split

- [x] [P4-T1] Move the hard-lock prompt resolution tests out of `extensions/drm-copilot/test/repo-automation-service.test.ts` into a dedicated test file focused on hard-lock prompt behavior.
	- Acceptance: A dedicated TypeScript test file exists for hard-lock prompt behavior, and those tests no longer reside only in `extensions/drm-copilot/test/repo-automation-service.test.ts`.

- [x] [P4-T2] Move the orchestration-artifact validation tests out of `extensions/drm-copilot/test/repo-automation-service.test.ts` into a dedicated test file focused on orchestration validation behavior.
	- Acceptance: A dedicated TypeScript test file exists for orchestration validation behavior, and those tests no longer reside only in `extensions/drm-copilot/test/repo-automation-service.test.ts`.

- [x] [P4-T3] Move the discovery and repository-automation dispatch tests out of `extensions/drm-copilot/test/repo-automation-service.test.ts` into a dedicated test file focused on discovery and dispatch behavior.
	- Acceptance: A dedicated TypeScript test file exists for discovery and dispatch behavior, and those tests no longer reside only in `extensions/drm-copilot/test/repo-automation-service.test.ts`.

- [x] [P4-T4] Capture the post-split line count for `extensions/drm-copilot/test/repo-automation-service.test.ts` in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p4-t4.repo-automation-service-test-lines.2026-04-18T18-50.md` with `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/test/repo-automation-service.test.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/test/repo-automation-service.test.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and a numeric `Output Summary:` that is `<= 500`.

- [x] [P4-T5] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/other/p4-t5.typescript-test-split-summary.2026-04-18T18-50.md` listing the final exact test-file paths created or updated for the split.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact lists the exact final file path for each split behavior area: hard-lock prompt, orchestration validation, and discovery or dispatch.

### Phase 5 — Final QA Gates and Feature-Review Rerun

- [x] [P5-T1] Run the final TypeScript formatting gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t1.typescript-format-check.2026-04-18T18-50.md` with `npm --prefix extensions/drm-copilot exec prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`. If this step fails, restart the TypeScript QA loop from [P5-T1].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot exec prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T2] Run the final TypeScript lint gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t2.typescript-lint.2026-04-18T18-50.md` with `npm --prefix extensions/drm-copilot run lint`. If this step fails, restart the TypeScript QA loop from [P5-T1].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T3] Run the final TypeScript type-check gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t3.typescript-typecheck.2026-04-18T18-50.md` with `npm --prefix extensions/drm-copilot run typecheck`. If this step fails, restart the TypeScript QA loop from [P5-T1].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T4] Run the final TypeScript test-and-coverage gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t4.typescript-coverage.2026-04-18T18-50.md` with `npm --prefix extensions/drm-copilot run test:unit -- --coverage`. If this step fails, restart the TypeScript QA loop from [P5-T1].
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` includes numeric `mcp-tools.ts Coverage:` and `repo-automation-service.ts Coverage:`.

- [x] [P5-T5] Run the final Python formatting gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t5.python-format-check.2026-04-18T18-50.md` with `poetry run black --check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`. If this step fails, restart the Python QA loop from [P5-T5].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run black --check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T6] Run the final Python lint gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t6.python-lint.2026-04-18T18-50.md` with `poetry run ruff check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`. If this step fails, restart the Python QA loop from [P5-T5].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools tests extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T7] Run the final Python type-check gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t7.python-typecheck.2026-04-18T18-50.md` with `poetry run pyright`. If this step fails, restart the Python QA loop from [P5-T5].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T8] Run the final Python test-and-coverage gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t8.python-coverage.2026-04-18T18-50.md` with `poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info`. If this step fails, restart the Python QA loop from [P5-T5].
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE: 0`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` either lists numeric mirror coverage values or references the successful parity evidence path from [P3-T9].

- [x] [P5-T9] Run the final PowerShell formatting gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t9.powershell-format.2026-04-18T18-50.md` with `mcp_drmcopilotext_run_poshqc_format`. If this step changes files or fails, restart the PowerShell QA loop from [P5-T9].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_format`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T10] Run the final PowerShell analyzer gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t10.powershell-analyze.2026-04-18T18-50.md` with `mcp_drmcopilotext_run_poshqc_analyze`. If this step fails, restart the PowerShell QA loop from [P5-T9].
	- Acceptance: The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_analyze`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P5-T11] Run the final PowerShell test-and-coverage gate and capture `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t11.powershell-coverage.2026-04-18T18-50.md` with `mcp_drmcopilotext_run_poshqc_test`. If this step fails, restart the PowerShell QA loop from [P5-T9].
	- Acceptance:
		- The artifact contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE: 0`, and `Output Summary:`.
		- `Output Summary:` includes numeric `Repo Coverage:`.
		- `Output Summary:` includes numeric `check-python-test-purity.ps1 Coverage:` and `enforce-python-batch-budget.ps1 Coverage:`.
		- Repo-wide coverage is `>= 80` and both hook-file coverage values are `>= 90`.

- [x] [P5-T12] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t12.acceptance-criteria-status.2026-04-18T18-50.md` summarizing acceptance-criteria status from `spec.md` only.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains the heading `Acceptance Criteria Status`.
		- The artifact contains `Source: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`.
		- The artifact contains numeric `Total AC items:`, `Checked off (delivered):`, and `Remaining (unchecked):` values.

- [x] [P5-T13] Resolve or confirm `PRBaseBranch` for the review rerun using merge-base ancestry rules and write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t13.feature-review-base-branch.2026-04-18T18-50.md`.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains `Resolution Mode:` with exactly one of `confirmed provided base` or `merge-base resolved`.
		- The artifact contains `Selected Base Branch:`, `Merge Base SHA:`, and `Merge Base Timestamp:`.
		- The artifact contains `Top Competing Candidates:` with either a branch list or `none`.

- [x] [P5-T14] Load `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, treat them as stale only when either file is missing or when the executor cannot prove they were generated for the current `HEAD` SHA and the base branch resolved in [P5-T13], and refresh stale artifacts with `mcp_drmcopilotext_collect_pr_context` using the resolved base before writing `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t14.pr-context-status.2026-04-18T18-50.md`.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
		- The artifact contains `Summary Path: artifacts/pr_context.summary.txt`.
		- The artifact contains `Appendix Path: artifacts/pr_context.appendix.txt`.
		- The artifact contains `Stale Condition:` with exactly one of `missing summary`, `missing appendix`, `base mismatch`, `head mismatch`, or `not stale`.
		- The artifact contains `Action:` with exactly one of `reused existing artifacts` or `refreshed artifacts`.
		- If `Action: refreshed artifacts`, `Command:` is `mcp_drmcopilotext_collect_pr_context(base=<Selected Base Branch>)` using the branch recorded in [P5-T13].
		- If `Action: reused existing artifacts`, `Command:` records the exact stale-check inspection performed against the branch from [P5-T13] and the current `HEAD` SHA.
		- The artifact contains `Base Branch Used:` matching the branch recorded in [P5-T13].

- [x] [P5-T15] Regenerate the feature-folder `policy-audit.*.md` artifact by calling `mcp_drmcopilotext_resolve_policy_audit_template_asset` with selector `template`, then validate the regenerated artifact with `mcp_drmcopilotext_validate_orchestration_artifacts` using `artifact_type: policy-audit`, and write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t15.policy-audit-rerun.2026-04-18T18-50.md` recording the exact generated path.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
		- The artifact contains `Template Selector: template`.
		- The artifact contains `Baseline Artifact: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-18T18-50.md`.
		- The artifact contains `Generated Artifact:` with the exact regenerated `policy-audit.*.md` path.
		- `Command:` is `mcp_drmcopilotext_resolve_policy_audit_template_asset(asset=template, target_path=<Generated Artifact>) -> mcp_drmcopilotext_validate_orchestration_artifacts(artifact_type=policy-audit, artifact_path=<Generated Artifact>)`.
		- The artifact contains `Is Newer Than Baseline: yes` and `Validator: pass`.

- [x] [P5-T16] Regenerate the feature-folder `code-review.*.md` artifact by calling `mcp_drmcopilotext_resolve_policy_audit_template_asset` with selector `code-review-template`, then validate the regenerated artifact with `mcp_drmcopilotext_validate_orchestration_artifacts` using `artifact_type: code-review`, and write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t16.code-review-rerun.2026-04-18T18-50.md` recording the exact generated path.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
		- The artifact contains `Template Selector: code-review-template`.
		- The artifact contains `Baseline Artifact: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/code-review.2026-04-18T18-50.md`.
		- The artifact contains `Generated Artifact:` with the exact regenerated `code-review.*.md` path.
		- `Command:` is `mcp_drmcopilotext_resolve_policy_audit_template_asset(asset=code-review-template, target_path=<Generated Artifact>) -> mcp_drmcopilotext_validate_orchestration_artifacts(artifact_type=code-review, artifact_path=<Generated Artifact>)`.
		- The artifact contains `Is Newer Than Baseline: yes` and `Validator: pass`.

- [x] [P5-T17] Regenerate the feature-folder `feature-audit.*.md` artifact in full-bug mode using `spec.md` as the only acceptance-criteria source by calling `mcp_drmcopilotext_resolve_policy_audit_template_asset` with selector `feature-audit-template`, then validate the regenerated artifact with `mcp_drmcopilotext_validate_orchestration_artifacts` using `artifact_type: feature-audit`, and write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t17.feature-audit-rerun.2026-04-18T18-50.md` recording the exact generated path.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
		- The artifact contains `Template Selector: feature-audit-template`.
		- The artifact contains `Acceptance Criteria Source: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`.
		- The artifact contains `Baseline Artifact: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/feature-audit.2026-04-18T18-50.md`.
		- The artifact contains `Generated Artifact:` with the exact regenerated `feature-audit.*.md` path.
		- `Command:` is `mcp_drmcopilotext_resolve_policy_audit_template_asset(asset=feature-audit-template, target_path=<Generated Artifact>) -> mcp_drmcopilotext_validate_orchestration_artifacts(artifact_type=feature-audit, artifact_path=<Generated Artifact>)`.
		- The artifact contains `Is Newer Than Baseline: yes` and `Validator: pass`.

- [x] [P5-T18] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t18.feature-review-rerun-summary.2026-04-18T18-50.md` listing the exact regenerated review artifact paths and validator outcomes from [P5-T15], [P5-T16], and [P5-T17].
	- Acceptance:
		- The summary artifact exists at the exact path named in this task.
		- The summary artifact contains exact fields `Timestamp:`, `Command: aggregate evidence from [P5-T14] through [P5-T17]`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
		- The summary artifact lists the exact full paths recorded in [P5-T15], [P5-T16], and [P5-T17].
		- The summary artifact records `Validator: pass` for each regenerated review artifact.
		- The summary artifact references the base-branch evidence path from [P5-T13] and the PR-context evidence path from [P5-T14].

- [x] [P5-T19] Write `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t19.final-remediation-verdict.2026-04-18T18-50.md` combining the final TS, Python, PowerShell, and review-rerun evidence into one go or no-go statement.
	- Acceptance:
		- The artifact exists at the exact path named in this task.
		- The artifact lists the exact evidence paths from [P5-T4], [P5-T8], [P5-T11], [P5-T12], and [P5-T18].
		- The artifact contains `Verdict: go` only if every referenced artifact reports `EXIT_CODE: 0` and the review rerun summary records regenerated review artifacts with validator success.
