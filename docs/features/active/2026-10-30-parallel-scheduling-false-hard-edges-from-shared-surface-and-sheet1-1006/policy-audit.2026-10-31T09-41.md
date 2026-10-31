# Policy Compliance Audit: parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (Issue #1006), Remediation Cycle 1 Re-audit

**Audit Date:** 2026-10-31
**Base Branch:** `main` (merge base `1898400756e909b88cde5f51a05f0b11d423d3b0`, equal to `origin/main`)
**Head Branch:** `bug/parallel-scheduling-false-hard-edges-1006` @ `d7dd48791e6ad0a1127251dcf32284c1cabd51aa`
**Scope:** full branch diff against the merge base (107 files, +5173/-95), per `artifacts/pr_context.summary.txt` (generated 2026-10-31 09:39:02 UTC at the head SHA above) and `git diff --stat 1898400756e909b88cde5f51a05f0b11d423d3b0..HEAD`. Prior review set: `*.2026-10-31T08-57.md`; cycle inputs: `remediation-inputs.2026-10-31T08-57.md` and `remediation-plan.2026-10-31T08-57.md`.
**Code Under Test:**

- Python production: `scripts/dev_tools/_blast_radius_token_shapes.py`, `scripts/dev_tools/_blast_radius_extraction.py`, `scripts/dev_tools/_blast_radius_write_intent.py`, `scripts/dev_tools/compute_blast_radius.py`, `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`
- PowerShell production: `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`, `BlastRadiusExtraction.psm1`, `BlastRadiusNormalization.psm1`, `BlastRadiusWriteIntent.psm1`, `BlastRadius.psm1`, and their five byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`
- TypeScript production: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` (modified), `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` (new), `extensions/drm-copilot/jest.config.cjs` (config)
- JSON configuration: `config/blast-radius.json`, its bundle copy, and three new corpus fixtures under `tests/fixtures/blast_radius_overlay/`
- Markdown rule: `.claude/rules/parallel-orchestration.md` and its bundle copy
- Tests: 8 Python test files (2 new), 4 Pester files (1 new), 3 TypeScript test files (1 new)
- Cycle 1 delta (`fc1d8618b..d7dd48791`): `unionStrings` moved into `claude-blast-radius-overlay-demote.ts` and imported by `claude-blast-radius-overlay.ts`; `$script:OverlayDirectiveKey` replaced by a local variable in `BlastRadius.KeyPartition.Tests.ps1`; cycle evidence under the feature folder.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 5 production, 8 test | 8334 passed, 6 skipped (tests/scripts/dev_tools) | PASS: 8334 pass, 0 fail | Changed files: 97.98% to 100% line, 95.24% to 100% branch | Changed files: 98.0% to 100% line, 95.24% to 100% branch; repo-wide not in local artifact | 100% of changed lines |
| PowerShell | 10 production (5 plus 5 bundle copies), 4 test | 13541 tests, 10 skipped | PASS: 0 failures, 0 errors | Changed files: 100% line each | Changed files: 100% line each; repo-wide 93.53% line (20880/22324) | 100% of changed lines |
| TypeScript | 2 production, 1 config, 3 test | 5257 tests, 324 suites | PASS: 5257 pass, 0 fail | Cycle baseline: overlay 99.57% line / 96.15% branch; demote 100% / 100%; repo-wide 97.05% line / 93.67% branch | overlay 99.55% line (442/444) / 96.00% branch (96/100); demote 100% (157/157) / 100% (27/27); repo-wide 97.05% line / 93.67% branch | 100% of changed lines |
| JSON | 5 files | Parity and truth-table tests | PASS | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/remediation-baseline/ts-coverage.2026-10-31T09-12.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (864264 bytes; reviewer re-read LF/LH/BRF/BRH for both files and they match the evidence), recorded in `evidence/qa-gates/ts-coverage.2026-10-31T09-17.md`
- PowerShell baseline coverage artifact: `evidence/baseline/pester-full.2026-10-31T08-22.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, fresh full run over `tests/scripts`, `evidence/qa-gates/pester-full.2026-10-31T09-35.md`)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (scoped to the five changed modules only; unchanged in cycle 1)
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-10-31T08-49.md`, `evidence/qa-gates/coverage-comparison.2026-10-31T09-17.md`, and Section 1.2.1 below

