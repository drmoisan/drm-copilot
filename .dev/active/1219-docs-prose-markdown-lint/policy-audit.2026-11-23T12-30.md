# Policy Compliance Audit: docs-prose-markdown-lint (#1219)

**Audit Date:** 2026-11-23
**Code Under Test:** merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca` of the base branch `origin/epic/documentation-estate-families-integration` and reviewed head `16b38d3cf103c7a657cd1f5dff8db184f4f99572` (`feature/docs-prose-markdown-lint-1219`); the diff between them lists the changed files (60 files, +1826/-150).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production modules (1 new, 2 modified) + 3 bundle mirrors; 7 test files | 29211 test cases (final gate) | ✅ 29193 pass, 0 fail, 18 skipped | 96.84% lines repo-wide (482 files) | 96.85% lines repo-wide (483 files) | `DocsPagePlaceholder.psm1` 100.00% (37/37) |
The remaining changed files carry no executable code: YAML and INI templates (the workflow template and the Vale styles, 7 files plus 7 bundle mirrors, checked by Pester content tests and by actionlint 1.7.12 with exit 0), the `core.json` pack manifest (checked by the push-down manifest pytest contracts), and Markdown skills and pages (checked by Pester content tests). Python, TypeScript, C#, and Bash have zero changed files on the branch.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope`
- PowerShell baseline coverage artifact: `.dev/active/1219-docs-prose-markdown-lint/evidence/baseline/pester-gate.2026-11-23T07-39.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (single final gate run, recorded in `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/pester-gate.2026-11-23T12-11.md`)
- Per-language comparison summary: `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/coverage-and-limits.2026-11-23T12-13.md` and section 1.2.1 below

Threshold source: the root `CLAUDE.md` (with its `AGENTS.md` import) states no line or branch coverage figure, so the defaults govern: 85% line for new, modified, and repo-wide PowerShell files. No branch threshold applies to PowerShell (Pester measures line and command coverage only). `quality-tiers.yml` is absent at the repository root, so tier classification is not applicable and is not a finding.

---

## Executive Summary

The branch adds Markdown lint and a pinned, SHA-256-verified Vale install and run to the init-written `_docs-quality.yml` template, adds the five-rule `DocsTonality` Vale style and loads it from the written `.vale.ini`, adds the placeholder counter module `DocsPagePlaceholder.psm1` and wires its `placeholders` section into `Invoke-DocsCoverageCommand`, and updates bundle copies, the pack manifest, the docs-init skill on every surface, and two engineering pages.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (not adopted; no `quality-tiers.yml`)
- ✅ `.claude/rules/tonality.md` (DocsTonality rule mapping and authored prose)

**Language-specific policies evaluated:**
- N/A Python (no changed Python file; no new Python introduced)
- ✅ `.claude/rules/powershell.md`
- N/A Bash (no changed `.sh` or `.bats` file)
- ✅ JSON: `core.json` structure checked by the push-down manifest contract tests

All recorded toolchain evidence is clean: format and PSScriptAnalyzer over 1869 files with 0 findings, one parallel Pester gate with 0 failures, the pytest suite (17104 passed, 0 failed) including the four push-down contract tests, and `Invoke-HarnessGeneration.ps1 -Check` with no drift. One documentation accuracy gap remains in `consumer-onboarding.md` (section 2.6), which this audit records as the single blocking item.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed on the branch; the evidence names helper scripts only by the `SCRATCH/` token, and `git diff --name-only` lists no scratch file.
- ✅ No ongoing tooling script was added.

---

## Rejected Scope Narrowing

None. The delegation prompt names the base branch, the full feature folder, and both AC sources. Its sentence "Reviewers read the final-QC static artifact and do not re-run format, lint, or type checks." restates the evidence model of the policy-audit template (format, lint, and type results are read from the final-QC static artifact) and does not exclude any language, file, or coverage check, so it is not a narrowing. The audit covers the full branch diff against the merge base above.

## Evidence Location Compliance

- `git diff --name-only 7c4bdc73..16b38d3c` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 30 evidence files of the item are under `.dev/active/1219-docs-prose-markdown-lint/evidence/{baseline,qa-gates,other}/`.
- Result: PASS. `validate_evidence_locations.py` was not run; the scan above is the diff-based equivalent and found zero violations.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the documentation surface check is not applicable and produces no finding.

## File Size Check

Logical line counts at the reviewed head (counted with `awk 'END{print NR}'`, which counts an unterminated final line once and adds no line for a trailing terminator; the values equal the `@(Get-Content).Count` figures in the coverage-and-limits evidence):

| File | Lines | Result |
|---|---|---|
| `.claude/lib/docs/DocsLedgerCommands.psm1` | 760 | PASS (at or below 800; non-blocking Warning at or above 700, reported in the code review) |
| `.claude/lib/docs/DocsPagePlaceholder.psm1` | 136 | PASS |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 276 | PASS |
| `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` | 438 | PASS |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | 600 | PASS |
| `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1` | 231 | PASS |
| `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` | 256 | PASS |
| `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` | 375 | PASS |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | 321 | PASS |
| `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | 117 | PASS |

