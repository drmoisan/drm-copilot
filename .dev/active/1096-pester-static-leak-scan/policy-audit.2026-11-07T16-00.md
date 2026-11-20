# Policy Compliance Audit: pester-static-leak-scan (#1096)

---

**Audit Date:** 2026-11-07
**Audit Type:** First full review of the branch
**Code Under Test:** Full branch diff of `feature/pester-static-leak-scan-1096` (head `c8e2152088bb5c27cbeb8718b5e04c8f1ff9df9c`) against `main` (merge base `278bb7047db986bbb0a8652ca323656ce85f8a08`): 104 paths, of which 52 are in the feature folder. Outside the feature folder: 52 paths, including 4 added code files (`PoshQC.LeakScan.psm1` and `PoshQC.LeakAllowlist.psm1` with their bundle copies), 2 added Pester suites, 1 added Pester suite for VS Code tasks, 1 added JSON allowlist, and modified PowerShell, Python, JSON, YAML, and Markdown files. No TypeScript, C#, or bash file is in the diff.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 17 files | 16158 tests | ✅ 16152 pass, 0 fail, 6 skipped | 96.71% lines, 93.66% branches | 96.98% lines, 94.14% branches | 98.77% lines, 97.37% branches |
| PowerShell | 22 files | 14825 tests | ✅ 14825 tests, 0 fail, 10 disabled | 93.96% lines | 94.01% lines | 95.16% lines |
| TypeScript | 0 files | 5289 tests | ✅ 5289 pass, 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

Rows for C# and bash are deleted because the branch diff holds zero files of those languages. The TypeScript row is kept because the bundled resources changed and Jest ran as a gate.

### Coverage Evidence Checklist

- Python baseline coverage artifact: docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/baseline/pytest-parallel.2026-11-07T14-21.md
- Python post-change coverage artifact: artifacts/python/lcov.info
- PowerShell baseline coverage artifact: docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/baseline/pester-parallel.2026-11-07T14-21.md
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows the policy-audit template on the reviewed branch and the most recent validated audit in the repository.

---

## Executive Summary

The branch delivers the static Pester leak scan, its allowlist, the CI step, the VS Code task, the `fix_all` step, the test fixes, the deferred parallel-gate command edits, the brief edits, and the ledger update. All 35 locally verifiable acceptance criteria evaluate as PASS. One blocking finding remains, and it is a wait, not a defect: the branch modifies `.github/workflows/_poshqc.yml`, and no green workflow run exists for the branch head.

- Static checks re-run by this review at head: `Invoke-Formatter` and `Invoke-ScriptAnalyzer` over the 22 changed PowerShell files gave 0 differences and 0 findings; `ruff`, `black --check`, and `pyright` over the 17 changed Python files gave 0 findings.
- `Invoke-PoshQCLeakScan -Root <worktree>` at head: 548 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures. This matches the recorded gate.
- 28 in-memory probes of `Get-PoshQCLeakFinding` matched the spec's detected kinds and restore rules R1 to R5, including a restore of a different name, a later literal assignment, a here-string, a `Mock`-named command, and a parse error.
- All 27 `Current` fences of ledger entry 0001 replay against their targets, and `Test-ProcessReductionLedger` returns valid.
- Coverage passes for Python and PowerShell against the 85% line and 75% branch thresholds, and no changed measured file is below its baseline figure.
- PA-1 (Blocking, `awaiting_ci`): `modified-workflow-needs-green-run`. The branch is pushed, but `gh run list --branch` returns no run and no PR exists.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [✅] `github-actions.instructions.md` and `.claude/rules/ci-workflows.md`
- [N/A] TypeScript: no TypeScript file in the branch diff
- [N/A] C#: no C# file in the branch diff

