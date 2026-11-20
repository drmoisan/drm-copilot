# Policy Compliance Audit: pester-static-leak-scan (#1096)

---

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 2
**Code Under Test:** Full branch diff of `feature/pester-static-leak-scan-1096` (head `cb8ae3d5cc496bb1e0877aba0ae87661df00d066`) against `main` (merge base `c24cbd295ecec1fc759f52a42806ad991aa49478`, equal to `origin/main` after `git fetch origin`): 177 paths before this review's artifacts. Outside the feature folder the diff holds 4 added code files (`PoshQC.LeakScan.psm1` and `PoshQC.LeakAllowlist.psm1` with their bundle copies), new and modified Pester suites, 18 modified Python files (0 added), a new JSON allowlist, and modified JSON, YAML, and Markdown files. No TypeScript, C#, or bash file is in the diff.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 18 files | 16219 tests | ✅ 16213 pass, 0 fail, 6 skipped | 96.71% lines, 93.66% branches | 96.99% lines, 94.16% branches | 98.77% lines, 97.37% branches |
| PowerShell | 22 files | 15994 tests | ✅ 15994 tests, 0 fail, 10 disabled | 93.96% lines | 94.10% lines | 95.19% lines |
| TypeScript | 0 files | 5345 tests | ✅ 5345 pass, 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

Rows for C# and bash are deleted because the branch diff holds zero files of those languages. The TypeScript row is kept because bundled resources changed and Jest ran as a gate.

### Coverage Evidence Checklist

- Python baseline coverage artifact: docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/baseline/pytest-parallel.2026-11-07T14-21.md
- Python post-change coverage artifact: artifacts/python/lcov.info
- PowerShell baseline coverage artifact: docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/baseline/pester-parallel.2026-11-07T14-21.md
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows the policy-audit template and the prior validated audit of this item, `policy-audit.2026-11-07T17-25.md`.

---

## Executive Summary