`config/file-size-baseline.json` is not changed on the branch.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Each `It` builds its own in-memory inputs; `Get-TestReader` returns a fresh closure per test. The lint-scope body test sets `$env:GITHUB_OUTPUT` and restores it in `finally`. The full suite passed in one 8-worker `Invoke-PoshQCParallelTest` run. |
| **Isolation** | ✅ PASS | `DocsPagePlaceholder.Tests.ps1` has one `Describe` per exported function and one behavior per `It`; workflow content tests select one step block each. |
| **Fast Execution** | ✅ PASS | All new tests operate on in-memory strings; the full gate took 760.89 s across 29211 test cases. |
| **Determinism** | ✅ PASS | No clock, network, random, or filesystem access in the new tests; template text is read read-only from the committed file; `Get-Content` and `Add-Content` are mocked for the lint-scope body run. |
| **Readability & Maintainability** | ✅ PASS | Descriptive `It` names, Arrange/Act/Assert comments, data-driven `-ForEach` cases with named fields. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.84% lines repo-wide; `DocsLedgerCommands.psm1` 99.69% (325/326); `DocsProfileCommands.psm1` 97.75% (87/89); `DocsPagePlaceholder.psm1` `N/A - no pre-change run` (new file)<br>**Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (one `Invoke-PoshQCParallelTest` run)<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-23T07-39.md`<br>**Timestamp:** 2026-11-23 07:39 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.85% lines repo-wide (47330 covered, 1541 missed) from the single final gate run<br>**Change:** +0.01% lines<br>**Status:** No regression; 0 per-file drops across the 482 baseline files (`evidence/qa-gates/coverage-and-limits.2026-11-23T12-13.md`). The changed lines of `DocsLedgerCommands.psm1` (457-458) are covered; its one missed line is 492, outside the diff. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** `DocsLedgerCommands.psm1` 99.70% (327/328); `DocsProfileCommands.psm1` 97.87% (92/94)<br>**Thresholds:** 85% line (default); no PowerShell branch threshold<br>**Status:** All changed files meet the threshold. Values re-read by this review from `artifacts/pester/powershell-coverage.xml` `LINE` counters. |
| **New Code Coverage** | ✅ PASS | **New file:** `.claude/lib/docs/DocsPagePlaceholder.psm1`<br>**New code coverage:** 100.00% (37/37)<br>**Calculation method:** per-file `LINE` counter of the JaCoCo report. The 90% new-code figure recorded in owner rulings is also met. |
| **Comprehensive Coverage** | ✅ PASS | `Get-DocsPlaceholderToken`: 1 test; `Measure-DocsPagePlaceholder`: 21 test cases (separators, wrap, blank line, casing, five excluded regions, unterminated and terminated front matter, CRLF); `Get-DocsPlaceholderReport`: 5 tests; `ConvertTo-DocsPlaceholderReportLine`: 1 test (populated and empty); export surface: 1 test. Coverage integration: `DocsLedgerCommands.Tests.ps1` key-set, context-member, and exit-code tests. |
| **Positive Flows** | ✅ PASS | Counts of 1, 3, 2-on-one-line; tab and multi-space separators; one-line-break wrap; report sum and ordering; report line rendering. |
| **Negative Flows** | ✅ PASS | Wrong case (two cases), blank-line separation, non-`.md` page, invalid UTF-8 page, `DOCS_LINT_SCOPE_EMPTY` throw for zero roots. |
| **Edge Cases** | ✅ PASS | Empty page set, terminated front matter with empty body, unterminated front matter, CRLF versus LF, ordinal ordering with `B.md`/`a.md`/`b.md`. |
| **Error Handling** | ✅ PASS | Strict UTF-8 decode failure is caught by type (`DecoderFallbackException`) and skipped; lint-scope empty-root throw is executed in memory; the Vale checksum throw position is asserted by content test and proven by `evidence/other/vale-sha256-mismatch.2026-11-23T11-54.md`. |
| **Concurrency** | N/A | The new functions are pure and hold no shared state. |
| **State Transitions** | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.84% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.85% lines. Change: +0.01% lines. New/changed-code coverage: `DocsPagePlaceholder.psm1` 100.00%; changed lines of `DocsLedgerCommands.psm1` and `DocsProfileCommands.psm1` covered. Disposition: PASS. Evidence: `evidence/baseline/pester-gate.2026-11-23T07-39.md`, `evidence/qa-gates/pester-gate.2026-11-23T12-11.md`, `evidence/qa-gates/coverage-and-limits.2026-11-23T12-13.md`, `artifacts/pester/powershell-coverage.xml`.
- Python, TypeScript, C#, Bash: N/A (zero changed files of these languages on the branch).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -Be` with exact expected arrays; `-Because` clauses on ordering assertions (for example 'the checksum throw precedes the first tar call'). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment-marked sections in the new tests. |
| **Document Intent** | ✅ PASS | File-level `.SYNOPSIS`/`.DESCRIPTION` and descriptive `It` names. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, process, or external tool in tests. Vale and actionlint ran only in recorded evidence scripts, not in tests. |
| **Use Mocks/Stubs** | ✅ PASS | `Get-Content` (parameter-filtered) and `Add-Content` are mocked for the lint-scope body; page bytes come from an in-memory `ReadBytes` scriptblock. |
| **Environment Stability** | ✅ PASS | No temporary files; CRLF input is built in memory; `$env:GITHUB_OUTPUT` is restored in `finally`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with the executor self-review at `evidence/qa-gates/self-review.2026-11-23T12-16.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1219, `spec.md` v0.2, `user-story.md`, research D1-D14. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-23T00-38.md` with three preflight rounds and a clearance record. |
| **Document the plan** | ✅ PASS | Plan and decision records `evidence/other/decisions.*.md` (D-E1 to D-E9). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One regex over masked body text; the integration is two lines in `Invoke-DocsCoverageCommand`. |
| **Reusability** | ✅ PASS | Reuses `ConvertFrom-DocsPageFrontMatter`, `Split-DocsPageLine`, `Get-DocsPageLineModel`, and `ConvertFrom-DocsUtf8Bytes`. |
| **Extensibility** | ✅ PASS | The placeholder section is a separate result key and text block; `DocsCoverageReport.psm1` is untouched (D9). |
| **Separation of concerns** | ✅ PASS | The counter module is pure; page bytes enter only through the injected `ReadBytes` scriptblock. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | `DocsPagePlaceholder.psm1` holds only the placeholder counter and its renderer. |
| **At or below the 800-line hard limit** | ✅ PASS | See `## File Size Check`. `DocsLedgerCommands.psm1` at 760 lines is a non-blocking Warning (at or above 700). |
| **Public vs internal** | ✅ PASS | `Export-ModuleMember` lists exactly the four spec functions; a test asserts the export set. |
| **No circular dependencies** | ✅ PASS | `DocsPagePlaceholder.psm1` imports `DocsJson`, `DocsPageMarkdown`, `DocsPageFrontMatter` only; it is imported by `DocsLedgerCommands.psm1`. Architecture suites (`DocsPageImportIsolation.Tests.ps1`) ran in the gate. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs: Get, Measure, ConvertTo. |
| **Docs/docstrings** | ✅ PASS | Module and function comment-based help. |
| **Comment why, not what** | ✅ PASS | Each DocsTonality file opens with the tonality section it enforces; Intensifiers states why four words are absent. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` check mode over all PowerShell files<br>**Result:** 1869 files, 0 rewritten (`evidence/qa-gates/powershell-static.2026-11-23T12-11.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings; actionlint 1.7.12 over the template exit 0 |
| **3. Type checking** | N/A | PowerShell has no type checker; no TypeScript or Python file changed. |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (one parallel run) and `run-test-suite.sh pytest`<br>**Result:** Pester 29193 passed, 0 failed; pytest 17104 passed, 0 failed |
| **Full toolchain loop** | ✅ PASS | Final static pass rewrote no file; phase gates P1-P3 and the final gate are recorded. Integration tests (stage 7) run in CI. |
| **Explicit reporting** | ✅ PASS | Every command and result is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `16b38d3cf` message and self-review artifact. |
| **Design choices explained** | ✅ PASS | Spec `## Decisions` D1-D15 and execution decisions D-E1 to D-E9. |
| **Update supporting documents** | ❌ FAIL | `.dev/engineering/documentation-estate/consumer-onboarding.md` line 33 still opens the `## Linting` section with "Linting is optional.", while the same section now states that the written workflow runs markdownlint and Vale and that an error-level alert fails the Vale step. A repository that calls the written `_docs-quality.yml` cannot skip the lint steps without editing the workflow, so the sentence is inaccurate after this change. `DocumentationEstateOnboarding.Tests.ps1` line 179 asserts the stale sentence. This is a related finding inside D13 (documentation updated in this item) and is fixable on the branch. |
| **Provide next steps** | ✅ PASS | Next step: correct the sentence and its test assertion, then PR to the integration branch. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 1869 files already formatted. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings at Error, Warning, Information. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 7 compatible** | ✅ PASS | Modules declare PowerShell 7.4; the repository PSSA settings enforce PowerShell 7 compatibility. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All four functions use `[CmdletBinding()]` and `[OutputType]`. |
| **Parameter validation** | ✅ PASS | Mandatory `Text`, `PagePath`, `ReadBytes`, `Report`; `[AllowEmptyString()]` and `[AllowNull()]/[AllowEmptyCollection()]` where empty input is valid. |
| **Avoid global state** | ✅ PASS | Script-scope values are read-only constants (token and pattern). |
| **Error handling** | ✅ PASS | Module-scope `ErrorActionPreference = 'Stop'`; only `DecoderFallbackException` is caught, per spec. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 136, 760, 276 lines. |
| **Approved verbs** | ✅ PASS | Get-DocsPlaceholderToken, Measure-DocsPagePlaceholder, Get-DocsPlaceholderReport, ConvertTo-DocsPlaceholderReportLine. |
| **Comment why** | ✅ PASS | Help text states the counted region and the decoding rule. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Clean. |
| **Step 2: Analyze** | ✅ PASS | Clean. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | One parallel gate run, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | No rewrite in the final pass. |

