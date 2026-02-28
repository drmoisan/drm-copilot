---
issue: 16
parent: none
owner: drmoisan
last_updated: 2026-02-17T00-30
status: Planned
status_color: blue
version: 1.0
---

# 2026-01-28-scaffold-extension - Plan

- **Issue:** #16
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-17T00-30
- **Status:** Planned
- **Version:** 1.0

**Status Badge:** ![Status: Planned (blue)](https://img.shields.io/badge/status-Planned-blue)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- PowerShell Code Change Policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Feature Specification: [`spec.md`](./spec.md)
- User Story: [`user-story.md`](./user-story.md)
- Implementation Research: [`research.md`](./research.md)
- Atomic Plan Contract Skill: [`.github/skills/atomic-plan-contract/SKILL.md`](../../../../.github/skills/atomic-plan-contract/SKILL.md)
- Evidence and Timestamp Conventions Skill: [`.github/skills/evidence-and-timestamp-conventions/SKILL.md`](../../../../.github/skills/evidence-and-timestamp-conventions/SKILL.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Requirements Traceability

| ID | Type | Requirement Statement | Source |
| --- | --- | --- | --- |
| REQ-001 | Functional | Register `scaffoldExtension.helloPython` and `scaffoldExtension.helloPowerShell` commands in the extension manifest and activation entrypoint. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 1 |
| REQ-002 | Functional | Ensure `hello_python.py` exists in workspace root before running Hello Python. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 2 |
| REQ-003 | Functional | Ensure `hello_pwsh.ps1` exists in workspace root before running Hello PowerShell. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 3 |
| REQ-004 | Functional | Run Hello Python from workspace root and generate `artifacts/hello_python.txt`. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 2 |
| REQ-005 | Functional | Run Hello PowerShell from workspace root and generate `artifacts/hello_pwsh.txt`. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 3 |
| REQ-006 | Functional | Fail with actionable error when no workspace is open. | `spec.md` General behavior |
| REQ-007 | Functional | Detect Python runtime and fail with explicit runtime-named error when unavailable. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 6 |
| REQ-008 | Functional | Detect PowerShell runtime preferring `pwsh` then fallback `powershell`, and fail with explicit runtime-named error when unavailable. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 6 |
| REQ-009 | Functional | Log runtime detection, command start/end, and error details to a dedicated OutputChannel. | `spec.md` General behavior |
| REQ-010 | Functional | Scaffold Python environment files (`pyproject.toml`, `poetry.toml`) in workspace when missing. | `spec.md` Behavior; `spec.md` Inputs/Outputs |
| REQ-011 | Functional | Ensure generated workspace `pyproject.toml` matches the exact spec template content. | `spec.md` API/CLI Surface; Definition of Done |
| REQ-012 | Functional | Scaffold PowerShell tooling configuration required for PoshQC usage in workspace when missing. | `spec.md` General behavior; Implementation Strategy |
| REQ-013 | Functional | Update extension README with first-run workflow and runtime prerequisites for Windows/macOS/Linux. | `spec.md` General behavior; `user-story.md` Acceptance Criteria 5 and 7 |
| CON-001 | Constraint | Use only built-in Node.js and VS Code APIs for MVP implementation. | `spec.md` Implementation Strategy |
| CON-002 | Constraint | Resolve all script and artifact paths relative to active workspace root; no manual path edits. | `spec.md` Behavior; `user-story.md` Acceptance Criteria 4 |
| CON-003 | Constraint | Do not overwrite existing user files; only copy scaffold assets when files are missing. | `spec.md` Data & State invariants |
| SEC-001 | Security | Execute child processes with explicit executable and argument arrays to prevent command injection and path-quoting errors. | `research.md` Risks and Mitigations |
| SEC-002 | Security | Surface runtime and process failures with sanitized error text in OutputChannel and user-visible errors. | `spec.md` Constraints & Risks; `research.md` Update/Reporting Strategy |

### Phase 0 — Context & Inputs

**Phase Completion Criteria:** All mandatory policy files are read in-order; baseline evidence files exist for TypeScript extension toolchain, Python repository toolchain, and PowerShell repository toolchain (format/lint/test sequence) under canonical feature evidence folders; Node.js and npm prerequisite checks are captured with `EXIT_CODE: 0`; each baseline command block includes schema fields `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.

- [ ] [P0-T1] Read mandatory policy files in this exact order and log completion in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/policy-read.2026-02-17T00-00.md`: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`.
  - Acceptance: File `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/policy-read.2026-02-17T00-00.md` exists, contains one `- [x]` line per file, and includes `Timestamp: 2026-02-17T00-00`, `Command: policy-read verification procedure`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P0-T2] Capture baseline Python toolchain evidence into `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/python-toolchain.2026-02-17T00-00.md` by running `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest -q` from repository root.
  - Acceptance: File exists with four command blocks; each block includes `Timestamp: 2026-02-17T00-00` (or command-specific ISO-8601 timestamp), exact `Command:`, numeric `EXIT_CODE:`, and non-empty `Output Summary:` lines.
- [ ] [P0-T3] Capture baseline PowerShell quality evidence into `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/powershell-toolchain.2026-02-17T00-00.md` by running `poetry run shell-qc-format`, `poetry run shell-qc-check`, and `poetry run shell-qc-test` from repository root.
  - Acceptance: File exists with three command blocks; each block includes `Timestamp: 2026-02-17T00-00` (or command-specific ISO-8601 timestamp), exact `Command:`, numeric `EXIT_CODE:`, and non-empty `Output Summary:` lines.
- [ ] [P0-T4] Capture baseline extension-folder evidence into `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/scaffold-extension-folder.2026-02-17T00-00.md` by running `powershell -NoProfile -Command "if (Test-Path 'extensions/scaffold-extension') { Write-Output 'present' } else { Write-Output 'missing' }"`.
  - Acceptance: File exists and contains `Timestamp: 2026-02-17T00-00`, `Command: powershell -NoProfile -Command "if (Test-Path 'extensions/scaffold-extension') { Write-Output 'present' } else { Write-Output 'missing' }"`, `Output Summary: missing` or `Output Summary: present`, and `EXIT_CODE: 0`.
- [ ] [P0-T5] Capture baseline TypeScript extension toolchain evidence into `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/typescript-toolchain.2026-02-17T00-00.md` by running `npm --prefix extensions/scaffold-extension run format`, `npm --prefix extensions/scaffold-extension run lint`, `npm --prefix extensions/scaffold-extension run typecheck`, and `npm --prefix extensions/scaffold-extension run test`.
  - Acceptance: File exists with four command blocks; each block includes `Timestamp: 2026-02-17T00-00` (or command-specific ISO-8601 timestamp), exact `Command:`, numeric `EXIT_CODE:`, and non-empty `Output Summary:` lines.
- [ ] [P0-T6] Capture Node.js prerequisite evidence into `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/node-prereq.2026-02-17T00-00.md` by running `node --version` from repository root.
  - Acceptance: File exists and contains `Timestamp: 2026-02-17T00-00` (or command-specific ISO-8601 timestamp), `Command: node --version`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P0-T7] Capture npm prerequisite evidence into `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/npm-prereq.2026-02-17T00-00.md` by running `npm --version` from repository root.
  - Acceptance: File exists and contains `Timestamp: 2026-02-17T00-00` (or command-specific ISO-8601 timestamp), `Command: npm --version`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

### Phase 1 — Extension Bootstrap Skeleton

**Phase Completion Criteria:** Extension folder structure, manifest, TypeScript config, and package scripts exist with deterministic command IDs and compile target; no production command implementation code is added before Phase 2 expect-fail tests.

- [ ] [P1-T1] Create folder tree `extensions/scaffold-extension/{src,resources/templates,resources/scaffold/python,resources/scaffold/powershell,test}`.
  - Acceptance: `powershell -NoProfile -Command "@('extensions/scaffold-extension/src','extensions/scaffold-extension/resources/templates','extensions/scaffold-extension/resources/scaffold/python','extensions/scaffold-extension/resources/scaffold/powershell','extensions/scaffold-extension/test') | ForEach-Object { if (!(Test-Path $_)) { throw \"missing: $_\" } }"` exits with code `0`.
- [ ] [P1-T2] Create `extensions/scaffold-extension/package.json` with exact command contributions for `scaffoldExtension.helloPython` and `scaffoldExtension.helloPowerShell`, `main` set to `./out/extension.js`, and `engines.vscode` set to `^1.90.0`.
  - Acceptance: `poetry run python -c "import json, pathlib; p=pathlib.Path('extensions/scaffold-extension/package.json'); d=json.loads(p.read_text(encoding='utf-8')); assert d['main']=='./out/extension.js'; ids={c['command'] for c in d['contributes']['commands']}; assert 'scaffoldExtension.helloPython' in ids and 'scaffoldExtension.helloPowerShell' in ids; assert d['engines']['vscode']=='^1.90.0'"` exits with code `0`.
- [ ] [P1-T3] Create `extensions/scaffold-extension/tsconfig.json` with compiler options that emit to `out/`, read from `src/`, target `ES2022`, and enforce strict typing.
  - Acceptance: `poetry run python -c "import json, pathlib; d=json.loads(pathlib.Path('extensions/scaffold-extension/tsconfig.json').read_text(encoding='utf-8')); c=d['compilerOptions']; assert c['outDir']=='out'; assert c['rootDir']=='src'; assert c['target']=='ES2022'; assert c['strict'] is True"` exits with code `0`.
- [ ] [P1-T4] Add extension-local npm scripts in `extensions/scaffold-extension/package.json`: `format`, `lint`, `typecheck`, `test`, `compile`.
  - Acceptance: `poetry run python -c "import json, pathlib; s=json.loads(pathlib.Path('extensions/scaffold-extension/package.json').read_text(encoding='utf-8'))['scripts']; req={'format','lint','typecheck','test','compile'}; assert req.issubset(set(s))"` exits with code `0`.

### Phase 2 — TDD Red: Deterministic Failing Regression Tests

**Phase Completion Criteria:** Regression tests for each required function/scenario exist and fail in a controlled way with auditable evidence artifacts under canonical regression-testing location.

- [ ] [P2-T1] [expect-fail] Add test `registers_hello_python_command` for function `activate` in `extensions/scaffold-extension/test/extension.test.ts` that asserts registration of command ID `scaffoldExtension.helloPython`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "registers_hello_python_command"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t1-registers-hello-python.2026-02-17T00-00.md` exists with `Timestamp: 2026-02-17T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [ ] [P2-T2] [expect-fail] Add test `registers_hello_powershell_command` for function `activate` in `extensions/scaffold-extension/test/extension.test.ts` that asserts registration of command ID `scaffoldExtension.helloPowerShell`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "registers_hello_powershell_command"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t2-registers-hello-powershell.2026-02-17T00-00.md` exists with `Timestamp`, `Command`, and non-zero `EXIT_CODE`.
- [ ] [P2-T3] [expect-fail] Add test `detect_runtime_python_missing_returns_error` for function `detectRuntime` in `extensions/scaffold-extension/test/extension.test.ts` with injected process-runner returning command-not-found.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "detect_runtime_python_missing_returns_error"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t3-detect-runtime-python-missing.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T4] [expect-fail] Add test `detect_runtime_powershell_prefers_pwsh_then_fallback` for function `detectRuntime` in `extensions/scaffold-extension/test/extension.test.ts` with two-step probe sequence.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "detect_runtime_powershell_prefers_pwsh_then_fallback"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t4-detect-runtime-powershell-fallback.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T5] [expect-fail] Add test `ensure_workspace_root_throws_when_no_workspace` for function `getWorkspaceRootOrThrow` in `extensions/scaffold-extension/test/extension.test.ts`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_workspace_root_throws_when_no_workspace"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t5-workspace-missing.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T6] [expect-fail] Add test `ensure_scaffolded_scripts_copies_hello_python_when_missing` for function `ensureScaffoldedScripts` in `extensions/scaffold-extension/test/extension.test.ts` using mocked `workspace.fs`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_scripts_copies_hello_python_when_missing"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t6-copy-hello-python.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T7] [expect-fail] Add test `ensure_scaffolded_scripts_does_not_overwrite_existing_hello_pwsh` for function `ensureScaffoldedScripts` in `extensions/scaffold-extension/test/extension.test.ts`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_scripts_does_not_overwrite_existing_hello_pwsh"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t7-no-overwrite-hello-pwsh.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T8] [expect-fail] Add test `ensure_scaffolded_environments_copies_pyproject_and_poetry_toml_when_missing` for function `ensureScaffoldedEnvironments` in `extensions/scaffold-extension/test/extension.test.ts`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_environments_copies_pyproject_and_poetry_toml_when_missing"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t8-copy-python-env-files.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T9] [expect-fail] Add test `ensure_scaffolded_environments_keeps_existing_pyproject_unchanged` for function `ensureScaffoldedEnvironments` in `extensions/scaffold-extension/test/extension.test.ts`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_environments_keeps_existing_pyproject_unchanged"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t9-keep-existing-pyproject.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T10] [expect-fail] Add test `hello_python_command_executes_workspace_script_and_writes_artifact` for function `runHelloPythonCommand` in `extensions/scaffold-extension/test/extension.test.ts` with mocked process executor.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "hello_python_command_executes_workspace_script_and_writes_artifact"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t10-run-hello-python.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T11] [expect-fail] Add test `hello_powershell_command_executes_workspace_script_and_writes_artifact` for function `runHelloPowerShellCommand` in `extensions/scaffold-extension/test/extension.test.ts` with mocked process executor.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "hello_powershell_command_executes_workspace_script_and_writes_artifact"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t11-run-hello-powershell.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T12] [expect-fail] Add test `hello_python_command_surfaces_named_runtime_error` for function `runHelloPythonCommand` in `extensions/scaffold-extension/test/extension.test.ts` when Python runtime is absent.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "hello_python_command_surfaces_named_runtime_error"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t12-python-runtime-error.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T13] [expect-fail] Add test `hello_powershell_command_surfaces_named_runtime_error` for function `runHelloPowerShellCommand` in `extensions/scaffold-extension/test/extension.test.ts` when both `pwsh` and `powershell` runtimes are absent.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "hello_powershell_command_surfaces_named_runtime_error"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t13-powershell-runtime-error.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T14] [expect-fail] Add test `pyproject_template_output_matches_spec_exactly` in `extensions/scaffold-extension/test/extension.test.ts` that compares scaffolded `pyproject.toml` bytes against `spec.md` template snapshot file `extensions/scaffold-extension/resources/scaffold/python/pyproject.toml`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "pyproject_template_output_matches_spec_exactly"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t14-pyproject-exact-match.2026-02-17T00-00.md` exists with required schema.
- [ ] [P2-T15] [expect-fail] Add integration test `end_to_end_creates_hello_artifacts` in `extensions/scaffold-extension/test/extension.integration.test.ts` that executes both commands and asserts `artifacts/hello_python.txt` and `artifacts/hello_pwsh.txt` are created under workspace root.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "end_to_end_creates_hello_artifacts"` fails; artifact `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t15-end-to-end-artifacts.2026-02-17T00-00.md` exists with `Timestamp`, exact `Command`, and non-zero `EXIT_CODE`.

### Phase 3 — Implement Extension Logic to Satisfy Red Tests

**Phase Completion Criteria:** All Phase 2 scenarios pass with implementation code; commands, runtime detection, scaffolding, and logging behavior satisfy REQ/SEC/CON constraints, including explicit `CON-001` import-surface enforcement evidence.

- [ ] [P3-T1] Create `extensions/scaffold-extension/src/extension.ts` with exported function signatures `activate(context: vscode.ExtensionContext)` and `deactivate()` plus typed declarations for `detectRuntime`, `getWorkspaceRootOrThrow`, `ensureScaffoldedScripts`, and `ensureScaffoldedEnvironments` without final command behavior.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/src/extension.ts').read_text(encoding='utf-8'); assert 'export function activate(context: vscode.ExtensionContext)' in t; assert 'export function deactivate()' in t; assert 'function detectRuntime' in t; assert 'function getWorkspaceRootOrThrow' in t"` exits with code `0`.
- [ ] [P3-T2] Implement `createOutputChannel()` helper in `extensions/scaffold-extension/src/extension.ts` returning a singleton OutputChannel named `Scaffold Utils` for REQ-009.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "output channel"` exits with code `0`.
- [ ] [P3-T3] Implement `getWorkspaceRootOrThrow()` in `extensions/scaffold-extension/src/extension.ts` to return first workspace folder fsPath or throw `Error("No workspace folder is open. Open a folder and re-run the command.")` for REQ-006.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_workspace_root_throws_when_no_workspace"` exits with code `0`.
- [ ] [P3-T4] Implement `detectRuntime(kind: 'python' | 'powershell', execProbe)` in `extensions/scaffold-extension/src/extension.ts` that probes `python` for `python`, then `pwsh` and `powershell` in order for `powershell`, returning structured result `{ found: boolean; executable: string; errorMessage?: string }` for REQ-007 and REQ-008.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "detect_runtime_"` exits with code `0`.
- [ ] [P3-T5] Implement `ensureScaffoldedScripts(workspaceRoot: string, extensionUri: vscode.Uri, fsApi)` in `extensions/scaffold-extension/src/extension.ts` to copy `resources/templates/hello_python.py` and `resources/templates/hello_pwsh.ps1` only when destination files are missing for REQ-002, REQ-003, and CON-003.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_scripts_"` exits with code `0`.
- [ ] [P3-T6] Implement `ensureScaffoldedEnvironments(workspaceRoot: string, extensionUri: vscode.Uri, fsApi)` in `extensions/scaffold-extension/src/extension.ts` to copy `resources/scaffold/python/pyproject.toml`, `resources/scaffold/python/poetry.toml`, and `resources/scaffold/powershell/PoshQC.psd1` only when missing for REQ-010 and REQ-012.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_environments_"` exits with code `0`.
- [ ] [P3-T7] Implement `runHelloPythonCommand()` in `extensions/scaffold-extension/src/extension.ts` to call workspace/runtime/scaffold helpers, execute `hello_python.py` with explicit executable/args, and verify `artifacts/hello_python.txt` exists for REQ-004, CON-002, and SEC-001.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "hello_python_command_"` exits with code `0`.
- [ ] [P3-T8] Implement `runHelloPowerShellCommand()` in `extensions/scaffold-extension/src/extension.ts` to call workspace/runtime/scaffold helpers, execute `hello_pwsh.ps1` with explicit executable/args, and verify `artifacts/hello_pwsh.txt` exists for REQ-005, CON-002, and SEC-001.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "hello_powershell_command_"` exits with code `0`.
- [ ] [P3-T9] Register both command handlers in `activate(context)` in `extensions/scaffold-extension/src/extension.ts` and push disposables into `context.subscriptions` for REQ-001.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "registers_hello_"` exits with code `0`.
- [ ] [P3-T10] Implement runtime/process error normalization in `extensions/scaffold-extension/src/extension.ts` so user-visible errors include runtime name and OutputChannel logs include start/end plus sanitized failure details for SEC-002 and REQ-009.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "surfaces_named_runtime_error|error logging"` exits with code `0`.
- [ ] [P3-T11] Enforce `CON-001` by validating extension runtime imports are limited to VS Code API, Node built-ins, and local modules in `extensions/scaffold-extension/src/extension.ts`.
  - Acceptance: `poetry run python -c "import re, pathlib; t=pathlib.Path('extensions/scaffold-extension/src/extension.ts').read_text(encoding='utf-8'); imports=re.findall(r\"^\\s*import\\s+.*?from\\s+['\\\"]([^'\\\"]+)['\\\"]\", t, re.M)+re.findall(r\"^\\s*import\\s+['\\\"]([^'\\\"]+)['\\\"]\", t, re.M); bad=[m for m in imports if not (m=='vscode' or m.startswith('node:') or m.startswith('./') or m.startswith('../'))]; assert not bad, bad"` exits with code `0`.

