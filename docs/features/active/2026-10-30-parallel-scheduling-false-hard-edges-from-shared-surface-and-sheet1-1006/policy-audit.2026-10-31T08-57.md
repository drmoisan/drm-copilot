# Policy Compliance Audit: parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (Issue #1006)

**Audit Date:** 2026-10-31
**Base Branch:** `main` (merge base `1898400756e909b88cde5f51a05f0b11d423d3b0`, equal to `origin/main`)
**Head Branch:** `bug/parallel-scheduling-false-hard-edges-1006` @ `fc1d8618bf26e9e2ffa2e81dec5e1380ec2763f8`
**Scope:** full branch diff against the merge base (82 files, +3573/-73), per `artifacts/pr_context.summary.txt` (generated 2026-10-31 08:53:30 UTC at the head SHA above) and `git diff --stat 1898400756e909b88cde5f51a05f0b11d423d3b0...HEAD`.
**Code Under Test:**

- Python production: `scripts/dev_tools/_blast_radius_token_shapes.py`, `scripts/dev_tools/_blast_radius_extraction.py`, `scripts/dev_tools/_blast_radius_write_intent.py`, `scripts/dev_tools/compute_blast_radius.py`, `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`
- PowerShell production: `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`, `BlastRadiusExtraction.psm1`, `BlastRadiusNormalization.psm1`, `BlastRadiusWriteIntent.psm1`, `BlastRadius.psm1`, and their five byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`
- TypeScript production: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` (modified), `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` (new), `extensions/drm-copilot/jest.config.cjs` (config)
- JSON configuration: `config/blast-radius.json`, `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`, three new corpus fixtures under `tests/fixtures/blast_radius_overlay/`
- Markdown rule: `.claude/rules/parallel-orchestration.md` and its bundle copy
- Tests: 6 Python test files (2 new), 4 Pester files (1 new), 3 TypeScript test files (1 new)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 5 production, 8 test | 8334 passed, 6 skipped (tests/scripts/dev_tools) | PASS: 8334 pass, 0 fail | Changed files: 98.0% to 100% line, 95.24% to 100% branch | Changed files: 98.0% to 100% line, 95.24% to 100% branch | 100% of changed lines |
| PowerShell | 10 production (5 plus 5 bundle copies), 4 test | 13541 tests, 10 skipped | PASS: 0 failures, 0 errors | Changed files: 100% line each | Changed files: 100% line each; repo-wide 93.53% line (20880/22324) | 100% of changed lines |
| TypeScript | 2 production, 1 config, 3 test | 5257 tests, 324 suites | PASS: 5257 pass, 0 fail | `claude-blast-radius-overlay.ts` 99.55% line, 95.87% branch | `claude-blast-radius-overlay.ts` 99.56% line, 96.15% branch; demote module 100%/100% | 100% (per Jest text report; no lcov artifact) |
| JSON | 5 files | Parity and truth-table tests | PASS | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/baseline/typescript.2026-10-31T08-06.md` (Jest text output transcribed; no `lcov.info` file)
- TypeScript post-change coverage artifact: absent. Neither `coverage/lcov.info` nor `extensions/drm-copilot/coverage/lcov.info` exists in the worktree; the recorded run used `--coverageReporters=text` (`evidence/qa-gates/ts-jest.2026-10-31T08-36.md`).
- PowerShell baseline coverage artifact: `evidence/baseline/pester-full.2026-10-31T08-22.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, fresh full run over `tests/scripts`)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (scoped to the five changed modules only)
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-10-31T08-49.md` and Section 1.2.1 below

---

## Executive Summary

The branch fixes two false hard scheduling edges. It adds a generic sheet-tab contract predicate (`Sheet`/`Chart` plus ASCII digits) at all six contract-filtering sites in Python and PowerShell. It moves `quality-tiers.yml` from `shared_surfaces` to `conflict_tolerance.append_only_paths` in both committed truth tables. It also adds a `shared_surfaces_demote` overlay directive to the Python and TypeScript overlay composers. The implementation is small and well-placed in leaf modules. It keeps the frozen scheduling surfaces unchanged and is backed by fail-before evidence, cross-runtime parity tests, and isolation checks.

**Policy documents evaluated:**

- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md` (coverage evidence gaps recorded in Section 8)
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; touched projects are classified: `scripts/dev_tools` T4, `.claude/lib/blast-radius` T3, `extensions/drm-copilot` T3; no T1/T2 property-test or mutation obligation applies)

