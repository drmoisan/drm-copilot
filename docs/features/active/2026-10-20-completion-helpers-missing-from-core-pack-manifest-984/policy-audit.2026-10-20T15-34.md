# Policy Compliance Audit: Completion helpers missing from the Claude core pack manifest (Issue #984)

---

**Audit Date:** 2026-10-20
**Base Branch:** `main` (resolved `origin/main`, merge base `58e5001c5907d74ee24f205690d891b4352fda23`)
**Head:** `bug/completion-helpers-missing-from-core-pack-manifest-984` at `a114539915767e4d9f04fe1c8df3b1debb8b11df`
**Scope:** full branch diff `58e5001c5907d74ee24f205690d891b4352fda23..a114539915767e4d9f04fe1c8df3b1debb8b11df` (109 files, 3951 insertions, 66 deletions; 2 commits)

**Code Under Test (non-documentation files):**

- PowerShell production: `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, and their six byte-identical bundle copies under `extensions/drm-copilot/resources/`.
- PowerShell tests: `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1` (new), `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1` (new), `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1` (new), `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1` (new), `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` (modified).
- Python tests and test support: `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` (new), `tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py` (new), `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (new), `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (modified).
- TypeScript test: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (modified).
- JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- Markdown: `extensions/drm-copilot/CHANGELOG.md`, four mirrored copies of `execution-environment/SKILL.md`, the promoted lifecycle record, and the feature folder.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 12 production (6 + 6 mirrors), 5 test | 7693 in hook/runtime scan folders; 11394 full `tests/scripts` | PASS 7693 pass, 0 fail; full run 11384 pass, 0 fail, 10 skipped | per-hook 90.58%-95.65% lines | per-hook 93.53%-100.00% lines; artifact total 92.70% lines | 100% of changed executable lines (12 of 12) |
| Python | 0 production, 4 test/test-support | 7367 full suite | PASS 7367 pass, 6 skipped | 94.11% lines, 88.78% branches (repo-wide, merge base) | 94.11% lines, 88.78% branches (repo-wide) | 100% of changed production lines (0 production Python lines changed) |
| TypeScript | 0 production, 1 test | 4130 (root Jest), 24 (changed file) | PASS 4130 pass; 24 pass | 97.99% lines, 92.35% branches (repo-wide, merge base) | 97.99% lines, 92.35% branches (repo-wide) | 100% of changed production lines (0 production TypeScript lines changed) |
| JSON | 2 manifests | covered by Python and Jest manifest tests | PASS | N/A (config) | N/A (config) | N/A |

Baseline Python and TypeScript figures were measured by the reviewer on an extracted copy of the merge-base tree (`git archive 58e5001c5907d74ee24f205690d891b4352fda23`) using the same virtual environment and `node_modules`: Python 7336 passed, 6 skipped; Jest 4122 passed.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: reviewer-generated `coverage/lcov.info` from the merge-base tree (session scratch copy; 56394 of 57553 lines, 8263 of 8947 branches).
- TypeScript post-change coverage artifact: `coverage/lcov.info` (reviewer-generated at head).
- Python baseline coverage artifact: reviewer-generated `artifacts/python/lcov.info` from the merge-base tree (session scratch copy; 16798 of 17849 lines, 5723 of 6446 branches).
- Python post-change coverage artifact: `artifacts/python/lcov.info` (reviewer-generated at head).
- PowerShell baseline coverage artifact: `FEATURE/evidence/baseline/ps-tests.2026-10-20T13-11.md` (per-hook values read from `artifacts/pester/powershell-coverage.xml` at baseline).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`; `FEATURE/evidence/qa-gates/ps-tests.2026-10-20T15-00.md`.
- Per-language comparison summary: Section 1.2.1 and `FEATURE/evidence/qa-gates/coverage-delta.2026-10-20T15-00.md`.

`FEATURE` denotes the active feature folder of issue #984.

---

## Executive Summary

