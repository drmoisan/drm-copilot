# Policy Compliance Audit: docs-prose-markdown-lint (#1219)

**Audit Date:** 2026-11-24
**Audit Type:** Re-review (remediation cycle 3) after the full cycle that executed `remediation-plan.2026-11-23T14-11.md` for finding R4 of `remediation-inputs.2026-11-23T14-11.md`
**Code Under Test:** merge base `6624aac72e7c30d69b947a9b134ad4f04c3caaff` of the base branch `origin/epic/documentation-estate-families-integration` (resolved to the same commit; the branch merged that tip in `ebfbe0da6`) and reviewed head `6d4e82d7acd24bf47aad7cbd4428a943cce56de1` (`feature/docs-prose-markdown-lint-1219`); the diff between them lists 90 changed files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production modules (1 new, 2 modified) + 3 bundle mirrors; 7 test files | 29211 cases (cycle-2 full gate) + 1029 cases (cycle-3 targeted run) + 18 cases (cycle-3 task check) | ✅ gate 29193 pass, 0 fail, 18 skipped; targeted 1029 pass, 0 fail; task check 18 pass, 0 fail | 96.84% lines repo-wide (482 files) | 96.85% lines repo-wide (cycle-2 full gate); per-file figures re-read at head from the cycle-3 run | `DocsPagePlaceholder.psm1` 100.00% (37/37) |

The remaining changed files carry no executable code: YAML and INI templates (the workflow template and the Vale styles, 7 files plus 7 bundle mirrors, checked by Pester content tests and by actionlint 1.7.12 with exit 0), the `core.json` pack manifest (checked by the push-down manifest pytest contracts), and Markdown skills, pages, templates, and feature records (checked by Pester content tests). Python, TypeScript, C#, and Bash have zero changed files on the branch.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope`
- PowerShell baseline coverage artifact: `.dev/active/1219-docs-prose-markdown-lint/evidence/baseline/pester-gate.2026-11-23T07-39.md`
- PowerShell post-change coverage artifact: `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/pester-gate.2026-11-23T14-00.md` (single full gate run of the item's final QC, cycle 2) for the repo-wide figure; `artifacts/pester/powershell-coverage.xml` (cycle-3 targeted run, session 03:47:42 to 03:49:13 UTC on 2026-11-24) for the per-file figures at the reviewed head
- Per-language comparison summary: section 1.2.1 below

Threshold source: the root `CLAUDE.md` (with its `AGENTS.md` import) states no line or branch coverage figure, so the defaults govern: 85% line for new, modified, and repo-wide PowerShell files. No branch threshold applies to PowerShell (Pester measures line and command coverage only).

Tier classification: `quality-tiers.yml` exists at the repository root on the resolved base branch (and on the earlier merge base `7c4bdc734`); the prior audits of this item stated that it was absent, which this audit corrects. `.claude/lib/docs` is classified `T3` (line 64), and the branch adds no new project folder, so tier classification is met. T3 carries no property-test, mutation, or golden-test obligation.

Coverage artifact state at this review: PASS under the owner-directed waiver recorded below. Cycle 3 ran a targeted Pester selection (41 files) instead of a full gate, as directed by the owner instruction dated 2026-11-23 ("The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests."). The targeted run overwrote `artifacts/pester/powershell-coverage.xml`; its report-level `LINE` counter (7983 covered, 41111 missed) reflects the selection population only and is not a repo-wide measurement. The repo-wide figure remains the cycle-2 full gate, 96.85%. That figure still describes the item: the item's production files are unchanged since the gate (`git diff --stat 69293991a HEAD` over the three modules and their mirrors is empty), and the per-file `LINE` counters of the cycle-3 artifact at head equal the gate figures (`DocsPagePlaceholder.psm1` 37/0, `DocsLedgerCommands.psm1` 327/1, `DocsProfileCommands.psm1` 92/2). The artifact write time (03:49:13 UTC) is later than the newest commit that touches a PowerShell file (`ebfbe0da6`, 03:37:11 UTC); the head commit `6d4e82d7a` touches Markdown evidence only.

---

## Executive Summary

This re-review covers the full branch diff at head `6d4e82d7a`, measured from the merge base `6624aac72` (the integration tip that the branch merged in `ebfbe0da6`). Cycle 3 changed one tracked non-evidence file, `.dev/engineering/documentation-estate/README.md`, in one table cell: "optional linting" became "linting" in the `consumer-onboarding.md` row. Finding R4 is resolved. A repository search for the claim in both word orders outside historical feature records returns only the retained phrase "the optional python pack, linting", which refers to the python pack.

Merge neutrality: the per-path numstat of the item's diff from `7c4bdc734` to `69293991a` equals the per-path numstat from `6624aac72` to `6d4e82d7a` for every pre-existing path; the only additions are the cycle-3 README row and new review and evidence records. `git merge-tree --write-tree` of the base and head is clean. The merge added integration content (#1218 families section in the docs-init skill, `core.json` entries, one new test in `DocsProfileCommands.Tests.ps1`) to files the item also changes; the targeted run of 1029 cases over every test that reads those files passed with 0 failures, and the harness check and the five push-down contract tests passed.

No blocking item remains. All 46 acceptance criteria evaluate PASS.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`.claude/lib/docs` classified T3)
- ✅ `.claude/rules/tonality.md` (DocsTonality rule mapping and authored prose)