**Language-specific policies evaluated:**

- PASS `.claude/rules/python.md` and `.claude/rules/python-suppressions.md`
- PASS `.claude/rules/powershell.md`
- PASS `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md` (implementation); coverage artifact gap recorded separately
- N/A C#: no C# files changed
- N/A Bash: no `.sh` or `.bats` files changed

Toolchain results recorded under `evidence/qa-gates/` all report `EXIT_CODE: 0`. The audit records one autonomous blocking finding: the TypeScript coverage artifact is absent. It also records one blocking finding that waits on CI: the repo-wide Python coverage figure cannot be read from the scoped local artifact.

**Temporary artifacts cleanup:**

- PASS: no temporary or one-time scripts are committed; the executor's helper scripts live in the session scratchpad (`SCRATCH/issue-1006-*.sh`), and `git status --porcelain` is empty.
- PASS: no new ongoing tooling script was added.

---

## Rejected Scope Narrowing

None detected. The caller prompt specified the full branch against `main` with merge base `1898400756e909b88cde5f51a05f0b11d423d3b0` and did not narrow scope to a plan, phase, or file subset.

---

## Evidence Location Compliance

- Command: `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` returned `EXIT_CODE=0`.
- `git diff --name-only 1898400756e909b88cde5f51a05f0b11d423d3b0...HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (grep for `^artifacts/` returned no match).
- All feature evidence lives under `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Verdict: PASS. No violation found.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Seeded Jest shuffle (`--randomize --seed=1006`, 5257 passed), reversed-order pytest over 8 files (214 passed), and three seeded Pester file-order shuffles (172 passed each) in `evidence/regression-testing/isolation.2026-10-31T08-39.md`. |
| **Isolation** | PASS | Each new test targets one predicate row, one filtering site, one demotion rule, or one scenario (for example `test_extract_write_intent_contracts_drops_a_generic_token`, `test_unknown_entry_is_rejected`). |
| **Fast Execution** | PASS | `tests/scripts/dev_tools` 8334 tests in 51.96 s; new generic-contract pytest file ran in 0.14 s at fail-before. |
| **Determinism** | PASS | Fixed `COMPUTED_AT` constant, in-memory file systems (`RecordingFileSystem`, `MemoryFile`), no clock, RNG, or network use in new tests. |
| **Readability & Maintainability** | PASS | Descriptive names, docstrings on every Python test, explicit Arrange/Act/Assert comments in `test_blast_radius_generic_contracts.py`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `evidence/baseline/python-tests.2026-10-31T08-04.md`, `evidence/baseline/pester-full.2026-10-31T08-22.md`, `evidence/baseline/typescript.2026-10-31T08-06.md`. |
| **No Coverage Regression** | PASS | Every changed file holds or improves line and branch coverage (`evidence/qa-gates/coverage-comparison.2026-10-31T08-49.md`); the only uncovered lines (`_blast_radius_write_intent.py` 349 and 355; `claude-blast-radius-overlay.ts` 371-372) are pre-existing and not changed lines. |
| **Changed and new file thresholds (85% line, 75% branch)** | PASS | Python per-file figures verified directly in `artifacts/python/lcov.info` (LF/LH and BRF/BRH). PowerShell per-file LINE counters verified directly in `artifacts/pester/powershell-coverage.xml` (all 100%). TypeScript per-file figures come from the Jest text report; the per-file `coverageThreshold` entries for both files (85/75) would fail the `--coverage` run, and that run exited 0. |
| **Repo-wide thresholds** | FAIL | PowerShell repo-wide 93.53% line (PASS). Python: `artifacts/python/lcov.info` covers only the five changed modules, so the artifact cannot give a repo-wide figure (finding PA-2). TypeScript: no coverage artifact exists, so the artifact cannot give a repo-wide figure (finding PA-1). |
| **Comprehensive Coverage** | PASS | Every new symbol is tested: `is_generic_contract_token` (13 rows), `Test-GenericContractToken` (13 rows plus parity and export rows), `_apply_shared_surface_demotion` / `applySharedSurfaceDemotion` (move, consume, ordering, no-op, idempotence, absent-key, non-mutation, four rejection paths, guard, push-down). |
| **Positive Flows** | PASS | `test_generic_contract_token_is_recognized[Sheet1/sheet12/CHART3]`, `test_demotion_moves_the_entry_and_keeps_the_remaining_order`, `test_ac04_push_demotes_quality_tiers_with_tolerance_5000`. |
| **Negative Flows** | PASS | `test_non_generic_token_is_rejected` (10 rows), `test_malformed_directive_is_rejected` (2 rows), `test_missing_append_only_paths_is_rejected` (2 rows), `test_unknown_entry_is_rejected`. |
| **Edge Cases** | PASS | Empty string, full-width digit, Kelvin sign, long s, `Sheet1.Range`, document without `shared_surfaces`, already-append-only entry. |
| **Error Handling** | PASS | Full error text asserted in both runtimes; `test_rejection_keeps_the_prior_destination_bytes` and the TS equivalent prove prior bytes are preserved. |
| **Concurrency** | N/A | Pure functions and single-threaded composition; no concurrent behavior introduced. |
| **State Transitions** | N/A | No stateful component introduced; idempotence of repeated composition is tested. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: changed modules 97.98% to 100% line, 95.24% to 100% branch -> Post-change: 98.00% to 100% line, 95.24% to 100% branch. Change: +0.02% line on `_blast_radius_write_intent.py`, 0 elsewhere. New/changed-code coverage: 100%. Repo-wide: not derivable from the scoped artifact (PA-2). Disposition: FAIL (repo-wide figure absent; changed-file figures PASS). Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-tests.2026-10-31T08-34.md`.
- PowerShell: Baseline: 100% line for each of the five changed modules -> Post-change: 100% line for each (39/39, 80/80, 52/52, 103/103, 108/108). Repo-wide post-change 93.53% line (20880 covered, 1444 missed). Change: 0. New/changed-code coverage: 100%. Disposition: PASS. Branch threshold not applicable (Pester measures no branch coverage). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester-full.2026-10-31T08-49.md`.
- TypeScript: Baseline: `claude-blast-radius-overlay.ts` 99.55% line, 95.87% branch -> Post-change: 99.56% line, 96.15% branch; `claude-blast-radius-overlay-demote.ts` 100% line, 100% branch. Change: +0.01% line, +0.28% branch. New/changed-code coverage: 100%. Repo-wide: not recorded. Disposition: FAIL (coverage artifact absent; PA-1). Evidence: `evidence/qa-gates/ts-jest.2026-10-31T08-36.md` (text transcription only).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions carry messages, for example `f"Hard edges with reason kinds: {hard_reasons}."` and `f"{token!r} must be recognized as a generic token."`. |
| **Arrange-Act-Assert Pattern** | PASS | Explicit `# Arrange`, `# Act`, `# Assert` comments in the generic-contract tests; demotion tests follow the same structure. |
| **Document Intent** | PASS | Module docstrings state the issue scenario and fail-before design; every test function has a one-line docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, subprocess, or database use in the new tests. The committed truth tables are read as text. |
| **Use Mocks/Stubs** | PASS | In-memory `RecordingFileSystem` and an injected empty directory lister drive the push-down; `DestinationMergeFileSystem` wraps the in-memory file system. |
| **Environment Stability** | PASS | A grep for `tmp_path`, `tempfile`, `TemporaryFile`, `TestDrive`, `tmpdir`, `mkdtemp`, `writeFileSync`, `Set-Content`, and `Out-File` over the four new test files returned no match. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, with `code-review.2026-10-31T08-57.md` and `feature-audit.2026-10-31T08-57.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (#1006), `spec.md` (full-bug, 25 AC), `research/research.2026-10-30T11-05.md`. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-10-31T08-00.md`. |
| **Document the plan** | PASS | `plan.2026-10-30T06-58.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One anchored regex predicate per runtime; demotion is a single post-composition pass. |
| **Reusability** | PASS | The Python demotion reuses `_as_string_list`, `_as_object`, and `_union_strings`. The TypeScript demotion re-implements the union loop instead of reusing `unionStrings` (code-review Minor; semantics are equivalent). |
| **Extensibility** | PASS | The stem set is a single closed constant; the directive is isolated in its own key and module. |
| **Separation of concerns** | PASS | The predicate is in the token-shape leaf modules. The demotion is a pure function in a new TypeScript module, and the composer only dispatches to it. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | New TS module holds only the demotion directive; new predicate sits with sibling token-shape predicates. |
| **At or below the 800-line hard limit** | PASS | Largest covered file `extensions/drm-copilot/jest.config.cjs` 540 lines; largest Python 478 (`compute_blast_radius.py`); largest PowerShell 479 (`BlastRadius.psm1`); largest new file 320. No covered file is at or above 700 lines, so no Warning applies. `config/file-size-baseline.json` is not in the diff. Source: `evidence/qa-gates/line-counts.2026-10-31T08-40.md`. The rule Markdown (727 lines) is exempt. |
| **Public vs internal** | PASS | Python adds `SHARED_SURFACES_DEMOTE_KEY` to `__all__`; helper constants are underscore-prefixed. TS exports only the key, the result type, and `applySharedSurfaceDemotion`. |
| **No circular dependencies** | PASS | `claude-blast-radius-overlay-demote.ts` imports nothing from the overlay module; Python write-intent imports only leaf modules (docstring updated). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `is_generic_contract_token`, `Test-GenericContractToken`, `applySharedSurfaceDemotion`, `GENERIC_CONTRACT_STEMS`. |
| **Docs/docstrings** | PASS | Google-style docstrings with Args/Returns/Raises in Python; comment-based help in PowerShell; TSDoc in TypeScript. |
| **Comment why, not what** | PASS | Comments explain the ASCII guard (Kelvin sign, long s folding under .NET) and why the directive is consumed. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Black `--check` exit 0; Invoke-Formatter exit 0; Prettier `--check` exit 0 (`evidence/qa-gates/python-black…`, `ps-format…`, `ts-prettier…`). |
| **2. Linting** | PASS | Ruff exit 0; PSScriptAnalyzer exit 0; `npm run lint` exit 0. |
| **3. Type checking** | PASS | Pyright exit 0; `npm run typecheck` exit 0; N/A for PowerShell. |
| **4. Architecture-boundary tests** | PASS | No new cross-module import edge; the existing suites ran inside the full Jest and pytest runs. Mapping is in `evidence/qa-gates/seven-stage-mapping.2026-10-31T08-37.md`. |
| **5. Unit tests** | PASS | pytest 8334 passed; Pester 13541 with 0 failures; Jest 5257 passed. |
| **6. Contract / schema checks** | PASS | Push-down contract tests and Codex generator `--check` exit 0 (`push-down-contracts…`, `codex-generator-check…`). |
| **7. Integration tests** | PASS | In-memory push-down tests in both runtimes (AC-04). |
| **Full toolchain loop** | PASS | `seven-stage-mapping.2026-10-31T08-37.md` records a single clean pass after the Python loop was restarted once for an added branch test. |
| **Explicit reporting** | PASS | Every command, exit code, and summary is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Five scoped commits (`4be50e8f7`, `963dc4f1f`, `537905f0d`, `9a40db5c5`, `fc1d8618b`). |
| **Design choices explained** | PASS | Spec "Proposed Fix" and the rule subsection "Generic contract-token rejection (issue #1006)". |
| **Update supporting documents** | PASS | `.claude/rules/parallel-orchestration.md` and its bundle copy are byte-identical (`cmp` returned identical). |
| **Provide next steps** | PASS | `evidence/other/follow-ups.2026-10-31T08-43.md` records the stale "three token shapes" sentence in `.claude/skills/parallel-plan/SKILL.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `evidence/qa-gates/python-black.2026-10-31T08-34.md`, exit 0. |
| **Linting with Ruff** | PASS | `evidence/qa-gates/python-ruff.2026-10-31T08-34.md`, exit 0. |
| **Type checking with Pyright** | PASS | `evidence/qa-gates/python-pyright.2026-10-31T08-34.md`, exit 0. |
| **Testing with Pytest** | PASS | `evidence/qa-gates/python-tests.2026-10-31T08-34.md`, 8334 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All new functions are annotated; `cast` is used on narrowed JSON values, consistent with the module's existing pattern. No `Any`. |
| **Dataclasses for value objects** | N/A | No new value object. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | `BlastRadiusOverlayError` with explicit detail text; no broad catch. |
| **Logging over print** | N/A | No logging or print added (spec: no logging changes). |
| **Invariants at construction** | PASS | Demotion validates shape, presence of `append_only_paths`, and entry membership before building output. |

