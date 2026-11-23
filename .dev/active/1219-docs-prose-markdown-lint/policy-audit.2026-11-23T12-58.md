# Policy Compliance Audit: docs-prose-markdown-lint (#1219)

**Audit Date:** 2026-11-23
**Audit Type:** Re-review (remediation cycle 1, R4) after the light cycle that executed `remediation-inputs.2026-11-23T12-30.md`
**Code Under Test:** merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca` of the base branch `origin/epic/documentation-estate-families-integration` (resolved `aa3e960a66f6ac682dd43a63b460a40b3965f85c`) and reviewed head `0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0` (`feature/docs-prose-markdown-lint-1219`); the diff between them lists 65 changed files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production modules (1 new, 2 modified) + 3 bundle mirrors; 7 test files | 29211 test cases (final gate) + 23 cases (cycle-1 task check) | ✅ final gate 29193 pass, 0 fail, 18 skipped; task check 23 pass, 0 fail | 96.84% lines repo-wide (482 files) | 96.85% lines repo-wide (483 files) | `DocsPagePlaceholder.psm1` 100.00% (37/37) |
The remaining changed files carry no executable code: YAML and INI templates (the workflow template and the Vale styles, 7 files plus 7 bundle mirrors, checked by Pester content tests and by actionlint 1.7.12 with exit 0), the `core.json` pack manifest (checked by the push-down manifest pytest contracts), and Markdown skills, pages, and feature records (checked by Pester content tests). Python, TypeScript, C#, and Bash have zero changed files on the branch.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope`
- PowerShell baseline coverage artifact: `.dev/active/1219-docs-prose-markdown-lint/evidence/baseline/pester-gate.2026-11-23T07-39.md`
- PowerShell post-change coverage artifact: `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/pester-gate.2026-11-23T12-11.md` (single final gate run; figures parsed from `artifacts/pester/powershell-coverage.xml` at that time and re-read from the XML by the 12-30 review)
- Per-language comparison summary: `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/coverage-and-limits.2026-11-23T12-13.md` and section 1.2.1 below

Threshold source: the root `CLAUDE.md` (with its `AGENTS.md` import) states no line or branch coverage figure, so the defaults govern: 85% line for new, modified, and repo-wide PowerShell files. No branch threshold applies to PowerShell (Pester measures line and command coverage only). `quality-tiers.yml` is absent at the repository root, so tier classification is not applicable and is not a finding.

Coverage artifact state at this review: FAIL for PowerShell repo-wide coverage as measured by the artifact. The local `artifacts/pester/powershell-coverage.xml` was rewritten at 2026-11-23 12:41 UTC (`sessioninfo start=1795437692434`) by the cycle-1 two-file selection run and now reports 61 covered of 48871 lines (0.12% repo-wide), below the 85% default line threshold. The coverage verification procedure reads the artifact as it exists and does not regenerate it, so this audit records FAIL. `git diff --name-only 16b38d3cf..0f5a4be23` lists no production file, so the 12-11 final-gate figures (96.85%) are expected to reproduce; the remediation is to run the single parallel Pester gate at the remediated head so the artifact reflects a gate run (finding R3 in `remediation-inputs.2026-11-23T12-58.md`).

Revision note: this audit was revised before the review completed, after the stop hook `validate-feature-review-coverage` reported the 0.12% artifact figure. The first draft treated the overwrite as Info; it is now a coverage FAIL.

---

## Executive Summary

This re-review covers the full branch diff at head `0f5a4be23`. Cycle 1 replaced the first sentence of `## Linting` in `.dev/engineering/documentation-estate/consumer-onboarding.md` ("Linting is optional." became "Lint steps are part of the written workflow.") and renamed the matching `It` and its asserted token in `DocumentationEstateOnboarding.Tests.ps1`. Finding R1 of the 12-30 review is resolved.

A search of the repository for the same statement found one related document that the change also makes inaccurate and that no epic child owns: the bundled consumer epic template `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` states at lines 16, 82, and 95 that linting is optional and that adopting a Markdown or prose linter as a required gate is a non-goal. After this item, the init-written `_docs-quality.yml` runs markdownlint and Vale and fails the job on findings. Sibling child 1223 lists the template as out of its scope (`.dev/active/1223-docs-epic-scale-routing/spec.md` line 114). This audit records that as a blocking item (section 2.6). A second blocking item is the PowerShell coverage artifact: the cycle-1 selection run overwrote `artifacts/pester/powershell-coverage.xml`, which now reports 0.12% repo-wide (section 1.2).

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

