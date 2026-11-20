---
issue: 16
parent: none
owner: drmoisan
last_updated: 2026-03-01T00-00
status: Planned
status_color: blue
version: 1.1
work_mode: full
---

# 2026-01-28-scaffold-extension — Plan

- **Issue:** #16
- **Last Updated:** 2026-03-01T00-00
- **Status:** Planned
- **Work Mode Resolution:** `full` (resolved by fail-closed policy because `issue.md` has no `- Work Mode:` marker)

**Status Badge:** ![Status: Planned (blue)](https://img.shields.io/badge/status-Planned-blue)

## Scope Lock

This plan implements the extension-side bundled-script execution pattern defined in `spec.md` and `user-story.md`:

- Keep command IDs exactly `drmCopilotExtension.helloPython` and `drmCopilotExtension.helloPowerShell`.
- Execute bundled scripts from extension resources.
- Preserve invariant: no copying `hello_python.py` or `hello_pwsh.ps1` into workspace root.
- Preserve explicit runtime detection with clear runtime-named errors.
- Preserve `Scaffold Utils` output channel logging.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Inputs

**Phase Completion Criteria:** Required policy/order inputs are logged; baseline evidence files exist under canonical `evidence/baseline/` with machine-checkable schema (`Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`).

- [x] [P0-T1] Record policy-read order evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/policy-read.2026-03-01T00-00.md` for these files in exact order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`.
  - Acceptance: evidence file exists and contains one checked line per required file plus exact fields `Timestamp: 2026-03-01T00-00`, `Command: policy-read verification`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [x] [P0-T2] Capture baseline TypeScript extension toolchain evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/typescript-toolchain.2026-03-01T00-00.md` by running `npm --prefix extensions/scaffold-extension run format`, `npm --prefix extensions/scaffold-extension run lint`, `npm --prefix extensions/scaffold-extension run typecheck`, and `npm --prefix extensions/scaffold-extension run test`.
  - Acceptance: evidence file exists with four command blocks and each block contains `Timestamp:`, exact `Command:`, integer `EXIT_CODE:`, and non-empty `Output Summary:`.
- [x] [P0-T3] Capture baseline Python toolchain evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/python-toolchain.2026-03-01T00-00.md` by running `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: evidence file exists with four command blocks and each block contains `Timestamp:`, exact `Command:`, integer `EXIT_CODE:`, and non-empty `Output Summary:`.
- [x] [P0-T4] Capture baseline PowerShell toolchain evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/powershell-toolchain.2026-03-01T00-00.md` by running `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`.
  - Acceptance: evidence file exists with three command blocks and each block contains `Timestamp:`, exact `Command:`, integer `EXIT_CODE:`, and non-empty `Output Summary:`.
- [x] [P0-T5] Capture extension-presence baseline in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/extension-path.2026-03-01T00-00.md` using `pwsh -NoLogo -NoProfile -Command "if (Test-Path 'extensions/scaffold-extension') { 'present' } else { 'missing' }"`.
  - Acceptance: evidence file exists and contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary: present` or `Output Summary: missing`.

### Phase 1 — Extension Skeleton and Execution Wiring

**Phase Completion Criteria:** Extension scaffold compiles; command contributions are registered; execution helpers target extension resources and workspace context without copy behavior.

- [x] [P1-T1] Create folder structure `extensions/scaffold-extension/src`, `extensions/scaffold-extension/resources/templates`, and `extensions/scaffold-extension/test`.
  - Acceptance: `pwsh -NoLogo -NoProfile -Command "@('extensions/scaffold-extension/src','extensions/scaffold-extension/resources/templates','extensions/scaffold-extension/test') | ForEach-Object { if (!(Test-Path $_)) { throw \"missing: $_\" } }"` exits with `EXIT_CODE: 0`.
- [x] [P1-T2] Create `extensions/scaffold-extension/package.json` with command contributions for `drmCopilotExtension.helloPython` and `drmCopilotExtension.helloPowerShell` and `main` value `./out/extension.js`.
  - Acceptance: `poetry run python -c "import json, pathlib; d=json.loads(pathlib.Path('extensions/scaffold-extension/package.json').read_text(encoding='utf-8')); ids={c['command'] for c in d['contributes']['commands']}; assert 'drmCopilotExtension.helloPython' in ids; assert 'drmCopilotExtension.helloPowerShell' in ids; assert d['main']=='./out/extension.js'"` exits with `EXIT_CODE: 0`.
- [x] [P1-T3] Create `extensions/scaffold-extension/tsconfig.json` with strict TypeScript settings and output to `out/` from `src/`.
  - Acceptance: `poetry run python -c "import json, pathlib; d=json.loads(pathlib.Path('extensions/scaffold-extension/tsconfig.json').read_text(encoding='utf-8')); c=d['compilerOptions']; assert c['strict'] is True; assert c['outDir']=='out'; assert c['rootDir']=='src'"` exits with `EXIT_CODE: 0`.
- [x] [P1-T4] Create `extensions/scaffold-extension/src/extension.ts` exporting command handlers that resolve workspace root, detect runtime (`python`; `pwsh` then `powershell`), resolve bundled script path via extension URI, execute with explicit executable+args, and log lifecycle to output channel `Scaffold Utils`.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/src/extension.ts').read_text(encoding='utf-8'); assert 'drmCopilotExtension.helloPython' in t; assert 'drmCopilotExtension.helloPowerShell' in t; assert 'Scaffold Utils' in t; assert 'pwsh' in t and 'powershell' in t"` exits with `EXIT_CODE: 0`.
- [x] [P1-T5] Create bundled Python script `extensions/scaffold-extension/resources/templates/hello_python.py` that writes deterministic marker `hello_python:ok` to `artifacts/hello_python.txt`.
  - Acceptance: `poetry run python -c "from pathlib import Path; py=Path('extensions/scaffold-extension/resources/templates/hello_python.py').read_text(encoding='utf-8'); assert 'artifacts/hello_python.txt' in py; assert 'hello_python:ok' in py"` exits with `EXIT_CODE: 0`.
- [x] [P1-T6] Create bundled PowerShell script `extensions/scaffold-extension/resources/templates/hello_pwsh.ps1` that writes deterministic marker `hello_pwsh:ok` to `artifacts/hello_pwsh.txt`.
  - Acceptance: `poetry run python -c "from pathlib import Path; ps=Path('extensions/scaffold-extension/resources/templates/hello_pwsh.ps1').read_text(encoding='utf-8'); assert 'artifacts/hello_pwsh.txt' in ps; assert 'hello_pwsh:ok' in ps"` exits with `EXIT_CODE: 0`.

### Phase 2 — TDD Red Regression Scenarios

**Phase Completion Criteria:** Each required scenario has an explicit failing regression test task with auditable expect-fail evidence under canonical `evidence/regression-testing/`.

- [x] [P2-T1] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `activate registers drmCopilotExtension.helloPython`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "activate registers drmCopilotExtension.helloPython"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t1.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P2-T2] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `activate registers drmCopilotExtension.helloPowerShell`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "activate registers drmCopilotExtension.helloPowerShell"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t2.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P2-T3] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `detectRuntime prefers pwsh then powershell`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "detectRuntime prefers pwsh then powershell"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t3.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P2-T4] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `detectRuntime returns named Python error when python missing`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "detectRuntime returns named Python error when python missing"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t4.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P2-T5] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `helloPython uses bundled extension script path`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "helloPython uses bundled extension script path"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t5.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P2-T6] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `helloPowerShell uses bundled extension script path`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "helloPowerShell uses bundled extension script path"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t6.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P2-T7] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `hello commands do not copy hello scripts into workspace root`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "hello commands do not copy hello scripts into workspace root"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t7.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.
- [x] [P2-T8] [expect-fail] Add Jest test in `extensions/scaffold-extension/test/extension.test.ts` for `handlers log runtime probe start success failure to Scaffold Utils output channel`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "handlers log runtime probe start success failure to Scaffold Utils output channel"` fails and evidence file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/regression-testing/p2-t8.2026-03-01T00-00.md` contains `Timestamp: 2026-03-01T00-00`, exact `Command:`, and non-zero `EXIT_CODE:`.