---

## Executive Summary

The branch fixes two false hard scheduling edges: a generic sheet-tab contract predicate at all six contract-filtering sites in Python and PowerShell, `quality-tiers.yml` moved to `conflict_tolerance.append_only_paths` in both truth tables, and a `shared_surfaces_demote` overlay directive in the Python and TypeScript composers. Remediation cycle 1 closed PA-1 (TypeScript coverage artifact) and the two in-scope code-review items (shared union helper, Pester script-scope write). This re-audit verified the cycle code diff directly, re-read the TypeScript `lcov.info` per-file counters, recomputed the PowerShell repo-wide counter, re-ran bundle `cmp` checks, the evidence-location validator, and logical line counts.

**Policy documents evaluated:**

- PASS `.claude/rules/general-code-change.md`
- PARTIAL `.claude/rules/general-unit-test.md` (Python repo-wide coverage figure awaits CI; PA-2)
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; touched projects are classified: `scripts/dev_tools` T4, `.claude/lib/blast-radius` T3, `extensions/drm-copilot` T3; no T1/T2 property-test or mutation obligation applies)

**Language-specific policies evaluated:**

- PASS `.claude/rules/python.md` and `.claude/rules/python-suppressions.md` (implementation); repo-wide coverage awaits CI
- PASS `.claude/rules/powershell.md`
- PASS `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md`
- N/A C#: no C# files changed
- N/A Bash: no `.sh` or `.bats` files changed

All toolchain results recorded under `evidence/qa-gates/` report `EXIT_CODE: 0`. One blocking finding remains: PA-2, the repo-wide Python coverage figure, which is classified awaiting_ci because the PR CI job enforces it on the head and no PR exists yet.

**Temporary artifacts cleanup:**

- PASS: no temporary or one-time scripts are committed; helper scripts live in the session scratchpad (`SCRATCH/issue-1006-*`), and `git status --porcelain` is empty at the head.
- PASS: no new ongoing tooling script was added.

---

## Rejected Scope Narrowing