Toolchain state: every static tool was re-run check-only at head with zero findings. The Pester, pytest, and Jest gates ran after the last code commit (`a6541a577`, 10:36 local time; Pester artifact 10:43, Python artifact 10:46) and reported zero failures. Under the owner directive that gates are re-run only after a fix, this review did not re-run a test suite.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --porcelain` was empty before this review wrote its artifacts, and the branch diff holds no script outside `tests/`, `scripts/`, and the bundle.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: the two new PoshQC modules are covered at 98.22% and 95.40% of lines.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller text below was evaluated against the Scope Invariant.

> "Owner decisions that govern this item: test gates are parallel only (one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix); this plan carries an owner-directed test baseline (spec Decision 9); and `poshqc / PowerShell hook suites (Linux)` stays unchanged."

This text governs how tests are run and does not limit the files audited or waive any language. Coverage for Python and PowerShell carries an explicit verdict from the gate artifacts.

> "SubagentStop artifact checks test repository-relative paths from the main checkout, where this item's folder does not exist. This is a known limit, being filed separately. Do not create files in the main checkout and do not retry on that message."

This text concerns the stop hook's working directory, not audit scope. All artifacts were written in the item worktree.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0. `git diff --name-only 278bb7047..HEAD -- artifacts/` returned no path. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/other/`, all canonical kinds. No violations were found.

---

## Process-Reduction Ledger Compliance

Rule: `feature-review-workflow` `### Process-reduction ledger`. `docs/engineering/process-reductions/` exists, and the branch moves the serial commands deferred by #1094 to the parallel gates, so the rule applies.

| Requirement | Status | Evidence |
|------------|--------|----------|
| **A reduction has an entry** | ✅ PASS | The removals are later landings of entry 0001, which records them in `## Files Changed` and `## Prior Text`. No new entry was added, as spec Decision 7 states. |
| **Entry format** | ✅ PASS | `Test-ProcessReductionLedger` over the real folder returns `IsValid` true. |
| **Entry is revertible** | ✅ PASS | This review replayed all 27 Revert Blocks with `Invoke-ProcessReductionRevert` in memory at head: 27 OK, 0 failed. |
| **Token in a commit subject** | ✅ PASS | `45e2f0f09` (`refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001`) and `07c392826` (fence correction, `reduction: 0001`). |
| **Each reduction is its own commit** | ✅ PASS | `45e2f0f09` holds the serial-command edits, the six brief `## Test Runtime` lines, and the entry update, and no leak-scan module, allowlist, or CI step. The leak-scan additions are in `dc3d8440b`, `0e02323d6`, `8b59b6e49`, `982507b0c`, and `16fd2f126`. |
| **Merge commit back-filled** | ✅ PASS | `Merge commit: 278bb7047db986bbb0a8652ca323656ce85f8a08`. `origin/main` carries the same line change; `git merge-tree` of head with `origin/main` reports no conflict. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The leak-scan suites use in-memory text and injected seams. The branch removes the global `Import-ScriptFunction` definition and the process-directory writes, and the scan itself now guards independence statically. |
| **Isolation** - Each test targets single behavior | ✅ PASS | `LS-K`, `LS-R`, `LA-`, `LI-`, `VT-`, and `WF06` cases each pin one behavior or table row. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 8 shards in about 4.8 minutes over 14825 tests; pytest 169.09 s over 16158 tests. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, or temporary file in the added tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Tagged identifiers, table-driven cases, and Arrange-Act-Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | `PoshQC.psm1` 88.52%, `DrmCopilotPromptSupport.ps1` 87.50%; Python changed files 93.20% to 100% lines and 77.78% to 100% branches. Read by this review from the two artifacts. |
| **New Code Threshold** | ✅ PASS | `PoshQC.LeakScan.psm1` 221 of 225 lines (98.22%); `PoshQC.LeakAllowlist.psm1` 83 of 87 lines (95.40%). |
| **Comprehensive Tests** | ✅ PASS | Each detected kind and restore rule has a unit case; allowlist validation and scan-level throws are covered with injected seams. |
| **Positive Flows** - Valid inputs | ✅ PASS | `LS-K01` per kind; `LA-` valid allowlist; `LI-` clean scan. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `LS-R03` unpaired writes; `LA-` rejection rows; `LI-` throws on unallowlisted, stale, invalid, and parse-error inputs. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Dynamic names, here-strings, `Mock`-named commands, backslash paths, empty folder sets, and the Windows PowerShell 5.1 version type. |
| **Error Handling** - Error paths | ✅ PASS | Parse errors and allowlist errors throw naming the source; the default-folder throw reaches the caller. |
| **Concurrency** - If applicable | N/A | The scan is single-threaded and reads only. |
| **State Transitions** - If applicable | ✅ PASS | R3 restore consumption is covered by `LS-R06`. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.71% lines, 93.66% branches -> Post-change: 96.98% lines, 94.14% branches. Change: +0.27 pp lines, +0.48 pp branches. New/changed-code coverage: 98.77% lines, 97.37% branches. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pytest-parallel.2026-11-07T15-46.md.
- PowerShell: Baseline: 93.96% lines -> Post-change: 94.01% lines. Change: +0.05 pp. New/changed-code coverage: 95.16% lines. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pester-parallel.2026-11-07T15-43.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