### Phase 3 — Implement to Green

**Phase Completion Criteria:** All regression scenarios from Phase 2 pass; command behavior matches spec/user-story objective and invariants.

- [x] [P3-T1] Implement command registration in `extensions/scaffold-extension/src/extension.ts` so both command IDs are registered and disposed through `context.subscriptions`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "activate registers drmCopilotExtension.hello"` exits with `EXIT_CODE: 0`.
- [x] [P3-T2] Implement workspace guard in `extensions/scaffold-extension/src/extension.ts` that throws clear no-workspace error before runtime probing.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "no workspace"` exits with `EXIT_CODE: 0` and output contains `No workspace`.
- [x] [P3-T3] Implement Python runtime probe in `extensions/scaffold-extension/src/extension.ts` that checks `python` explicitly and emits runtime-named failure.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "Python error when python missing"` exits with `EXIT_CODE: 0`.
- [x] [P3-T4] Implement PowerShell runtime probe in `extensions/scaffold-extension/src/extension.ts` that probes `pwsh` first and `powershell` second.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "prefers pwsh then powershell"` exits with `EXIT_CODE: 0`.
- [x] [P3-T5] Implement bundled script path resolution in `extensions/scaffold-extension/src/extension.ts` using extension URI path joining instead of workspace-relative script file lookup.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "uses bundled extension script path"` exits with `EXIT_CODE: 0`.
- [x] [P3-T6] Implement subprocess execution in `extensions/scaffold-extension/src/extension.ts` with explicit executable and argument arrays for both runtimes.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "explicit executable"` exits with `EXIT_CODE: 0`.
- [x] [P3-T7] Implement no-copy invariant in `extensions/scaffold-extension/src/extension.ts` by removing any workspace-root script materialization path for hello scripts.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "do not copy hello scripts into workspace root"` exits with `EXIT_CODE: 0`.
- [x] [P3-T8] Implement output channel lifecycle logging in `extensions/scaffold-extension/src/extension.ts` for runtime detection, resolved script path, command start, command success, and command failure.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "Scaffold Utils output channel"` exits with `EXIT_CODE: 0`.