None detected. The caller prompt specified the full branch against `main` with merge base `1898400756e909b88cde5f51a05f0b11d423d3b0` and did not narrow scope to a plan, phase, cycle, or file subset. This re-audit covers the full branch diff, not only the cycle 1 delta.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` returned exit 0.
- `git diff --name-only 1898400756e909b88cde5f51a05f0b11d423d3b0..HEAD` filtered with `^artifacts/(baselines|qa|evidence|coverage)/` returned no match.
- All feature evidence, including cycle 1 evidence, lives under `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- Verdict: PASS. No violation found.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Cycle 1: seeded Jest shuffle `--seed=1006` (5257 passed) and three seeded Pester file-order shuffles, seeds 11/23/47 (172 passed each), in `evidence/regression-testing/isolation.2026-10-31T09-36.md`. Initial: reversed-order pytest (214 passed) in `isolation.2026-10-31T08-39.md`. The `$script:` write inside an `It` block was replaced by a local variable. |
| **Isolation** | PASS | Each new test targets one predicate row, one filtering site, one demotion rule, or one scenario. |
| **Fast Execution** | PASS | `tests/scripts/dev_tools` 8334 tests in 51.96 s; the KeyPartition Pester file alone runs 6 tests. |
| **Determinism** | PASS | Fixed `COMPUTED_AT`, in-memory file systems, no clock, RNG, or network in new tests. |
| **Readability & Maintainability** | PASS | Descriptive names, docstrings, explicit Arrange/Act/Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `evidence/baseline/python-tests.2026-10-31T08-04.md`, `evidence/baseline/pester-full.2026-10-31T08-22.md`, `evidence/baseline/typescript.2026-10-31T08-06.md`, `evidence/remediation-baseline/ts-coverage.2026-10-31T09-12.md`. |
| **No Coverage Regression** | PASS | Every changed file holds its coverage on changed lines. The overlay module moved from 99.57% to 99.55% line and 96.15% to 96.00% branch only because 21 fully covered lines and 4 fully covered branches were removed; the uncovered set is unchanged at 2 lines and 4 branches (`coverage-comparison.2026-10-31T09-17.md`). |
| **Changed and new file thresholds (85% line, 75% branch)** | PASS | Python per-file verified in `artifacts/python/lcov.info`. PowerShell per-file LINE counters in `artifacts/pester/powershell-coverage.xml` are 100%. TypeScript per-file read by the reviewer from `extensions/drm-copilot/coverage/lcov.info`: overlay LH 442/LF 444, BRH 96/BRF 100; demote LH 157/LF 157, BRH 27/BRF 27. |
| **Repo-wide thresholds** | PARTIAL | TypeScript repo-wide 97.05% line, 93.67% branch (PASS). PowerShell repo-wide 93.53% line (PASS; JaCoCo report-level LINE counter missed 1444, covered 20880). Python: `artifacts/python/lcov.info` holds five `SF:` records only, so no repo-wide figure is derivable locally; CI enforces it on the PR head (PA-2, awaiting_ci). |
| **Comprehensive Coverage** | PASS | Every new symbol is tested, including `unionStrings` (FNDA 85 calls, no zero-hit DA record). |
| **Positive Flows** | PASS | `test_generic_contract_token_is_recognized`, `test_demotion_moves_the_entry_and_keeps_the_remaining_order`, `test_ac04_push_demotes_quality_tiers_with_tolerance_5000`. |
| **Negative Flows** | PASS | `test_non_generic_token_is_rejected` (10 rows), `test_malformed_directive_is_rejected`, `test_missing_append_only_paths_is_rejected`, `test_unknown_entry_is_rejected`. |
| **Edge Cases** | PASS | Empty string, full-width digit, Kelvin sign, long s, `Sheet1.Range`, absent `shared_surfaces`, already-append-only entry. |
| **Error Handling** | PASS | Full error text asserted in both runtimes; prior destination bytes preserved on rejection. |
| **Concurrency** | N/A | Pure functions and single-threaded composition. |
| **State Transitions** | N/A | No stateful component; idempotence of repeated composition is tested. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: changed modules 97.98% to 100% line, 95.24% to 100% branch -> Post-change: 98.00% to 100% line, 95.24% to 100% branch. Change: +0.02% line on `_blast_radius_write_intent.py`, 0 elsewhere. New/changed-code coverage: 100%. Repo-wide: not derivable from the scoped artifact. Disposition: FAIL until CI records the repo-wide figure (PA-2, awaiting_ci; changed-file figures PASS). Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-tests.2026-10-31T08-34.md`.
- PowerShell: Baseline: 100% line for each of the five changed modules -> Post-change: 100% line for each (108/108, 80/80, 52/52, 39/39, 103/103). Repo-wide 93.53% line. Change: 0. New/changed-code coverage: 100%. Disposition: PASS. Branch threshold not applicable (Pester measures no branch coverage). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester-full.2026-10-31T09-35.md`.
- TypeScript: Baseline: 99.57% line, 96.15% branch for `claude-blast-radius-overlay.ts` (463/465, 100/104); demote 100% line, 100% branch; repo-wide 97.05% line, 93.67% branch -> Post-change: 99.55% line, 96.00% branch for `claude-blast-radius-overlay.ts` (442/444, 96/100); demote 100% (157/157) / 100% (27/27); repo-wide 97.05% line (61650/63521), 93.67% branch (9389/10023). Change: -0.02% line and -0.15% branch on the overlay module (fully covered lines removed; uncovered set unchanged), 0 on the demote module, 0 repo-wide. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/ts-coverage.2026-10-31T09-17.md`, `evidence/qa-gates/coverage-comparison.2026-10-31T09-17.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions carry messages such as `f"Hard edges with reason kinds: {hard_reasons}."`. |
| **Arrange-Act-Assert Pattern** | PASS | Explicit AAA comments in the generic-contract tests; demotion tests follow the same structure. |
| **Document Intent** | PASS | Module docstrings state the issue scenario; every test function has a docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, subprocess, or database use in the new tests. |
| **Use Mocks/Stubs** | PASS | In-memory `RecordingFileSystem` and `DestinationMergeFileSystem`. |
| **Environment Stability** | PASS | No temporary-file API in the new tests (grep in the prior review; the cycle changed no test except one variable). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, with `code-review.2026-10-31T09-41.md` and `feature-audit.2026-10-31T09-41.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (#1006), `spec.md` (full-bug, 25 AC), `research/research.2026-10-30T11-05.md`. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-10-31T08-00.md`, `evidence/remediation-baseline/phase0-instructions-read.2026-10-31T09-11.md`. |
| **Document the plan** | PASS | `plan.2026-10-30T06-58.md`, `remediation-plan.2026-10-31T08-57.md` (all tasks checked). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One anchored regex predicate per runtime; demotion is a single post-composition pass. |
| **Reusability** | PASS | Cycle 1 resolved the duplicated union: `unionStrings` is defined once (reviewer grep over `extensions/drm-copilot/src` returns one definition, in the demote module) and imported by the overlay module. The Python side reuses `_union_strings`. |
| **Extensibility** | PASS | Closed stem constant; the directive is isolated in its own key and module. |
| **Separation of concerns** | PASS | Predicate in the token-shape leaf modules; demotion is a pure function in its own module. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The demote module now also hosts the shared union helper, documented in its module comment; it remains a leaf with respect to the overlay module. |
| **At or below the 800-line hard limit** | PASS | Reviewer logical line counts over all added or modified covered files: largest `extensions/drm-copilot/jest.config.cjs` 540, `test_blast_radius_config_parity.py` 511, `BlastRadius.psm1` 479; `claude-blast-radius-overlay.ts` 444; demote module 157. No covered file is at or above 700 lines. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | PASS | `unionStrings` is exported from the demote module as an internal seam between two files of the same feature; no other module imports it. Existing public signatures are unchanged. |
| **No circular dependencies** | PASS | Reviewer grep: `claude-blast-radius-overlay-demote.ts` has no import of `./claude-blast-radius-overlay`; the only importers of that specifier are the overlay's existing consumers (`claude-customizations.ts`). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `is_generic_contract_token`, `Test-GenericContractToken`, `applySharedSurfaceDemotion`, `unionStrings`, `$overlayDirectiveKey`. |
| **Docs/docstrings** | PASS | TSDoc on `unionStrings` with `@param` and `@returns`; Google-style docstrings in Python; comment-based help in PowerShell. |
| **Comment why, not what** | PASS | Comments explain the ASCII guard, the consumed directive, and why the helper lives in the demote module (no import cycle). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Cycle 1: Prettier `--check` exit 0 (`ts-prettier.2026-10-31T09-17.md`); Invoke-Formatter unchanged hash (`ps-format.2026-10-31T09-18.md`). Initial: Black exit 0. |
| **2. Linting** | PASS | Cycle 1: `npm run lint` exit 0 with 0 problems (`ts-lint.2026-10-31T09-17.md`); PSScriptAnalyzer 0 findings (`pssa.2026-10-31T09-18.md`). Initial: Ruff exit 0. |
| **3. Type checking** | PASS | Cycle 1: `npm run typecheck` exit 0 (`ts-typecheck.2026-10-31T09-17.md`). Initial: Pyright exit 0. N/A for PowerShell. |
| **4. Architecture-boundary tests** | PASS | No new cross-module import edge beyond demote-to-overlay direction already present; suites ran in the full Jest run. |
| **5. Unit tests** | PASS | Jest 5257 passed (`ts-coverage.2026-10-31T09-17.md`); Pester 13541, 0 failures (`pester-full.2026-10-31T09-35.md`); pytest 8334 passed (no Python change in cycle 1). |
| **6. Contract / schema checks** | PASS | Push-down contract tests and Codex generator `--check` exit 0 (initial run); cycle 1 changed no bundled resource. |
| **7. Integration tests** | PASS | In-memory push-down tests in both runtimes. |
| **Full toolchain loop** | PASS | Cycle 1 Phase 3 recorded a single clean pass for TypeScript and PowerShell. |
| **Explicit reporting** | PASS | Every command, exit code, and summary is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Scoped commits, including cycle 1 commits `6ad196d22` (shared union) and `3c94c93c9` (local variable). |
| **Design choices explained** | PASS | Spec "Proposed Fix"; remediation plan P1-T1 equivalence argument. |
| **Update supporting documents** | PASS | Rule and five `.psm1` files byte-identical to their bundle copies (reviewer `cmp`, six pairs identical). |
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
| **Testing with Pytest** | PASS | `evidence/qa-gates/python-tests.2026-10-31T08-34.md`, 8334 passed. No Python file changed in cycle 1. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All new functions annotated; no `Any`. |
| **Dataclasses for value objects** | N/A | No new value object. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | `BlastRadiusOverlayError` with explicit detail text. |
| **Logging over print** | N/A | No logging or print added. |
| **Invariants at construction** | PASS | Demotion validates before building output. |

