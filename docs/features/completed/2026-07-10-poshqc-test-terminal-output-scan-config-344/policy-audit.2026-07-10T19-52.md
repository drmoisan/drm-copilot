# Policy Compliance Audit: poshqc-test-terminal-output-scan-config (Issue #344)

**Audit Date:** 2026-07-10
**Reviewer:** feature-review agent
**Base Branch:** `main` (merge-base `cf036d3f5c1608f900d2ad23e08f809713101fa3`)
**Head:** `drm-copilot-wt-2026-07-10T16-55` @ `2ed08b193e9adaabd115983f56d0cf2f3992ffad`
**Template source note:** The MCP resolver tool `resolve_policy_audit_template_asset` could not be invoked in this review session; this artifact was instantiated from the bundled asset source file that the resolver serves (`extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`), which is byte-for-byte the same template content. The instruction block was removed per template guidance.

**Code Under Test:**

Production TypeScript: `extensions/drm-copilot/src/poshqc-terminal-output.ts` (new), `extensions/drm-copilot/src/poshqc-scan-config.ts` (new), `extensions/drm-copilot/src/poshqc-folder-picker.ts` (new), `extensions/drm-copilot/src/poshqc-command-registration.ts`, `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`.
Production PowerShell: `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` (new), `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, plus byte-identical bundled mirrors under `extensions/drm-copilot/resources/powershell/PoshQC/` (including resynced `PoshQC.psd1` and `settings/pester.runsettings.psd1`).
Configuration: `config/poshqc-scan.json` (new).
Tests: `extensions/drm-copilot/test/poshqc-terminal-output.test.ts`, `test/poshqc-scan-config.test.ts`, `test/poshqc-folder-picker.test.ts`, `test/extension.run-poshqc-commands.test.ts`, `test/mcp-server.test.ts`, `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
Documentation: feature-folder scoping docs and evidence tree.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 7 production, 5 test | 1640 tests | PASS 1640 pass, 0 fail (gate log) | 96.64% lines, 88.61% branches | 96.77% lines, 88.78% branches (gate log; the on-disk lcov artifact is stale — see 1.2.1) | 94.27%–100% lines, 76.92%–100% branches per file (gate log; not artifact-corroborated) |
| PowerShell | 3 production (+3 bundled mirrors, 2 bundled data files), 3 test | 1103 tests | PASS 1103 pass, 0 fail, 9 disabled | 93.44% lines (1039/1112, report-level; no branch counter emitted) | 93.44% lines (1039/1112, verified from `artifacts/pester/powershell-coverage.xml`; no branch counter emitted) | 0% instrumented (changed `.psm1` files are outside `CodeCoverage.Path`) |
| Python | 1 test file (`test_poshqc_bundled_parity.py`), 0 production | 1 parity test | PASS 1 pass, 0 fail | N/A (no Python coverage artifact on disk) | N/A (no Python coverage artifact on disk) | N/A (test-only change) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/baseline/baseline-ts-test-coverage.md` (numeric baseline 96.64% lines / 88.61% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` — present but stale relative to branch HEAD (mtime 2026-07-10 17:43; omits the three new modules; totals equal the recorded baseline); numeric post-change figures exist only in the gate log `evidence/qa-gates/final-ts-test-coverage.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/baseline/baseline-ps-test-coverage.md` (93.44% report-level line)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (report-level LINE covered=1039 missed=73, independently re-parsed in this review)
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/qa-gates/coverage-comparison.md`

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** Applied. Required post-change machine-readable coverage evidence is incomplete for TypeScript (stale artifact), unavailable for the changed PowerShell production files (outside instrumentation), and absent for Python. The verdict is therefore BLOCKED, not PASS.

---

## Executive Summary

This audit covers the full branch diff `cf036d3f..2ed08b19` (61 files, +11953/-55) against `main`, per the feature-vs-base scope invariant. The feature adds integrated-terminal streaming for the `Run PoshQC Test` command, reconciles the bundled PoshQC module snapshot with the workspace copies via an extended byte-parity gate, introduces a persisted scan-folder configuration (`config/poshqc-scan.json`) consumed identically by the task, command, and MCP surfaces, and replaces the native folder dialog with a seeded multi-select QuickPick.

Toolchain execution evidence (executor QA gates, all EXIT_CODE 0) covers format, lint, type-check, and tests for TypeScript, PowerShell, and Python. Implementation quality is high and all 16 acceptance criteria except the coverage clause of AC16 are satisfied. Three blocking findings remain, all in the coverage-evidence category (section 8): the TypeScript post-change lcov artifact is stale relative to HEAD, the changed PowerShell production modules are outside the coverage-measurement denominator with no approved exception, and no Python coverage artifact exists despite a changed Python file.

**Policy documents evaluated:**
- [x] `general-code-change` policy (`.claude/rules/general-code-change.md`)
- [x] `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- [x] Python: `.claude/rules/python*` (test-only change in scope)
- [x] PowerShell: `.claude/rules/powershell.md`
- [x] TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- N/A C#: no C# files changed
- N/A GitHub Actions: no workflow files changed (`modified-workflow-needs-green-run` rule not triggered — no diff under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`)

**Temporary artifacts cleanup:**
- [x] No temporary/one-time scripts remain in the diff; all changed script files are production modules or tests with suites.

### Rejected Scope Narrowing

None detected. The caller instructed a full feature-vs-base audit across all languages with changed files; no narrowing was attempted.

### Evidence Location Compliance

PASS. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. `git diff --name-only cf036d3f..HEAD` contains no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All committed evidence lives under the canonical `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/<kind>/` tree.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Jest suites use fresh in-memory `FileSystem` fakes and harness mocks per test; Pester suites inject `$ReadContent`/`$TestPathExists`/`$Logger` scriptblocks per `It`. No shared mutable state observed in the new suites. |
| **Isolation** - Each test targets single behavior | PASS | One behavior per `it`/`It` (e.g., `poshqc-scan-config.test.ts` has one case per validation rule; `PoshQC.ScanConfig.Tests.ps1` has 12 focused It blocks). |
| **Fast Execution** - Tests complete quickly | PASS | TS suite: 140 suites / 1640 tests, single gate run exit 0. Pester: 1103 tests in one run. No timer waits in new tests. |
| **Determinism** - Consistent results | PASS | Grep of all new/changed test files found no `setTimeout`, `setInterval`, `Date.now`, `Math.random`, `Start-Sleep`, or `Thread.Sleep`. All I/O flows through injected seams. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive test names (e.g., "throws an error naming the file for an absolute-path entry"); Arrange–Act–Assert structure observed on inspection. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | TS: 96.64% lines / 88.61% branches (`evidence/baseline/baseline-ts-test-coverage.md`); PS: 93.44% report-level lines (`evidence/baseline/baseline-ps-test-coverage.md`). Captured before implementation (plan P0-T4/P0-T6). |
| **No Coverage Regression** | PASS (repo-wide) | TS gate log reports 96.64% -> 96.77% lines (+0.13); PS report-level line coverage unchanged at 93.44% (independently re-parsed from `artifacts/pester/powershell-coverage.xml`: LINE covered=1039 missed=73). |
| **New Code Coverage** | FAIL | TS: gate log reports 96.49–100% lines per new module, but the on-disk `coverage/lcov.info` (mtime 17:43) omits all three new modules and its totals equal the baseline, so the per-file figures are not corroborated by a machine-readable artifact at HEAD. PS: the new `PoshQC.ScanConfig.psm1` has zero instrumented lines (outside `CodeCoverage.Path`; confirmed by re-parsing the coverage XML — no PoshQC module among the 16 measured sourcefiles). |
| **Comprehensive Coverage** | PASS | New behavior is covered by 12 + 4 new Pester It blocks and 4 new/extended Jest suites spanning all validation, precedence, picker, terminal, and failure paths. See section 5. |
| **Positive Flows** | PASS | Valid-config read, canonical write, round-trip, terminal streaming, picker accept-path tests present. |
| **Negative Flows** | PASS | Malformed JSON, wrong version, blank entry, absolute path, `..` segment, all-folders-do-not-exist, non-zero child exit — all tested in both consumers where applicable. |
| **Edge Cases** | PASS | Empty selection, cancel (`undefined`), empty `scanFolders`, absent file, whitespace-only content, configured-but-nonexistent folder marker, terminal-exited replacement. |
| **Error Handling** | PASS | AC5 test asserts `CommandExecutionError` with `exitCode`/`stdout`/`stderr` and unchanged `getStderrExcerpt` while the tee is active (`extension.run-poshqc-commands.test.ts:228-247`). |
| **Concurrency** | N/A | No concurrent behavior introduced; spawn pipeline unchanged. |
| **State Transitions** | PASS | Terminal writer lifecycle (pre-open buffering, open flush, close, exited-terminal replacement) tested in `poshqc-terminal-output.test.ts`. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.64% lines / 88.61% branches -> Post-change: 96.77% lines / 88.78% branches (gate log). Change: +0.13% lines, +0.17% branches. New/changed-code coverage: 94.27%–100% lines per file (gate log). Disposition: FAIL — the persisted post-change artifact `extensions/drm-copilot/coverage/lcov.info` is stale relative to HEAD (omits `poshqc-scan-config.ts`, `poshqc-terminal-output.ts`, `poshqc-folder-picker.ts`; totals 31877/32985 = 96.64% equal the baseline), so per-file threshold compliance for the new modules cannot be verified from evidence. Evidence: `evidence/qa-gates/final-ts-test-coverage.md`, `extensions/drm-copilot/coverage/lcov.info`.
- PowerShell: Baseline: 93.44% lines -> Post-change: 93.44% lines. Change: 0.00% (no regression on the measured set). New/changed-code coverage: 0% instrumented for the changed production modules. Disposition: FAIL — the new production file `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` and the modified `PoshQC.Testing.psm1`/`PoshQC.psm1` are outside the `CodeCoverage.Path` denominator; the line >= 85% new-file threshold cannot be evidenced, and no branch counter is emitted by the tool. Behavioral mitigation exists (16 new passing seam-injection It blocks plus the byte-parity lock) but is not an approved policy exception. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/final-ps-test-coverage.md`.
- Python: Disposition: FAIL — the changed file is test-only (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`), but Python has changed files in the branch diff and no Python coverage artifact exists at `artifacts/python/lcov.info`; coverage verification is mandatory for all languages with changed files. Evidence: absence confirmed by directory listing of `artifacts/`; `evidence/qa-gates/final-py-parity.md` records the executor's test-only rationale.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Error-path assertions match exact fail-fast messages that name `config/poshqc-scan.json`; Jest `expect(...).toThrow(...)` with message matchers. |
| **Arrange-Act-Assert Pattern** | PASS | Verified by inspection of the four new/extended Jest suites and two Pester suites. |
| **Document Intent** | PASS | Self-documenting test names; comments explain non-obvious mock plumbing (e.g., `mcp-server.test.ts:13-19`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | In-memory `FileSystem` fake; mocked `createTerminal`/`showQuickPick`/spawn seams; injected PowerShell scriptblocks. No network, no external processes in unit tests. |
| **Use Mocks/Stubs** | PASS | Mocks limited to host seams (VS Code API, filesystem, child process, `$ReadContent`/`$TestPathExists`). |
| **Environment Stability** | PASS | Grep found no temporary-file APIs (`mkdtemp`, `tmpdir`, `New-TemporaryFile`, `GetTempPath`) in the new/changed test files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review for the feature branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #344; spec.md v1.0 with FR-mapped capabilities; research basis in `research/research-findings.md`. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md` records the policy-order read (plan P0-T1). |
| **Document the plan** | PASS | `plan.md` (340 lines) with phased tasks and verification notes. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Tee sink over spawn-pipeline rewrite; config resolution inside the module so MCP converges with zero MCP code change. |
| **Reusability** | PASS | `canonicalizeFolders` shared by reader, writer, picker; `createTeeOutput` generic over `CommandOutput`. |
| **Extensibility** | PASS | `version: 1` schema gate; `test` scoping key leaves room for `format`/`analyze` sections; injectable seams (`createService`, `createTerminalOutput`, `fileSystem`, `$ResolveScanConfig`). |
| **Separation of concerns** | PASS | Pure validation/canonicalization isolated from VS Code API (picker/terminal modules) and from the spawn pipeline (unchanged `command-runtime.ts`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One concern per new module (terminal output, scan config, folder picker, PS scan-config resolution). |
| **Under 500 lines** | PASS | Independently verified with `wc -l`: largest changed production file is `extension.ts` at 488; `repo-automation-service.ts` (487) has no diff; all other changed files 81–472 lines. See `evidence/qa-gates/file-size-check.md`. |
| **Public vs internal** | PASS | TS modules export a minimal surface; `PseudoterminalStreamingWriter` is module-private; PS module exports only `Get-PoshQCScanConfigFolder`. |
| **No circular dependencies** | PASS | `poshqc-folder-picker.ts` -> `poshqc-scan-config.ts` -> `lib/file-system`; no back-edges observed. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Get-PoshQCScanConfigFolder` (approved verb), `readPoshQcScanFolders`, `createTeeOutput`, kebab-case filenames. |
| **Docs/docstrings** | PASS | JSDoc on every exported TS symbol; comment-based help on the PS function. |
| **Comment why, not what** | PASS | e.g., persistence-before-run rationale, StrictMode-safe property access rationale, CRLF normalization rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | TS: `npm run format` clean (`final-ts-format.md`); PS: `run_poshqc_format` clean with byte-identical mirrors (`final-ps-format.md`); Py: `black --check` clean (`final-py-format.md`). All EXIT_CODE 0. |
| **2. Linting** | PASS | TS: ESLint zero errors/warnings (`final-ts-lint.md`); PS: PSScriptAnalyzer zero findings across workspace and bundled trees (`final-ps-analyze.md`); Py: Ruff clean (`final-py-lint.md`). |
| **3. Type checking** | PASS | TS: `tsc --noEmit` zero errors (`final-ts-typecheck.md`); Py: Pyright 0/0/0 (`final-py-typecheck.md`); PS: N/A. |
| **4. Testing** | PASS | TS 1640/1640; PS 1103/1103 (9 disabled); Py parity 1/1. All EXIT_CODE 0. |
| **5–7. Coverage / contract / integration** | PARTIAL | Coverage: see FAIL dispositions in 1.2.1. Contract: extended byte-parity gate (8 file pairs) passing (`parity-gate-extended.md`). Integration: task-vs-command JUnit discovered-set diff recorded (1103=1103, `evidence/regression-testing/junit-diff-post-change.md`). |
| **Explicit reporting** | PASS | Every gate records command, timestamp, and EXIT_CODE in the evidence tree. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Single commit `2ed08b19` with descriptive message; feature docs complete. |
| **Design choices explained** | PASS | spec.md records option selection (research Options A/B/C per capability) and non-goals. |
| **Update supporting documents** | PASS | MCP tool description strings updated in both definition files (AC12). |
| **Provide next steps** | PARTIAL | FR2.5 residual limitation (installed extension converges at next packaged release) is documented and must be carried into the PR description. Remediation items in section 8 are outstanding. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check .` — 231 files unchanged (`final-py-format.md`). |
| **Linting with Ruff** | PASS | `poetry run ruff check .` — all checks passed (`final-py-lint.md`). |
| **Type checking with Pyright** | PASS | 0 errors / 0 warnings (`final-py-typecheck.md`). |
| **Testing with Pytest** | PASS | Extended parity test passes; 8 byte-locked file pairs (`final-py-parity.md`). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | The only Python change extends the typed `POSHQC_PARITY_PATHS` tuple by four path literals; no `Any`. |
| **Dataclasses / Protocols / utility classes** | N/A | No new Python classes or interfaces. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions / logging / invariants** | N/A | Test-data-only change; assertion behavior unchanged. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | `run_poshqc_format` clean; mirrors byte-identical post-format (`final-ps-format.md`). |
| **Linting with PSScriptAnalyzer** | PASS | `run_poshqc_analyze` ok:true, zero findings across workspace, tests, and bundled trees (`final-ps-analyze.md`). |
| **Fix all findings** | PASS | Zero findings on the final pass. |
| **PowerShell 7+ compatible** | PASS | Analyzer settings enforce compatibility; no version-specific syntax added. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Get-PoshQCScanConfigFolder` uses `[CmdletBinding()]`, `[OutputType()]`, named parameters. |
| **Parameter validation** | PASS | `[Parameter(Mandatory = $true)]` on `$Root`; entry-level validation is fail-fast in the function body per FR3.6. |
| **Avoid global state** | PASS | All dependencies injected as scriptblock seams (`$TestPathExists`, `$ReadContent`, `$Logger`, `$ResolveScanConfig`); no script-scoped mutable state added. |
| **Error handling** | PASS | `throw` with file-naming messages; `ConvertFrom-Json -ErrorAction Stop` wrapped with contextual rethrow; no silent catch-alls. |
| **Change budget** | PASS | 3 production files (`PoshQC.ScanConfig.psm1` new, `PoshQC.psm1`, `PoshQC.Testing.psm1`) — at the per-batch cap (<= 3) as an explicit planned batch per spec Constraints; bundled mirrors are mechanical copies locked by the parity gate. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | `PoshQC.ScanConfig.psm1` 125; `PoshQC.Testing.psm1` 421; `PoshQC.psm1` 103 (wc -l verified). |
| **Approved verbs** | PASS | `Get-PoshQCScanConfigFolder` uses the approved verb `Get`. |
| **Comment why** | PASS | StrictMode-safe access, skip-with-warning policy, and precedence rationale all commented. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | `final-ps-format.md`, EXIT_CODE 0. |
| **Step 2: Analyze** | PASS | `final-ps-analyze.md`, EXIT_CODE 0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | `final-ps-test-coverage.md`: 1103 tests, 0 failures via MCP `run_poshqc_test`. |
| **Rerun loop if needed** | PASS | Final pass recorded clean on all stages. |

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier / ESLint / TSC** | PASS | `final-ts-format.md`, `final-ts-lint.md`, `final-ts-typecheck.md`; all EXIT_CODE 0. |
| **Strong typing, no `any`** | PASS | New modules use precise types (`asserts folder is string` narrowing, `ParsedScanConfig` with `unknown` fields, discriminated absence handling). Grep found no new suppressions (`eslint-disable`, `@ts-expect-error`, `@ts-ignore`) in the changed files. |
| **ES modules, naming, file naming** | PASS | ES imports only; kebab-case filenames; PascalCase types, camelCase members. |
| **Error handling** | PASS | Fail-fast errors naming `config/poshqc-scan.json`; JSON parse failure rethrown with context and `{ cause }`. |
| **Dependencies** | PASS | No new dependencies (spec Implementation Strategy; `package.json` not in diff). |
| **Test framework note** | PASS (documented deviation) | The extension package's established harness is Jest (`run-jest.cjs`), not Vitest as `.claude/rules/typescript.md` states generically. The spec explicitly prohibits introducing a second framework; this is a pre-existing package-level convention, not a change introduced by this feature. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | `config/poshqc-scan.json` is strict JSON, no comments or trailing commas. |
| **Schema validation** | PASS | Schema enforced at runtime by both consumers (version gate, entry validation); the file matches the documented schema exactly (verified against spec Configuration Schema). |
| **Deterministic key order** | PASS | Writer emits canonical, sorted, deduplicated content with stable round-trip (AC11 tests). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v` — 1 passed. |
| **Coverage expectation** | FAIL | No Python coverage artifact exists at `artifacts/python/lcov.info`; coverage verification is mandatory for all languages with changed files, even though the sole change is test code. See sections 1.2.1 and 8. |
| **Style / naming / structure** | PASS | Existing parametrized parity test extended in place; mirrors production structure under `tests/scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It` with `BeforeAll`; modern `Should` syntax in both new suites. |
| **Use PoshQC Configuration** | PASS | MCP `run_poshqc_test` with repo runsettings; config-driven default scan set exercised (AC3/AC12). |
| **Test location mirrors code** | PASS | `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1` mirrors `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`. |
| **File naming `*.Tests.ps1`** | PASS | Both new/extended files conform. |
| **Mocking rules** | PASS | Injectable scriptblock seams only (per `.claude/rules/powershell.md` seam options); no direct executable mocking. |
| **No alternative runners** | PASS | Pester via PoshQC only. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | PASS (documented deviation) | Jest via `run-jest.cjs`, the package's single established harness; `*.test.ts` naming; no host runtime required. |
| **AAA, one behavior per test, mock hygiene** | PASS | Verified by inspection of the four new/extended suites; harness mock seams (`createTerminal`, `showQuickPick`, spawn) reset per test. |
| **No external dependencies / no temp files** | PASS | In-memory `FileSystem`; grep confirms no temp-file APIs. |
| **Coverage thresholds** | FAIL | Per-file figures in the gate log exceed thresholds, but the machine-readable lcov artifact at HEAD does not contain the new modules (see 1.2.1). |

---

## 5. Test Coverage Detail

### Get-PoshQCScanConfigFolder (12 It blocks, PoshQC.ScanConfig.Tests.ps1)

| Test scenario | Scenario Type | Status |
|-----------|--------------|--------|
| Absent file returns `@()` | Positive/absence | PASS |
| Blank content returns `@()` | Edge case | PASS |
| Absent/empty `scanFolders` returns `@()` | Edge case | PASS |
| Malformed JSON throws naming the file | Negative | PASS |
| `version` other than 1 throws | Negative | PASS |
| Blank entry throws | Negative | PASS |
| Absolute-path entry throws | Negative | PASS |
| `..` segment throws | Negative | PASS |
| Nonexistent folder skipped with warning | Error handling | PASS |
| All-folders-nonexistent throws | Error handling | PASS |
| All-present success | Positive | PASS |

### Invoke-PoshQCTest scan-config precedence (4 It blocks, PoshQC.ScanFolders.Tests.ps1)

| Test scenario | Scenario Type | Status |
|-----------|--------------|--------|
| Explicit `-ScanFolders` bypasses config | Positive/precedence | PASS |
| Config-yielded folders reach run paths | Positive | PASS |
| Empty config falls back to `Run.Path` defaults | Edge case | PASS |
| Explicit missing folder still throws | Negative | PASS |

### TypeScript new modules

- `poshqc-scan-config.test.ts` (13 cases): absence semantics, all five validation failures, canonical read, canonical write, byte-stable round-trip, path resolution, pure canonicalization.
- `poshqc-terminal-output.test.ts` (6 cases): stable-name creation, CRLF termination, pre-open buffering and flush, post-open streaming and reuse, internal-break normalization, reveal, exited-terminal replacement, tee ordering.
- `poshqc-folder-picker.test.ts` (6 cases): depth-2 enumeration with exclusions, seeded `picked`, warning marker for configured-but-nonexistent folders, persistence-before-return, cancel semantics, empty-selection semantics.
- `extension.run-poshqc-commands.test.ts` (extended): terminal streaming + dual-sink on the command path, AC5 failure semantics, picker multi-select flow.
- `mcp-server.test.ts` (extended): MCP `run_poshqc_test` creates no terminal (AC6).

**Not covered (machine-verified):** the three new TS modules have no entries in the on-disk lcov artifact (stale artifact — remediation item R1); the changed PowerShell `.psm1` files have zero instrumented lines (structural constraint — remediation item R2).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| TypeScript tests | 1640 passed / 1640 total, 140 suites | PASS |
| PowerShell tests | 1103 passed / 1103 executed, 9 disabled, 0 failures | PASS |
| Python parity test | 1 passed / 1 total | PASS |
| TS coverage (gate log) | 96.77% lines, 88.78% branches | PASS (numbers) / FAIL (artifact staleness) |
| PS coverage (report-level, artifact-verified) | 93.44% lines (1039/1112); no branch counter emitted | PASS (measured set) |
| Largest changed file | `extension.ts`, 488 lines | PASS (< 500) |

---

## 7. Code Quality Checks

**For TypeScript (in `extensions/drm-copilot/`):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm run format` | clean, no changes on final pass | PASS |
| ESLint | `npm run lint` | 0 errors, 0 warnings | PASS |
| TSC | `npm run typecheck` | 0 errors | PASS |
| Jest | `npm run test:coverage` | 1640/1640 | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | MCP `run_poshqc_format` | clean; mirrors byte-identical | PASS |
| PSScriptAnalyzer | MCP `run_poshqc_analyze` | ok:true, zero findings | PASS |
| Pester | MCP `run_poshqc_test` | 1103/1103 | PASS |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check .` | 231 files unchanged | PASS |
| Ruff | `poetry run ruff check .` | all checks passed | PASS |
| Pyright | `poetry run pyright` | 0/0/0 | PASS |
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v` | 1 passed | PASS |

**Notes:**
The executor escalated a behavioral observation: running the bundled command wrapper (`run-poshqc-test.ps1`) inside this development repository reports 31 failures in PoshQC's own self-mocking test files (module-instance collision after the FR2.2 `RequiredModules` removal). This audit's determination: **not a blocking finding** — see section 8, "Assessed non-blocking items."

---

## 8. Gaps and Exceptions

### Identified Gaps (blocking — remediation required)

1. **R1 — TypeScript post-change coverage artifact is stale relative to branch HEAD.** `extensions/drm-copilot/coverage/lcov.info` (mtime 2026-07-10 17:43) contains 146 file records whose totals (31877/32985 lines = 96.64%, 4056/4577 branches = 88.62%) equal the recorded baseline, and it contains no records for `poshqc-scan-config.ts`, `poshqc-terminal-output.ts`, or `poshqc-folder-picker.ts`. The final gate log (`final-ts-test-coverage.md`, 18:25) reports compliant per-file figures, but the fail-closed evidence rule prohibits PASS on figures not corroborated by a machine-readable artifact at HEAD. Remediation: rerun `npm run test:coverage` at branch HEAD, confirm per-file thresholds from the regenerated lcov, and record the refreshed comparison in the feature evidence tree.
2. **R2 — Changed PowerShell production modules are outside the coverage-measurement denominator.** The new production file `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` (and the modified `PoshQC.Testing.psm1` / `PoshQC.psm1`) have zero instrumented lines: `PoshQC.psm1` loads sub-modules via `. ([scriptblock]::Create((Get-Content <file> -Raw)))`, so Pester breakpoints never bind (empirically confirmed by the executor; independently confirmed here — no PoshQC module among the coverage XML's 16 sourcefiles). The new-file line >= 85% threshold therefore cannot be evidenced. The Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` states that no production file may be excluded from coverage measurement and that the correct response to untestable lines is refactoring; the constraint is pre-existing, but this branch adds a new production file into the unmeasured set, and no approved exception is recorded. Remediation options: (a) refactor the sub-module loading so breakpoints bind (e.g., dot-source by path) and add the module files to `CodeCoverage.Path`; or (b) record an explicit human-approved exception for the PoshQC module-loading structural constraint. The 16 passing behavioral It blocks and the byte-parity lock are strong mitigations but do not substitute for the required metric absent an approved exception.
3. **R3 — Python coverage artifact absent for a language with changed files.** `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` changed, but no artifact exists at `artifacts/python/lcov.info`. Coverage verification is mandatory for every language with changed files; the test-only nature of the change lowers practical severity but does not waive the artifact requirement. Remediation: run `poetry run pytest --cov` with the lcov reporter, persist the artifact, and record the repo-wide Python figures in the coverage comparison.

### Assessed non-blocking items

- **Bundled-wrapper self-test failures in this development repository (escalated by executor).** Running `run-poshqc-test.ps1` (the bundled command wrapper) against this repository reports 31 failures confined to PoshQC's own self-mocking test files, caused by a module-instance collision between the wrapper's pre-imported bundled `PoshQC` module and the workspace module re-imported by those tests. Determination: **non-blocking**. Rationale: (1) AC2 is defined as discovered-test-set parity, which holds exactly (1103 = 1103, zero set difference, verified in `evidence/regression-testing/junit-diff-post-change.md`); (2) the authoritative PowerShell test gate (task path / MCP path per FR2.4) passes with 0 failures; (3) the collision requires the presence of PoshQC's own self-mocking test files, which exist only in this development repository, not in production consumer repositories; (4) the alternative (restoring the bundled `RequiredModules` block) would violate the byte-identical parity requirement of FR2.2/AC2 and was correctly reverted; (5) no policy rule requires the non-authoritative bundled wrapper to pass PoshQC's self-tests inside the PoshQC development repository. A follow-up issue is recommended (see code review finding CR-4) to address the wrapper's resident-module collision (e.g., wrapper-side `Remove-Module PoshQC` after building the invocation, or self-test-side defensive re-import), because the in-repo command-palette experience currently reports failures that do not reflect defects. This is a developer-experience defect in the development repository only.

### Approved Exceptions

**None.** No exceptions have been approved for this feature. R2 explicitly requires either remediation or a recorded human-approved exception.

### Removed/Skipped Tests

**None removed.** 9 pre-existing disabled Pester tests are unchanged from baseline (present in both baseline and post-change JUnit outputs).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **2ed08b19** - `feat(poshqc-test-command): add terminal streaming, folder picker, and scan config for #344` (sole commit in `cf036d3f..HEAD`)

### Files Modified

1. **extensions/drm-copilot/src/poshqc-terminal-output.ts** (NEW) — streaming pseudoterminal writer + tee sink (Capability 1).
2. **extensions/drm-copilot/src/poshqc-scan-config.ts** (NEW) — scan-config read/validate/canonical-write via `FileSystem` seam (Capability 3).
3. **extensions/drm-copilot/src/poshqc-folder-picker.ts** (NEW) — seeded `canPickMany` QuickPick with persistence-before-run (Capability 4).
4. **extensions/drm-copilot/src/poshqc-command-registration.ts** (MODIFIED) — per-invocation service factory, tee wiring, picker strategy injection.
5. **extensions/drm-copilot/src/extension.ts** (MODIFIED, +5) — minimal `createService` factory pass-through.
6. **extensions/drm-copilot/src/mcp-tool-definitions.ts / mcp-repo-automation-tool-definitions.ts** (MODIFIED) — `run_poshqc_test` description documents config-aware default (AC12).
7. **scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1** (NEW) + bundled mirror — `Get-PoshQCScanConfigFolder` with injectable seams.
8. **scripts/powershell/PoshQC/PoshQC.psm1 / PoshQC.Testing.psm1** (MODIFIED) + bundled mirrors — sub-module load, export, `$ResolveScanConfig` precedence block.
9. **extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1, settings/pester.runsettings.psd1** (MODIFIED) — resync to workspace copies (`RequiredModules` and `CodeCoverage.ExcludedPath` blocks removed) (FR2.2).
10. **config/poshqc-scan.json** (NEW) — seeded `version: 1` config.
11. **tests/scripts/dev_tools/test_poshqc_bundled_parity.py** (MODIFIED) — parity set extended to eight file pairs (FR2.1).
12. **Test suites** (NEW/MODIFIED) — as listed in Code Under Test.
13. **Feature docs and evidence** (NEW) — spec, user-story, plan, research, baseline/qa-gates/regression-testing evidence.

---

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT (BLOCKED pending coverage-evidence remediation)

The implementation, toolchain hygiene, test design, determinism, file-size compliance, evidence locations, and acceptance-criteria delivery are of high quality; format/lint/type-check/test stages are clean across all three languages. The audit is blocked solely by three coverage-evidence gaps (section 8: R1 stale TypeScript lcov, R2 PowerShell production modules outside the coverage denominator without an approved exception, R3 absent Python coverage artifact). Per the fail-closed rule, the audit cannot report PASS while required machine-readable coverage evidence is incomplete.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure (500-line limit independently verified)
- PASS Naming, Docs, Comments
- PARTIAL Toolchain Execution (stages 1–4 clean; coverage stage FAIL per 1.2.1)
- PARTIAL Summarize & Document (FR2.5 note must reach the PR description)

#### Language-Specific Code Change Policy (Section 3)
- Python: PASS (test-only change; tooling clean)
- PowerShell: PASS (tooling, design, seams, change budget)
- TypeScript: PASS (tooling, typing, no suppressions)
- JSON: PASS

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- FAIL Coverage & Scenarios (new-code coverage evidence; see 1.2.1)
- PASS Test Structure
- PASS External Dependencies

#### Language-Specific Unit Test Policy (Section 4)
- Python: PASS framework/style; FAIL coverage artifact
- PowerShell: PASS framework/style/location; FAIL changed-code instrumentation
- TypeScript: PASS framework/style; FAIL artifact staleness

### Metrics Summary

- 1640/1640 TypeScript tests passing; 1103/1103 PowerShell tests passing; 1/1 Python parity test passing
- 93.44% PowerShell report-level line coverage (artifact-verified, unchanged from baseline)
- 96.77% TypeScript line coverage per gate log (artifact at HEAD required — R1)
- All changed files <= 500 lines (largest 488)
- Zero lint/type/format findings across all languages
- Extended parity gate byte-locks 8 workspace/bundled file pairs

### Recommendation

**Blocked** — remediate R1, R2, and R3 (section 8), then re-audit. No implementation-logic defects require rework; the remediation scope is coverage-evidence generation plus either a coverage-instrumentation refactor for the PoshQC module loading or a recorded human-approved exception.

---

## Appendix A: Test Inventory

### New/extended PowerShell (Pester)

1. Get-PoshQCScanConfigFolder › returns empty for absent file
2. Get-PoshQCScanConfigFolder › returns empty for blank content
3. Get-PoshQCScanConfigFolder › returns empty for absent `test`/`scanFolders`
4. Get-PoshQCScanConfigFolder › returns empty for empty `scanFolders`
5. Get-PoshQCScanConfigFolder › throws on malformed JSON (names file)
6. Get-PoshQCScanConfigFolder › throws on version != 1
7. Get-PoshQCScanConfigFolder › throws on blank entry
8. Get-PoshQCScanConfigFolder › throws on absolute-path entry
9. Get-PoshQCScanConfigFolder › throws on `..` segment
10. Get-PoshQCScanConfigFolder › skips nonexistent folder with warning
11. Get-PoshQCScanConfigFolder › throws when all folders nonexistent
12. Get-PoshQCScanConfigFolder › returns all existing folders
13. Invoke-PoshQCTest scan-config precedence › explicit -ScanFolders bypasses config
14. Invoke-PoshQCTest scan-config precedence › config-yielded folders reach run paths
15. Invoke-PoshQCTest scan-config precedence › empty config falls back to Run.Path defaults
16. Invoke-PoshQCTest scan-config precedence › explicit missing folder still throws
17. PoshQC.Comprehensive `Invoke-PoshQCTest` cases (5, updated to inject `-ResolveScanConfig`)

### New/extended TypeScript (Jest)

- `poshqc-terminal-output.test.ts` › createPoshQcTerminalOutput › creates a stably-named terminal and streams appended lines with CRLF termination; streams lines appended after open immediately and reuses the same terminal; normalizes internal line breaks within a single appended line to CRLF; reveals the terminal via show(); creates a replacement terminal once the previous terminal has exited
- `poshqc-terminal-output.test.ts` › createTeeOutput › forwards every appendLine to both sinks in order
- `poshqc-scan-config.test.ts` › 13 cases (absence semantics; malformed JSON; version gate; blank/absolute/`..` entries; canonical read; canonical write; byte-stable round-trip; path resolution; pure canonicalization)
- `poshqc-folder-picker.test.ts` › enumerates workspace folders to depth 2 excluding standard directories; seeds picked=true for configured folders; shows configured-but-nonexistent folder with warning marker; persists accepted non-empty selection canonically before returning; performs no write/run on cancel; shows information message and performs no write on empty accepted selection
- `extension.run-poshqc-commands.test.ts` › terminal streaming + dual-sink on the command path; rejects with CommandExecutionError carrying exitCode/stdout/stderr and preserves getStderrExcerpt while the tee is active; picker multi-select flow
- `mcp-server.test.ts` › creates no terminal on the MCP run_poshqc_test path (buffered sink only)

### Python (pytest)

- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources` (8 byte-locked pairs)

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (in `extensions/drm-copilot/`):**
```bash
npm run format
npm run lint
npm run typecheck
npm run test:coverage   # regenerates coverage/lcov.info (remediation R1)
```

**For PowerShell (via MCP):**
```text
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test    # artifacts/pester/pester-junit.xml, powershell-coverage.xml
```

**For Python:**
```bash
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v
poetry run pytest --cov   # remediation R3: persist artifacts/python/lcov.info
```

**Review-support commands executed in this audit:**
```bash
git diff --stat cf036d3f..HEAD
git diff --name-only cf036d3f..HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
wc -l <changed files>
# lcov and JaCoCo XML parsed programmatically for repo-wide and per-file figures
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-10
**Policy Version:** Current (as of audit date)