### Phase 4 — Integration, Security, and Documentation

**Phase Completion Criteria:** End-to-end command behavior is verified for artifacts and no-copy invariant; docs are updated to match new execution model.

- [x] [P4-T1] Add integration test in `extensions/scaffold-extension/test/extension.integration.test.ts` for `helloPython produces artifacts/hello_python.txt using bundled script execution`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "helloPython produces artifacts/hello_python.txt"` exits with `EXIT_CODE: 0`.
- [x] [P4-T2] Add integration test in `extensions/scaffold-extension/test/extension.integration.test.ts` for `helloPowerShell produces artifacts/hello_pwsh.txt using bundled script execution`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "helloPowerShell produces artifacts/hello_pwsh.txt"` exits with `EXIT_CODE: 0`.
- [x] [P4-T3] Add integration test in `extensions/scaffold-extension/test/extension.integration.test.ts` for `execution leaves no hello_python.py or hello_pwsh.ps1 in workspace root`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "leaves no hello_python.py or hello_pwsh.ps1 in workspace root"` exits with `EXIT_CODE: 0`.
- [x] [P4-T4] Add security-focused unit test in `extensions/scaffold-extension/test/extension.test.ts` for `subprocess calls use argv arrays and never shell-concatenated command strings`.
  - Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "argv arrays and never shell-concatenated"` exits with `EXIT_CODE: 0`.