### Section 3B: PowerShell

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | `ps-format.2026-10-31T09-18.md`, hash unchanged. |
| **Linting with PSScriptAnalyzer** | PASS | `pssa.2026-10-31T09-18.md`, 0 findings. |
| **Fix all findings** | PASS | No finding recorded. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | No 7-only syntax added. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Test-GenericContractToken` uses `[CmdletBinding()]` and `[OutputType([bool])]`. |
| **Parameter validation** | PASS | Mandatory `[string]` with `[AllowEmptyString()]`. |
| **Avoid global state** | PASS | Module `$script:` constants only; the test-file `$script:` write inside an `It` block was removed in cycle 1. |
| **Error handling** | PASS | The predicate is total. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | PASS | Largest changed module 479 lines. |
| **Approved verbs** | PASS | `Test-`. |
| **Comment why** | PASS | Comments explain the ordinal ASCII check and anchoring. |

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
| **Formatting with Prettier** | PASS | `ts-prettier.2026-10-31T09-17.md`, exit 0. |
| **Linting with ESLint** | PASS | `ts-lint.2026-10-31T09-17.md`, exit 0. |
| **Type checking with tsc** | PASS | `ts-typecheck.2026-10-31T09-17.md`, exit 0. |
| **Testing with Jest** | PASS | `ts-coverage.2026-10-31T09-17.md`, 5257 passed; `ts-union-helper.2026-10-31T09-15.md`, 71 of 71 in the three overlay suites with no test file edited. |
| **No suppressions or `any`** | PASS | Cycle diff contains no `eslint-disable`, `@ts-ignore`, `any`, or `as` cast; `unionStrings` is generic over `T`. |
| **Per-file coverage threshold for new module** | PASS | `jest.config.cjs` keeps per-file entries (85/75) for both files; the `test:coverage` run exited 0. |

### Section 3D: JSON Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | Both truth tables and three fixtures parse in the parity and corpus tests. |
| **Cross-copy Class 1 parity** | PASS | `conflict_tolerance` equal across both copies. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize`, `pytest.raises`. |
| **Coverage expectation** | PARTIAL | Changed files PASS. The repo-wide figure is enforced by CI on the PR head and is not derivable from the scoped local artifact (PA-2, awaiting_ci). |
| **Focused unit tests** | PASS | One behavior per test. |
| **Mocking sparingly** | PASS | In-memory file system only. |
| **Organization** | PASS | Tests under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`. |
| **Naming conventions** | PASS | `test_<behavior>` names. |

### Section 4B: PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It -ForEach`. |
| **Use PoshQC Configuration** | PASS | `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts`. |
| **Organization** | PASS | `tests/scripts/claude-lib/blast-radius/` holds the blast-radius Pester tests. |
| **File Naming** | PASS | `*.Tests.ps1`. |