**Language-specific policies evaluated:**
- N/A Python (no changed Python file; no new Python introduced)
- ✅ `.claude/rules/powershell.md`
- N/A Bash (no changed `.sh` or `.bats` file)
- ✅ JSON: `core.json` structure checked by the push-down manifest contract tests

Recorded toolchain evidence: PoshQC format (1869 files, 0 rewritten) and PSScriptAnalyzer (0 findings) in `powershell-static.2026-11-23T13-38.md` (no PowerShell file of the item changed after it); the cycle-2 full Pester gate with 0 failures in `pester-gate.2026-11-23T14-00.md`; the cycle-3 targeted run with 0 failures in `pester-gate.2026-11-24T03-56.md`; `Invoke-HarnessGeneration.ps1 -Check` with no drift and 45 contract pytest cases passed in `contracts.2026-11-24T03-56.md`; the cycle-3 task check (18 cases, 0 failures) in `task-check.P1-T2.2026-11-23T14-30.md`.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed on the branch; `git status --porcelain` is empty at the reviewed head.
- ✅ No ongoing tooling script was added.

---

## Rejected Scope Narrowing

None. The delegation names the PR base, the merge base to head range, the full feature folder, and both AC sources. Its statement that changes from #1218, #1222, and main are not part of the item's diff when measured from the merge base matches the computed range and is not a narrowing. The owner instruction on targeted tests concerns test-run scope, not review scope; this audit applies it as an owner-directed waiver for the cycle-3 run and still reports an explicit PASS or FAIL coverage verdict for PowerShell.

## Evidence Location Compliance

- `git diff --name-only 6624aac72 HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence files of the item, including the cycle-3 files `evidence/baseline/readme-linting-row.2026-11-23T14-25.md`, `evidence/other/task-check.P1-T2.2026-11-23T14-30.md`, `evidence/other/decisions.2026-11-23T14-26.md`, `evidence/other/decisions.2026-11-24T03-56.md`, `evidence/qa-gates/pester-gate.2026-11-24T03-56.md`, `evidence/qa-gates/contracts.2026-11-24T03-56.md`, and `evidence/qa-gates/self-review.2026-11-24T03-56.md`, are under `.dev/active/1219-docs-prose-markdown-lint/evidence/{baseline,qa-gates,other}/`.
- Command: `env -u VIRTUAL_ENV poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` returned exit code 0 with no reported path.
- Append-only: the cycle-3 diff `69293991a..6d4e82d7a` adds evidence and review files, edits the README row, and changes `remediation-plan.2026-11-23T14-11.md` only by its own creation in this range (the plan file was authored and its task boxes ticked within the cycle). No earlier evidence or review file is modified.
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
| `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` | 399 | PASS (375 before the merge; the 24-line increase is the #1218 test merged from the integration branch) |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | 321 | PASS |
| `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | 117 | PASS |