### Phase 4 — Scaffold Assets and Documentation Completion

**Phase Completion Criteria:** Template scripts and environment scaffold files are present with exact required content; README first-run instructions cover all required platforms and caveats.

- [ ] [P4-T1] Create `extensions/scaffold-extension/resources/templates/hello_python.py` that writes `artifacts/hello_python.txt` with deterministic content `hello_python:ok` when executed from workspace root.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/resources/templates/hello_python.py').read_text(encoding='utf-8'); assert 'artifacts/hello_python.txt' in t; assert 'hello_python:ok' in t"` exits with code `0`.
- [ ] [P4-T2] Create `extensions/scaffold-extension/resources/templates/hello_pwsh.ps1` that writes `artifacts/hello_pwsh.txt` with deterministic content `hello_pwsh:ok` when executed from workspace root.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/resources/templates/hello_pwsh.ps1').read_text(encoding='utf-8'); assert 'artifacts/hello_pwsh.txt' in t; assert 'hello_pwsh:ok' in t"` exits with code `0`.
- [ ] [P4-T3] Create `extensions/scaffold-extension/resources/scaffold/python/pyproject.toml` with exact byte-for-byte content defined in `docs/features/active/2026-01-28-scaffold-extension-16/spec.md` section `Python Scaffold Template (pyproject.toml)` for REQ-011.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --grep "pyproject_template_output_matches_spec_exactly"` exits with code `0`.
- [ ] [P4-T4] Create `extensions/scaffold-extension/resources/scaffold/python/poetry.toml` with deterministic local virtualenv settings: `[virtualenvs]`, `create = true`, `in-project = true`.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/resources/scaffold/python/poetry.toml').read_text(encoding='utf-8'); assert '[virtualenvs]' in t; assert 'create = true' in t; assert 'in-project = true' in t"` exits with code `0`.
- [ ] [P4-T5] Create `extensions/scaffold-extension/resources/scaffold/powershell/PoshQC.psd1` with deterministic module metadata required to bootstrap PoshQC checks.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/resources/scaffold/powershell/PoshQC.psd1').read_text(encoding='utf-8'); assert 'RootModule' in t; assert 'ModuleVersion' in t"` exits with code `0`.
- [ ] [P4-T6] Update `extensions/scaffold-extension/README.md` with sections `Prerequisites`, `First Run`, and `Platform Notes` including exact command IDs `scaffoldExtension.helloPython` and `scaffoldExtension.helloPowerShell` for REQ-013.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert '## Prerequisites' in t; assert '## First Run' in t; assert '## Platform Notes' in t; assert 'scaffoldExtension.helloPython' in t; assert 'scaffoldExtension.helloPowerShell' in t"` exits with code `0`.