### Section 4C: TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | `describe`/`it`/`it.each`. |
| **Organization** | PASS | `extensions/drm-copilot/test/lib/push-down/` mirrors `src/lib/push-down/`. |
| **Coverage expectation** | PASS | `extensions/drm-copilot/coverage/lcov.info` exists; per-file and repo-wide figures meet 85/75 (PA-1 closed). |

---

## 5. Test Coverage Detail

### `is_generic_contract_token` / `Test-GenericContractToken`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_generic_contract_token_is_recognized[Sheet1, sheet12, CHART3]` | Positive | predicate body | PASS |
| `test_non_generic_token_is_rejected` (10 rows) | Negative / Edge Case | ASCII guard and regex | PASS |
| `test_generic_contract_stems_are_sheet_and_chart` | Positive | constant | PASS |
| Pester `'pins GenericContractStem to GENERIC_CONTRACT_STEMS in the Python source'` | Parity | constant | PASS |

**Coverage:** 100% line and branch (Python), 100% line (PowerShell).

### Shared-surface demotion and `unionStrings`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_demotion_moves_the_entry_and_keeps_the_remaining_order` and TS `"moves the entry and keeps the remaining order"` | Positive | move path, union | PASS |
| `test_already_append_only_entry_is_a_no_op` and TS mirror | Edge Case | no-op path, union de-duplication | PASS |
| `test_malformed_directive_is_rejected`, `test_missing_append_only_paths_is_rejected`, `test_unknown_entry_is_rejected` | Error Handling | validation | PASS |
| TS `"composes %s to its expected text"` (all corpus rows) | Parity | composer string-list and nested-list union through `unionStrings` | PASS |
| `test_ac04_push_demotes_quality_tiers_with_tolerance_5000` and TS mirror | Integration | full push-down | PASS |