The bundle mirrors of the three modules are byte-identical to their sources (`cmp`), and both docs-init skill bundle pairs are byte-identical. `config/file-size-baseline.json` and `.push-down-manifest.json` are not changed on the branch. The cycle-3 edit is Markdown, which is exempt.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Each `It` builds its own in-memory inputs; the lint-scope body test restores `$env:GITHUB_OUTPUT` in `finally`. The full suite passed in one 8-worker parallel gate (cycle 2) and the targeted selection passed in an 8-shard parallel run (cycle 3). |
| **Isolation** | ✅ PASS | One behavior per `It`. No test of the item changed in cycle 3. |
| **Fast Execution** | ✅ PASS | In-memory tests; the targeted run of 1029 cases took 105 s of JUnit test time. |
| **Determinism** | ✅ PASS | No clock, network, random, or temporary-file access in the new or changed tests. |
| **Readability & Maintainability** | ✅ PASS | Descriptive `It` names with Arrange-Act-Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.84% lines repo-wide; `DocsLedgerCommands.psm1` 99.69% (325/326); `DocsProfileCommands.psm1` 97.75% (87/89); `DocsPagePlaceholder.psm1` `N/A - no pre-change run` (new file)<br>**Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-23T07-39.md`<br>**Timestamp:** 2026-11-23 07:39 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.85% lines repo-wide from the single full gate of the item's final QC (cycle 2)<br>**Change:** +0.01% lines<br>**Status:** No regression; the item's production files are unchanged since that gate, and their changed lines remain covered in the cycle-3 artifact. |
| **Repo-wide PowerShell coverage at reviewed head** | ✅ PASS | Owner-directed waiver: cycle 3 ran a targeted selection, so the current XML (7983/49094 lines) measures the selection only and is not used as a repo-wide figure. Repo-wide evidence is the cycle-2 full gate (96.85%); no item production file changed after it. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** `DocsLedgerCommands.psm1` 99.70% (327/328); `DocsProfileCommands.psm1` 97.87% (92/94), read by this review from the per-file `LINE` counters of the current XML and equal to the cycle-2 gate<br>**Thresholds:** 85% line (default); no PowerShell branch threshold<br>**Status:** All changed files meet the threshold. |
| **New Code Coverage** | ✅ PASS | **New file:** `.claude/lib/docs/DocsPagePlaceholder.psm1`<br>**New code coverage:** 100.00% (37/37)<br>**Calculation method:** per-file `LINE` counter of the JaCoCo report. |
| **Comprehensive Coverage** | ✅ PASS | Counter, report, renderer, and export-surface tests (29 cases); coverage integration tests in `DocsLedgerCommands.Tests.ps1`. |
| **Positive Flows** | ✅ PASS | Counts 1, 3, and 2 on one line; wrap; report sum and ordering; report rendering. |
| **Negative Flows** | ✅ PASS | Wrong case, blank-line separation, non-`.md` page, invalid UTF-8 page, empty lint scope. |
| **Edge Cases** | ✅ PASS | Empty page set, terminated and unterminated front matter, CRLF versus LF, ordinal ordering. |
| **Error Handling** | ✅ PASS | Narrow `DecoderFallbackException` catch; `DOCS_LINT_SCOPE_EMPTY` throw executed in memory; checksum throw position asserted and proven by recorded evidence. |
| **Concurrency** | N/A | The new functions are pure and hold no shared state. |
| **State Transitions** | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.84% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.85% lines (cycle-2 full gate). Change: +0.01% lines. New/changed-code coverage: `DocsPagePlaceholder.psm1` 100.00%; `DocsLedgerCommands.psm1` 99.70% (baseline 99.69%); `DocsProfileCommands.psm1` 97.87% (baseline 97.75%), re-read at head from the cycle-3 artifact. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-gate.2026-11-23T07-39.md`, `evidence/qa-gates/pester-gate.2026-11-23T14-00.md`, `evidence/qa-gates/pester-gate.2026-11-24T03-56.md`.
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
| **Pre-submission Review** | ✅ PASS | This audit, the 12-30, 12-58, and 14-11 reviews, and the cycle-3 self-review `evidence/qa-gates/self-review.2026-11-24T03-56.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1219, `spec.md`, `user-story.md`, research D1-D14. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-23T00-38.md`; `remediation-plan.2026-11-23T14-11.md` (all five tasks checked). |
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
| **1. Formatting** | ✅ PASS | **Command:** PoshQC format (write mode) then `Invoke-PoshQCFormat` check mode over all files<br>**Result:** 1869 files `Already formatted:`, 0 `Formatted:` lines (`evidence/qa-gates/powershell-static.2026-11-23T13-38.md`); no item PowerShell file changed after it |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings over 1869 files; actionlint 1.7.12 exit 0 (`evidence/other/actionlint.2026-11-23T11-52.md`, the workflow template is unchanged since) |
| **3. Type checking** | N/A | PowerShell has no type checker; no TypeScript or Python file changed. |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (parallel full gate, cycle 2); `run-test-suite.sh pester -TestPath <41 files>` (parallel targeted run, cycle 3); `run-test-suite.sh pytest` over five contract files<br>**Result:** gate 29193 passed, 0 failed; targeted 1029 passed, 0 failed; pytest 45 passed, 0 failed |
| **Full toolchain loop** | ✅ PASS | No stage rewrote a file. Integration tests (stage 7) run in CI; the two integration-lane files the cycle-3 search matched are refused locally by the launcher and run in CI. |
| **Explicit reporting** | ✅ PASS | Every command and result is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commits through `6d4e82d7a`; self-review, decision, and task-check artifacts. |
| **Design choices explained** | ✅ PASS | Spec decisions D1-D15 and execution decisions, including cycle-3 D1 (proximity-search acceptance narrowed to the exact phrase) and D1/D2 of `decisions.2026-11-24T03-56.md` (targeted run, integration-lane exclusion). |
| **Update supporting documents** | ✅ PASS | R4 resolved: `.dev/engineering/documentation-estate/README.md` line 36 now reads "Prerequisites, the optional python pack, linting, adoption steps, consumer CI and the epic template". `git grep -i -P '(optional[^.\n]{0,40}lint|lint[^.\n]{0,40}optional|no required linter)'` over tracked files outside `.dev/active`, `.dev/potential`, `.dev/epics`, `.dev/archive`, and `.dev/completed` returns only that row, where "optional" qualifies the python pack. |
| **Provide next steps** | ✅ PASS | Next step: open the PR to the integration branch and confirm CI at the PR head against the `## CI Cross-check` rows. |

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
| **Step 4: Test** | ✅ PASS | One parallel full gate (cycle 2) and one parallel targeted run (cycle 3), 0 failures each. |
| **Rerun loop if needed** | ✅ PASS | No rewrite in any pass. |