### Phase 5 — Final QA and Delivery Evidence

**Phase Completion Criteria:** Full toolchain loop passes cleanly for extension TypeScript scope, repository Python scope, and repository PowerShell scope (format/lint/test); final QA evidence file captures commands, exit codes, and summaries for each gate.

- [ ] [P5-T1] Run extension-local formatting gate from `extensions/scaffold-extension` using `npm run format`; if files change, re-run Phase 5 from P5-T1 (depends on [P0-T6], [P0-T7]).
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/extension-toolchain.2026-02-17T00-00.md` contains a command block with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run format`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P5-T2] Run extension-local linting gate from `extensions/scaffold-extension` using `npm run lint`; if lint fails or auto-fixes, re-run Phase 5 from P5-T1 (depends on [P0-T6], [P0-T7]).
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/extension-toolchain.2026-02-17T00-00.md` contains a command block with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run lint`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P5-T3] Run extension-local typecheck gate from `extensions/scaffold-extension` using `npm run typecheck`; if failures occur, fix and re-run Phase 5 from P5-T1 (depends on [P0-T6], [P0-T7]).
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/extension-toolchain.2026-02-17T00-00.md` contains a command block with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run typecheck`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P5-T4] Run extension-local tests from `extensions/scaffold-extension` using `npm run test`; if failures occur, fix and re-run Phase 5 from P5-T1 (depends on [P0-T6], [P0-T7]).
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/extension-toolchain.2026-02-17T00-00.md` contains a command block with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run test`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P5-T5] Run repository Python gates in order `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest -q`; if any command fails, fix and re-run Phase 5 from P5-T1.
  - Acceptance: QA evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/repo-python-toolchain.2026-02-17T00-00.md` contains four command entries, each with `Timestamp:`, exact `Command:`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P5-T6] Run repository PowerShell quality gates in order `poetry run shell-qc-format`, `poetry run shell-qc-check`, and `poetry run shell-qc-test`; if any command fails, fix and re-run Phase 5 from P5-T1.
  - Acceptance: QA evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/repo-powershell-toolchain.2026-02-17T00-00.md` contains three command entries, each with `Timestamp:`, exact `Command:`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [ ] [P5-T7] Generate delivery summary `docs/features/active/2026-01-28-scaffold-extension-16/evidence/other/delivery-summary.2026-02-17T00-00.md` mapping each `REQ-*`, `SEC-*`, and `CON-*` item to passing test names and QA artifacts.
  - Acceptance: Summary file exists and has one row per ID from the Requirements Traceability table with non-empty `Evidence` column values.