### Section 3B: PowerShell

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | `evidence/qa-gates/ps-format.2026-10-31T08-34.md`, exit 0. |
| **Linting with PSScriptAnalyzer** | PASS | `evidence/qa-gates/pssa.2026-10-31T08-34.md`, exit 0. |
| **Fix all findings** | PASS | No finding recorded post-change. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Uses `[regex]::new`, `-cnotmatch`, and `RegexOptions` only; no 7-only syntax added. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Test-GenericContractToken` uses `[CmdletBinding()]` and `[OutputType([bool])]`. |
| **Parameter validation** | PASS | `[Parameter(Mandatory = $true)]`, `[AllowEmptyString()]`, `[string]`. |
| **Avoid global state** | PASS | Module `$script:` constants only, initialized at import. |
| **Error handling** | PASS | The predicate is total and never throws. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | PASS | Largest changed module 479 lines. |
| **Approved verbs** | PASS | `Test-` is an approved verb. |
| **Comment why** | PASS | Comments explain the ordinal ASCII check and `\A...\z` anchoring. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Exit 0. |
| **Step 2: Analyze** | PASS | Exit 0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | Fresh single-process `Invoke-PoshQCTest` over `tests/scripts`, 13541 tests, 0 failures. |
| **Rerun loop if needed** | PASS | Single clean pass recorded. |

### Section 3C: TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | `evidence/qa-gates/ts-prettier.2026-10-31T08-36.md`, exit 0. |
| **Linting with ESLint** | PASS | `evidence/qa-gates/ts-lint.2026-10-31T08-36.md`, exit 0. |
| **Type checking with tsc** | PASS | `evidence/qa-gates/ts-typecheck.2026-10-31T08-36.md`, exit 0. |
| **Testing with Jest** | PASS | `evidence/qa-gates/ts-jest.2026-10-31T08-36.md`, 5257 passed. |
| **No suppressions or `any`** | PASS | Inspected diff contains no `eslint-disable`, `@ts-ignore`, or `any`. |
| **Per-file coverage threshold for new module** | PASS | `jest.config.cjs` adds `./src/lib/push-down/claude-blast-radius-overlay-demote.ts` with lines 85, branches 75. |

### Section 3D: JSON Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | Both truth tables and three fixtures parse in the parity and corpus tests. |
| **Cross-copy Class 1 parity** | PASS | `conflict_tolerance` equal across both copies (`test_class_one_keys_are_equal_across_both_committed_copies` passed within the full pytest run). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize`, `pytest.raises`. |
| **Coverage expectation** | FAIL | Changed files PASS. The repo-wide figure cannot be read from the scoped artifact (PA-2). |
| **Focused unit tests** | PASS | One behavior per test. |
| **Mocking sparingly** | PASS | In-memory file system only. |
| **Organization** | PASS | Tests under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`. |
| **Naming conventions** | PASS | `test_<behavior>` names. |

### Section 4B: PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It -ForEach`, `Should -Not -Contain`. |
| **Use PoshQC Configuration** | PASS | `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts`. |
| **Organization** | PASS | `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1` sits beside the existing blast-radius Pester tests for `.claude/lib/blast-radius/`. |
| **File Naming** | PASS | `*.Tests.ps1`. |