### Section 3D: JSON Configuration (pack manifest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Structure** | ✅ PASS | `core.json` adds six entries for the item with matching indentation; the merge added the integration entries without conflict; the manifest completeness and dependency-closure tests pass in the cycle-3 contract run. |

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
| **Use PoshQC test command** | ✅ PASS | `Invoke-PoshQCParallelTest`, 8 workers (gate), 8 shards (cycle-3 targeted run). |
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
| Total Tests | 29211 (cycle-2 Pester gate) + 1029 (cycle-3 targeted run) + 18 (cycle-3 task check) + 45 (cycle-3 contract pytest) | ✅ |
| Tests Passed | 29193 gate, 1029 targeted, 18 task check, 45 pytest | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | about 500 s Pester gate; 105 s targeted run (JUnit `time` 104.972) | ✅ |
| Average Time per Test | about 17 ms gate; about 102 ms targeted run (JUnit time / cases) | ✅ |
| Discovery Time | Not recorded separately | N/A |
| Functions Tested | 4/4 new functions (100%) | ✅ |
| Test File Size | largest changed test file 600 logical lines | ✅ |
| Code Coverage | 96.85% lines repo-wide (cycle-2 gate); 100.00% new module (re-read at head) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` (check mode, all files) | 1869 already formatted | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with repository settings | 0 findings | ✅ |
| Pester full gate (cycle 2) | `Invoke-PoshQCParallelTest` | 29193 passed, 0 failed | ✅ |
| Pester targeted run (cycle 3) | `run-test-suite.sh pester -TestPath <41 files>` | 1029 passed, 0 failed | ✅ |

**For the workflow template and harness:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint 1.7.12 | `actionlint -no-color .claude/lib/docs/templates/_docs-quality.yml` | exit 0, 0 findings | ✅ |
| Harness parity | `Invoke-HarnessGeneration.ps1 -Check` | no drift | ✅ |

**Notes:** The review read the recorded static, gate, targeted-run, and contract artifacts and did not re-run format, lint, or tests. This review independently re-verified at head `6d4e82d7a`: the README diff (one row); the repository search for the claim; the per-path numstat of the item diff across the old and new merge bases; `git merge-tree` of base and head (clean); the per-file `LINE` counters and session times of the current coverage XML and the JUnit header (`tests="1029" failures="0" errors="0"`); byte identity of the three module bundle pairs and both docs-init skill bundle pairs (`cmp`); logical line counts; AC checkbox counts; `quality-tiers.yml` classification of `.claude/lib/docs`; and evidence locations (`validate_evidence_locations.py` exit 0).

---

## CI Cross-check

CI status at the head is not available: no pull request exists for the branch yet (`gh pr list --head feature/docs-prose-markdown-lint-1219` returns an empty list, and `gh run list --branch` returns no run). The remote branch is at `6d4e82d7a`. The rows below record the local evidence the review relies on, for comparison with CI once the PR runs.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| PowerShell format (Invoke-PoshQCFormat) | pass | 1869 files, 0 rewritten | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/powershell-static.2026-11-23T13-38.md` |
| PowerShell lint (PSScriptAnalyzer) | pass | 0 findings | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/powershell-static.2026-11-23T13-38.md` |
| Pester tests (full gate) | pass | 29193 passed, 0 failed | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/pester-gate.2026-11-23T14-00.md` |
| Pester line coverage (full gate) | pass | 96.85% lines repo-wide (47330/48871) | 69293991ae9585c5a371de4b55ffa5f290554ac9 | `evidence/qa-gates/pester-gate.2026-11-23T14-00.md` |
| Pester tests (targeted, after merge) | pass | 1029 passed, 0 failed | 6d4e82d7acd24bf47aad7cbd4428a943cce56de1 | `evidence/qa-gates/pester-gate.2026-11-24T03-56.md`; `artifacts/pester/pester-junit.xml` |
| Pester per-file coverage of item modules | pass | 37/37, 327/328, 92/94 lines | 6d4e82d7acd24bf47aad7cbd4428a943cce56de1 | `artifacts/pester/powershell-coverage.xml` |
| pytest push-down contracts | pass | 45 passed, 0 failed | 6d4e82d7acd24bf47aad7cbd4428a943cce56de1 | `evidence/qa-gates/contracts.2026-11-24T03-56.md` |
| Harness generation check | pass | no drift | 6d4e82d7acd24bf47aad7cbd4428a943cce56de1 | `evidence/qa-gates/contracts.2026-11-24T03-56.md` |