The branch fixes issue #984: the Claude core pack manifest omitted `.claude/hooks/enforce-completion-helpers.ps1`, and `enforce-completion-consistency.ps1` denied every Write/Edit call when that helper failed to load. The change adds seven paths to the Claude `core.json` and one to the Codex `core.json`, converts six hooks (four Claude, two Codex) to the H1 named-handler pattern so an evaluation-only dependency failure denies only in-scope paths, empties the grandfathered exception sets in the Python and TypeScript manifest-completeness tests, adds a Python manifest dependency-closure test with in-memory scanner self-tests, adds four Pester suites proving allow/deny behavior on repository and bundle roots, and adds a `### Fixed` CHANGELOG entry.

The reviewer re-ran the Python, TypeScript, JSON-manifest, and generator checks (all pass), generated the Python and TypeScript coverage artifacts that were absent, parsed the existing PowerShell coverage artifact, verified byte-identical mirror parity for every changed hook and skill copy, verified that `hook-dependency-guard.ps1` and the Codex `enforce-completion-consistency.ps1` are unchanged, and confirmed the 500-line limit. PowerShell format, analyzer, and Pester results are taken from the executor's loop-pass-3 evidence because the review environment does not invoke PowerShell directly; the coverage figures in that evidence match the on-disk coverage artifact exactly.