Python detail. This review parsed `artifacts/python/lcov.info`: 366 files, 32364 of 33372 lines and 11784 of 12518 branches. The figures match the gate record. The changed-code figure is the sum over the six changed production files: 560 of 567 lines and 185 of 190 branches. Per file: `fix_all_branches.py` 87/87 and 26/26; `fix_all_branches_extra.py` 85/85 and 24/24; `cli_preflight.py` 153/153 and 77/78; `qc_runner.py` 96/103 and 14/18; `prompt_builder.py` 124/124 and 44/44; `qc_toolchain.py` 15/15 with no branch. The baseline figure is the total recorded in the baseline gate file.

PowerShell detail. The root LINE counter of `artifacts/pester/powershell-coverage.xml` is 23951 covered and 1527 missed (94.01%), and `artifacts/pester/pester-junit.xml` reads 14825 tests with 0 failures and 0 errors, which identifies a full-tree merged run. The changed-code figure sums the four measured production files: 393 of 413 lines. The baseline repo-wide figure, 23645 covered and 1519 missed, was read by this review from the merged baseline file that the executor copied to the session scratchpad after the baseline run; the baseline evidence file records per-file figures only. The three bundle copies under `extensions/drm-copilot/resources/powershell/PoshQC/` are not measured and share blob ids with their sources. `PoshQC.psd1` is a manifest with no executable lines.

Freshness. The last commit that changes a path outside `docs/features/` is `a6541a577` at 10:36 local time. The Pester artifact was written at 10:43 and the Python artifact at 10:46, both after it, and both match the third-pass gate records.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` text on workflow and task assertions; findings rendered as `path, line, kind, name` in assertions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit comments in the new and edited suites. |
| **Document Intent** | ✅ PASS | File headers state the issue and what each family pins; new Python tests carry docstrings. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The scan tests pass script text through `-ReadText`, `-ReadAllowlist`, and `-EnumerateFiles` seams. |
| **Use Mocks/Stubs** | ✅ PASS | `Test-Path` is mocked in the activation-path cases; the location seam replaces `Push-Location` and `[Environment]::CurrentDirectory`. |
| **Environment Stability** | ✅ PASS | A diff scan of added test lines found no `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `tmp_path`, `tempfile`, `Set-Content`, `Out-File`, or `WriteAllText`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` Decisions 1 to 9, and `user-story.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-11-07T14-05.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-11-07T02-06.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One pure core (`Get-PoshQCLeakFinding`) and one I/O entry point with seams. |
| **Reusability** | ✅ PASS | Restore pairing rules share one region test, `Test-PoshQCLeakRegionRestore`. |
| **Extensibility** | ✅ PASS | Command families are data arrays; a new kind is one detector and one allowlist enum value. |
| **Separation of concerns** | ✅ PASS | Parsing and pairing in `PoshQC.LeakScan.psm1`; allowlist validation, comparison, and I/O in `PoshQC.LeakAllowlist.psm1`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The scan is split along the parse and allowlist boundary named in the spec. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest logical line counts among 37 covered files: `test_qc_runner.py` 711, `test_prompt_builder.py` 696, `qc_runner.py` 573, `PoshQC.LeakScan.psm1` 497. `test_qc_runner.py` crosses the 700-line advisory tier on this branch (665 at the merge base) and is reported as a non-blocking Warning in the code review. `config/file-size-baseline.json` is not in the branch diff. |
| **Public vs internal** | ✅ PASS | Only `Invoke-PoshQCLeakScan` is exported, in both export lists of both copies. |
| **No circular dependencies** | ✅ PASS | `PoshQC.LeakAllowlist.psm1` calls `Get-PoshQCLeakFinding` and `Get-PoshQCScanConfigFolder` through the parent module's sub-module load order. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs and `PoshQCLeak` nouns throughout. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on the public and core functions; README entry in both copies. |
| **Comment why, not what** | ✅ PASS | Comments state why the consumed set holds AST nodes and why both integer types are accepted. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check` and `Invoke-Formatter`.<br>**Result:** 17 Python files unchanged; 22 PowerShell files identical after formatting (reviewer runs at head). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check` and `Invoke-ScriptAnalyzer`.<br>**Result:** 0 findings in each (reviewer runs at head). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` over the changed files.<br>**Result:** 0 errors, 0 warnings. Does not apply to PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and one `node run-jest.cjs` run.<br>**Result:** 0 failures in all three. |
| **Full toolchain loop** | ✅ PASS | Static tools are clean at head; no code changed after the gates. |
| **Explicit reporting** | ✅ PASS | Commands are recorded under `evidence/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 of this audit and the commit history. |
| **Design choices explained** | ✅ PASS | Spec `## Decisions` and `## Constraints & Risks`. |
| **Update supporting documents** | ✅ PASS | PoshQC README, brief, and ledger entry 0001. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check <17 files>`<br>**Result:** 17 files unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check <17 files>`<br>**Result:** no findings. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <17 files>`<br>**Result:** 0 errors. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`<br>**Result:** 16152 passed, 6 skipped, 0 failures. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Command lists keep their `list[str]` annotations. |
| **Dataclasses for value objects** | N/A | None added. |
| **Protocols/ABCs for interfaces** | N/A | None added. |
| **Avoid utility classes** | ✅ PASS | Edits are to existing functions and one class constant. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No handler changed. |
| **Logging over print** | ✅ PASS | No output path changed. |
| **Invariants at construction** | N/A | No constructor changed. |