**Coverage:** Python 100% line and branch; TypeScript demote module 100% line and branch; `unionStrings` FNDA 85.

**Not covered:** None of the changed lines.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 8334 pytest (dev_tools) + 13541 Pester + 5257 Jest | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | pytest 51.96 s; Pester 796.65 s (full, with coverage); Jest not timed in evidence | PASS |
| Test File Size | Largest changed test file 511 logical lines | PASS |
| Code Coverage | Changed files 98% to 100% line, 95.24% to 100% branch; TS and PS repo-wide above thresholds | PASS (Python repo-wide awaits CI) |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black / Ruff / Pyright | changed Python files | exit 0 | PASS |
| Pytest | `poetry run pytest tests/scripts/dev_tools ... --cov-branch` | 8334 passed | PASS |
| Invoke-Formatter / PSScriptAnalyzer | per-file, PoshQC settings | exit 0, 0 findings | PASS |
| Pester | `Invoke-PoshQCTest -ScanFolders tests/scripts` | 0 failures | PASS |
| Prettier / ESLint / tsc | `ts-*.2026-10-31T09-17.md` | exit 0 | PASS |
| Jest with coverage | `npm --prefix extensions/drm-copilot run test:coverage` | exit 0, 5257 passed | PASS |

**Notes:** No PR exists for the branch (`gh pr list --head bug/parallel-scheduling-false-hard-edges-1006 --state all` returned `[]`), so no CI status exists for the head.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (closed in cycle 1): TypeScript coverage artifact.** `extensions/drm-copilot/coverage/lcov.info` now exists. The reviewer re-read the per-file counters (overlay LF 444/LH 442, BRF 100/BRH 96; demote LF 157/LH 157, BRF 27/BRH 27), which match `evidence/qa-gates/ts-coverage.2026-10-31T09-17.md`. Repo-wide 97.05% line and 93.67% branch. The run was at `3c94c93c9`; the only later commit, `d7dd48791`, adds feature-folder documentation only. Status: PASS.
- **PA-2 (FAIL, blocking, carried forward): Python repo-wide coverage figure absent.** `artifacts/python/lcov.info` still holds exactly five `SF:` records (the changed modules), so no repo-wide Python line or branch percentage can be derived from it. Remediability: awaiting_ci. CI job `quality-checks7 / Code Quality & Tests` runs `pytest --cov --cov-branch` over the whole repository and the step `Enforce Python coverage thresholds` (`--min-line 85 --min-branch 75`) on the PR head; no PR exists, so that record cannot exist yet. Cycle 1 changed no Python file, and each changed Python module holds or raises its coverage with every added line covered.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** The pre-existing unconditional skip on `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` is unchanged against the merge base (AC-22).

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
8. **4fdb1848a** - docs(features): record issue 1006 feature review and remediation cycle 1 inputs
9. **40da16a85** - docs(features): record issue 1006 remediation cycle 1 plan and baseline
10. **6ad196d22** - refactor(push-down): share one order-preserving union between overlay modules
11. **3c94c93c9** - test(blast-radius): use a local variable for the overlay directive key list
12. **d7dd48791** - docs(features): record issue 1006 remediation cycle 1 QA and coverage evidence

### Files Modified