### Section 4C: TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | `describe`/`it`/`it.each` from `@jest/globals`. |
| **Organization** | PASS | `extensions/drm-copilot/test/lib/push-down/` mirrors `src/lib/push-down/`. |
| **Coverage expectation** | FAIL | Per-file thresholds pass (run exit 0). The coverage artifact is absent and no repo-wide figure is recorded (PA-1). |

---

## 5. Test Coverage Detail

### `is_generic_contract_token` / `Test-GenericContractToken` (13 predicate rows per runtime, plus parity and export rows)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_generic_contract_token_is_recognized[Sheet1, sheet12, CHART3]` | Positive | predicate body | PASS |
| `test_non_generic_token_is_rejected` (10 rows) | Negative / Edge Case | ASCII guard and regex | PASS |
| `test_generic_contract_stems_are_sheet_and_chart` | Positive | constant | PASS |
| Pester `'pins GenericContractStem to GENERIC_CONTRACT_STEMS in the Python source'` | Parity | constant | PASS |

**Coverage:** 100% line and branch (Python), 100% line (PowerShell).

### Shared-surface demotion (Python 13 test nodes; TypeScript 13 tests plus 3 corpus cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_demotion_moves_the_entry_and_keeps_the_remaining_order` | Positive | move path | PASS |
| `test_demotion_runs_after_every_other_key` | Positive | ordering | PASS |
| `test_already_append_only_entry_is_a_no_op` | Edge Case | no-op path | PASS |
| `test_document_without_shared_surfaces_keeps_that_key_absent` | Edge Case | absent-key branch | PASS |
| `test_malformed_directive_is_rejected` (2) | Error Handling | shape check | PASS |
| `test_missing_append_only_paths_is_rejected` (2) | Error Handling | tolerance check | PASS |
| `test_unknown_entry_is_rejected` | Error Handling | membership check | PASS |
| `test_rejection_keeps_the_prior_destination_bytes` | Error Handling | write guard | PASS |
| `test_ac04_push_demotes_quality_tiers_with_tolerance_5000` | Integration | full push-down | PASS |