Remediation cycle 2 merged `origin/main` twice with merge commits: `eca1041af` (PR #1110, issue #1097; one conflicted hunk in ledger entry 0001, resolved with both sides kept) and `885c52b2f` (PR #1113, issue #1105; conflict-free). The cycle made no other change outside the feature folder. MC-2 is closed. PA-1 of the cycle 1 re-audit is also closed: CI run `42400459749` on the predecessor head `885c52b2f` concluded success, including the step `Scan Pester tests for leaked state` and `CI Required Gate`, and every later commit changes only the feature folder. No blocking finding remains.

- MC-2 merge: `git merge-base --is-ancestor origin/main HEAD` exits 0; both cycle merge commits have two parents and neither carries `reduction: 0001`; no cycle 2 commit carries the token.
- MC-2 entry 0001: this review read the resolved entry. Main's `## Revert Steps` step 1 (revert entry `0006` first) and the `## Partial Revert` section are present next to the branch's #1096 additions to steps 1, 5, and 6, the `Merge commit:` line (one occurrence), and the reworded revert signal; `Before #1096 lands` occurs 0 times.
- MC-2 fences: this review replayed all 177 Revert Blocks of entries 0001 to 0006 in memory at head (0001: 26), 177 OK and 0 failed, and `Test-ProcessReductionLedger` returns valid.
- MC-2 brief: the six `execution-environment` copies share blob id `452229bc0`; the `Invoke-PoshQCLeakScan` bullet is the last bullet of `## Test Isolation Checks`. The PR #1113 merge changed only `## Hook Execution Context`.
- MC-2 scan: `Invoke-PoshQCLeakScan -Root <worktree>` at head: 568 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures. The CI run on `885c52b2f` logged the same line.
- Static checks re-run by this review at head: Black, Ruff, and Pyright over the 18 changed Python files gave 0 findings; `Invoke-ScriptAnalyzer` and `Invoke-Formatter` over the 22 changed PowerShell files gave 0 findings and 0 differences.
- Coverage passes for Python and PowerShell; this review's parse of both artifacts matches the restart gate records.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [✅] `github-actions.instructions.md` and `.claude/rules/ci-workflows.md`
- [N/A] TypeScript: no TypeScript file in the branch diff
- [N/A] C#: no C# file in the branch diff

Toolchain state: every static tool was re-run check-only at head with zero findings. The restart gates after the `885c52b2f` merge (Pester 18:26 UTC, pytest 18:30 UTC, Jest 18:30 UTC) reported zero failures, and the coverage artifacts were written after that merge (Pester files 18:26 UTC, Python lcov 18:29 UTC). No commit after `885c52b2f` changes a path outside the feature folder. Under the owner directive that gates are re-run only after a fix, this review did not re-run a test suite.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --porcelain` was empty before this review wrote its artifacts.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: the two new PoshQC modules are covered at 98.22% and 95.56% of lines.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller text below was evaluated against the Scope Invariant.

> "Owner decisions that govern this item: test gates are parallel only (one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix); this plan carries an owner-directed test baseline (spec Decision 9); and `poshqc / PowerShell hook suites (Linux)` stays unchanged."

This text governs how tests are run and does not limit the files audited or waive any language. Coverage for Python and PowerShell carries an explicit verdict from the gate artifacts.

> "Stop-hook note: SubagentStop artifact checks may test repository-relative paths from the main checkout, where this item's folder does not exist. Do not create files in the main checkout and do not retry on that message."

This text concerns the stop hook's working directory, not audit scope. All artifacts were written in the item worktree.

> "Cycle inputs: remediation-inputs.2026-11-07T17-35.md; prior review artifacts carry the stamp 2026-11-07T17-25."

This names the cycle inputs. The audit scope remained the full diff against the merge base, not the cycle's findings.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0. `git diff --name-only c24cbd295..HEAD -- artifacts/` returned no path. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/qa-gates/`, and `<FEATURE>/evidence/other/`. No violations were found.

---

## Process-Reduction Ledger Compliance

Rule: `feature-review-workflow` `### Process-reduction ledger`. The branch lands the serial-command removals deferred by #1094 under entry 0001, so the rule applies.

| Requirement | Status | Evidence |
|------------|--------|----------|
| **A reduction has an entry** | ✅ PASS | Entry 0001 records the removals in `## Files Changed` and `## Prior Text`; no new entry was added by this branch (spec Decision 7). Entries 0002 to 0006 arrive from `main` and are not in the branch diff. |
| **Entry format** | ✅ PASS | `Test-ProcessReductionLedger` over the real folder returns `IsValid` true at head. |
| **Entry is revertible** | ✅ PASS | This review replayed every Revert Block with `Invoke-ProcessReductionRevert` in memory at head: 177 OK, 0 failed (entry 0001: 26 OK). Revert step 1 orders the `0006` revert before the patch. |
| **Token in a commit subject** | ✅ PASS | `45e2f0f09`, `07c392826`, and `1faa5f00f`; cycle 2 added no token commit because no fence needed correction. |
| **Each reduction is its own commit** | ✅ PASS | Each of the three token commits adds 0 lines holding `LeakScan` or `leak scan` outside the entry and the feature evidence folder (`scope-check.2026-11-07T18-32.md`). |
| **Merge commit back-filled** | ✅ PASS | Entry reads one `Merge commit:` line; the four merges of `origin/main` carry no token. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The leak-scan suites use in-memory text and injected seams; the scan guards independence statically and is clean at head over 568 files. |
| **Isolation** - Each test targets single behavior | ✅ PASS | `LS-K`, `LS-R`, `LA-`, `LI-`, `VT-`, and `WF06` cases each pin one behavior. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 8 shards in 312.45 s over 15994 tests; pytest 191.42 s over 16219 testcases. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, or temporary file in the added tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Tagged identifiers, table-driven cases, Arrange-Act-Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | `PoshQC.psm1` 88.52%, `DrmCopilotPromptSupport.ps1` 87.50%; Python changed files 93.20% to 100% lines and 77.78% to 100% branches. Read by this review from the two artifacts. |
| **New Code Threshold** | ✅ PASS | `PoshQC.LeakScan.psm1` 221 of 225 lines (98.22%); `PoshQC.LeakAllowlist.psm1` 86 of 90 lines (95.56%). |
| **Comprehensive Tests** | ✅ PASS | Each detected kind, restore rule, allowlist condition, and scan-level failure (including `read-error`) has a unit case. |
| **Positive Flows** - Valid inputs | ✅ PASS | `LS-K01` per kind; `LA-` valid allowlist; `LI-` clean scan. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `LS-R03`; `LA-` rejection rows; `LI-` throws on unallowlisted, stale, invalid, parse-error, and read-error inputs. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Dynamic names, here-strings, `Mock`-named commands, backslash paths, empty folder sets. |
| **Error Handling** - Error paths | ✅ PASS | Read and parse failures each logged with their own label and ending in one throw. |
| **Concurrency** - If applicable | N/A | The scan is single-threaded and reads only. |
| **State Transitions** - If applicable | ✅ PASS | R3 restore consumption is covered by `LS-R06`. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.71% lines, 93.66% branches -> Post-change: 96.99% lines, 94.16% branches. Change: +0.28 pp lines, +0.50 pp branches. New/changed-code coverage: 98.77% lines, 97.37% branches. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pytest-parallel.2026-11-07T18-30.md.
- PowerShell: Baseline: 93.96% lines -> Post-change: 94.10% lines. Change: +0.14 pp. New/changed-code coverage: 95.19% lines. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pester-parallel.2026-11-07T18-26.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

Python detail. This review parsed `artifacts/python/lcov.info` (written 18:29 UTC): 368 files, 32456 of 33464 lines and 11827 of 12560 branches, matching the restart gate record. The changed-code figure sums the six changed production files: 560 of 567 lines and 185 of 190 branches. Per file: `fix_all_branches.py` 87/87 and 26/26; `fix_all_branches_extra.py` 85/85 and 24/24; `cli_preflight.py` 153/153 and 77/78; `qc_runner.py` 96/103 and 14/18; `prompt_builder.py` 124/124 and 44/44; `qc_toolchain.py` 15/15 with no branch.

PowerShell detail. The root LINE counter of `artifacts/pester/powershell-coverage.xml` (written 18:26 UTC) is 24578 covered of 26118 (94.10%), and `artifacts/pester/pester-junit.xml` reads 15994 tests with 0 failures and 0 errors, which identifies a full-tree merged run on the post-merge tree. The changed-code figure sums the four measured production files: 396 of 416 lines (`PoshQC.LeakScan.psm1` 221/225, `PoshQC.LeakAllowlist.psm1` 86/90, `PoshQC.psm1` 54/61, `DrmCopilotPromptSupport.ps1` 35/40). The three bundle copies are not measured and share blob ids with their sources; `PoshQC.psd1` is a manifest with no executable lines.

Baseline note. The baseline figures were recorded before any change, at the original merge base (spec Decision 9, owner-directed). The merges of `origin/main` changed the repository denominator since then; the per-file comparison in `coverage-thresholds.2026-11-07T18-31.md` is therefore the governing no-regression check, and every changed file is at or above its baseline figure.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` text on workflow and task assertions; failures rendered as `path, line, kind, name`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit comments in new and edited suites. |
| **Document Intent** | ✅ PASS | File headers and docstrings. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Scan tests pass text through `-ReadText`, `-ReadAllowlist`, and `-EnumerateFiles` seams. |
| **Use Mocks/Stubs** | ✅ PASS | `LI-14` injects a throwing reader; no file is touched. |
| **Environment Stability** | ✅ PASS | No temporary-file API in added test lines. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-07T17-35.md` and spec Decisions 1 to 9. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T17-45.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-11-07T17-35.md`, all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Cycle 2 changed no production logic; the conflict resolution keeps both sides of one hunk. |
| **Reusability** | ✅ PASS | Restore pairing rules share `Test-PoshQCLeakRegionRestore`. |
| **Extensibility** | ✅ PASS | Command families are data arrays. |
| **Separation of concerns** | ✅ PASS | Parse and pairing in `PoshQC.LeakScan.psm1`; allowlist and I/O in `PoshQC.LeakAllowlist.psm1`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Split along the parse and allowlist boundary named in the spec. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest logical line counts among covered changed files: `test_prompt_builder.py` 769 (768 at the merge base), `test_cli_part3.py` 687, `test_qc_runner.py` 669, `qc_runner.py` 574, `test_execution_environment_brief_contracts.py` 571. `test_prompt_builder.py` is reported as a non-blocking Warning in the code review. `config/file-size-baseline.json` is not in the branch diff. |
| **Public vs internal** | ✅ PASS | Only `Invoke-PoshQCLeakScan` is exported. |
| **No circular dependencies** | ✅ PASS | Sub-module load order in `PoshQC.psm1` unchanged by the cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs and `PoshQCLeak` nouns. |
| **Docs/docstrings** | ✅ PASS | `.DESCRIPTION`, README, and spec `## API / CLI Surface`. |
| **Comment why, not what** | ✅ PASS | The workflow step comment states why the step exists and how it fails. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check` and `Invoke-Formatter`.<br>**Result:** 18 Python files unchanged; 22 PowerShell files identical (reviewer runs at head). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check` and `Invoke-ScriptAnalyzer`.<br>**Result:** 0 findings in each (reviewer runs at head). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` over the changed files.<br>**Result:** 0 errors, 0 warnings, 0 informations. |
| **4. Testing** | ✅ PASS | **Command:** one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, one `node run-jest.cjs` run after the last merge.<br>**Result:** 0 failures in all three. |
| **Full toolchain loop** | ✅ PASS | Static tools clean at head; the gates postdate the last change outside the feature folder. |
| **Explicit reporting** | ✅ PASS | Commands under `evidence/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 and the commit history. |
| **Design choices explained** | ✅ PASS | `merge-conflicts.2026-11-07T17-44.md` records both sides of the conflicted hunk. |
| **Update supporting documents** | ✅ PASS | README in both copies, spec, ledger entry 0001. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check <18 files>`<br>**Result:** 18 files unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check <18 files>`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <18 files>`<br>**Result:** 0 errors. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`<br>**Result:** 16213 passed, 6 skipped, 0 failures. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Command lists keep their `list[str]` annotations. |
| **Dataclasses for value objects** | N/A | None added. |
| **Protocols/ABCs for interfaces** | N/A | None added. |
| **Avoid utility classes** | ✅ PASS | Edits are to list literals, string constants, and one class constant. |

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
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with the repo settings<br>**Result:** identical for all 22 files. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with the repo settings<br>**Result:** 0 findings in all 22 files. |
| **Fix all findings** | ✅ PASS | None to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | No PowerShell file changed in cycle 2. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` on every new function. |
| **Parameter validation** | ✅ PASS | Mandatory parameters with `AllowEmptyString` and `AllowEmptyCollection` where empty input is legal. |
| **Avoid global state** | ✅ PASS | Script-scoped values are constant lookup arrays. |
| **ShouldProcess for state changes** | N/A | The scan reads only. |
| **Error handling** | ✅ PASS | Read and parse failures accumulate with distinct labels and end in one throw. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | `PoshQC.LeakScan.psm1` 497 logical lines; `PoshQC.LeakAllowlist.psm1` below 500. |
| **Approved verbs** | ✅ PASS | `Get`, `Test`, `Compare`, `ConvertFrom`, `Resolve`, `Invoke`. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `evidence/qa-gates/powershell-format.2026-11-07T18-20.md`. |
| **Step 2: Analyze** | ✅ PASS | `evidence/qa-gates/powershell-analyze.2026-11-07T18-20.md`. |
| **Step 3: Type check** | N/A | Does not apply to this language. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/pester-parallel.2026-11-07T18-26.md`. |
| **Rerun loop if needed** | ✅ PASS | One restart gate pass after the last merge. |

---

### Section 3C: GitHub Actions Workflow Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No deliberately failing nested command** | ✅ PASS | The `pwsh` step calls a PowerShell function that throws on failure and invokes no native command. |
| **No new job or required context** | ✅ PASS | One step added to `poshqc-static`; `WF06-LEAK-SCAN-STEP` passed; `.github/workflows/ci.yml` is not in the diff; the `poshqc-linux-hooks` job text equals the merge base. |
| **modified-workflow-needs-green-run** | ✅ PASS | CI run `42400459749` (event `pull_request`, head `885c52b2f`) concluded success. Its `poshqc / PowerShell QC static` job ran step 6 `Scan Pester tests for leaked state` to success and logged `Leak scan: 568 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures.`; `CI Required Gate` succeeded. Predecessor-head conditions: `885c52b2f` is an ancestor of the head; it is the latest commit that changes a path outside the feature folder, because `git log 885c52b2f..HEAD -- . ':!<feature folder>'` returns no commit. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Existing modules and fixtures. |
| **Coverage expectation** | ✅ PASS | Repo-wide 96.99% line, 94.16% branch, against 85% and 75%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Each case asserts one command list or prompt text. |
| **Mocking sparingly** | ✅ PASS | Runner fakes record commands; no process starts. |
| **Organization** | ✅ PASS | Under `tests/scripts/dev_tools/`; each `def test_` name in `test_execution_environment_brief_contracts.py` occurs once after the auto-merge. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<subject>_<expected behavior>`. |
| **Docstrings/comments** | ✅ PASS | Unchanged in cycle 2. |

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
| **Test Behavior Over Implementation** | ✅ PASS | `LI-` cases assert thrown messages, not internal state. |
| **Mocking Used Sparingly** | ✅ PASS | Seams are scriptblock parameters. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1`, `PoshQC.LeakAllowlist.Tests.ps1`, `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`.<br>**Code files:** `scripts/powershell/PoshQC/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites. |
| **Describe/Context/It Structure** | ✅ PASS | Tag counts: `LS-K` 38, `LS-R` 31, `LA-` 21, `LI-` 14, `VT-` 6, `WF06` 1, all passed. |
| **Logical Grouping** | ✅ PASS | Detected kinds, restore pairing, allowlist, invocation. |
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

### PoshQC.LeakAllowlist.Tests.ps1 (35 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `LA-` rows | Positive and Negative | Allowlist validation and comparison | ✅ |
| `LI-` rows, including `LI-14` | Positive, Negative, Error | `Invoke-PoshQCLeakScan` seams, read-error, parse-error, and throws | ✅ |

**Coverage:** `PoshQC.LeakAllowlist.psm1` 95.56% of lines.

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
| Total Tests | 37558 (15994 Pester, 16219 pytest, 5345 Jest) | ✅ |
| Tests Passed | 16213 pytest; 5345 Jest; Pester 15994 with 0 failures and 10 disabled | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 312.45 s Pester wall-clock, 191.42 s pytest | ✅ Fast |
| Average Time per Test | N/A - parallel wall-clock | ✅ |
| Discovery Time | N/A - not recorded by the parallel gates | ✅ |
| Functions/Classes Tested | 1 public and 26 private PowerShell functions added | ✅ |
| Test File Size | 769 maximum among changed files (768 at the merge base) | ✅ PASS |
| Code Coverage (if applicable) | Python 96.99% lines, 94.16% branches; PowerShell 94.10% lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` | 18 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | no findings | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 0 failures | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` | identical, 22 files | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings, 22 files | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | ExitCode 0, 0 failures | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan -Root .` | 0 failures, 568 files | ✅ |

**Notes:**
Tier classification: `quality-tiers.yml` exists at the root; `check_quality_tiers.py` reports `OK (29 entries, 29 discovered projects)` at head. Each changed PoshQC file (`PoshQC.LeakScan.psm1`, `PoshQC.LeakAllowlist.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, `README.md`) shares a blob id with its bundle copy. The branch adds no `.py` file and touches no `atomic-plan-contract` copy, no Epic #1019 folder, no file under `.claude/rules/` or `.github/instructions/`, no `.github/workflows/ci.yml`, and no `pyproject.toml`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- None blocking. MC-2 (cycle 2 input) and PA-1 (cycle 1 re-audit, `awaiting_ci`) are closed.
- The two CI-dependent acceptance criteria are pending CI and carry no finding block. CI run `42401971146` on the current head `cb8ae3d5c` was queued at review time, and its change-scope job marked `CI full run` and `poshqc / PowerShell QC static` as skipped because the commits after `885c52b2f` change only the feature folder. The scan step therefore does not run on the final head; run `42400459749` on `885c52b2f` is the run that exercised it. The S9 owner decides the check-off of criteria 36 and 37 on that basis.

Non-blocking items recorded in `code-review.2026-11-07T18-43.md`: `test_prompt_builder.py` at 769 lines (advisory tier, 768 at the merge base); R3 nested-block restore is reported (conservative, as specified).

### Approved Exceptions

- Spec Decision 1: policy files still name single-process commands; recorded for the owner report.
- Spec Decision 2: the `LASTEXITCODE` exemption; 67 findings exempt through it.
- Spec Decision 3: proof by construction for the three named tests.
- Spec Decision 8: `poshqc / PowerShell hook suites (Linux)` unchanged; confirmed by `scope-check.2026-11-07T18-32.md` and by this review's diff of `_poshqc.yml`.
- Spec Decision 9: owner-directed baseline recorded before any change.

### Removed/Skipped Tests

Cycle 2 removed no test. The 22 branch-added duplicate cases removed in cycle 1 each name a main counterpart in `duplicate-test-review.2026-11-07T16-30.md`. No pre-existing test was removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

Commits of remediation cycle 2 that change paths outside the feature folder:

1. **eca1041af** - Merge origin/main into feature/pester-static-leak-scan-1096 (PR #1110; entry 0001 conflict resolved with both sides kept)
2. **885c52b2f** - Merge origin/main into feature/pester-static-leak-scan-1096 (PR #1113; conflict-free, brief `## Hook Execution Context` only within the branch diff)

Every other cycle 2 commit changes only the feature folder. The earlier code commits are listed in `policy-audit.2026-11-07T16-00.md` and `policy-audit.2026-11-07T17-25.md`.

### Files Modified

1. **`docs/engineering/process-reductions/0001-parallel-only-test-gates.md`** (MERGED in cycle)
   - Step 1 of `## Revert Steps` holds main's `0006`-first ordering and the branch's #1096 block sentence.
2. **Six `execution-environment` brief copies** (MERGED in cycle)
   - Main's `## Hook Execution Context` text and the branch's leak-scan passages; one blob id.
3. **`tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`** (MERGED in cycle)
   - Main's `Phase 0 baseline` token next to the branch's scan assertions.

---

## 10. Compliance Verdict

### Overall Status: ✅ PASS

Coverage, toolchain, mirror, scope, ledger, and workflow requirements are met; MC-2 and PA-1 are closed; all 35 locally verifiable acceptance criteria evaluate as PASS. Criteria 36 and 37 are pending CI and owned by S9.

**Fail-closed reminder:** numeric post-change coverage is recorded for every changed language, and changed-code coverage is recorded for the changed production files.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and policy reads recorded
- ✅ Design Principles: compliant
- ✅ Module & File Structure: one test file at the advisory tier, inherited from main; no file above 800
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: clean at head; gates postdate the last merge
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
- ✅ Toolchain: one parallel gate run after the last merge

**For GitHub Actions:**
- ✅ modified-workflow-needs-green-run: green predecessor-head run `42400459749`

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
- ✅ Python 96.99% line and 94.16% branch against 85% and 75%
- ✅ PowerShell 94.10% line against 85%; new modules 98.22% and 95.56%
- ✅ Leak scan clean at head; 177 of 177 ledger fences replay
- ✅ Branch current with `origin/main`
- ✅ Green CI run of the modified workflow on the predecessor head `885c52b2f`

---

### Recommendation

**Ready to merge after S9**

No code change is required. The S9 CI green gate confirms `CI Required Gate` on the final PR head and owns the check-off of criteria 36 and 37.

---

## Appendix A: Test Inventory

### Complete Test List

- `PoshQC.LeakScan.Tests.ps1` › detected kinds › `LS-K01` to `LS-K06`
- `PoshQC.LeakScan.Tests.ps1` › restore pairing › `LS-R01` to `LS-R06`
- `PoshQC.LeakAllowlist.Tests.ps1` › `LA-` allowlist validation and comparison rows
- `PoshQC.LeakAllowlist.Tests.ps1` › `LI-01` to `LI-14` `Invoke-PoshQCLeakScan` rows
- `PoshQcWorkflow.Tests.ps1` › `WF06-LEAK-SCAN-STEP`
- `VsCodeQualityTasks.Tests.ps1` › `VT-` rows
- `Enter-DrmCopilotShell.Tests.ps1` › seam and default-path cases
- `PoshQC.TestingInvokeConfigPaths.Tests.ps1` › omitted-root test and holder-hashtable captures
- `test_fix_all_branches.py`, `test_fix_all.py`, `test_fix_all_failure_paths.py`, `test_fix_all_json_cancel.py` › leak-scan step and `-n auto` cases
- `test_qc_runner.py` › `-n auto` and `FULL_TEST` command lists
- `test_cli_part2_part2.py` › `TestPreflightParallelCommand`
- `test_cli_part3.py` › `_PYTEST_STEP` with `-n auto`
- `test_plan_discovery.py` › `test_real_file_system_glob_sorts_matches`
- `test_unicode_integration.py` › `TestQCRunnerFilterHelpers` (moved)
- `test_prompt_builder.py` › `-n auto` prompt text
- `test_execution_environment_brief_contracts.py` › scan token rows
- `test_poshqc_bundled_parity.py` › new module paths

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Reviewer runs at head, check-only, over the 18 changed Python files
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python scripts/dev_tools/check_quality_tiers.py --repo-root . --file quality-tiers.yml

# Gate, per evidence/qa-gates/pytest-parallel.2026-11-07T18-30.md
PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov
```

**For PowerShell:**
```powershell
# Reviewer runs at head, check-only, over the 22 changed PowerShell files
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Leak scan, from the item worktree
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root .

# Ledger fence replay over every entry
Import-Module ./scripts/dev-tools/ProcessReductionLedger.psm1
Invoke-ProcessReductionRevert -Text <target text> -Block <block>
Test-ProcessReductionLedger -Ledger (Read-ProcessReductionLedger -LedgerPath docs/engineering/process-reductions)

# Gate, per evidence/qa-gates/pester-parallel.2026-11-07T18-26.md
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

**For CI state:**
```bash
gh pr view 1112 -R drmoisan/drm-copilot --json state,mergeable,headRefOid,statusCheckRollup
gh run list -R drmoisan/drm-copilot --branch feature/pester-static-leak-scan-1096 --workflow CI
gh run view 42400459749 -R drmoisan/drm-copilot --json headSha,conclusion,jobs
gh run view 42400459749 -R drmoisan/drm-copilot --log --job 128487118140
git merge-base --is-ancestor 885c52b2f HEAD
git log 885c52b2f..HEAD -- . ':!docs/features/active/2026-11-06-pester-static-leak-scan-1096'
git merge-base --is-ancestor origin/main HEAD
```

No suite was re-run by this review. Coverage figures were parsed from the existing artifacts.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