---

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with the repo settings<br>**Result:** output identical for all 22 files. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with the repo settings<br>**Result:** 0 findings in all 22 files. |
| **Fix all findings** | ✅ PASS | None to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | `a6541a577` accepts the `Int32` version type that Windows PowerShell 5.1 returns from `ConvertFrom-Json`, and the AST APIs used exist in both. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every new function uses `CmdletBinding`; most declare `OutputType`. |
| **Parameter validation** | ✅ PASS | Mandatory parameters with `AllowEmptyString` and `AllowEmptyCollection` where empty input is legal. |
| **Avoid global state** | ✅ PASS | Script-scoped values are constant lookup arrays; no state is written. |
| **ShouldProcess for state changes** | N/A | The scan reads only and changes no state. |
| **Error handling** | ✅ PASS | Failures accumulate and end in one throw; a parse error is never skipped. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | `PoshQC.LeakScan.psm1` 497, `PoshQC.LeakAllowlist.psm1` 212 logical lines. |
| **Approved verbs** | ✅ PASS | `Get`, `Test`, `Compare`, `ConvertFrom`, `Resolve`, `Invoke`. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `evidence/qa-gates/powershell-format.2026-11-07T15-38.md`. |
| **Step 2: Analyze** | ✅ PASS | `evidence/qa-gates/powershell-analyze.2026-11-07T15-38.md`. |
| **Step 3: Type check** | N/A | Does not apply to this language. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/pester-parallel.2026-11-07T15-43.md`. |
| **Rerun loop if needed** | ✅ PASS | Three gate passes, each after a fix. |

---

### Section 3C: GitHub Actions Workflow Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No deliberately failing nested command** | ✅ PASS | The new `pwsh` step calls a PowerShell function that throws on failure; it invokes no native command whose exit code could leak, so `.claude/rules/ci-workflows.md` imposes no reset. |
| **No new job or required context** | ✅ PASS | One step added to `poshqc-static`; `WF06-LEAK-SCAN-STEP` pins its position and the absence of `continue-on-error` and `if`. |
| **modified-workflow-needs-green-run** | ❌ FAIL | No run exists for the branch; see PA-1 in Section 8. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Existing modules and fixtures. |
| **Coverage expectation** | ✅ PASS | Repo-wide 96.98% line, 94.14% branch, against 85% and 75%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | New cases assert one command list each. |
| **Mocking sparingly** | ✅ PASS | Runner fakes record commands; no process starts. |
| **Organization** | ✅ PASS | Under `tests/scripts/dev_tools/`, mirroring the tools. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<subject>_<expected behavior>`. |
| **Docstrings/comments** | ✅ PASS | `899b62b1e` and `07c392826` documented the helpers and fakes. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto`<br>**Result:** 0 failures. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

---

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`, `It -ForEach`, and `Should`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7 per repository rule. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One case per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Cases assert findings and throws, not internal records. |
| **Mocking Used Sparingly** | ✅ PASS | Seams are scriptblock parameters; `Mock` is used for `Test-Path` only. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1`, `PoshQC.LeakAllowlist.Tests.ps1`, `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`.<br>**Code files:** `scripts/powershell/PoshQC/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites. |
| **Describe/Context/It Structure** | ✅ PASS | Tag counts: `LS-K` 38, `LS-R` 31, `LA-` 21, `LI-` 13, `VT-` 6, `WF06` 1, all passed. |
| **Logical Grouping** | ✅ PASS | Detected kinds, restore pairing, allowlist, and invocation families. |
| **Docstrings/Comments** | ✅ PASS | File headers and inline Arrange comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Result:** ExitCode 0, 8 shards. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### PoshQC.LeakScan.Tests.ps1 (69 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `LS-K01` to `LS-K06` | Positive and Negative | Detectors and sorting | ✅ |
| `LS-R01` to `LS-R06` | Positive, Negative, Error | Pairing rules R1 to R5 and parse errors | ✅ |

