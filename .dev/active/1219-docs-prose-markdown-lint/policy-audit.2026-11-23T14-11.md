# Policy Compliance Audit: docs-prose-markdown-lint (#1219)

**Audit Date:** 2026-11-23
**Audit Type:** Re-review (remediation cycle 2, R4) after the full cycle that executed `remediation-plan.2026-11-23T12-58.md` for findings R2 and R3 of `remediation-inputs.2026-11-23T12-58.md`
**Code Under Test:** merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca` of the base branch `origin/epic/documentation-estate-families-integration` (resolved `aa3e960a66f6ac682dd43a63b460a40b3965f85c`) and reviewed head `69293991ae9585c5a371de4b55ffa5f290554ac9` (`feature/docs-prose-markdown-lint-1219`); the diff between them lists 77 changed files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production modules (1 new, 2 modified) + 3 bundle mirrors; 7 test files | 29211 test cases (cycle-2 final gate) + 60 cases (cycle-2 task check) | ✅ gate 29193 pass, 0 fail, 18 skipped; task check 60 pass, 0 fail | 96.84% lines repo-wide (482 files) | 96.85% lines repo-wide (483 files) | `DocsPagePlaceholder.psm1` 100.00% (37/37) |

The remaining changed files carry no executable code: YAML and INI templates (the workflow template and the Vale styles, 7 files plus 7 bundle mirrors, checked by Pester content tests and by actionlint 1.7.12 with exit 0), the `core.json` pack manifest (checked by the push-down manifest pytest contracts), and Markdown skills, pages, templates, and feature records (checked by Pester content tests). Python, TypeScript, C#, and Bash have zero changed files on the branch.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope`
- PowerShell baseline coverage artifact: `.dev/active/1219-docs-prose-markdown-lint/evidence/baseline/pester-gate.2026-11-23T07-39.md`
- PowerShell post-change coverage artifact: `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/pester-gate.2026-11-23T14-00.md` (single final gate run of cycle 2; figures re-read by this review from `artifacts/pester/powershell-coverage.xml`)
- Per-language comparison summary: section 1.2.1 below

Threshold source: the root `CLAUDE.md` (with its `AGENTS.md` import) states no line or branch coverage figure, so the defaults govern: 85% line for new, modified, and repo-wide PowerShell files. No branch threshold applies to PowerShell (Pester measures line and command coverage only). `quality-tiers.yml` is absent at the repository root, so tier classification is not applicable and is not a finding.

Coverage artifact state at this review: PASS. `artifacts/pester/powershell-coverage.xml` carries `sessioninfo start=1795441499479` (2026-11-23 13:44:59 UTC) and `dump=1795441999554` (13:53:19 UTC), which postdates the cycle-2 task check (13-28) and matches the gate record `pester-gate.2026-11-23T14-00.md`. The report-level `LINE` counter is 47330 covered and 1541 missed (96.85%). No Pester run is recorded after the gate. Finding R3 is resolved.

---

## Executive Summary

This re-review covers the full branch diff at head `69293991a`. Cycle 2 (commit `69293991a`) changed one tracked file, `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md`, in exactly three statements (4 insertions, 4 deletions), and added baseline, task-check, gate, and self-review evidence. The template no longer states that linting is optional; it states that the init-written workflow runs markdownlint and Vale and that `check` is the required page-structure gate. Finding R2 is resolved. The single parallel Pester gate regenerated the coverage XML at 96.85% repo-wide. Finding R3 is resolved.

A repository search for the remaining forms of the same claim ("optional linting", "linting is optional", "linting stays optional", "no required linter") outside historical feature records found one current page that the item's change makes inaccurate: the topic index `.dev/engineering/documentation-estate/README.md` line 36 describes `consumer-onboarding.md` as covering "optional linting". The onboarding page's `## Linting` section now opens "Lint steps are part of the written workflow.", and spec `## Scope` item 4 requires the engineering pages that describe the changed behavior to be updated in the same change. No sibling epic child edits the README. This audit records that as one blocking item (section 2.6). All other policy checks pass.

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

All recorded toolchain evidence of cycle 2 is clean: PoshQC format (1869 files, 0 rewritten) and PSScriptAnalyzer (0 findings) in `powershell-static.2026-11-23T13-38.md`; one parallel Pester gate with 0 failures in `pester-gate.2026-11-23T14-00.md`; pytest 17104 passed, 0 failed and `Invoke-HarnessGeneration.ps1 -Check` with no drift in `contracts.2026-11-23T14-02.md`; the template task check (60 cases, 0 failures) in `task-check.P1-T2.2026-11-23T13-28.md`.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed on the branch; `git status --porcelain` is empty at the reviewed head.
- ✅ No ongoing tooling script was added.