## Test Plan

| Scope | Scenario ID | Function / Command | Test File | Command | Expected Result |
| --- | --- | --- | --- | --- | --- |
| Unit | TS-UNIT-001 | `activate` registers `scaffoldExtension.helloPython` | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "registers_hello_python_command"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-002 | `activate` registers `scaffoldExtension.helloPowerShell` | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "registers_hello_powershell_command"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-003 | `detectRuntime('python')` missing-runtime behavior | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "detect_runtime_python_missing_returns_error"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-004 | `detectRuntime('powershell')` fallback order | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "detect_runtime_powershell_prefers_pwsh_then_fallback"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-005 | `getWorkspaceRootOrThrow` no-workspace error | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_workspace_root_throws_when_no_workspace"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-006 | `ensureScaffoldedScripts` copy and no-overwrite behavior | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_scripts_"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-007 | `ensureScaffoldedEnvironments` copy and no-overwrite behavior | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "ensure_scaffolded_environments_"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-008 | `runHelloPythonCommand` success and runtime-error behavior | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "hello_python_command_"` | Exit code `0` after Phase 3 |
| Unit | TS-UNIT-009 | `runHelloPowerShellCommand` success and runtime-error behavior | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "hello_powershell_command_"` | Exit code `0` after Phase 3 |
| Integration | TS-INT-001 | End-to-end command run creates both artifacts | `extensions/scaffold-extension/test/extension.integration.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "end_to_end_creates_hello_artifacts"` | Exit code `0` during Phase 5 |
| Config | CFG-001 | `pyproject.toml` exact template parity | `extensions/scaffold-extension/test/extension.test.ts` | `npm --prefix extensions/scaffold-extension run test -- --grep "pyproject_template_output_matches_spec_exactly"` | Exit code `0` during Phase 4/5 |

## Open Questions / Notes

- No open questions remain for implementation start.
- If either [P0-T6] or [P0-T7] fails, stop execution and record blocking evidence before any npm-dependent task proceeds.