**Coverage:** `PoshQC.LeakScan.psm1` 98.22% of lines.

**Not covered:** 4 lines; none is a detection rule named in the spec table.

---

### PoshQC.LeakAllowlist.Tests.ps1 (34 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `LA-` rows | Positive and Negative | Allowlist validation and comparison | ✅ |
| `LI-` rows | Positive, Negative, Error | `Invoke-PoshQCLeakScan` seams and throws | ✅ |

**Coverage:** `PoshQC.LeakAllowlist.psm1` 95.40% of lines.

**Not covered:** 4 lines, including default seam bodies that run only in the real scan.

---

### Workflow and task suites (7 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `WF06-LEAK-SCAN-STEP` | Positive and Negative | `_poshqc.yml` text | ✅ |
| `VT-` rows | Positive and Negative | `.vscode/tasks.json` text | ✅ |

**Coverage:** configuration text, not production code.

**Not covered:** nothing additional.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 36272 (14825 Pester, 16158 pytest, 5289 Jest) | ✅ |
| Tests Passed | 16152 pytest; 5289 Jest; Pester 14825 tests with 0 failures and 10 disabled | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | about 4.8 minutes Pester, 169.09 s pytest | ✅ Fast |
| Average Time per Test | N/A - parallel wall-clock | ✅ |
| Discovery Time | N/A - not recorded by the parallel gates | ✅ |
| Functions/Classes Tested | 1 public and 26 private PowerShell functions added | ✅ |
| Test File Size | 302 logical lines for the largest new suite; 711 maximum among changed files | ✅ PASS |
| Code Coverage (if applicable) | Python 96.98% lines, 94.14% branches; PowerShell 94.01% lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` | 17 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | no findings | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 0 failures | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` | identical, 22 files | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings, 22 files | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | ExitCode 0, 0 failures | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan -Root .` | 0 failures, 548 files | ✅ |

**Notes:**
`check_quality_tiers` reported OK for 29 entries and 29 discovered projects; `scripts/powershell/PoshQC` is T3 and the new modules fall under it. The six `execution-environment` copies share blob `e43b9af24`. Each new PoshQC module shares a blob with its bundle copy, and `POSHQC_PARITY_PATHS` lists both. The branch adds no `.py` file and touches no `atomic-plan-contract` copy, no Epic #1019 folder, no file under `.claude/rules/` or `.github/instructions/`, and neither `.agents/skills/powershell` nor `.agents/skills/python`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Blocking, `awaiting_ci`): `modified-workflow-needs-green-run`.** The diff modifies `.github/workflows/_poshqc.yml`. The branch head is pushed (`git ls-remote` returns `c8e215208`), but `gh run list --branch feature/pester-static-leak-scan-1096` returns no run and `gh pr list --head` returns no PR, so no qualifying green run exists. `ci.yml` calls `_poshqc.yml` and accepts `workflow_dispatch`, so a dispatched run against the branch head, or the PR run, satisfies the rule. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.
- The two CI-dependent acceptance criteria are pending CI and carry no separate finding block.

Non-blocking items recorded in `code-review.2026-11-07T16-00.md`: `test_qc_runner.py` crosses the 700-line advisory tier; `QCRunner.FULL_TEST` keeps `--cov-report` flags with no coverage source, which the spec records; a file read failure in `Invoke-PoshQCLeakScan` is labelled `parse-error`; a restore inside a nested block is reported (conservative), as the spec's R3 defines.

### Approved Exceptions

- Spec Decision 1: policy files still name single-process commands; recorded for the owner report.
- Spec Decision 2: the `LASTEXITCODE` exemption, the only `exemptGlobalVariables` name; 67 findings are exempt through it.
- Spec Decision 3: proof by construction for the three named tests; no single-process reproduction.
- Spec Decision 8: `poshqc / PowerShell hook suites (Linux)` unchanged; `LINUX-HOOKS-JOB-UNCHANGED=True` in the scope gate.

### Removed/Skipped Tests

No test was removed or skipped. The two process-directory tests in `Enter-DrmCopilotShell.Tests.ps1` were rewritten in place with their titles kept, and two default-path cases were added.

---

## 9. Summary of Changes

### Commits in This PR/Branch

35 commits. Commits that change paths outside the feature folder:

1. **dc3d8440b** - feat(poshqc): add the static Pester leak-scan core (#1096)
2. **0e02323d6** - feat(poshqc): add the leak allowlist and Invoke-PoshQCLeakScan (#1096)
3. **8eb24f13b** - test: stop the known Pester state leaks (#1096)
4. **e8add3daa** - test: remove the process-directory dependency of the named tests (#1096)
5. **1c5df3025** - test: restore the codex child-guard environment under its finally (#1096)
6. **8b59b6e49** - feat(poshqc): add the leak-scan allowlist (#1096)
7. **982507b0c** - feat(ci): run the Pester leak scan in CI, VS Code, and fix_all (#1096)
8. **45e2f0f09** - refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001
9. **18d4b83ab** - test(atomic-executor): close the preflight and prompt builder coverage gap (#1096)
10. **16fd2f126** - docs(skills): state the Pester leak scan in the execution-environment brief (#1096)
11. **07c392826** - test(atomic-executor): document the reduction test fakes and correct their fences, reduction: 0001
12. **899b62b1e** - test(atomic-executor): document the preflight and prompt builder test helpers (#1096)
13. **a6541a577** - fix(poshqc): accept the Windows PowerShell 5.1 allowlist version type (#1096)

### Files Modified

1. **`scripts/powershell/PoshQC/PoshQC.LeakScan.psm1`, `PoshQC.LeakAllowlist.psm1`, and bundle copies** (NEW)
   - AST scan, pairing rules, allowlist validation, and `Invoke-PoshQCLeakScan`.
2. **`config/poshqc-leak-allowlist.json`** (NEW)
   - One `LASTEXITCODE` exemption and two reasoned entries.
3. **`.github/workflows/_poshqc.yml`, `.vscode/tasks.json`, `scripts/dev_tools/fix_all_branches.py`** (MODIFIED)
   - Scan step, task, and `fix_all` step; parallel Pester in `fix_all`; aggregate tasks on parallel gates.
4. **`scripts/dev_tools/atomic_executor/*.py`, `fix_all_branches_extra.py`** (MODIFIED)
   - `-n auto` on full-suite pytest commands and prompt text; stale `--cov=src/lexile_corpus_tuner` removed.
5. **`scripts/dev-tools/DrmCopilotPromptSupport.ps1`** (MODIFIED)
   - `-GetLocationPath` seam with a `$PWD.ProviderPath` default.
6. **Test suites** (NEW and MODIFIED)
   - Leak-scan, allowlist, workflow, and task suites; leak fixes in eight existing suites and `TestHelpers.ps1`.
7. **Brief in six copies and ledger entry 0001** (MODIFIED)

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIAL

Coverage, toolchain, mirror, scope, and ledger requirements are met, and all 35 locally verifiable acceptance criteria evaluate as PASS. PA-1 holds the branch until a green run of the modified workflow exists for the head.

**Fail-closed reminder:** numeric post-change coverage is recorded for every changed language, and changed-code coverage is recorded for the changed production files.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and policy reads recorded
- ✅ Design Principles: compliant
- ✅ Module & File Structure: one test file crosses the 700-line advisory tier; no file above 800
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: clean at head; gates postdate the last code commit
- ✅ Summarize & Document: compliant

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean at head
- ✅ Python Design & Typing: compliant
- ✅ Error Handling: unchanged

**For PowerShell:**
- ✅ Tooling & Baseline: clean at head
- ✅ PowerShell Design & Safety: compliant
- ✅ Structure & Naming: compliant
- ✅ Toolchain: one parallel gate run per fix

**For GitHub Actions:**
- ❌ modified-workflow-needs-green-run: PA-1, awaiting CI

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: both changed coverage languages above the thresholds and at or above baseline
- ✅ Test Structure: compliant
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: compliant
- ✅ Toolchain: `pytest -n auto`

**For PowerShell:**
- ✅ Framework & Scope: compliant
- ✅ Toolchain: `Invoke-PoshQCParallelTest`

---

### Metrics Summary

- ✅ 0 failures in all three gates
- ✅ Python 96.98% line and 94.14% branch against 85% and 75%
- ✅ PowerShell 94.01% line against 85%; new modules 98.22% and 95.40%
- ✅ Leak scan clean at head; 27 of 27 ledger fences replay
- ❌ No green run of the modified workflow for the branch head

---

### Recommendation

**Wait for CI**

Run CI against the branch head, by `workflow_dispatch` of `ci.yml` on `feature/pester-static-leak-scan-1096` or by the PR run, then re-check PA-1. No code change is required.

---

## Appendix A: Test Inventory

### Complete Test List

- `PoshQC.LeakScan.Tests.ps1` › detected kinds › `LS-K01` to `LS-K06`
- `PoshQC.LeakScan.Tests.ps1` › restore pairing › `LS-R01` to `LS-R06`
- `PoshQC.LeakAllowlist.Tests.ps1` › `LA-` allowlist validation and comparison rows
- `PoshQC.LeakAllowlist.Tests.ps1` › `LI-` `Invoke-PoshQCLeakScan` rows
- `PoshQcWorkflow.Tests.ps1` › `WF06-LEAK-SCAN-STEP`
- `VsCodeQualityTasks.Tests.ps1` › `VT-LEAK-SCAN-TASK`, `VT-AGGREGATES-PARALLEL-ONLY` (2 rows), `VT-DEPENDS-ON-RESOLVES`, `VT-DEFAULT-TEST-TASK`, `VT-SERIAL-TASKS-REMAIN`
- `Enter-DrmCopilotShell.Tests.ps1` › seam and default-path cases for `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath`
- `PoshQC.TestingInvokeConfigPaths.Tests.ps1` › omitted-root test and holder-hashtable captures
- `test_fix_all_branches.py`, `test_fix_all.py`, `test_fix_all_failure_paths.py`, `test_fix_all_json_cancel.py` › leak-scan step and `-n auto` cases
- `test_qc_runner.py`, `test_cli_part2_part2.py`, `test_cli_part3.py`, `test_plan_discovery.py`, `test_prompt_builder.py` › `-n auto` commands and prompt text
- `test_execution_environment_brief_contracts.py` › scan token rows
- `test_poshqc_bundled_parity.py` › new module paths

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Reviewer runs at head, check-only, over the 17 changed Python files
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.check_quality_tiers --repo-root .

# Gate, per evidence/qa-gates/pytest-parallel.2026-11-07T15-46.md
PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov
```

**For PowerShell:**
```powershell
# Reviewer runs at head, check-only, over the 22 changed PowerShell files
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Leak scan and core probes, from the item worktree
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root .
& (Get-Module PoshQC) { Get-PoshQCLeakFinding -Content <text> -Path 'tests/p.Tests.ps1' }

# Ledger fence replay
Import-Module ./scripts/dev-tools/ProcessReductionLedger.psm1
Invoke-ProcessReductionRevert -Block <block> -Text <target text>
Test-ProcessReductionLedger -Ledger (Read-ProcessReductionLedger -LedgerPath docs/engineering/process-reductions)

# Gate, per evidence/qa-gates/pester-parallel.2026-11-07T15-43.md
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

**For CI state:**
```bash
gh run list -R drmoisan/drm-copilot --branch feature/pester-static-leak-scan-1096
gh pr list -R drmoisan/drm-copilot --head feature/pester-static-leak-scan-1096
git merge-tree --write-tree --name-only HEAD origin/main
```

No suite was re-run by this review. Coverage figures were parsed from the existing artifacts.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