The format, lint, and full-gate rows were produced at `69293991a`; no PowerShell file of the item changed between that head and `6d4e82d7a`. The targeted and contract runs executed on the working tree after the merge `ebfbe0da6`; the head commit `6d4e82d7a` added only the evidence records of those runs.

---

## 8. Gaps and Exceptions

### Identified Gaps

None.

### Approved Exceptions

1. **Cycle-3 targeted Pester run in place of a full gate** — owner instruction dated 2026-11-23, recorded in `evidence/other/decisions.2026-11-24T03-56.md` (D1). The repo-wide coverage evidence is the cycle-2 full gate of the item's final QC. The cycle-3 coverage XML is a selection measurement and is not used as a repo-wide figure.
2. **Integration-lane exclusion** — `DocsCompleteIntegration.Tests.ps1` and `DocsReferenceIntegration.Tests.ps1` are refused locally by the launcher (`TEST_EXECUTION_POLICY_BLOCKED`) and run in CI (D2).

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

The branch adds Markdown lint and a pinned, checksum-verified Vale run with a new `DocsTonality` style to the init-written documentation workflow, adds a counted `SME input required` placeholder section to the docs `coverage` output, corrects the onboarding page's linting sentence (cycle 1), corrects three linting statements in the bundled documentation-estate epic template (cycle 2), and corrects the engineering topic index row for the onboarding page (cycle 3).

---

## 10. Compliance Verdict

### Overall Status: ✅ Compliant

R4 is resolved. Toolchain, coverage, size, parity, tier, evidence-location, and supply-chain requirements are met with recorded and re-read evidence. The cycle-3 targeted test run is an owner-directed waiver and is recorded as an approved exception.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes
- ✅ Design Principles
- ✅ Module & File Structure (one 700-line Warning)
- ✅ Naming, Docs, Comments
- ✅ Toolchain Execution
- ✅ Summarize & Document

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

- ✅ 29193/29211 Pester cases passing in the full gate (18 skipped, 0 failed); 1029/1029 in the cycle-3 targeted run
- ✅ 4/4 new functions tested
- ✅ 96.85% repo-wide PowerShell line coverage (full gate); 100.00% on the new module
- ✅ Test files mirror production layout
- ✅ Format, analyzer, actionlint, harness check clean

---

### Recommendation

**Ready for PR**

Open the PR to `epic/documentation-estate-families-integration` and confirm CI at the PR head against the `## CI Cross-check` rows.

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

---

## Appendix B: Toolchain Commands Reference

```powershell
# Formatting and analysis (recorded by the executor)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (parallel only)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <selection>
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <contract files>

# Evidence locations (run by this review)
env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# Parity
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-24
**Policy Version:** Current (as of audit date)