No blocking finding was identified. Non-blocking observations are listed in Section 8 and in the code review.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` + `.claude/rules/self-explanatory-code-commenting.md`
- PASS `.claude/rules/powershell.md`
- PASS `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md`
- N/A Bash: no shell files changed
- PASS JSON: both manifests parse and are consumed by passing tests; the Codex manifest matches generator serialization (`--check` exit 0)

**Temporary artifacts cleanup:**
- PASS No temporary script is committed. The executor's `SCRATCH/` scripts are outside the repository; the reviewer's parsing scripts are in the session scratchpad.
- PASS The new Python scanner module is retained test infrastructure with its own self-test file.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope. The caller prompt requested a review of the whole branch diff against the merge base.

The plan of record states that "no Python or TypeScript coverage threshold applies" because only test files changed in those languages. That statement is a plan assertion, not a caller instruction; it was not applied as a scope limit. Python and TypeScript coverage were measured repo-wide in this review and received explicit verdicts (Section 1.2.1).

---

## Evidence Location Compliance

- `git diff --name-only 58e5001c5907d74ee24f205690d891b4352fda23..HEAD` filtered for `artifacts/(baselines|qa|evidence|coverage)/`: no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- All committed evidence is under `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).
- A scan of added diff lines for host paths (`C:/Users`, `/home/`, `AppData`) found none.

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Pester suites reset `$script:<Handler>ImportFailure` and dependency-failure state in `finally` and re-dot-source the clean hook in `AfterAll`. Seeded shuffled Pester runs (seeds 984, 9841, 98401) pass: `evidence/regression-testing/pester-shuffle-seed-*.2026-10-20T15-03.md`. Python reversed-order run passes: `evidence/regression-testing/python-reversed-order.2026-10-20T14-46.md`. Jest shuffle seed 984 passes. |
| **Isolation** - Each test targets single behavior | PASS | Rows are labeled CH0-CH6, DV0-DV5, BB0-BB4, CB0-CB3, each asserting one decision path; Python self-tests cover one form (F1-F7) per parametrized case. |
| **Fast Execution** - Tests complete quickly | PASS | Targeted Python files: 58 passed in 0.76s (reviewer run). Changed Jest file: 24 passed. Full Python suite 118s for 7367 tests. |
| **Determinism** - Consistent results | PASS | Missing-dependency simulation uses `Mock Import-Module { }` and `Mock Join-Path { throw }` with a `-ParameterFilter` on the leaf; envelopes are in-memory; checkpoint read seam is mocked. No clock or randomness in the changed code. |
| **Readability & Maintainability** - Clear structure | PASS | Pester `It` names state the condition and outcome; Python tests have docstrings; Arrange/Act/Assert comments are present in the Pester rows. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell per-hook baseline: `evidence/baseline/ps-tests.2026-10-20T13-11.md` (93.29%, 95.65%, 90.58%, 90.58%, 95.24%, 95.24%). Python (94.11% lines, 88.78% branches) and TypeScript (97.99% lines, 92.35% branches) baselines measured by the reviewer on the merge-base tree. |
| **No Coverage Regression** | PASS | Every changed hook held or rose: 93.29 to 95.33, 95.65 to 100.00, 90.58 to 93.53 (x2), 95.24 to 95.28 (x2). `evidence/qa-gates/coverage-delta.2026-10-20T15-00.md`; reviewer re-parse of `artifacts/pester/powershell-coverage.xml` gives the same values. |
| **New Code Coverage >= 85% line** | PASS | Changed executable lines: 2 per hook, 12 of 12 covered (100%). No new production file. |
| **Comprehensive Coverage** | PASS | Each new handler branch (allow out-of-scope, deny in-scope) is exercised on both repository and bundle roots. |
| **Positive Flows** - Valid inputs | PASS | CH0, DV0, BB0, CB0 (helper loaded, out-of-scope allowed); CH1, DV1, BB1, CB1 (helper failed, out-of-scope allowed). |
| **Negative Flows** - Invalid inputs | PASS | CH2 (six checkpoint path forms denied), DV3, BB2, CB2 (in-scope denied naming the leaf). |
| **Edge Cases** - Boundary conditions | PASS | Relative, absolute, and backslash checkpoint paths; missing `file_path` allowed; Edit without content on a discovery path allowed (DV2). |
| **Error Handling** - Error paths | PASS | CH3/DV4 (HookPayload.psm1 failure still denies every call); CH6 (envelope anomaly denies); Python `test_target_escaping_bundle_root_is_rejected` (ValueError). |
| **Concurrency** - If applicable | N/A | Hooks are single-invocation processes; no concurrency in the changed code. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.58% lines (lowest changed hook; range 90.58%-95.65%) -> Post-change: 93.53% lines (lowest changed hook; range 93.53%-100.00%). Change: +0.04 to +4.35 points per hook; no hook regressed. New/changed-code coverage: 100% (12 of 12 changed executable lines). Artifact total (LINE counter): 92.70% (17750 covered, 1398 missed). No branch gate applies (Pester). Disposition: PASS. Evidence: `FEATURE/evidence/baseline/ps-tests.2026-10-20T13-11.md`, `FEATURE/evidence/qa-gates/ps-tests.2026-10-20T15-00.md`, `FEATURE/evidence/qa-gates/coverage-delta.2026-10-20T15-00.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 94.11% lines, 88.78% branches (merge base, 216 files) -> Post-change: 94.11% lines, 88.78% branches (head, 216 files; 16798 of 17849 lines, 5723 of 6446 branches). Change: 0.00 points lines, 0.00 points branches. New/changed-code coverage: 100% of changed production Python lines; the branch changes 0 production Python lines (the four changed Python files are test infrastructure under `tests/`, which the coverage configuration omits), so the no-regression check holds with no line to evaluate. Thresholds 85% line and 75% branch met. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (head) and the merge-base measurement described above.
- TypeScript: Baseline: 97.99% lines, 92.35% branches (merge base, 237 files) -> Post-change: 97.99% lines, 92.35% branches (head, 237 files; 56394 of 57553 lines, 8263 of 8947 branches). Change: 0.00 points lines, 0.00 points branches. New/changed-code coverage: 100% of changed production TypeScript lines; the branch changes 0 production TypeScript lines (the one changed TypeScript file is a test), so the no-regression check holds with no line to evaluate. Thresholds met. Disposition: PASS. Evidence: `coverage/lcov.info` (head) and the merge-base measurement described above.
- C#: no changed files. Disposition: N/A. Evidence: branch diff contains no `.cs` file.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Pester assertions use `-Because $decision.permissionDecisionReason`; Python closure assertions emit `<pack>: <source> -> <target>` messages; fail-before evidence shows actionable messages (`evidence/regression-testing/fail-before-python-ts.2026-10-20T13-34.md`). |
| **Arrange-Act-Assert Pattern** | PASS | Pester rows carry Arrange/Act/Assert comments; Python self-tests follow the structure. |
| **Document Intent** | PASS | Suite `.SYNOPSIS`/`.DESCRIPTION` blocks state the handler and issue; Python module docstrings state purpose and approach. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or external process. The closure test reads committed bundle files read-only, consistent with the existing completeness tests. |
| **Use Mocks/Stubs** | PASS | `Import-Module`, `Join-Path` (leaf-filtered), `Get-CheckpointFileContent`, `Read-ClaudeHookRawPayload`, and helper functions are mocked in Pester. |
| **Environment Stability** | PASS | Grep for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `tmp_path`, `tempfile`, `Start-Sleep`, `Out-File`, `Set-Content` in the new tests: no matches. No temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy audit for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` and `spec.md` (FR-1 to FR-8, NFR-1 to NFR-8, AC1 to AC9). |
| **Read existing change plans** | PASS | `research/2026-10-20T12-15-completion-helpers-manifest-research.md`; `evidence/baseline/phase0-instructions-read.2026-10-20T12-51.md`. |
| **Document the plan** | PASS | `plan.2026-10-20T07-56.md`: 57 tasks checked, 0 unchecked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Each hook change is two lines: a single-statement handler assignment and a single-line in-scope deny after the path-scope allow. |
| **Reusability** | PASS | Reuses the established H1 named-handler pattern (#565) and the existing exemption table; the closure test imports pack-selection logic from `scripts.dev_tools.push_down_claude_pack_selection` and `push_down_codex_pack_selection` rather than restating it. |
| **Extensibility** | PASS | Handler rows gain a per-entry leaf column; the scanner's named non-dependency forms are a tuple of patterns. |
| **Separation of concerns** | PASS | The scanner module is pure text processing; file I/O is confined to the closure test's `Surface` loader. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One scanner module, one scanner self-test file, one real-bundle closure test, one Pester suite per hook family. |
| **Under 500 lines** | PASS | Largest changed file `.claude/hooks/enforce-python-batch-budget.ps1` 496 lines; `enforce-powershell-batch-budget.ps1` 493; `enforce-completion-consistency.ps1` 489; scanner 458; all others below 350 (reviewer `wc -l`). |
| **Public vs internal** | PASS | Scanner helpers are `_`-prefixed; public functions are the four documented scanners. |
| **No circular dependencies** | PASS | Test module imports production `scripts.dev_tools` modules one-way. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `$script:CompletionHelpersImportFailure`, `find_unrecognized_psscriptroot`, `extract_hook_command_paths`. |
| **Docs/docstrings** | PASS | Every Python function and the `Surface` dataclass carry Google-style docstrings; loops and branches carry intent comments. |
| **Comment why, not what** | PASS | Hook comment states handler id, issue, and the allow/deny consequence. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Black `--check`: "4 files would be left unchanged."; Prettier `--check`: "All matched files use Prettier code style!"; PowerShell format: 0 of 11 files differ (`evidence/qa-gates/ps-format.2026-10-20T15-00.md`). |
| **2. Linting** | PASS | Ruff: "All checks passed!"; ESLint on the changed test: exit 0; PSScriptAnalyzer: 0 findings across 11 files (`evidence/qa-gates/ps-analyze.2026-10-20T15-00.md`). |
| **3. Type checking** | PASS | Pyright: "0 errors, 0 warnings, 0 informations"; `npm run typecheck` (extension and test tsconfig): exit 0. PowerShell: N/A. |
| **4. Architecture-boundary tests** | PASS | No module boundary changed; guard, structural (S1-S6), and exemption suites pass in the Pester evidence (`evidence/regression-testing/pass-after-pester.2026-10-20T13-49.md`, `evidence/qa-gates/ps-tests.2026-10-20T15-00.md`). |
| **5. Unit tests** | PASS | Python 7367 passed, 6 skipped; root Jest 4130 passed; changed Jest file 24 passed; Pester 7693 passed (scan folders) and 11384 passed, 10 skipped (full `tests/scripts`). |
| **6. Contract / schema checks** | PASS | Resource-contract and completeness tests pass; `generate_codex_agent_variants --check` exit 0 (reviewer re-run). |
| **7. Integration tests** | PASS | Process-level `&` route rows CH4, CH5, DV5, BB4 pass. |
| **Full toolchain loop** | PASS | Executor recorded three loop passes; the third pass is clean across all stages. |
| **Explicit reporting** | PASS | Commands and results in Appendix B and the evidence folder. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `fix(pack-manifest): restore missing Claude core pack dependencies`; Section 9. |
| **Design choices explained** | PASS | `evidence/other/decision-record.2026-10-20T12-51.md` (FR-2, FR-6, FR-7, handler ids H9-H12, leaf column). |
| **Update supporting documents** | PASS | `extensions/drm-copilot/CHANGELOG.md` `### Fixed`; execution-environment brief lists the new closure test in all four mirrored copies. |
| **Provide next steps** | PASS | CHANGELOG instructs downstream repositories on 1.1.19-1.1.21 to re-run the Claude push-down. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check <4 changed files>`<br>**Result:** 4 files would be left unchanged. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <4 changed files>`<br>**Result:** All checks passed! No suppressions added. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <4 changed files>`<br>**Result:** 0 errors, 0 warnings, 0 informations (strict mode). |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest --cov --cov-branch -q -x --no-header -p no:randomly`<br>**Result:** 7367 passed, 6 skipped. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Full annotations; `Literal` alias `HookCommandSource`; `cast` used for JSON narrowing; no `Any`. |
| **Dataclasses for value objects** | PASS | `Surface` is a frozen dataclass. |
| **Protocols/ABCs for interfaces** | N/A | Single implementation; no interface needed. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | `ValueError` for a target escaping the bundle root; no broad `except`. |
| **Logging over print** | PASS | No `print`. |
| **Invariants at construction** | N/A | `Surface` is a loader result with no invariants beyond its types. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` plus a non-writing formatter comparison<br>**Result:** porcelain unchanged; 0 of 11 files differ (`evidence/qa-gates/ps-format.2026-10-20T15-00.md`). |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings (`evidence/qa-gates/ps-analyze.2026-10-20T15-00.md`). |
| **Fix all findings** | PASS | No findings. Baseline analyzer findings: `evidence/baseline/ps-analyze.2026-10-20T12-58.md`. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Changed lines use only `try/catch`, `Join-Path`, and string interpolation; hooks keep their existing `#Requires`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | No new functions in production hooks; existing `CmdletBinding` functions unchanged. |
| **Parameter validation** | N/A | No parameter changes. |
| **Avoid global state** | PASS | Handler state is script-scoped (`$script:`), matching H1. |
| **Error handling** | PASS | In-scope paths still fail closed with the hook's existing deny code; `HookPayload.psm1` and `codex-pretooluse-file-mapping.ps1` (scope dependencies) remain guarded by `Add-HookDependencyFailure`. `hook-dependency-guard.ps1` unchanged at all locations. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 489, 240, 496, 493, 351, 348 lines; helpers 174; new suites 145-223. |
| **Approved verbs** | PASS | New test helpers: `Initialize-Ch984State`, `ConvertTo-Ch984Envelope`, `Invoke-Ch984HookProcess` (approved verbs). |
| **Comment why** | PASS | Handler comment cites H9 and #984 and states the allow/deny consequence. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | See 3B.1. |
| **Step 2: Analyze** | PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | 7693 passed, 0 failed (scan folders, coverage-enabled); 11384 passed, 0 failed, 10 skipped (full `tests/scripts`, `evidence/regression-testing/ps-tests-full-run.2026-10-20T15-20.md`). |
| **Rerun loop if needed** | PASS | Three loop passes recorded; final pass clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | PASS | Claude manifest edits preserve the existing sorted, two-space layout; Codex manifest matches generator serialization (`generate_codex_agent_variants --check` exit 0). |
| **Schema validation** | PASS | Manifests are loaded by `load_pack_manifests` in passing tests. |
| **Required $schema** | N/A | Pack manifests are not schema-governed files in this repository. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | Both files parse with `json.loads` and `JSON.parse`. |
| **Deterministic key order** | PASS | Claude entries inserted in sorted position; Codex entry in generator order. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | `npx prettier --check test/lib/push-down/claude-pack-manifest-completeness.test.ts`: All matched files use Prettier code style! |
| **Linting with ESLint** | PASS | `npx eslint <file>`: exit 0. |
| **Type checking** | PASS | `npm run typecheck`: exit 0. No `any`, no suppression; a type guard narrows `unknown` JSON. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Pytest with `pytest.mark.parametrize` for form cases and published-path rows. |
| **Coverage expectation** | PASS | Repo-wide 94.11% lines, 88.78% branches; no production Python changed. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One form per self-test case; one closure property per real-bundle test. |
| **Mocking sparingly** | PASS | No mocks; pure functions over in-memory text. |
| **Organization** | PASS | Files under `tests/scripts/dev_tools/` beside the existing completeness tests. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_synthetic_manifest_missing_target_is_reported`, `test_unrecognized_psscriptroot_form_fails_exhaustiveness_guard`. |
| **Docstrings/comments** | PASS | Every test has a docstring. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Targeted run 58 passed; full run 7367 passed. |
| **No Alternative Test Runners** | PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `BeforeDiscovery`, `-ForEach`, `Should -Invoke`. |
| **Use PoshQC Configuration** | PASS | **Command:** `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-hooks,tests/scripts/codex-hooks,tests/scripts/claude-runtime`. |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | Suites declare `#Requires -Version 7.0`, consistent with the existing hook suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | One decision path per row. |
| **Test Behavior Over Implementation** | PASS | Assertions on `permissionDecision` and reason text; `Should -Invoke ... -Times 0` proves helpers are not called on the deny path. |
| **Mocking Used Sparingly** | PASS | Mocks limited to the load seam, checkpoint read seam, and payload reader. |
| **Organization** | PASS | **Test files:** `tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/codex-hooks/*.Tests.ps1`<br>**Code files:** `.claude/hooks/*.ps1`, `.codex/hooks/*.ps1`<br>Matches the existing hook-suite layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All four new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | One parametrized `Describe` per root/hook, `It` per row. |
| **Logical Grouping** | PASS | Grouped by hook and root. |
| **Docstrings/Comments** | PASS | Comment-based help at the top of each suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | See 4B.1. |
| **No Alternative Test Runners** | PASS | Pester through PoshQC. |

---

## 5. Test Coverage Detail

### `.claude/hooks/enforce-completion-consistency.ps1` (CH0-CH6, x2 roots)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| CH0 allows a non-checkpoint Edit when the helpers load | Positive | path-scope allow | PASS |
| CH1 allows a non-checkpoint Edit when the helper fails to load | Positive | handler assignment, path-scope allow | PASS |
| CH2 denies Write/Edit of relative, absolute, backslash checkpoint path | Negative | handler deny | PASS |
| CH3 denies when HookPayload.psm1 fails to load | Error Handling | dependency decision | PASS |
| CH4/CH5 process route allow and deny | Integration | entry point | PASS |
| CH6 envelope anomaly denies; missing file_path allows | Edge Case | envelope checks | PASS |

**Coverage:** 95.33% (143 of 150 lines). Changed executable lines covered: 2 of 2.

### `.claude/hooks/enforce-discovery-artifact-gate.ps1` (DV0-DV5, x2 roots)

**Coverage:** 100.00% (70 of 70 lines). Changed executable lines covered: 2 of 2.

### Claude and Codex batch-budget hooks (BB0-BB4 and CB0-CB3, x2 hooks, x2 roots)

**Coverage:** Claude 93.53% each (130 of 139); Codex 95.28% each (101 of 106). Changed executable lines covered: 8 of 8.

### `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` (16 self-tests)

F1-F7 form extraction, line and block comment handling, `#` inside a quoted literal, named non-dependency forms, unrecognized form, synthetic missing target, bundle-root escape, and command-text extraction from settings, frontmatter, and TOML. Test-support module under `tests/`, outside the coverage population by configuration.

**Not covered:** None identified in production code.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (Python full suite) | 7373 (7367 passed, 6 skipped) | PASS |
| Total Tests (root Jest) | 4130 passed, 284 suites | PASS |
| Total Tests (Pester scan folders) | 7693 passed | PASS |
| Total Tests (Pester full `tests/scripts`) | 11394 (11384 passed, 10 skipped) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Python 118s; Jest 12.4s; targeted Python 0.76s | PASS |
| Test File Size | largest new test file 347 lines | PASS |
| Code Coverage | PowerShell 92.70% lines (artifact total); Python 94.11% lines / 88.78% branches; TypeScript 97.99% lines / 92.35% branches | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <files>` | 4 files would be left unchanged | PASS |
| Ruff Linting | `poetry run ruff check <files>` | All checks passed! | PASS |
| Pyright Type Checking | `poetry run pyright <files>` | 0 errors | PASS |
| Pytest Tests | `poetry run pytest --cov --cov-branch` | 7367 passed, 6 skipped | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `run_poshqc_format` + non-writing comparison | 0 of 11 files differ | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` (repository settings) | 0 findings | PASS |
| Pester Tests | `Invoke-PoshQCTest` | 7693 passed; full run 11384 passed | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check <file>` | clean | PASS |
| ESLint | `npx eslint <file>` | exit 0 | PASS |
| TSC | `npm run typecheck` | exit 0 | PASS |
| Jest | `node run-jest.cjs <file>`; `npm run test:unit:coverage` | 24 passed; 4130 passed | PASS |

**Other:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Codex generator | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | exit 0 | PASS |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |
| Tier classification | `poetry run python -m scripts.dev_tools.check_quality_tiers` | quality-tiers: OK (25 entries, 25 discovered projects) | PASS |
| Mirror parity | `cmp` of each changed repository file with its bundle copy | all equal | PASS |
| Modified workflows | branch diff filtered for `.github/workflows/**`, `.github/actions/**`, `scripts/benchmarks/**` | none | N/A |

**Notes:** No pre-existing failures were observed. PowerShell results come from the executor's evidence; the reviewer verified that the per-hook coverage values in that evidence equal the values in `artifacts/pester/powershell-coverage.xml`.

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap. Non-blocking observations:

- Python and TypeScript coverage artifacts were absent at review start. The plan treated those languages as having no coverage obligation. The reviewer generated both artifacts at head and at the merge base; both languages exceed the thresholds and show no change between baseline and head. No remediation is required.
- The executor's baseline Pester console summary reported "Covered 64.08%" command coverage for the derived population, while the LINE counter in the post-change `powershell-coverage.xml` totals 92.70%. The two figures come from different reporting paths and were not reconciled in the evidence. The coverage artifact is the authoritative source for this audit.
- The six bundle copies of the converted hooks under `extensions/drm-copilot/resources/` are not part of the Pester coverage population (pre-existing configuration). They are byte-identical to the measured repository copies and are exercised by the mirror-root test rows.
- Quality tiers: `quality-tiers.yml` exists on the base branch; changed production paths are in classified projects (`.claude/hooks` T3, `.codex/hooks` T3, `extensions/drm-copilot` T3); the tier check passes. No new project was introduced.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

1. **`test_documented_exceptions_remain_absent_from_every_manifest`** (Python completeness test) - replaced by `test_pre_existing_exception_set_is_empty`.
   - **Reason:** spec FR-3 requires the exception set to be empty.
   - **Impact:** none; the "remain absent" property no longer has members to check.
   - **Justification:** required by the specification.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. `fix(pack-manifest): restore missing Claude core pack dependencies` (head)
2. `docs(984): add research, spec, and atomic plan for completion-helpers manifest gap`

### Files Modified

1. **`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`** (MODIFIED) - adds seven paths (FR-1).
2. **`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`** (MODIFIED) - adds `.codex/scripts/post-codex-worktree-session.ps1` (FR-2).
3. **Six hooks and six bundle copies** (MODIFIED) - H9-H12 named-handler conversion (FR-5, FR-6).
4. **`tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`** (MODIFIED) - per-row leaf column and eight handler rows.
5. **Four Pester suites** (NEW) - handler proofs on repository and bundle roots.
6. **Python scanner, scanner self-tests, closure test** (NEW); **Python and TypeScript completeness tests** (MODIFIED) - FR-3, FR-4.
7. **`extensions/drm-copilot/CHANGELOG.md`** (MODIFIED) - `### Fixed` entry (FR-8).
8. **Four copies of `execution-environment/SKILL.md`** (MODIFIED) - lists the new closure test.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policies are satisfied by verified evidence. Coverage for every language with changed files has an explicit PASS verdict with numeric post-change metrics; PowerShell also has numeric baseline and changed-line metrics.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: spec, research, and plan present.
- PASS Design Principles: minimal two-line hook conversions using the established H1 pattern.
- PASS Module & File Structure: all files at or below 496 lines.
- PASS Naming, Docs, Comments: complete docstrings and intent comments.
- PASS Toolchain Execution: all seven stages pass.
- PASS Summarize & Document: CHANGELOG and decision record present.

#### Language-Specific Code Change Policy (Section 3)

**For Python:** PASS tooling; PASS design and typing; PASS error handling.

**For PowerShell:** PASS tooling; PASS design and safety; PASS structure and naming; PASS toolchain.

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:** PASS framework, style, naming, toolchain.

**For PowerShell:** PASS framework, style, naming, toolchain.

---

### Metrics Summary

- PASS 0 failing tests across Python (7367), Jest (4130), and Pester (11384 full run).
- PASS PowerShell changed-line coverage 100%; per-hook 93.53%-100%.
- PASS Python repo-wide 94.11% lines, 88.78% branches.
- PASS TypeScript repo-wide 97.99% lines, 92.35% branches.
- PASS All code quality checks passing.

---

### Recommendation

**Ready for merge**, subject to the orchestrator's S9 CI green gate on the final PR head. No workflow file is modified, so the `modified-workflow-needs-green-run` rule does not fire.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1` > repository, mirror > CH0, CH1 (x2 paths), CH2 (x6 forms), CH3, CH4, CH5, CH6
- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1` > repository, mirror > DV0, DV1 (x2 paths), DV2, DV3, DV4, DV5
- `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1` > Python and PowerShell hooks x repository, mirror > BB0-BB4
- `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1` > Python and PowerShell hooks x repository, mirror > CB0-CB3
- `tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py::test_extracts_target_for_form[F1..F7]`, `::test_ignores_reference_in_line_comment`, `::test_ignores_reference_in_block_comment`, `::test_hash_inside_quoted_literal_does_not_start_comment`, `::test_named_non_dependency_forms_are_recognized`, `::test_unrecognized_psscriptroot_form_fails_exhaustiveness_guard`, `::test_synthetic_manifest_missing_target_is_reported`, `::test_target_escaping_bundle_root_is_rejected`, `::test_hook_command_paths_from_settings_frontmatter_and_toml`
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py::test_scanned_source_floor`, `::test_claude_manifest_powershell_dependency_closure`, `::test_codex_manifest_powershell_dependency_closure`, `::test_every_psscriptroot_occurrence_is_recognized`, `::test_codex_routing_module_candidates_are_in_codex_core`, `::test_claude_command_text_closure`, `::test_codex_command_text_closure`, `::test_core_only_selection_publishes_issue_984_path[x7]`, `::test_codex_core_selection_publishes_issue_984_path[x2]`
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest`, `::test_pre_existing_exception_set_is_empty`
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` > keeps the pre-existing exception set empty (issue #984); issue #984: <path> is present in the core pack manifest (x7)

---

## Appendix B: Toolchain Commands Reference

Commands run by the reviewer:

```bash
git diff --stat 58e5001c5907d74ee24f205690d891b4352fda23..HEAD
git diff --name-status 58e5001c5..HEAD
poetry run black --check <4 changed Python files>
poetry run ruff check <4 changed Python files>
poetry run pyright <4 changed Python files>
poetry run pytest -q -p no:cacheprovider --no-cov <6 manifest and contract test files>
poetry run pytest --cov --cov-branch -q -x --no-header -p no:randomly
npm run test:unit:coverage
npm --prefix extensions/drm-copilot run typecheck
(extensions/drm-copilot) npx prettier --check test/lib/push-down/claude-pack-manifest-completeness.test.ts
(extensions/drm-copilot) npx eslint test/lib/push-down/claude-pack-manifest-completeness.test.ts
(extensions/drm-copilot) node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.check_quality_tiers
cmp <repository file> <bundle copy>   # for each changed hook and skill copy

# Merge-base coverage baseline (extracted tree in the session scratchpad)
git archive 58e5001c5907d74ee24f205690d891b4352fda23 | tar -x -C <scratch>/base
(<scratch>/base) <venv>/python -m pytest --cov --cov-branch -q --no-header -p no:cacheprovider
(<scratch>/base) npm run test:unit:coverage
```

PowerShell commands recorded by the executor (evidence under `evidence/qa-gates/` and `evidence/regression-testing/`):

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1
Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/claude-hooks,tests/scripts/codex-hooks,tests/scripts/claude-runtime -DisableKoverageCopy
Invoke-PoshQCTest -Root . -ScanFolders tests/scripts -DisableKoverageCopy
Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 <files>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-20
**Policy Version:** Current (as of audit date)