All recorded toolchain evidence is clean: format and PSScriptAnalyzer over 1869 files with 0 findings, one parallel Pester gate with 0 failures, the pytest suite (17104 passed, 0 failed) including the four push-down contract tests, `Invoke-HarnessGeneration.ps1 -Check` with no drift, and the cycle-1 task check (23 cases, 0 failures; PoshQC format and analyze over the changed test directory).

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed on the branch; `git status --porcelain` is empty at the reviewed head.
- ✅ No ongoing tooling script was added.

---

## Rejected Scope Narrowing

None. The delegation prompt states "Same inputs as the original review, no scope narrowing", names the base branch, the full feature folder, and both AC sources, and asks for a search across the whole diff. The audit covers the full branch diff against the merge base above.

## Evidence Location Compliance

- `git diff --name-only 7c4bdc734 HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 31 evidence files of the item, including the new `evidence/other/task-check.P0-T1.2026-11-23T12-44.md`, are under `.dev/active/1219-docs-prose-markdown-lint/evidence/{baseline,qa-gates,other}/`.
- Command: `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` returned exit code 0 with no reported path.
- Result: PASS.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head (`ls` exit 2), so the documentation surface check is not applicable and produces no finding.

## File Size Check

Logical line counts at the reviewed head (counted with `awk 'END{print NR}'`, which counts an unterminated final line once and adds no line for a trailing terminator; equal to `@(Get-Content).Count`):

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
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | 321 | PASS (unchanged count; cycle 1 edited two lines in place) |
| `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | 117 | PASS |