**Coverage:** Python 100% line and branch; TypeScript demote module 100% line and branch.

**Not covered:** None of the changed lines.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 8334 pytest (dev_tools) + 13541 Pester + 5257 Jest | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | pytest 51.96 s; Pester 829 s (full, with coverage); Jest suite (not timed in evidence) | PASS |
| Test File Size | Largest new test file 320 logical lines | PASS |
| Code Coverage | Changed files 98% to 100% line, 95.24% to 100% branch | PASS (per file) |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check <changed Python files>` | exit 0 | PASS |
| Ruff | `poetry run ruff check <changed Python files>` | exit 0 | PASS |
| Pyright | `poetry run pyright <changed Python files>` | exit 0 | PASS |
| Pytest | `poetry run pytest tests/scripts/dev_tools ... --cov-branch` | 8334 passed | PASS |
| Invoke-Formatter | per-file, PoshQC settings | exit 0 | PASS |
| PSScriptAnalyzer | per-file, PoshQC settings | exit 0 | PASS |
| Pester | `Invoke-PoshQCTest -ScanFolders tests/scripts` | 0 failures | PASS |
| Prettier / ESLint / tsc / Jest | as recorded under `evidence/qa-gates/ts-*` | exit 0 | PASS |

**Notes:** CI status for the head is not available; no PR exists yet (`artifacts/pr_context.summary.txt`, "CI status (HEAD): not available").

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (FAIL, blocking): TypeScript coverage artifact absent.** TypeScript has changed production files (`claude-blast-radius-overlay.ts`, new `claude-blast-radius-overlay-demote.ts`). Neither `coverage/lcov.info` nor `extensions/drm-copilot/coverage/lcov.info` exists. The recorded run overrode the configured `lcov` reporter with `--coverageReporters=text`, so the only coverage record is a text transcription and no repo-wide TypeScript figure is reported. Coverage verification is mandatory for every language with changed files. Remediability: autonomous. The fix is to regenerate the coverage locally with `npm --prefix extensions/drm-copilot run test:coverage` (lcov plus text-summary) and record the per-file and repo-wide line and branch figures under `evidence/qa-gates/`. CI's `drm-copilot-extension-tests` job runs `npm run test` without coverage, so CI cannot supply this artifact.
- **PA-2 (FAIL, blocking): Python repo-wide coverage figure absent.** `artifacts/python/lcov.info` contains exactly five `SF:` records (the changed modules), because the run used five dotted `--cov=` targets, so no repo-wide Python line or branch percentage can be derived from it. Remediability: awaiting_ci. CI job `quality-checks7 / Code Quality & Tests` runs `pytest --cov --cov-branch` over the whole repository and the step `Enforce Python coverage thresholds` (`--min-line 85 --min-branch 75`) on the PR head. The changed files cannot lower the repo-wide figure, because each holds or raises its coverage and every added line is covered. A local full-repository run would also clear it.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests are implemented. The pre-existing unconditional skip on `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` is unchanged against the merge base (AC-22).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **a36fb55a4** - docs(features): prepare issue 1006 feature folder and plan
2. **07ed1dfcf** - Merge remote-tracking branch 'origin/main' into bug/parallel-scheduling-false-hard-edges-1006
3. **4be50e8f7** - fix(blast-radius): reject generic sheet contracts and make quality-tiers.yml append-only
4. **963dc4f1f** - feat(push-down): add shared_surfaces_demote overlay directive
5. **537905f0d** - docs(rules): document append-only quality-tiers.yml, generic contract tokens, and demotion
6. **9a40db5c5** - chore(bundle): mirror blast-radius modules and parallel-orchestration rule
7. **fc1d8618b** - test(blast-radius): complete issue 1006 verification loop and QA evidence

### Files Modified

1. **`scripts/dev_tools/_blast_radius_token_shapes.py`** (MODIFIED): `GENERIC_CONTRACT_STEMS`, `GENERIC_CONTRACT_RE`, `is_generic_contract_token`.
2. **`scripts/dev_tools/_blast_radius_extraction.py`, `_blast_radius_write_intent.py`, `compute_blast_radius.py`** (MODIFIED): predicate added as a conjunct at each contract-filtering site.
3. **`scripts/dev_tools/push_down_claude_blast_radius_overlay.py`** (MODIFIED): `SHARED_SURFACES_DEMOTE_KEY`, `_apply_shared_surface_demotion`, composer dispatch.
4. **`.claude/lib/blast-radius/*.psm1`** (5 MODIFIED, plus 5 bundle copies): PowerShell predicate, re-export, and three filtering sites.
5. **`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts`** (NEW) and **`claude-blast-radius-overlay.ts`** (MODIFIED): TypeScript directive.
6. **`config/blast-radius.json`** and bundle copy (MODIFIED): `quality-tiers.yml` moved to `append_only_paths`.
7. **`.claude/rules/parallel-orchestration.md`** and bundle copy (MODIFIED): constraint 2, five-shape list, new subsection, overlay paragraph.
8. Tests and fixtures listed in spec items 23 to 40.
9. Feature folder documents, evidence, and the issue-promotion record `docs/features/potential/promoted/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1.md`.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Implementation, toolchain, test-quality, file-size, evidence-location, scope, and mirror-parity requirements are met. Two coverage-verification requirements are not met: PA-1 (TypeScript artifact absent, autonomous) and PA-2 (Python repo-wide figure absent, awaiting CI).

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

- PASS Python: tooling, design, error handling
- PASS PowerShell: tooling, design, structure, toolchain
- PASS TypeScript: tooling and implementation
- PASS JSON: structure and cross-copy parity

#### General Unit Test Policy (Section 1)

- PASS Core Principles
- FAIL Coverage & Scenarios (scenarios PASS; repo-wide coverage evidence gaps PA-1 and PA-2)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

### Metrics Summary

- PASS: 0 failing tests across pytest, Pester, and Jest
- PASS: 100% coverage of changed lines in all three languages
- PASS: PowerShell repo-wide 93.53% line
- FAIL: TypeScript coverage artifact absent
- FAIL: Python repo-wide coverage figure absent from the local artifact (awaiting CI)

### Recommendation

**Needs revision.** Regenerate the TypeScript coverage with the lcov reporter and record the per-file and repo-wide figures (PA-1). Confirm PA-2 from the PR CI step `Enforce Python coverage thresholds` on the final head. No production or test code change is required for either finding.

---

## Appendix A: Test Inventory

New test files:

- `tests/scripts/dev_tools/test_blast_radius_generic_contracts.py`: `test_generic_contract_token_is_recognized` (3), `test_non_generic_token_is_rejected` (10), `test_generic_contract_stems_are_sheet_and_chart`, `test_extract_contract_identifiers_drops_a_generic_token`, `test_extract_write_intent_contracts_drops_a_generic_token`, `test_normalize_declared_radius_drops_a_recorded_generic_contract`, `test_issue_1006_scenario_has_no_hard_edge` (self-hosted, bundled), `test_issue_1006_scenario_tolerance_zero_equals_detection` (self-hosted, bundled)
- `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py`: `test_demotion_moves_the_entry_and_keeps_the_remaining_order`, `test_demotion_consumes_the_directive_key`, `test_demotion_runs_after_every_other_key`, `test_already_append_only_entry_is_a_no_op`, `test_composing_a_composed_result_again_is_identical`, `test_document_without_shared_surfaces_keeps_that_key_absent`, `test_malformed_directive_is_rejected` (2), `test_missing_append_only_paths_is_rejected` (2), `test_unknown_entry_is_rejected`, `test_rejection_keeps_the_prior_destination_bytes`, `test_forbidden_glob_guard_still_runs_with_the_directive`, `test_ac04_push_demotes_quality_tiers_with_tolerance_5000`
- `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1`: Describe 'Generic contract-token rejection (issue #1006)' > Context 'Test-GenericContractToken' (recognition, rejection, stem parity, export rows) > Context 'Contract-filtering sites' (3) > Context 'Issue 1006 scenario' (no hard edge, tolerance-zero identity, per table)
- `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts`: describe 'issue #1006 shared-surface demotion semantics' (7), 'issue #1006 shared-surface demotion fails closed' (rejection rows, prior bytes, forbidden-glob guard), 'issue #1006 AC-04 destination push-down' (1)

Updated test files: `blast_radius_parity_test_support.py`, `test_blast_radius_config_parity.py`, `test_blast_radius_config_tolerance_keys.py`, `test_push_down_claude_overlay_parity.py` (corpus `expected_error` support; `test_shared_surfaces_demote_key_constants_match`), `test_blast_radius_mandate_reads.py`, `test_blast_radius_extraction.py` (comment only), `BlastRadius.TruthTable.Tests.ps1`, `BlastRadius.KeyPartition.Tests.ps1`, `BlastRadiusExtraction.Path.Tests.ps1` (comment only), `config-carriage.test-helpers.ts`, `claude-blast-radius-overlay-parity.test.ts`.

---

## Appendix B: Toolchain Commands Reference

Python:

```bash
poetry run black --check <changed Python files>
poetry run ruff check <changed Python files>
poetry run pyright <changed Python files>
poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider --cov=<five dotted modules> --cov-branch --cov-report=term-missing
```

PowerShell:

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1
Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1   # per file
Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1   # per file
Invoke-PoshQCTest -Root . -ScanFolders tests/scripts
```

TypeScript (in `extensions/drm-copilot/`):

```bash
npx prettier --check <changed TS files>
npm run lint
npm run typecheck
node run-jest.cjs --coverage --coverageReporters=text
node run-jest.cjs --randomize --seed=1006
```

Reviewer checks (this audit):

```bash
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .
git diff --stat 1898400756e909b88cde5f51a05f0b11d423d3b0...HEAD
cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-31
**Policy Version:** Current (as of audit date)
