---
title: "Remediation Plan: 2026-02-04-extension-tests-fail-in-container-12"
issue: 12
owner: drmoisan
last_updated: 2026-02-09T15-50
status: Planned
status_color: blue
version: 0.2
---

# Remediation Plan: 2026-02-04-extension-tests-fail-in-container-12

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

- **Issue:** #12
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-09T15-50
- **Status:** Planned
- **Version:** 0.2

## Required References

- Copilot instructions: [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript policies: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md), [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- PowerShell policies: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Python policies: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md), [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

**Variables (deterministic):**
- `RUN_TS`: Current execution timestamp in `yyyy-MM-ddTHH-mm` format.

**Requirements Traceability (REQ-/SEC-/CON-):**

| ID | Requirement / Constraint | Source | Planned Tasks |
|---|---|---|---|
| REQ-01 | Split scope into three branches and keep Issue #12 branch clean; verify via commit file lists and regenerated PR context. | `remediation-inputs.2026-02-09T15-50.md` | P1-T1 → P1-T22 |
| REQ-02 | Update `README.md` Testing section to state `npm test` and `npm run test:integration` run Jest unit tests (no GUI). | `remediation-inputs.2026-02-09T15-50.md` | P2-T1 |
| REQ-03 | Run PowerShell toolchain (format/analyze/test) and record evidence. | `remediation-inputs.2026-02-09T15-50.md` | P3-T1 → P3-T3, P6-T9 → P6-T11 |
| REQ-04 | Validate Jest tests in dev container and record evidence. | `remediation-inputs.2026-02-09T15-50.md` | P4-T1 |
| CON-01 | Do not broaden scope beyond Issue #12 or introduce new dependencies. | `remediation-inputs.2026-02-09T15-50.md` | P1-T2 → P1-T22 |
| CON-02 | Do not weaken or bypass repo policies (no suppressions or config relaxations). | `remediation-inputs.2026-02-09T15-50.md` | P0-T2 → P0-T12 |
| SEC-01 | Do not introduce external services, network calls, or GUI-based test runners. | `spec.md` (Scope & Non-Goals) | P2-T1, P4-T1 |

### Phase 0 — Context & Inputs
- [ ] [P0-T1] Create evidence directories `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline`, `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates`, and `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/regression-testing`
  - Acceptance: All three directories exist.
- [ ] [P0-T2] Record policy read for `.github/copilot-instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes `Timestamp: <RUN_TS>` and a line `Policy: .github/copilot-instructions.md`.
- [ ] [P0-T3] Record policy read for `.github/instructions/general-code-change.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/general-code-change.instructions.md`.
- [ ] [P0-T4] Record policy read for `.github/instructions/general-unit-test.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/general-unit-test.instructions.md`.
- [ ] [P0-T5] Record policy read for `.github/instructions/typescript-code-change.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/typescript-code-change.instructions.md`.
- [ ] [P0-T6] Record policy read for `.github/instructions/typescript-unit-test.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/typescript-unit-test.instructions.md`.
- [ ] [P0-T7] Record policy read for `.github/instructions/typescript-suppressions.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/typescript-suppressions.instructions.md`.
- [ ] [P0-T8] Record policy read for `.github/instructions/python-code-change.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/python-code-change.instructions.md`.
- [ ] [P0-T9] Record policy read for `.github/instructions/python-unit-test.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/python-unit-test.instructions.md`.
- [ ] [P0-T10] Record policy read for `.github/instructions/python-suppressions.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/python-suppressions.instructions.md`.
- [ ] [P0-T11] Record policy read for `.github/instructions/powershell-code-change.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/powershell-code-change.instructions.md`.
- [ ] [P0-T12] Record policy read for `.github/instructions/powershell-unit-test.instructions.md` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/policy-read.<RUN_TS>.md`
  - Acceptance: Evidence file includes a line `Policy: .github/instructions/powershell-unit-test.instructions.md`.
- [ ] [P0-T13] Capture baseline TypeScript formatting output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/ts-format.<RUN_TS>.txt` using `npm run format`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run format`, and `EXIT_CODE:`.
- [ ] [P0-T14] Capture baseline TypeScript lint output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/ts-lint.<RUN_TS>.txt` using `npm run lint`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run lint`, and `EXIT_CODE:`.
- [ ] [P0-T15] Capture baseline TypeScript typecheck output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/ts-typecheck.<RUN_TS>.txt` using `npm run typecheck`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run typecheck`, and `EXIT_CODE:`.
- [ ] [P0-T16] Capture baseline Jest unit test output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/ts-test-unit.<RUN_TS>.txt` using `npm run test:unit`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run test:unit`, and `EXIT_CODE:`.
- [ ] [P0-T17] Capture baseline Python formatting output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/py-format.<RUN_TS>.txt` using `poetry run black .`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run black .`, and `EXIT_CODE:`.
- [ ] [P0-T18] Capture baseline Python lint output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/py-lint.<RUN_TS>.txt` using `poetry run ruff check`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run ruff check`, and `EXIT_CODE:`.
- [ ] [P0-T19] Capture baseline Python typecheck output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/py-typecheck.<RUN_TS>.txt` using `poetry run pyright`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run pyright`, and `EXIT_CODE:`.
- [ ] [P0-T20] Capture baseline Python test output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/py-test.<RUN_TS>.txt` using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, and `EXIT_CODE:`.
- [ ] [P0-T21] Capture baseline PowerShell formatting output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/ps-format.<RUN_TS>.txt` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, and `EXIT_CODE:`.
- [ ] [P0-T22] Capture baseline PowerShell analysis output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/ps-analyze.<RUN_TS>.txt` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, and `EXIT_CODE:`.
- [ ] [P0-T23] Capture baseline PowerShell test output in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/baseline/ps-test.<RUN_TS>.txt` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, and `EXIT_CODE:`.

### Phase 1 — Scope Split into Three Branches
- [ ] [P1-T1] Capture current PR context in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/pr-context.pre-scope.<RUN_TS>.txt` using `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`, and `EXIT_CODE:`.
- [ ] [P1-T2] Create a scope allowlist file at `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-a.<RUN_TS>.txt` for **Branch A** containing exactly the following lines (one prefix per line):
  - `scripts/dev_tools/`
  - `tests/scripts/dev_tools/`
  - `scripts/dev-tools/`
  - `tests/scripts/dev-tools/`
  - Acceptance: `scope-allowlist.branch-a.<RUN_TS>.txt` exists and contains only the listed prefixes.
- [ ] [P1-T3] Create **Branch A** `chore/test-coverage-expansion` and cherry-pick commits `5b6d0e4` and `2496634`
  - Acceptance: `git log --oneline -n 2` on Branch A includes both commits in order.
- [ ] [P1-T4] Capture commit file list for `5b6d0e4` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/commit-files.5b6d0e4.<RUN_TS>.txt` using `git show --name-only 5b6d0e4`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git show --name-only 5b6d0e4`, and `EXIT_CODE:`.
- [ ] [P1-T5] Capture commit file list for `2496634` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/commit-files.2496634.<RUN_TS>.txt` using `git show --name-only 2496634`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git show --name-only 2496634`, and `EXIT_CODE:`.
- [ ] [P1-T6] Capture PR context for **Branch A** in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/pr-context.branch-a.<RUN_TS>.txt` using `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`
  - Preconditions: Branch A is checked out.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`, and `EXIT_CODE:`.
- [ ] [P1-T7] Capture Branch A diff file list in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-a.<RUN_TS>.txt` using `git diff --name-only origin/feature/import-pre-built-functionality...HEAD`
  - Preconditions: Branch A is checked out.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git diff --name-only origin/feature/import-pre-built-functionality...HEAD`, and `EXIT_CODE:`.
- [ ] [P1-T8] Verify Branch A diff list contains only allowlisted prefixes and record violations in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-a.<RUN_TS>.txt`
  - Preconditions: Branch A diff list exists (`scope-diff.branch-a.<RUN_TS>.txt`).
  - Acceptance: `pwsh -NoLogo -NoProfile -Command "$allowed = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-a.<RUN_TS>.txt; $violations = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-a.<RUN_TS>.txt | Where-Object { $path = $_; -not ($allowed | Where-Object { $path.StartsWith($_) }) }; @('Timestamp: <RUN_TS>', 'Command: pwsh -NoLogo -NoProfile -Command $allowed = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-a.<RUN_TS>.txt; $violations = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-a.<RUN_TS>.txt | Where-Object { $path = $_; -not ($allowed | Where-Object { $path.StartsWith($_) }) }', 'EXIT_CODE: 0') + $violations | Set-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-a.<RUN_TS>.txt; if ((Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-a.<RUN_TS>.txt | Select-Object -Skip 3).Length -ne 0) { exit 1 }"` exits with code 0.
- [ ] [P1-T9] Create a scope allowlist file at `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-b.<RUN_TS>.txt` for **Branch B** containing exactly the following lines (one prefix per line):
  - `.github/agents/`
  - `.github/skills/`
  - `docs/`
  - `AGENTS.md`
  - Acceptance: `scope-allowlist.branch-b.<RUN_TS>.txt` exists and contains only the listed prefixes.
- [ ] [P1-T10] Create **Branch B** `feature/agents-skills-docs` and cherry-pick commits `b1353f9` and `d8755a8`
  - Acceptance: `git log --oneline -n 2` on Branch B includes both commits in order.
- [ ] [P1-T11] Capture commit file list for `b1353f9` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/commit-files.b1353f9.<RUN_TS>.txt` using `git show --name-only b1353f9`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git show --name-only b1353f9`, and `EXIT_CODE:`.
- [ ] [P1-T12] Capture commit file list for `d8755a8` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/commit-files.d8755a8.<RUN_TS>.txt` using `git show --name-only d8755a8`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git show --name-only d8755a8`, and `EXIT_CODE:`.
- [ ] [P1-T13] Capture PR context for **Branch B** in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/pr-context.branch-b.<RUN_TS>.txt` using `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`
  - Preconditions: Branch B is checked out.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`, and `EXIT_CODE:`.
- [ ] [P1-T14] Capture Branch B diff file list in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-b.<RUN_TS>.txt` using `git diff --name-only origin/feature/import-pre-built-functionality...HEAD`
  - Preconditions: Branch B is checked out.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git diff --name-only origin/feature/import-pre-built-functionality...HEAD`, and `EXIT_CODE:`.
- [ ] [P1-T15] Verify Branch B diff list contains only allowlisted prefixes and record violations in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-b.<RUN_TS>.txt`
  - Preconditions: Branch B diff list exists (`scope-diff.branch-b.<RUN_TS>.txt`).
  - Acceptance: `pwsh -NoLogo -NoProfile -Command "$allowed = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-b.<RUN_TS>.txt; $violations = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-b.<RUN_TS>.txt | Where-Object { $path = $_; -not ($allowed | Where-Object { $path.StartsWith($_) }) }; @('Timestamp: <RUN_TS>', 'Command: pwsh -NoLogo -NoProfile -Command $allowed = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-b.<RUN_TS>.txt; $violations = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-b.<RUN_TS>.txt | Where-Object { $path = $_; -not ($allowed | Where-Object { $path.StartsWith($_) }) }', 'EXIT_CODE: 0') + $violations | Set-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-b.<RUN_TS>.txt; if ((Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-b.<RUN_TS>.txt | Select-Object -Skip 3).Length -ne 0) { exit 1 }"` exits with code 0.
- [ ] [P1-T16] Create a scope allowlist file at `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-c.<RUN_TS>.txt` for **Branch C** containing exactly the following lines (one path per line):
  - `README.md`
  - `docs/developer-tooling.md`
  - `package.json`
  - `tests/unit/vscode-test-removal.test.ts`
  - `tests/unit/extension.test.ts`
  - `tests/unit/drm-task-provider.test.ts`
  - `tests/integration/extension.test.ts`
  - `.vscode-test.mjs`
  - `tsconfig.vscode-test.json`
  - `scripts/dev-tools/format-powershell.ps1`
  - `tests/scripts/dev-tools/format-powershell.Tests.ps1`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/feature-audit.2026-02-09T15-50.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/policy-audit.2026-02-09T15-50.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/remediation-inputs.2026-02-09T15-50.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/remediation-plan.2026-02-09T15-50.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/spec.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/issue.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/links.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/pr-notes.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/plan.2026-02-04T18-36.md`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/regression-testing/expect-fail-scripts.txt`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/regression-testing/expect-fail-vscode-test-mjs.txt`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/regression-testing/expect-fail-vscode-test-tsconfig.txt`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-format.txt`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-lint.txt`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-typecheck.txt`
  - `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-test-unit.txt`
  - Acceptance: `scope-allowlist.branch-c.<RUN_TS>.txt` exists and contains only the listed paths.
- [ ] [P1-T17] Create **Branch C** `bugfix/extension-tests-failing-in-container-#12` and cherry-pick commits `00d059d` and `2f67b88` (explicitly exclude `dd5b5f7`)
  - Acceptance: `git log --oneline -n 2` on Branch C includes `00d059d` and `2f67b88` in order.
- [ ] [P1-T18] Capture commit file list for `00d059d` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/commit-files.00d059d.<RUN_TS>.txt` using `git show --name-only 00d059d`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git show --name-only 00d059d`, and `EXIT_CODE:`.
- [ ] [P1-T19] Capture commit file list for `2f67b88` in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/commit-files.2f67b88.<RUN_TS>.txt` using `git show --name-only 2f67b88`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git show --name-only 2f67b88`, and `EXIT_CODE:`.
- [ ] [P1-T20] Capture PR context for **Branch C** in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/pr-context.branch-c.<RUN_TS>.txt` using `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`
  - Preconditions: Branch C is checked out.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`, and `EXIT_CODE:`.
- [ ] [P1-T21] Capture Branch C diff file list in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-c.<RUN_TS>.txt` using `git diff --name-only origin/feature/import-pre-built-functionality...HEAD`
  - Preconditions: Branch C is checked out.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: git diff --name-only origin/feature/import-pre-built-functionality...HEAD`, and `EXIT_CODE:`.
- [ ] [P1-T22] Verify Branch C diff list contains only allowlisted prefixes and record violations in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-c.<RUN_TS>.txt`
  - Preconditions: Branch C diff list exists (`scope-diff.branch-c.<RUN_TS>.txt`).
  - Acceptance: `pwsh -NoLogo -NoProfile -Command "$allowed = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-c.<RUN_TS>.txt; $violations = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-c.<RUN_TS>.txt | Where-Object { $path = $_; -not ($allowed | Where-Object { $path.StartsWith($_) }) }; @('Timestamp: <RUN_TS>', 'Command: pwsh -NoLogo -NoProfile -Command $allowed = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-allowlist.branch-c.<RUN_TS>.txt; $violations = Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-diff.branch-c.<RUN_TS>.txt | Where-Object { $path = $_; -not ($allowed | Where-Object { $path.StartsWith($_) }) }', 'EXIT_CODE: 0') + $violations | Set-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-c.<RUN_TS>.txt; if ((Get-Content docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/scope-violations.branch-c.<RUN_TS>.txt | Select-Object -Skip 3).Length -ne 0) { exit 1 }"` exits with code 0.

### Phase 2 — README Update (Testing Guidance)
- [ ] [P2-T1] Update `README.md` lines 32–37 (Integration Tests block) to the exact text below:
  - `**Integration Tests** (alias for unit tests — no GUI required):`
  - ``npm test  # or npm run test:integration``
  - `Both commands execute Jest unit tests with mocked VS Code APIs and do not launch the VS Code extension host.`
  - Acceptance: `README.md` contains the exact text above at lines 32–34 and removes the GUI-only note about `libatk-1.0.so.0` at lines 37–37.

### Phase 3 — PowerShell Toolchain Evidence
- [ ] [P3-T1] Run PowerShell formatter and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ps-format.<RUN_TS>.txt` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, and `EXIT_CODE:`.
- [ ] [P3-T2] Run PowerShell analyzer and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ps-analyze.<RUN_TS>.txt` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, and `EXIT_CODE:`.
- [ ] [P3-T3] Run PowerShell tests and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ps-test.<RUN_TS>.txt` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, and `EXIT_CODE:`.

### Phase 4 — Dev Container Repro Verification
- [ ] [P4-T1] Run Jest unit tests inside the dev container and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/devcontainer-test-unit.<RUN_TS>.txt` using `npm run test:unit`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run test:unit`, and `EXIT_CODE:`.

### Phase 5 — Audit Updates
- [ ] [P5-T1] Update `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/feature-audit.2026-02-09T15-50.md` row `Repro steps now produce expected behavior in all documented environments` to **PASS** with evidence reference `evidence/qa-gates/devcontainer-test-unit.<RUN_TS>.txt`
  - Acceptance: The row shows **PASS** and includes the evidence path.
- [ ] [P5-T2] Update `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/feature-audit.2026-02-09T15-50.md` row `No unintended behavior changes outside defined scope` to **PASS** with evidence reference `evidence/qa-gates/pr-context.branch-c.<RUN_TS>.txt`
  - Acceptance: The row shows **PASS** and includes the evidence path.
- [ ] [P5-T3] Update `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/feature-audit.2026-02-09T15-50.md` row `Docs/config references updated to match behavior` to **PASS** with evidence reference to `README.md` updated lines 32–34
  - Acceptance: The row shows **PASS** and includes the evidence reference.
- [ ] [P5-T4] Update `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/feature-audit.2026-02-09T15-50.md` row `Full toolchain pass completed` to **PASS** with evidence references to Phase 6 `ts-*`, `py-*`, and `ps-*` evidence files
  - Acceptance: The row shows **PASS** and includes evidence paths for all three language toolchains.
- [ ] [P5-T5] Update `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/policy-audit.2026-02-09T15-50.md` PowerShell tooling sections to **PASS** with evidence references to `evidence/qa-gates/ps-format.<RUN_TS>.txt`, `evidence/qa-gates/ps-analyze.<RUN_TS>.txt`, and `evidence/qa-gates/ps-test.<RUN_TS>.txt`
  - Acceptance: The PowerShell tooling section lists **PASS** for format/analyze/test and references the evidence paths.

### Phase 6 — Final QA Loop (Restart on Any Failure or Auto-Fix)
- [ ] [P6-T1] Run `npm run format` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ts-format.<RUN_TS>.txt`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run format`, and `EXIT_CODE: 0`.
- [ ] [P6-T2] Run `npm run lint` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ts-lint.<RUN_TS>.txt`
  - Preconditions: P6-T1 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run lint`, and `EXIT_CODE: 0`.
  - Acceptance: If lint fails or auto-fixes files, re-run P6-T1 then re-run P6-T2 until lint passes.
- [ ] [P6-T3] Run `npm run typecheck` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ts-typecheck.<RUN_TS>.txt`
  - Preconditions: P6-T2 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run typecheck`, and `EXIT_CODE: 0`.
  - Acceptance: If typecheck fails, re-run P6-T1 → P6-T3 in order until a clean pass is recorded.
- [ ] [P6-T4] Run `npm run test:unit` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ts-test-unit.<RUN_TS>.txt`
  - Preconditions: P6-T3 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: npm run test:unit`, and `EXIT_CODE: 0`.
  - Acceptance: If tests fail, re-run P6-T1 → P6-T4 in order until a clean pass is recorded.
- [ ] [P6-T5] Run `poetry run black .` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/py-format.<RUN_TS>.txt`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run black .`, and `EXIT_CODE: 0`.
- [ ] [P6-T6] Run `poetry run ruff check` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/py-lint.<RUN_TS>.txt`
  - Preconditions: P6-T5 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run ruff check`, and `EXIT_CODE: 0`.
  - Acceptance: If Ruff fails or auto-fixes files, re-run P6-T5 then re-run P6-T6 until lint passes.
- [ ] [P6-T7] Run `poetry run pyright` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/py-typecheck.<RUN_TS>.txt`
  - Preconditions: P6-T6 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run pyright`, and `EXIT_CODE: 0`.
  - Acceptance: If typecheck fails, re-run P6-T5 → P6-T7 in order until a clean pass is recorded.
- [ ] [P6-T8] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/py-test.<RUN_TS>.txt`
  - Preconditions: P6-T7 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, and `EXIT_CODE: 0`.
  - Acceptance: If tests fail, re-run P6-T5 → P6-T8 in order until a clean pass is recorded.
- [ ] [P6-T9] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ps-format.<RUN_TS>.txt`
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, and `EXIT_CODE: 0`.
- [ ] [P6-T10] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ps-analyze.<RUN_TS>.txt`
  - Preconditions: P6-T9 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, and `EXIT_CODE: 0`.
  - Acceptance: If analysis fails or auto-fixes files, re-run P6-T9 then re-run P6-T10 until analyze passes.
- [ ] [P6-T11] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and capture evidence in `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/evidence/qa-gates/ps-test.<RUN_TS>.txt`
  - Preconditions: P6-T10 completed with `EXIT_CODE: 0`.
  - Acceptance: Evidence file contains `Timestamp: <RUN_TS>`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, and `EXIT_CODE: 0`.
  - Acceptance: If tests fail, re-run P6-T9 → P6-T11 in order until a clean pass is recorded.

## Test Plan

- Unit: `npm run test:unit` (host) and `npm run test:unit` (dev container) with evidence in `evidence/qa-gates/ts-test-unit.<RUN_TS>.txt` and `evidence/qa-gates/devcontainer-test-unit.<RUN_TS>.txt`.
- Integration: None (integration harness removed; `npm test` is an alias for unit tests).
- Manual/CLI: PowerShell toolchain commands from Phase 3 and Phase 6, with evidence in `evidence/qa-gates/ps-format.<RUN_TS>.txt`, `evidence/qa-gates/ps-analyze.<RUN_TS>.txt`, and `evidence/qa-gates/ps-test.<RUN_TS>.txt`.

## Open Questions / Notes

- None. All requirements are enumerated and scoped to Issue #12 remediation.