1. **`scripts/dev_tools/_blast_radius_token_shapes.py`** and three filtering-site modules (MODIFIED): generic-contract predicate and conjuncts.
2. **`scripts/dev_tools/push_down_claude_blast_radius_overlay.py`** (MODIFIED): `shared_surfaces_demote` directive.
3. **`.claude/lib/blast-radius/*.psm1`** (5 MODIFIED, plus 5 bundle copies): PowerShell predicate, re-export, and filtering sites.
4. **`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts`** (NEW; hosts `unionStrings` after cycle 1) and **`claude-blast-radius-overlay.ts`** (MODIFIED; imports `unionStrings`).
5. **`config/blast-radius.json`** and bundle copy (MODIFIED): `quality-tiers.yml` moved to `append_only_paths`.
6. **`.claude/rules/parallel-orchestration.md`** and bundle copy (MODIFIED).
7. Tests and fixtures listed in spec items 23 to 40; `BlastRadius.KeyPartition.Tests.ps1` local-variable fix in cycle 1.
8. Feature folder documents, evidence, and the issue-promotion record under `docs/features/potential/promoted/`.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

All implementation, toolchain, test-quality, file-size, evidence-location, scope, and mirror-parity requirements are met, and PA-1 is closed. One coverage-verification requirement remains open: PA-2 (Python repo-wide figure), classified awaiting_ci.

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
- PASS TypeScript: tooling, implementation, coverage
- PASS JSON: structure and cross-copy parity

#### General Unit Test Policy (Section 1)

- PASS Core Principles
- PARTIAL Coverage & Scenarios (scenarios PASS; Python repo-wide figure awaits CI, PA-2)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

### Metrics Summary

- PASS: 0 failing tests across pytest, Pester, and Jest
- PASS: 100% coverage of changed lines in all three languages
- PASS: PowerShell repo-wide 93.53% line
- PASS: TypeScript repo-wide 97.05% line, 93.67% branch
- FAIL: Python repo-wide coverage figure absent from the local artifact (awaiting CI)

### Recommendation

**Proceed to PR; confirm PA-2 at the CI gate.** Open the PR and record, at the S9 CI gate, the job id, the step `Enforce Python coverage thresholds` conclusion, and the pytest `TOTAL` line under `evidence/qa-gates/`. No production or test code change is required.

---

## Appendix A: Test Inventory

New test files:

- `tests/scripts/dev_tools/test_blast_radius_generic_contracts.py`: predicate recognition (3) and rejection (10) rows, stem pin, three filtering-site tests, issue scenario no-hard-edge and tolerance-zero identity (self-hosted and bundled tables).
- `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py`: move, consume, ordering, no-op, idempotence, absent-key, malformed (2), missing target (2), unknown entry, prior bytes, forbidden-glob guard, AC-04 push-down.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1`: predicate rows, stem parity, export rows, three filtering sites, issue scenario per table.
- `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts`: demotion semantics (7), fail-closed rows, prior bytes, guard, AC-04 push-down.

Updated test files: `blast_radius_parity_test_support.py`, `test_blast_radius_config_parity.py`, `test_blast_radius_config_tolerance_keys.py`, `test_push_down_claude_overlay_parity.py`, `test_blast_radius_mandate_reads.py`, `test_blast_radius_extraction.py` (comment only), `BlastRadius.TruthTable.Tests.ps1`, `BlastRadius.KeyPartition.Tests.ps1` (directive-key block; local variable in cycle 1), `BlastRadiusExtraction.Path.Tests.ps1` (comment only), `config-carriage.test-helpers.ts`, `claude-blast-radius-overlay-parity.test.ts`.

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
npm run test:coverage
node run-jest.cjs --randomize --seed=1006
```

Reviewer checks (this audit):

```bash
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
git diff --stat 1898400756e909b88cde5f51a05f0b11d423d3b0..HEAD
git diff fc1d8618bf26e9e2ffa2e81dec5e1380ec2763f8..HEAD -- extensions tests
awk over extensions/drm-copilot/coverage/lcov.info for LF/LH/BRF/BRH of both overlay files
tail of artifacts/pester/powershell-coverage.xml (report-level LINE counter)
cmp <source> <bundle copy>   # six pairs
gh pr list --head bug/parallel-scheduling-false-hard-edges-1006 --state all
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-31
**Policy Version:** Current (as of audit date)