- [x] [P4-T5] Update `extensions/scaffold-extension/README.md` with required runtime names, command IDs, output channel behavior, and explicit no-copy invariant statement.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert 'drmCopilotExtension.helloPython' in t; assert 'drmCopilotExtension.helloPowerShell' in t; assert 'Scaffold Utils' in t; assert 'no workspace-root script copying' in t"` exits with `EXIT_CODE: 0`.

### Phase 5 — Final QA Toolchain Loop

**Phase Completion Criteria:** Final QA evidence under `evidence/qa-gates/` proves clean toolchain passes for each applicable language scope in one pass.

- [x] [P5-T1] Run TypeScript format gate with `npm --prefix extensions/scaffold-extension run format` and record evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/typescript-toolchain.2026-03-01T00-00.md`.
  - Acceptance: evidence file contains a command block with exact `Command: npm --prefix extensions/scaffold-extension run format`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [x] [P5-T2] Run TypeScript lint gate with `npm --prefix extensions/scaffold-extension run lint`; if it changes files or fails, restart Phase 5 from [P5-T1].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/typescript-toolchain.2026-03-01T00-00.md` contains exact `Command: npm --prefix extensions/scaffold-extension run lint` with `EXIT_CODE: 0`.
- [x] [P5-T3] Run TypeScript typecheck gate with `npm --prefix extensions/scaffold-extension run typecheck`; if it fails, restart Phase 5 from [P5-T1].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/typescript-toolchain.2026-03-01T00-00.md` contains exact `Command: npm --prefix extensions/scaffold-extension run typecheck` with `EXIT_CODE: 0`.
- [x] [P5-T4] Run TypeScript test gate with `npm --prefix extensions/scaffold-extension run test`; if it fails, restart Phase 5 from [P5-T1].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/typescript-toolchain.2026-03-01T00-00.md` contains exact `Command: npm --prefix extensions/scaffold-extension run test` with `EXIT_CODE: 0`.
- [x] [P5-T5] Run Python format gate with `poetry run black .` and append results to `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/python-toolchain.2026-03-01T00-00.md`.
  - Acceptance: evidence file contains exact `Command: poetry run black .` with `EXIT_CODE: 0` and non-empty `Output Summary:`.
- [x] [P5-T6] Run Python lint gate with `poetry run ruff check`; if it fails or fixes output, restart Phase 5 from [P5-T5].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/python-toolchain.2026-03-01T00-00.md` contains exact `Command: poetry run ruff check` with `EXIT_CODE: 0`.
- [x] [P5-T7] Run Python typecheck gate with `poetry run pyright`; if it fails, restart Phase 5 from [P5-T5].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/python-toolchain.2026-03-01T00-00.md` contains exact `Command: poetry run pyright` with `EXIT_CODE: 0`.
- [x] [P5-T8] Run Python test gate with `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`; if it fails, restart Phase 5 from [P5-T5].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/python-toolchain.2026-03-01T00-00.md` contains exact `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` with `EXIT_CODE: 0`.
- [x] [P5-T9] Run PowerShell format gate with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and append results to `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/powershell-toolchain.2026-03-01T00-00.md`.
  - Acceptance: evidence file contains exact `Command:` with `Invoke-PoshQCFormat -Root .`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [x] [P5-T10] Run PowerShell lint gate with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`; if it fails, restart Phase 5 from [P5-T9].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/powershell-toolchain.2026-03-01T00-00.md` contains exact `Command:` with `Invoke-PoshQCAnalyze -Root .` and `EXIT_CODE: 0`.
- [x] [P5-T11] Run PowerShell test gate with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`; if it fails, restart Phase 5 from [P5-T9].
  - Acceptance: `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/powershell-toolchain.2026-03-01T00-00.md` contains exact `Command:` with `Invoke-PoshQCTest -Root .` and `EXIT_CODE: 0`.

## Preflight Handoff Contract

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

Required preflight result signals:
- `PREFLIGHT: ALL CLEAR`
- `PREFLIGHT: REVISIONS REQUIRED`