### Section 3D: JSON Configuration (pack manifest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Structure** | ✅ PASS | `core.json` adds six string entries in the existing array with matching indentation and no trailing comma; `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass in the final pytest run. |

### Workflow template (YAML, consumer CI)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Actions pinned to full commit SHAs** | ✅ PASS | Three `uses:` lines, each a 40-character SHA with a `# vX.Y.Z` comment; asserted by Pester. |
| **Least-privilege permissions** | ✅ PASS | `contents: read` at workflow and job level only. |
| **No expression injection in `run:`** | ✅ PASS | No `${{` in any `run:` body; values pass through `env:`. |
| **Pinned, hash-verified Vale** | ✅ PASS | `VALE_VERSION: "3.25.1"`, `VALE_SHA256` matching the upstream checksums file; `-cne` comparison and `throw` before `tar`; mismatch run proven. |
| **actionlint** | ✅ PASS | actionlint 1.7.12, exit 0, 0 findings. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester** | ✅ PASS | `BeforeAll`, `Describe`/`It`, `-ForEach`, `Mock`, `Should -Invoke`. The `#Requires` line declares a 5.0.0 minimum, consistent with sibling docs test files; the gate runs the repository Pester version. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through `run-test-suite.sh pester`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged). |
| **PowerShell 7 Compatible** | ✅ PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | ✅ PASS | Counter and report tests assert outputs; the lint-scope step body is executed rather than only pattern-matched. |
| **Mocking Used Sparingly** | ✅ PASS | Two mocks, both I/O cmdlets in the executed step body. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1`<br>**Code file:** `.claude/lib/docs/DocsPagePlaceholder.psm1`<br>Mirrors the existing `claude-lib/docs` layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | ✅ PASS | `DocsPagePlaceholder.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 4 `Describe` blocks, 15 `It` blocks (29 cases with `-ForEach`). |
| **Logical Grouping** | ✅ PASS | Grouped by exported function. |
| **Docstrings/Comments** | ✅ PASS | File help and per-test Arrange/Act/Assert comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQC test command** | ✅ PASS | `Invoke-PoshQCParallelTest`, 8 workers, exit 0. |
| **No Alternative Test Runners** | ✅ PASS | Parallel-only runs; no serial, shuffled, or reversed runs recorded. |