`config/file-size-baseline.json` is not changed on the branch (`git diff --name-only 7c4bdc734 HEAD -- config/file-size-baseline.json` is empty).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Each `It` builds its own in-memory inputs; the lint-scope body test restores `$env:GITHUB_OUTPUT` in `finally`. The full suite passed in one 8-worker `Invoke-PoshQCParallelTest` run; the cycle-1 selection passed in a 2-worker parallel run. |
| **Isolation** | ✅ PASS | One behavior per `It`; the renamed onboarding `It` asserts the replacement sentence and the `check` gate sentence only. |
| **Fast Execution** | ✅ PASS | In-memory tests; full gate 760.89 s across 29211 cases. |
| **Determinism** | ✅ PASS | No clock, network, random, or temporary-file access in the new or changed tests. |
| **Readability & Maintainability** | ✅ PASS | Descriptive `It` names; the renamed `It` states the asserted behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.84% lines repo-wide; `DocsLedgerCommands.psm1` 99.69% (325/326); `DocsProfileCommands.psm1` 97.75% (87/89); `DocsPagePlaceholder.psm1` `N/A - no pre-change run` (new file)<br>**Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-23T07-39.md`<br>**Timestamp:** 2026-11-23 07:39 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.85% lines repo-wide (47330 covered, 1541 missed) from the single final gate run<br>**Change:** +0.01% lines<br>**Status:** No regression; changed lines of `DocsLedgerCommands.psm1` covered. Cycle 1 changed no production file, so the gate figures apply at the reviewed head. |
| **Repo-wide PowerShell coverage artifact at reviewed head** | ❌ FAIL | `artifacts/pester/powershell-coverage.xml` reports 0.12% line coverage (61/48871) repo-wide because the cycle-1 selection run overwrote the gate XML; below the 85% default. Remediation: one parallel Pester gate through the launcher at the remediated head (R3). |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** `DocsLedgerCommands.psm1` 99.70% (327/328); `DocsProfileCommands.psm1` 97.87% (92/94)<br>**Thresholds:** 85% line (default); no PowerShell branch threshold<br>**Status:** All changed files meet the threshold (`evidence/qa-gates/pester-gate.2026-11-23T12-11.md`). |
| **New Code Coverage** | ✅ PASS | **New file:** `.claude/lib/docs/DocsPagePlaceholder.psm1`<br>**New code coverage:** 100.00% (37/37)<br>**Calculation method:** per-file `LINE` counter of the final-gate JaCoCo report. |
| **Comprehensive Coverage** | ✅ PASS | Counter, report, renderer, and export-surface tests (29 cases); coverage integration tests in `DocsLedgerCommands.Tests.ps1`. |
| **Positive Flows** | ✅ PASS | Counts 1, 3, and 2 on one line; wrap; report sum and ordering; report rendering. |
| **Negative Flows** | ✅ PASS | Wrong case, blank-line separation, non-`.md` page, invalid UTF-8 page, empty lint scope. |
| **Edge Cases** | ✅ PASS | Empty page set, terminated and unterminated front matter, CRLF versus LF, ordinal ordering. |
| **Error Handling** | ✅ PASS | Narrow `DecoderFallbackException` catch; `DOCS_LINT_SCOPE_EMPTY` throw executed in memory; checksum throw position asserted and proven by recorded evidence. |
| **Concurrency** | N/A | The new functions are pure and hold no shared state. |
| **State Transitions** | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.84% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.85% lines. Change: +0.01% lines. New/changed-code coverage: `DocsPagePlaceholder.psm1` 100.00%; changed lines of `DocsLedgerCommands.psm1` and `DocsProfileCommands.psm1` covered (final gate). Disposition: FAIL for the coverage artifact at the reviewed head: the current PowerShell coverage XML reports 0.12% repo-wide (cycle-1 selection run), so a gate run must regenerate it (R3). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-gate.2026-11-23T07-39.md`, `evidence/qa-gates/pester-gate.2026-11-23T12-11.md`, `evidence/qa-gates/coverage-and-limits.2026-11-23T12-13.md`.
- Python, TypeScript, C#, Bash: N/A (zero changed files of these languages on the branch).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact expected values and `-Because` clauses on ordering assertions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment-marked sections, including the renamed onboarding `It`. |
| **Document Intent** | ✅ PASS | File-level help and descriptive `It` names. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, process, or external tool in tests. |
| **Use Mocks/Stubs** | ✅ PASS | `Get-Content` and `Add-Content` mocked for the lint-scope body; in-memory `ReadBytes`. |
| **Environment Stability** | ✅ PASS | No temporary files; `$env:GITHUB_OUTPUT` restored in `finally`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, the 12-30 review, the executor self-review `evidence/qa-gates/self-review.2026-11-23T12-16.md`, and the cycle-1 task check. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1219, `spec.md`, `user-story.md`, research D1-D14. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-23T00-38.md`; light inputs `remediation-inputs.2026-11-23T12-30.md`. |
| **Document the plan** | ✅ PASS | Plan, decision records, and the light-cycle task check. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One regex over masked body text; two-line integration in `Invoke-DocsCoverageCommand`. |
| **Reusability** | ✅ PASS | Reuses the existing front-matter, line-model, and strict UTF-8 helpers. |
| **Extensibility** | ✅ PASS | Separate `placeholders` result key; `DocsCoverageReport.psm1` untouched. |
| **Separation of concerns** | ✅ PASS | Pure counter module; I/O only through the injected `ReadBytes`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | `DocsPagePlaceholder.psm1` holds only the counter and renderer. |
| **At or below the 800-line hard limit** | ✅ PASS | See `## File Size Check`; one non-blocking Warning (760). |
| **Public vs internal** | ✅ PASS | Exactly the four spec functions exported; asserted by test. |
| **No circular dependencies** | ✅ PASS | Imports `DocsJson`, `DocsPageMarkdown`, `DocsPageFrontMatter`; imported by `DocsLedgerCommands.psm1`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs Get, Measure, ConvertTo. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on the module and every function. |
| **Comment why, not what** | ✅ PASS | Each DocsTonality file names the tonality section it enforces. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` check mode<br>**Result:** 1869 files, 0 rewritten (`evidence/qa-gates/powershell-static.2026-11-23T12-11.md`); cycle 1: PoshQC format over `tests/scripts/claude-lib/docs`, 0 rewrites (`task-check.P0-T1.2026-11-23T12-44.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings; actionlint 1.7.12 exit 0; cycle 1: PoshQC analyze invoked over the changed test directory with result `ok` (the MCP result carries no count, as the task check states) |
| **3. Type checking** | N/A | PowerShell has no type checker; no TypeScript or Python file changed. |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (parallel) and `run-test-suite.sh pytest`<br>**Result:** Pester 29193 passed, 0 failed; pytest 17104 passed, 0 failed; cycle-1 selection 23 passed, 0 failed |
| **Full toolchain loop** | ✅ PASS | Final static pass rewrote no file; cycle 1 rewrote no file. Integration tests (stage 7) run in CI. |
| **Explicit reporting** | ✅ PASS | Every command and result is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commits `16b38d3cf` and `0f5a4be23`; self-review and task-check artifacts. |
| **Design choices explained** | ✅ PASS | Spec decisions D1-D15 and execution decisions D-E1 to D-E9. |
| **Update supporting documents** | ❌ FAIL | R1 is resolved: `consumer-onboarding.md` line 33 now reads "Lint steps are part of the written workflow." and no "Linting is optional" text remains under `.dev/engineering/documentation-estate/` or `tests/`. New related item: the bundled consumer epic template `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` states "Linting is optional; the page check is the required page gate." (line 16, an `nfrs` entry), "Adopting a Markdown or prose linter as a required gate; linting stays optional." (line 82, `## Non-Goals`), and "Linting is optional: `init -Write` writes linter configuration as data, and `check` is the required page gate." (line 95). After this item the init-written workflow runs markdownlint and Vale and fails on findings, so these statements are inaccurate for any consumer that plans an estate from the template. No epic child owns the correction: sibling 1223 excludes the template (`1223-docs-epic-scale-routing/spec.md` line 114), and spec non-goals of 1219 do not exclude it. The file is pushed down to consumer repositories and is fixable on the branch. |
| **Provide next steps** | ✅ PASS | Next step: correct the three template statements, keep `DocumentationEstateEpicTemplate.Tests.ps1` and the onboarding neutrality test passing, then PR to the integration branch. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 1869 files already formatted; cycle-1 test directory 0 rewrites. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings at Error, Warning, Information. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 7 compatible** | ✅ PASS | Modules declare PowerShell 7.4; repository PSSA settings enforce compatibility. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType]` on all four functions. |
| **Parameter validation** | ✅ PASS | Mandatory parameters with `[AllowEmptyString()]`, `[AllowNull()]`, `[AllowEmptyCollection()]` where empty input is valid. |
| **Avoid global state** | ✅ PASS | Script-scope values are read-only constants. |
| **Error handling** | ✅ PASS | Module-scope `ErrorActionPreference = 'Stop'`; only `DecoderFallbackException` is caught. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 136, 760, 276 lines. |
| **Approved verbs** | ✅ PASS | Get, Measure, ConvertTo. |
| **Comment why** | ✅ PASS | Help text states the counted region and the decoding rule. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Clean. |
| **Step 2: Analyze** | ✅ PASS | Clean. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | One parallel gate run, 0 failures; cycle-1 parallel selection, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | No rewrite in the final pass or in cycle 1. |

### Section 3D: JSON Configuration (pack manifest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Structure** | ✅ PASS | `core.json` adds six entries with matching indentation; manifest completeness and dependency-closure tests pass in the final pytest run. |

### Workflow template (YAML, consumer CI)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Actions pinned to full commit SHAs** | ✅ PASS | Three `uses:` lines with 40-character SHAs and `# vX.Y.Z` comments. |
| **Least-privilege permissions** | ✅ PASS | `contents: read` at workflow and job level only. |
| **No expression injection in `run:`** | ✅ PASS | No `${{` in any `run:` body. |
| **Pinned, hash-verified Vale** | ✅ PASS | `VALE_VERSION: "3.25.1"`, pinned `VALE_SHA256`, `-cne` and `throw` before `tar`; mismatch run recorded. |
| **actionlint** | ✅ PASS | actionlint 1.7.12, exit 0. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester** | ✅ PASS | `Describe`/`It`, `-ForEach`, `Mock`, `Should -Invoke`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through `run-test-suite.sh pester`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged). |
| **PowerShell 7 Compatible** | ✅ PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | ✅ PASS | Output assertions; the lint-scope step body is executed. |
| **Mocking Used Sparingly** | ✅ PASS | Two I/O cmdlet mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1`<br>**Code file:** `.claude/lib/docs/DocsPagePlaceholder.psm1`<br>Mirrors the `claude-lib/docs` layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | ✅ PASS | `*.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 4 `Describe` blocks, 15 `It` blocks in the new file. |
| **Logical Grouping** | ✅ PASS | Grouped by exported function. |
| **Docstrings/Comments** | ✅ PASS | File help and Arrange/Act/Assert comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQC test command** | ✅ PASS | `Invoke-PoshQCParallelTest`, 8 workers (gate), 2 workers (cycle-1 selection). |
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
| Total Tests | 29211 (Pester gate) + 17110 (pytest, including 6 skipped) + 23 (cycle-1 selection) | ✅ |
| Tests Passed | 29193 Pester, 17104 pytest, 23 selection | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 760.89 s Pester (8 workers); 66.38 s pytest | ✅ |
| Average Time per Test | about 26 ms Pester (wall clock / cases) | ✅ |
| Discovery Time | Not recorded separately | N/A |
| Functions Tested | 4/4 new functions (100%) | ✅ |
| Test File Size | largest changed test file 600 logical lines | ✅ |
| Code Coverage | 96.85% lines repo-wide; 100.00% new module | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` (check mode, all files) | 1869 already formatted | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with repository settings | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 29193 passed, 0 failed | ✅ |
| Pester selection (cycle 1) | `run-test-suite.sh pester -TestPath DocumentationEstateOnboarding.Tests.ps1 test-name-uniqueness.Tests.ps1` | 23 passed, 0 failed | ✅ |

**For the workflow template:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint 1.7.12 | `actionlint -no-color .claude/lib/docs/templates/_docs-quality.yml` | exit 0, 0 findings | ✅ |
| Harness parity | `Invoke-HarnessGeneration.ps1 -Check` | no drift | ✅ |

**Notes:** The review read the final-QC static artifact and the cycle-1 task check and did not re-run format, lint, or type checks. This review independently re-verified at head `0f5a4be23`: byte identity of the ten `.claude/lib/docs` bundle pairs and both docs-init skill bundle pairs (`cmp`), logical line counts, the cycle-1 file list (`git diff --name-only 16b38d3cf 0f5a4be23`), uniqueness of the renamed `It` (one case-insensitive match under `tests/`), and evidence locations (`validate_evidence_locations.py` exit 0). Cycle 1 changed no harness source or generated file, so the recorded harness check still applies.

---

## CI Cross-check

CI status at the head is not available: no pull request exists for the branch yet (`artifacts/pr_context.summary.txt`, generated 2026-11-23 12:50:25 UTC for head `0f5a4be23`). The rows below record the local evidence the review relies on, for comparison with CI once the PR runs. The head column is the reviewed head from `git log`; the full-suite rows ran on the tree of `16b38d3cf`, and the only later changes are one Markdown page, one test file (covered by the selection row), and review records.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| PowerShell format (Invoke-PoshQCFormat) | pass | 1869 files, 0 rewritten | 0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0 | `evidence/qa-gates/powershell-static.2026-11-23T12-11.md`; `evidence/other/task-check.P0-T1.2026-11-23T12-44.md` |
| PowerShell lint (PSScriptAnalyzer) | pass | 0 findings | 0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0 | `evidence/qa-gates/powershell-static.2026-11-23T12-11.md` |
| Pester tests | pass | 29193 passed, 0 failed (gate); 23 passed (selection) | 0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0 | `evidence/qa-gates/pester-gate.2026-11-23T12-11.md`; `evidence/other/task-check.P0-T1.2026-11-23T12-44.md` |
| Pester line coverage (local artifact) | fail | 0.12% lines repo-wide in the current XML (selection run); 96.85% at the 12-11 gate | 0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0 | `artifacts/pester/powershell-coverage.xml`; `evidence/qa-gates/pester-gate.2026-11-23T12-11.md` |
| pytest suite (push-down contracts) | pass | 17104 passed, 0 failed | 0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0 | `evidence/qa-gates/contracts.2026-11-23T12-11.md` |
| Harness generation check | pass | no drift | 0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0 | `evidence/qa-gates/contracts.2026-11-23T12-11.md` |

---

## 8. Gaps and Exceptions

### Identified Gaps

- Update supporting documents: `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` lines 16, 82, and 95 state that linting is optional and that a required linter gate is a non-goal, which this item's change to the init-written workflow makes inaccurate. Remediation: reword the three statements so that they describe the written workflow running markdownlint and Vale while `check` stays the required page-structure gate, keep the template within the epic-manifest YAML subset, and re-run `DocumentationEstateEpicTemplate.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` through the launcher.
- PowerShell coverage artifact: `artifacts/pester/powershell-coverage.xml` reports 0.12% repo-wide after the cycle-1 selection run. Remediation: run one parallel Pester gate (`sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`) after the template fix, as the last test run before review, and record repo-wide and per-file figures under `evidence/qa-gates/`.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

1. **"docs workflow template content.contains no linter step"** - replaced in P2-T2
   - **Reason:** The behavior it asserted is intentionally reversed by this feature.
   - **Impact:** None; superseded by eight lint-step content tests.
   - **Justification:** Planned replacement recorded in the plan and in `coverage-and-limits.2026-11-23T12-13.md`.
2. **"states that linting is optional and check is the required page gate"** - renamed in cycle 1
   - **Reason:** Its asserted sentence was removed by the R1 fix.
   - **Impact:** None; the renamed `It` asserts the replacement sentence and keeps the `check` gate assertion.
   - **Justification:** `task-check.P0-T1.2026-11-23T12-44.md`.

---

## 9. Summary of Changes

The branch adds Markdown lint and a pinned, checksum-verified Vale run with a new `DocsTonality` style to the init-written documentation workflow, adds a counted `SME input required` placeholder section to the docs `coverage` output, and (cycle 1) corrects the onboarding page's linting sentence.

---

## 10. Compliance Verdict

### Overall Status: ❌ One documentation gap and one coverage-artifact FAIL

R1 is resolved. Toolchain, size, parity, evidence-location, and supply-chain requirements are met with recorded evidence. Two autonomous remediation items remain: the epic template linting statements, and a PowerShell coverage artifact at the reviewed head that reports 0.12% repo-wide because a selection run overwrote the gate output.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes
- ✅ Design Principles
- ✅ Module & File Structure (one 700-line Warning)
- ✅ Naming, Docs, Comments
- ✅ Toolchain Execution
- ⚠️ Summarize & Document: epic template linting statements

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline
- ✅ PowerShell Design & Safety
- ✅ Structure & Naming
- ✅ Toolchain

#### General Unit Test Policy (Section 1)
- ✅ Core Principles
- ❌ Coverage & Scenarios: PowerShell coverage artifact at the reviewed head reports 0.12% (selection run); gate re-run required
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

- ✅ 29193/29211 Pester cases passing (18 skipped, 0 failed); 23/23 cycle-1 selection
- ✅ 4/4 new functions tested
- ✅ 96.85% repo-wide PowerShell line coverage at the final gate; 100.00% on the new module
- ❌ PowerShell coverage artifact at the reviewed head: 0.12% repo-wide (selection-run overwrite)
- ✅ Test files mirror production layout
- ✅ Format, analyzer, actionlint, harness check clean

---

### Recommendation

**Needs revision**

Correct the three linting statements in `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md`, run the template and onboarding test files through the launcher, then run one parallel Pester gate as the last test run so that `artifacts/pester/powershell-coverage.xml` reflects a gate run, and record the evidence. No production code change is required.

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
17. docs workflow template content › lint-step content tests (markdownlint, lint scope content and execution, Vale install, Vale run, pins, permissions, step order)
18. documentation-estate onboarding pages › states that lint steps are part of the written workflow and check is the required page gate (renamed in cycle 1)

---

## Appendix B: Toolchain Commands Reference

```powershell
# Formatting and analysis (recorded by the executor)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (parallel only)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest

# Evidence locations (run by this review)
env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# Parity
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-23
**Policy Version:** Current (as of audit date)