---

## Rejected Scope Narrowing

None. The delegation prompt states "Same inputs as the original review, no scope narrowing", names the base branch, the full feature folder, and both AC sources, and asks the review to "look for any new finding across the whole diff". The audit covers the full branch diff against the merge base above.

## Evidence Location Compliance

- `git diff --name-only 7c4bdc734 HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence files of the item, including the cycle-2 files `evidence/baseline/epic-template-statements.2026-11-23T13-18.md`, `evidence/other/task-check.P1-T2.2026-11-23T13-28.md`, `evidence/qa-gates/powershell-static.2026-11-23T13-38.md`, `evidence/qa-gates/pester-gate.2026-11-23T14-00.md`, `evidence/qa-gates/contracts.2026-11-23T14-02.md`, and `evidence/qa-gates/self-review.2026-11-23T14-05.md`, are under `.dev/active/1219-docs-prose-markdown-lint/evidence/{baseline,qa-gates,other}/`.
- Command: `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` returned exit code 0 with no reported path.
- Append-only: the cycle-2 diff `0f5a4be23..69293991a` adds evidence and review files only; no existing evidence or review file is modified.
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
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | 321 | PASS |
| `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | 117 | PASS |

The bundle mirrors of the three modules are byte-identical to their sources (`cmp`), so their counts are the same. `config/file-size-baseline.json` is not changed on the branch. The cycle-2 edit is Markdown, which is exempt.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Each `It` builds its own in-memory inputs; the lint-scope body test restores `$env:GITHUB_OUTPUT` in `finally`. The full suite passed in one 8-worker `Invoke-PoshQCParallelTest` run; the cycle-2 selection passed in a 3-shard parallel run. |
| **Isolation** | ✅ PASS | One behavior per `It`. No test changed in cycle 2. |
| **Fast Execution** | ✅ PASS | In-memory tests; the gate completed in about 8 minutes (session start to dump) across 29211 cases. |
| **Determinism** | ✅ PASS | No clock, network, random, or temporary-file access in the new or changed tests. |
| **Readability & Maintainability** | ✅ PASS | Descriptive `It` names with Arrange-Act-Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.84% lines repo-wide; `DocsLedgerCommands.psm1` 99.69% (325/326); `DocsProfileCommands.psm1` 97.75% (87/89); `DocsPagePlaceholder.psm1` `N/A - no pre-change run` (new file)<br>**Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-23T07-39.md`<br>**Timestamp:** 2026-11-23 07:39 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.85% lines repo-wide (47330 covered, 1541 missed) from the single cycle-2 gate run<br>**Change:** +0.01% lines<br>**Status:** No regression; changed lines of `DocsLedgerCommands.psm1` and `DocsProfileCommands.psm1` covered. |
| **Repo-wide PowerShell coverage artifact at reviewed head** | ✅ PASS | `artifacts/pester/powershell-coverage.xml` (session 13:44:59 to 13:53:19 UTC, the cycle-2 gate) reports 96.85% (47330/48871), at or above the 85% default. R3 resolved. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** `DocsLedgerCommands.psm1` 99.70% (327/328); `DocsProfileCommands.psm1` 97.87% (92/94), read by this review from the per-file `LINE` counters of the XML<br>**Thresholds:** 85% line (default); no PowerShell branch threshold<br>**Status:** All changed files meet the threshold. |
| **New Code Coverage** | ✅ PASS | **New file:** `.claude/lib/docs/DocsPagePlaceholder.psm1`<br>**New code coverage:** 100.00% (37/37)<br>**Calculation method:** per-file `LINE` counter of the gate JaCoCo report. |
| **Comprehensive Coverage** | ✅ PASS | Counter, report, renderer, and export-surface tests (29 cases); coverage integration tests in `DocsLedgerCommands.Tests.ps1`. |
| **Positive Flows** | ✅ PASS | Counts 1, 3, and 2 on one line; wrap; report sum and ordering; report rendering. |
| **Negative Flows** | ✅ PASS | Wrong case, blank-line separation, non-`.md` page, invalid UTF-8 page, empty lint scope. |
| **Edge Cases** | ✅ PASS | Empty page set, terminated and unterminated front matter, CRLF versus LF, ordinal ordering. |
| **Error Handling** | ✅ PASS | Narrow `DecoderFallbackException` catch; `DOCS_LINT_SCOPE_EMPTY` throw executed in memory; checksum throw position asserted and proven by recorded evidence. |
| **Concurrency** | N/A | The new functions are pure and hold no shared state. |
| **State Transitions** | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.84% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.85% lines. Change: +0.01% lines. New/changed-code coverage: `DocsPagePlaceholder.psm1` 100.00%; `DocsLedgerCommands.psm1` 99.70% (baseline 99.69%); `DocsProfileCommands.psm1` 97.87% (baseline 97.75%). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-gate.2026-11-23T07-39.md`, `evidence/qa-gates/pester-gate.2026-11-23T14-00.md`.
- Python, TypeScript, C#, Bash: N/A (zero changed files of these languages on the branch).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact expected values and `-Because` clauses on ordering assertions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment-marked sections. |
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
| **Pre-submission Review** | ✅ PASS | This audit, the 12-30 and 12-58 reviews, and the cycle-2 self-review `evidence/qa-gates/self-review.2026-11-23T14-05.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1219, `spec.md`, `user-story.md`, research D1-D14. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-23T00-38.md`; `remediation-plan.2026-11-23T12-58.md` (all tasks checked). |
| **Document the plan** | ✅ PASS | Plans, decision records, and per-task evidence. |

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
| **1. Formatting** | ✅ PASS | **Command:** PoshQC format (write mode) then `Invoke-PoshQCFormat` check mode over all files<br>**Result:** 1869 files `Already formatted:`, 0 `Formatted:` lines (`evidence/qa-gates/powershell-static.2026-11-23T13-38.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings over 1869 files; actionlint 1.7.12 exit 0 (`evidence/other/actionlint.2026-11-23T11-52.md`, the workflow template is unchanged since) |
| **3. Type checking** | N/A | PowerShell has no type checker; no TypeScript or Python file changed. |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (parallel) and `run-test-suite.sh pytest` (`-n auto`)<br>**Result:** Pester 29193 passed, 0 failed; pytest 17104 passed, 0 failed; cycle-2 selection 60 passed, 0 failed |
| **Full toolchain loop** | ✅ PASS | The cycle-2 static pass rewrote no file. Integration tests (stage 7) run in CI. |
| **Explicit reporting** | ✅ PASS | Every command and result is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commits `16b38d3cf`, `0f5a4be23`, and `69293991a`; self-review and task-check artifacts. |
| **Design choices explained** | ✅ PASS | Spec decisions D1-D15 and execution decisions. |
| **Update supporting documents** | ❌ FAIL | R2 is resolved: the epic template now reads "The init-written workflow runs markdownlint and Vale; the page check is the required page-structure gate." (line 16), "Adding linters beyond the markdownlint and Vale steps of the init-written workflow." (line 82), and "Linting: `init -Write` writes linter configuration as data and a workflow that runs markdownlint and Vale; `check` is the required page-structure gate." (lines 95-96). New related item: `.dev/engineering/documentation-estate/README.md` line 36, the `## Topic Pages` row for `consumer-onboarding.md`, lists the page content as "Prerequisites, the optional python pack, optional linting, adoption steps, consumer CI and the epic template". The page's `## Linting` section (line 33) now opens "Lint steps are part of the written workflow." and describes the markdownlint and Vale steps, so the index row is inaccurate. Spec `## Scope` item 4 requires "the engineering pages that describe the changed behavior" to be updated in the same change. No test reads the README, no sibling epic child names it, and the file is repository-fixable. |
| **Provide next steps** | ✅ PASS | Next step: replace "optional linting" in the README row with an accurate description (for example "linting"), then PR to the integration branch. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 1869 files already formatted. |
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
| **Step 4: Test** | ✅ PASS | One parallel gate run, 0 failures; cycle-2 parallel selection, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | No rewrite in the cycle-2 pass. |

### Section 3D: JSON Configuration (pack manifest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Structure** | ✅ PASS | `core.json` adds six entries with matching indentation; manifest completeness and dependency-closure tests pass in the cycle-2 pytest run. |

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
| **Use PoshQC test command** | ✅ PASS | `Invoke-PoshQCParallelTest`, 8 workers (gate), 3 shards (cycle-2 selection). |
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
| Total Tests | 29211 (Pester gate) + 17110 (pytest, including 6 skipped) + 60 (cycle-2 selection) | ✅ |
| Tests Passed | 29193 Pester, 17104 pytest, 60 selection | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | about 500 s Pester (JUnit `time` 500.075; 8 workers); 73.25 s pytest | ✅ |
| Average Time per Test | about 17 ms Pester (JUnit time / cases) | ✅ |
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
| Pester selection (cycle 2) | `run-test-suite.sh pester -TestPath DocumentationEstateEpicTemplate.Tests.ps1 DocumentationEstateOnboarding.Tests.ps1 cross-epic-skill-contract.Tests.ps1` | 60 passed, 0 failed | ✅ |

**For the workflow template and harness:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint 1.7.12 | `actionlint -no-color .claude/lib/docs/templates/_docs-quality.yml` | exit 0, 0 findings | ✅ |
| Harness parity | `Invoke-HarnessGeneration.ps1 -Check` | no drift | ✅ |

**Notes:** The review read the cycle-2 static, gate, and contract artifacts and did not re-run format, lint, or tests (the delegation prohibits any run that overwrites `artifacts/pester/`). This review independently re-verified at head `69293991a`: the coverage XML session time and report and per-file `LINE` counters; byte identity of the ten `.claude/lib/docs` bundle pairs and both docs-init skill bundle pairs (`cmp`); logical line counts; the cycle-2 file list (`git diff --stat 0f5a4be23..HEAD`); the template diff (three statements only); AC checkbox counts; and evidence locations (`validate_evidence_locations.py` exit 0).

---

## CI Cross-check

CI status at the head is not available: no pull request exists for the branch yet (`artifacts/pr_context.summary.txt`, generated 2026-11-23 14:07:41 UTC for head `69293991a`). The rows below record the local evidence the review relies on, for comparison with CI once the PR runs.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| PowerShell format (Invoke-PoshQCFormat) | pass | 1869 files, 0 rewritten | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/powershell-static.2026-11-23T13-38.md` |
| PowerShell lint (PSScriptAnalyzer) | pass | 0 findings | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/powershell-static.2026-11-23T13-38.md` |
| Pester tests | pass | 29193 passed, 0 failed (gate); 60 passed (selection) | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/pester-gate.2026-11-23T14-00.md`; `evidence/other/task-check.P1-T2.2026-11-23T13-28.md` |
| Pester line coverage (local artifact) | pass | 96.85% lines repo-wide (47330/48871) | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `artifacts/pester/powershell-coverage.xml`; `evidence/qa-gates/pester-gate.2026-11-23T14-00.md` |
| pytest suite (push-down contracts) | pass | 17104 passed, 0 failed | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/contracts.2026-11-23T14-02.md` |
| Harness generation check | pass | no drift | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/contracts.2026-11-23T14-02.md` |

The gate and contract runs executed on the working tree that commit `69293991a` recorded (the cycle-2 template edit preceded the 13-28 task check and the 13:44 UTC gate start); the commit added only that edit and new evidence.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Update supporting documents: `.dev/engineering/documentation-estate/README.md` line 36 describes `consumer-onboarding.md` as covering "optional linting", which the item's change to the init-written workflow and the corrected `## Linting` section make inaccurate. Remediation: replace "optional linting" in that row with an accurate term (for example "linting"); change no other line. No test reads the README, so no Pester run is needed, and running none keeps the gate coverage XML in place.

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

The branch adds Markdown lint and a pinned, checksum-verified Vale run with a new `DocsTonality` style to the init-written documentation workflow, adds a counted `SME input required` placeholder section to the docs `coverage` output, corrects the onboarding page's linting sentence (cycle 1), and corrects three linting statements in the bundled documentation-estate epic template (cycle 2).

---

## 10. Compliance Verdict

### Overall Status: ❌ One documentation gap

R2 and R3 are resolved. Toolchain, coverage, size, parity, evidence-location, and supply-chain requirements are met with recorded and re-read evidence. One autonomous remediation item remains: the engineering topic index still describes the onboarding page as covering "optional linting".

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes
- ✅ Design Principles
- ✅ Module & File Structure (one 700-line Warning)
- ✅ Naming, Docs, Comments
- ✅ Toolchain Execution
- ⚠️ Summarize & Document: engineering README index row

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

- ✅ 29193/29211 Pester cases passing (18 skipped, 0 failed); 60/60 cycle-2 selection
- ✅ 4/4 new functions tested
- ✅ 96.85% repo-wide PowerShell line coverage in the current artifact; 100.00% on the new module
- ✅ Test files mirror production layout
- ✅ Format, analyzer, actionlint, harness check clean

---

### Recommendation

**Needs revision**

Replace "optional linting" in the `consumer-onboarding.md` row of `.dev/engineering/documentation-estate/README.md` `## Topic Pages` with an accurate description, record a task-check artifact with the search result, and run no Pester selection afterwards (no test reads the README), so that `artifacts/pester/powershell-coverage.xml` keeps the cycle-2 gate figures. No production code change is required.

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
18. documentation-estate onboarding pages › states that lint steps are part of the written workflow and check is the required page gate
19. documentation-estate epic template (not in the diff; re-run in the cycle-2 task check) › manifest parse, feature count, schema findings, waves

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