---

## 5. Test Coverage Detail

### DocsPagePlaceholder.psm1 (29 test cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| counts <Expected> for <Case> (7 cases) | Positive / Edge Case | 68-77 | ✅ |
| counts a token wrapped across one line break | Edge Case | 68-77 | ✅ |
| counts 0 for words separated by a blank line | Negative | 68-77 | ✅ |
| counts 0 for <Case> casing (2 cases) | Negative | 68-77 | ✅ |
| counts 0 inside <Region> (5 cases) | Edge Case | 68-77 | ✅ |
| counts an unterminated front matter page | Edge Case | 68-77 | ✅ |
| counts the body after a terminated front matter block | Edge Case | 68-77 | ✅ |
| gives the same count for CRLF and LF | Edge Case | 68-77 | ✅ |
| skips a non-Markdown page | Negative | 96-113 | ✅ |
| skips a page that is not valid UTF-8 | Error Handling | 103-107 | ✅ |
| sums total and omits zero-count pages | Positive | 96-113 | ✅ |
| returns a zero total and no pages for an empty page set | Edge Case | 96-113 | ✅ |
| orders pages ordinally by page_path | Edge Case | 96-113 | ✅ |
| renders the summary line and one line per page | Positive / Edge Case | 125-129 | ✅ |
| returns the token literal | Positive | 50 | ✅ |
| exports exactly the four functions | Positive | 132-136 | ✅ |

**Coverage:** 100.00% (37/37 lines).

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 29211 (Pester) + 17110 (pytest, including 6 skipped) | ✅ |
| Tests Passed | 29193 Pester, 17104 pytest | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 760.89 s Pester (8 workers); 66.38 s pytest | ✅ |
| Average Time per Test | about 26 ms Pester (wall clock / cases) | ✅ |
| Discovery Time | Not recorded separately | N/A |
| Functions Tested | 4/4 new functions (100%) | ✅ |
| Test File Size | 231 logical lines (`DocsPagePlaceholder.Tests.ps1`); largest changed test file 600 | ✅ |
| Code Coverage | 96.85% lines repo-wide; 100.00% new module | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` (check mode, all files) | 1869 already formatted | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with repository settings | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 29193 passed, 0 failed | ✅ |

**For the workflow template:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint 1.7.12 | `actionlint -no-color .claude/lib/docs/templates/_docs-quality.yml` | exit 0, 0 findings | ✅ |
| Harness parity | `Invoke-HarnessGeneration.ps1 -Check` | no drift | ✅ |

**Notes:** Launcher exit 75 queue timeouts (machine test-suite lock held by sibling worktrees) are recorded as queue timeouts, not failures (D-E2). The review read the final-QC static artifact and did not re-run format, lint, or type checks. This review independently re-verified: byte identity of all ten `.claude/lib/docs` bundle copies and both docs-init skill bundle copies (`cmp`), per-file coverage counters in `artifacts/pester/powershell-coverage.xml`, logical line counts, and the absence of `DocsCoverageReport.psm1` from the diff against the integration merge base.

---

## CI Cross-check

CI status at the head is not available: no pull request exists for the branch yet (`artifacts/pr_context.summary.txt`, `CI status (HEAD): (not available)`). The rows below record the local evidence the review relies on, for comparison with CI once the PR runs.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| PowerShell format (Invoke-PoshQCFormat) | pass | 1869 files, 0 rewritten | 16b38d3cf103c7a657cd1f5dff8db184f4f99572 | `evidence/qa-gates/powershell-static.2026-11-23T12-11.md` |
| PowerShell lint (PSScriptAnalyzer) | pass | 0 findings | 16b38d3cf103c7a657cd1f5dff8db184f4f99572 | `evidence/qa-gates/powershell-static.2026-11-23T12-11.md` |
| Pester tests and line coverage | pass | 29193 passed, 0 failed; 96.85% lines | 16b38d3cf103c7a657cd1f5dff8db184f4f99572 | `evidence/qa-gates/pester-gate.2026-11-23T12-11.md` |
| pytest suite (push-down contracts) | pass | 17104 passed, 0 failed | 16b38d3cf103c7a657cd1f5dff8db184f4f99572 | `evidence/qa-gates/contracts.2026-11-23T12-11.md` |
| Harness generation check | pass | no drift | 16b38d3cf103c7a657cd1f5dff8db184f4f99572 | `evidence/qa-gates/contracts.2026-11-23T12-11.md` |

The final gate ran on the working tree that became head `16b38d3cf` (gate window 11-56 to 12-11 UTC; commit 12-26 UTC; the coverage XML timestamp matches the final gate).

---

## 8. Gaps and Exceptions

### Identified Gaps

- Update supporting documents: `consumer-onboarding.md` line 33 states "Linting is optional." after the change made lint steps part of the written workflow; `DocumentationEstateOnboarding.Tests.ps1` lines 174-179 assert that sentence. Remediation: replace the sentence with an accurate statement (for example, that `check` remains the required page gate and that the written workflow runs markdownlint and Vale), and update the test assertion to the new token.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

1. **"docs workflow template content.contains no linter step"** - replaced in P2-T2
   - **Reason:** The behavior it asserted is intentionally reversed by this feature.
   - **Impact:** None; it is superseded by eight lint-step content tests.
   - **Justification:** Planned replacement recorded in the plan and in `coverage-and-limits.2026-11-23T12-13.md`.

---

## 9. Summary of Changes

The branch adds Markdown lint and a pinned, checksum-verified Vale run with a new `DocsTonality` style to the init-written documentation workflow, and adds a counted `SME input required` placeholder section to the docs `coverage` output.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ One documentation gap; all code, test, coverage, and parity policies met

All coverage, toolchain, size, parity, evidence-location, and supply-chain requirements are met with recorded evidence. One related documentation sentence is inaccurate and is classified as an autonomous, contained remediation item.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, spec, decisions recorded
- ✅ Design Principles: pure counter module, minimal integration
- ✅ Module & File Structure: all files at or below 800; one 700-line Warning
- ✅ Naming, Docs, Comments: approved verbs, help text
- ✅ Toolchain Execution: clean final pass
- ⚠️ Summarize & Document: `consumer-onboarding.md` "Linting is optional." sentence

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline
- ✅ PowerShell Design & Safety
- ✅ Structure & Naming
- ✅ Toolchain

#### General Unit Test Policy (Section 1)
- ✅ Core Principles
- ✅ Coverage & Scenarios
- ✅ Test Structure
- ✅ External Dependencies
- ✅ Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope
- ✅ Test Style & Structure
- ✅ Naming & Readability
- ✅ Toolchain

---

### Metrics Summary

- ✅ 29193/29211 Pester cases passing (18 skipped, 0 failed)
- ✅ 4/4 new functions tested
- ✅ 96.85% repo-wide PowerShell line coverage; 100.00% on the new module
- ✅ Test file mirrors production layout
- ✅ Format, analyzer, actionlint, harness check clean
- ✅ Pester gate 760.89 s with 8 workers

---

### Recommendation

**Needs revision**

Correct the "Linting is optional." sentence in `.dev/engineering/documentation-estate/consumer-onboarding.md` and its assertion in `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`, re-run the affected Pester files through the launcher, and record the task-check evidence. No code change is required.

---

## Appendix A: Test Inventory

1. Measure-DocsPagePlaceholder › counts <Expected> for <Case> (7 cases)
2. Measure-DocsPagePlaceholder › counts a token wrapped across one line break
3. Measure-DocsPagePlaceholder › counts 0 for words separated by a blank line
4. Measure-DocsPagePlaceholder › counts 0 for <Case> casing (2 cases)
5. Measure-DocsPagePlaceholder › counts 0 inside <Region> (5 cases)
6. Measure-DocsPagePlaceholder › counts an unterminated front matter page
7. Measure-DocsPagePlaceholder › counts the body after a terminated front matter block
8. Measure-DocsPagePlaceholder › gives the same count for CRLF and LF
9. Get-DocsPlaceholderReport › skips a non-Markdown page
10. Get-DocsPlaceholderReport › skips a page that is not valid UTF-8
11. Get-DocsPlaceholderReport › sums total and omits zero-count pages
12. Get-DocsPlaceholderReport › returns a zero total and no pages for an empty page set
13. Get-DocsPlaceholderReport › orders pages ordinally by page_path
14. ConvertTo-DocsPlaceholderReportLine › renders the summary line and one line per page
15. DocsPagePlaceholder module surface › returns the token literal
16. DocsPagePlaceholder module surface › exports exactly the four functions
17. docs workflow template content › eight new or rewritten lint-step tests (markdownlint, lint scope content, lint scope execution, Vale install, Vale run, header, pins, permissions, step order)

---

## Appendix B: Toolchain Commands Reference

```powershell
# Formatting and analysis (recorded by the executor)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (parallel only)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest

# Parity
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-23
**Policy Version:** Current (as of audit date)
