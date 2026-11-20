# Policy Compliance Audit: pester-static-leak-scan (#1096)

---

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 1
**Code Under Test:** Full branch diff of `feature/pester-static-leak-scan-1096` (head `36372b6c69c6b75f486da0253c54d17279246634`) against `main` (merge base `a2e338950e64f21f23a7f5ab7a15cdeae7169de2`, equal to `origin/main`): 137 paths before this review's artifacts. Outside the feature folder the diff holds 4 added code files (`PoshQC.LeakScan.psm1` and `PoshQC.LeakAllowlist.psm1` with their bundle copies), new and modified Pester suites, 18 modified Python files (0 added), a new JSON allowlist, and modified JSON, YAML, and Markdown files. No TypeScript, C#, or bash file is in the diff.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 18 files | 16213 tests | ✅ 16207 pass, 0 fail, 6 skipped | 96.71% lines, 93.66% branches | 96.99% lines, 94.16% branches | 98.77% lines, 97.37% branches |
| PowerShell | 22 files | 15684 tests | ✅ 15684 tests, 0 fail, 10 disabled | 93.96% lines | 94.05% lines | 95.19% lines |
| TypeScript | 0 files | 5339 tests | ✅ 5339 pass, 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

Rows for C# and bash are deleted because the branch diff holds zero files of those languages. The TypeScript row is kept because bundled resources changed and Jest ran as a gate.

### Coverage Evidence Checklist

- Python baseline coverage artifact: docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/baseline/pytest-parallel.2026-11-07T14-21.md
- Python post-change coverage artifact: artifacts/python/lcov.info
- PowerShell baseline coverage artifact: docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/baseline/pester-parallel.2026-11-07T14-21.md
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows the policy-audit template and the prior validated audit of this item, `policy-audit.2026-11-07T16-00.md`.

---

## Executive Summary

Remediation cycle 1 merged `origin/main` (PR #1108 and the 1.1.27 release) into the branch with merge commits and closed the four cycle inputs. MC-1 is closed: the conflict resolutions keep both the branch's `-n auto` and main's `--cov=scripts/dev_tools`, and the branch is current with `origin/main`. NB-1, NB-2, and NB-3 are closed. One blocking finding remains, and it is a wait, not a defect: `.github/workflows/_poshqc.yml` is modified and no green workflow run exists for the head (PA-1, `awaiting_ci`, carried from the first review).

- MC-1: the four conflicted files read as planned at head; `git merge-base --is-ancestor origin/main HEAD` exits 0; both cycle merge commits have two parents and neither carries `reduction: 0001`.
- Ledger entry 0001: this review replayed all 26 Revert Blocks in memory at head, 26 OK and 0 failed, and `Test-ProcessReductionLedger` returns valid. The four `src/lexile_corpus_tuner` occurrences left in the entry are all `not in` assertions of test fences.
- NB-1: `test_qc_runner.py` is 669 logical lines; the four moved filter-helper tests each occur in exactly one file.
- NB-2: `QCRunner.FULL_TEST` carries `--cov=scripts/dev_tools`, and `test_run_full_runs_all_tools_on_entire_codebase` pins the full list.
- NB-3: a read failure is labelled `read-error`; a real-process probe of the shipped default reader and a parse-error control both produced the expected distinct labels. Module and README share blob ids with their bundle copies.
- Static checks re-run by this review at head: Black, Ruff, and Pyright over the 18 changed Python files gave 0 findings; `Invoke-ScriptAnalyzer` and `Invoke-Formatter` over the 22 changed PowerShell files gave 0 findings and 0 differences.
- `Invoke-PoshQCLeakScan -Root <worktree>` at head: 558 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures.
- Coverage passes for Python and PowerShell; this review's parse of both artifacts matches the gate records exactly.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [✅] `github-actions.instructions.md` and `.claude/rules/ci-workflows.md`
- [N/A] TypeScript: no TypeScript file in the branch diff
- [N/A] C#: no C# file in the branch diff

Toolchain state: every static tool was re-run check-only at head with zero findings. The Pester gate (17:04 UTC), pytest gate (17:08 UTC), and Jest gate (17:09 UTC) ran after the last code commit `6a9cf540e` (16:49 UTC) and reported zero failures. The later merge `eec0ac4b6` (17:13 UTC) brought only six release-version files (`package.json`, lock files, and `.codex/config.toml` copies), none in the branch diff. Under the owner directive that gates are re-run only after a fix, this review did not re-run a test suite.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --porcelain` was empty before this review wrote its artifacts.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: the two new PoshQC modules are covered at 98.22% and 95.56% of lines.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller text below was evaluated against the Scope Invariant.

> "Owner decisions that govern this item: test gates are parallel only (one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix); this plan carries an owner-directed test baseline (spec Decision 9); and `poshqc / PowerShell hook suites (Linux)` stays unchanged."

This text governs how tests are run and does not limit the files audited or waive any language. Coverage for Python and PowerShell carries an explicit verdict from the gate artifacts.

> "SubagentStop artifact checks test repository-relative paths from the main checkout, where this item's folder does not exist. This is a known limit, being filed separately. Do not create files in the main checkout and do not retry on that message."

This text concerns the stop hook's working directory, not audit scope. All artifacts were written in the item worktree.

> "Cycle inputs: remediation-inputs.2026-11-07T16-07.md; prior review artifacts carry the stamp 2026-11-07T16-00."

This names the cycle inputs. The audit scope remained the full diff against the merge base, not the cycle's findings.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0. `git diff --name-only a2e338950..HEAD -- artifacts/` returned no path. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/other/`. No violations were found.

---

## Process-Reduction Ledger Compliance

Rule: `feature-review-workflow` `### Process-reduction ledger`. The branch lands the serial-command removals deferred by #1094 under entry 0001, so the rule applies.

| Requirement | Status | Evidence |
|------------|--------|----------|
| **A reduction has an entry** | ✅ PASS | Entry 0001 records the removals in `## Files Changed` and `## Prior Text`; no new entry was added (spec Decision 7). |
| **Entry format** | ✅ PASS | `Test-ProcessReductionLedger` over the real folder returns `IsValid` true at head. |
| **Entry is revertible** | ✅ PASS | This review replayed all 26 Revert Blocks with `Invoke-ProcessReductionRevert` in memory at head: 26 OK, 0 failed. Each Prior restores main's `--cov=scripts/dev_tools`. |
| **Token in a commit subject** | ✅ PASS | `45e2f0f09`, `07c392826`, and the cycle commit `1faa5f00f` (`docs(process-reductions): reconcile entry 0001 with the main merge (reduction: 0001)`). |
| **Each reduction is its own commit** | ✅ PASS | Each of the three token commits adds 0 lines holding `LeakScan` or `leak scan` outside the entry and the feature evidence folder (reviewer count). `1faa5f00f` touches only the entry, two test files, its replay evidence, and the plan. |
| **Merge commit back-filled** | ✅ PASS | Entry reads its `Merge commit:` line; the cycle merges `30b20368e` and `eec0ac4b6` carry no token. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The leak-scan suites use in-memory text and injected seams; the scan guards independence statically and is clean at head over 558 files. |
| **Isolation** - Each test targets single behavior | ✅ PASS | `LS-K`, `LS-R`, `LA-`, `LI-`, `VT-`, and `WF06` cases each pin one behavior; `LI-14` pins the read-failure label. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 8 shards in about 7.7 minutes over 15684 tests; pytest 220.62 s over 16213 tests. |
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
| **Edge Cases** - Boundary conditions | ✅ PASS | Dynamic names, here-strings, `Mock`-named commands, backslash paths, empty folder sets, Windows PowerShell 5.1 version type. |
| **Error Handling** - Error paths | ✅ PASS | Read and parse failures each logged with their own label and ending in one throw; `LI-14` asserts the label and its absence of `parse-error`. |
| **Concurrency** - If applicable | N/A | The scan is single-threaded and reads only. |
| **State Transitions** - If applicable | ✅ PASS | R3 restore consumption is covered by `LS-R06`. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.71% lines, 93.66% branches -> Post-change: 96.99% lines, 94.16% branches. Change: +0.28 pp lines, +0.50 pp branches. New/changed-code coverage: 98.77% lines, 97.37% branches. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pytest-parallel.2026-11-07T17-08.md.
- PowerShell: Baseline: 93.96% lines -> Post-change: 94.05% lines. Change: +0.09 pp. New/changed-code coverage: 95.19% lines. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pester-parallel.2026-11-07T17-04.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

Python detail. This review parsed `artifacts/python/lcov.info` (written 17:08 UTC): 368 files, 32456 of 33464 lines and 11827 of 12560 branches. The figures match the gate record. The changed-code figure sums the six changed production files: 560 of 567 lines and 185 of 190 branches. Per file: `fix_all_branches.py` 87/87 and 26/26; `fix_all_branches_extra.py` 85/85 and 24/24; `cli_preflight.py` 153/153 and 77/78; `qc_runner.py` 96/103 and 14/18; `prompt_builder.py` 124/124 and 44/44; `qc_toolchain.py` 15/15 with no branch.

PowerShell detail. The root LINE counter of `artifacts/pester/powershell-coverage.xml` (written 17:03 UTC) is 24355 covered of 25895 (94.05%), and `artifacts/pester/pester-junit.xml` reads 15684 tests with 0 failures and 0 errors, which identifies a full-tree merged run. The changed-code figure sums the four measured production files: 396 of 416 lines. The three bundle copies are not measured and share blob ids with their sources; `PoshQC.psd1` is a manifest with no executable lines.

Baseline note. The baseline figures were recorded before any change, at the original merge base (spec Decision 9, owner-directed). The two merges of `origin/main` changed the repository denominator since then; the per-file comparison in `coverage-thresholds.2026-11-07T17-09.md` is therefore the governing no-regression check, and every changed file is at or above its baseline figure.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` text on workflow and task assertions; failures rendered as `path, line, kind, name`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit comments in new and edited suites, including `LI-14`. |
| **Document Intent** | ✅ PASS | File headers and docstrings; `test_unicode_integration.py` module docstring names both subjects after the NB-1 move. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Scan tests pass text through `-ReadText`, `-ReadAllowlist`, and `-EnumerateFiles` seams. |
| **Use Mocks/Stubs** | ✅ PASS | `LI-14` injects a throwing reader; no file is touched. |
| **Environment Stability** | ✅ PASS | No temporary-file API in added test lines; `test_unicode_integration.py` gained no `import subprocess`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-07T16-07.md` and spec Decisions 1 to 9. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T16-22.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-11-07T16-07.md`, all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The NB-3 fix splits one `try` into a read `try` and a parse `try`; no new function. |
| **Reusability** | ✅ PASS | Restore pairing rules share `Test-PoshQCLeakRegionRestore`. |
| **Extensibility** | ✅ PASS | Command families are data arrays. |
| **Separation of concerns** | ✅ PASS | Parse and pairing in `PoshQC.LeakScan.psm1`; allowlist and I/O in `PoshQC.LeakAllowlist.psm1`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Split along the parse and allowlist boundary named in the spec. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest logical line counts among covered changed files: `test_prompt_builder.py` 769 (768 at the merge base), `test_cli_part3.py` 687, `test_qc_runner.py` 669, `qc_runner.py` 574, `PoshQC.LeakScan.psm1` 497. `test_prompt_builder.py` is reported as a non-blocking Warning in the code review. `config/file-size-baseline.json` is not in the branch diff. |
| **Public vs internal** | ✅ PASS | Only `Invoke-PoshQCLeakScan` is exported. |
| **No circular dependencies** | ✅ PASS | Sub-module load order in `PoshQC.psm1` unchanged by the cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs and `PoshQCLeak` nouns. |
| **Docs/docstrings** | ✅ PASS | `.DESCRIPTION`, loop comment, README, and spec `## API / CLI Surface` name both `read-error` and `parse-error`. |
| **Comment why, not what** | ✅ PASS | The loop comment states why an unreadable file is not parsed. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check` and `Invoke-Formatter`.<br>**Result:** 18 Python files unchanged; 22 PowerShell files identical (reviewer runs at head). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check` and `Invoke-ScriptAnalyzer`.<br>**Result:** 0 findings in each (reviewer runs at head). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` over the changed files.<br>**Result:** 0 errors, 0 warnings, 0 informations. |
| **4. Testing** | ✅ PASS | **Command:** one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, one `node run-jest.cjs` run.<br>**Result:** 0 failures in all three. |
| **Full toolchain loop** | ✅ PASS | Static tools clean at head; no code changed after the gates. |
| **Explicit reporting** | ✅ PASS | Commands under `evidence/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 and the commit history. |
| **Design choices explained** | ✅ PASS | Spec `## Constraints & Risks` now records the `FULL_TEST` coverage source after the merge. |
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
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`<br>**Result:** 16207 passed, 6 skipped, 0 failures. |

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
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The NB-3 change uses only `try`/`catch` and `continue`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` on every new function. |
| **Parameter validation** | ✅ PASS | Mandatory parameters with `AllowEmptyString` and `AllowEmptyCollection` where empty input is legal. |
| **Avoid global state** | ✅ PASS | Script-scoped values are constant lookup arrays. |
| **ShouldProcess for state changes** | N/A | The scan reads only. |
| **Error handling** | ✅ PASS | Read and parse failures accumulate with distinct labels and end in one throw; neither is skipped. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | `PoshQC.LeakScan.psm1` 497 logical lines; `PoshQC.LeakAllowlist.psm1` stays below 500. |
| **Approved verbs** | ✅ PASS | `Get`, `Test`, `Compare`, `ConvertFrom`, `Resolve`, `Invoke`. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `evidence/qa-gates/powershell-format.2026-11-07T16-55.md`. |
| **Step 2: Analyze** | ✅ PASS | `evidence/qa-gates/powershell-analyze.2026-11-07T16-55.md`. |
| **Step 3: Type check** | N/A | Does not apply to this language. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/pester-parallel.2026-11-07T17-04.md`. |
| **Rerun loop if needed** | ✅ PASS | One cycle gate pass after the last fix. |

---

### Section 3C: GitHub Actions Workflow Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No deliberately failing nested command** | ✅ PASS | The `pwsh` step calls a PowerShell function that throws on failure and invokes no native command. |
| **No new job or required context** | ✅ PASS | One step added to `poshqc-static`; `WF06-LEAK-SCAN-STEP` passed; `.github/workflows/ci.yml` is not in the diff. |
| **modified-workflow-needs-green-run** | ❌ FAIL | No run exists for the branch; see PA-1 in Section 8. |

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
| **Organization** | ✅ PASS | Under `tests/scripts/dev_tools/`; the 22 duplicate cases removed by P1-T2 each have a named main counterpart in `duplicate-test-review.2026-11-07T16-30.md`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<subject>_<expected behavior>`. |
| **Docstrings/comments** | ✅ PASS | Moved classes keep their docstrings unchanged. |

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
| **Test Behavior Over Implementation** | ✅ PASS | `LI-14` asserts the thrown message, not internal state. |
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
| Total Tests | 37236 (15684 Pester, 16213 pytest, 5339 Jest) | ✅ |
| Tests Passed | 16207 pytest; 5339 Jest; Pester 15684 with 0 failures and 10 disabled | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | about 7.7 minutes Pester, 220.62 s pytest | ✅ Fast |
| Average Time per Test | N/A - parallel wall-clock | ✅ |
| Discovery Time | N/A - not recorded by the parallel gates | ✅ |
| Functions/Classes Tested | 1 public and 26 private PowerShell functions added | ✅ |
| Test File Size | 769 maximum among changed files (768 at the merge base) | ✅ PASS |
| Code Coverage (if applicable) | Python 96.99% lines, 94.16% branches; PowerShell 94.05% lines | ✅ |

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
| Leak scan | `Invoke-PoshQCLeakScan -Root .` | 0 failures, 558 files | ✅ |

**Notes:**
Tier classification: `quality-tiers.yml` exists and the prior review recorded `check_quality_tiers` OK; the cycle adds no project. Each changed PoshQC file (`PoshQC.LeakScan.psm1`, `PoshQC.LeakAllowlist.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, `README.md`) shares a blob id with its bundle copy. The branch adds no `.py` file and touches no `atomic-plan-contract` copy, no Epic #1019 folder, no file under `.claude/rules/` or `.github/instructions/`, no `.github/workflows/ci.yml`, and no `pyproject.toml`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Blocking, `awaiting_ci`): `modified-workflow-needs-green-run`.** The diff modifies `.github/workflows/_poshqc.yml`. The head `36372b6c6` is pushed (`git ls-remote` matches), but `gh run list --branch feature/pester-static-leak-scan-1096` returns no run and `gh pr list --head ... --state all` returns no PR, so no qualifying green run exists. A dispatched `ci.yml` run against the head, or the PR run, satisfies the rule. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.
- The two CI-dependent acceptance criteria are pending CI and carry no separate finding block.

Cycle inputs closed: MC-1, NB-1, NB-2, NB-3 (Section 1, Section 2, and the code review). Non-blocking items recorded in `code-review.2026-11-07T17-25.md`: `test_prompt_builder.py` at 769 lines (advisory tier, 768 at the merge base); R3 nested-block restore is reported (conservative, as specified).

### Approved Exceptions

- Spec Decision 1: policy files still name single-process commands; recorded for the owner report.
- Spec Decision 2: the `LASTEXITCODE` exemption; 67 findings exempt through it.
- Spec Decision 3: proof by construction for the three named tests.
- Spec Decision 8: `poshqc / PowerShell hook suites (Linux)` unchanged; confirmed by `scope-check.2026-11-07T17-17.md`.
- Spec Decision 9: owner-directed baseline recorded before any change.

### Removed/Skipped Tests

Cycle 1 removed 22 branch-added test cases (16 in `TestPreflightBranches`, 6 in `TestPromptBuilderContext`) because main's PR #1108 added cases asserting the same symbol paths and outcomes; each removal names its main counterpart in `duplicate-test-review.2026-11-07T16-30.md`, and per-file coverage of `cli_preflight.py` and `prompt_builder.py` stayed at 100% lines. No pre-existing test was removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

Commits of remediation cycle 1 that change paths outside the feature folder:

1. **30b20368e** - Merge origin/main into feature/pester-static-leak-scan-1096 (PR #1108 conflicts resolved)
2. **78861145f** - test(dev-tools): remove issue 1096 preflight and prompt cases that main duplicates
3. **1faa5f00f** - docs(process-reductions): reconcile entry 0001 with the main merge (reduction: 0001)
4. **5f28333e6** - test(dev-tools): move QCRunner filter helper tests to keep test_qc_runner.py under 700 lines
5. **6a9cf540e** - fix(poshqc): report a leak-scan file read failure as read-error
6. **eec0ac4b6** - Merge origin/main into feature/pester-static-leak-scan-1096 (release 1.1.27 version files)

The 13 earlier code commits are listed in `policy-audit.2026-11-07T16-00.md`.

### Files Modified

1. **`scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1`, `README.md`, and bundle copies** (MODIFIED in cycle)
   - `read-error` label for read failures.
2. **`scripts/dev_tools/atomic_executor/*.py`** (MERGED)
   - `-n auto` kept alongside main's `--cov=scripts/dev_tools`.
3. **`tests/scripts/dev_tools/atomic_executor/*.py`** (MODIFIED in cycle)
   - Duplicates removed; `_PYTEST_STEP` gains `-n auto`; classes moved to keep files under 700 lines.
4. **`docs/engineering/process-reductions/0001-parallel-only-test-gates.md`** (MODIFIED in cycle)
   - Fences match the merged text.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIAL

Coverage, toolchain, mirror, scope, and ledger requirements are met; the four cycle inputs are closed; all 35 locally verifiable acceptance criteria evaluate as PASS. PA-1 holds the branch until a green run of the modified workflow exists for the head.

**Fail-closed reminder:** numeric post-change coverage is recorded for every changed language, and changed-code coverage is recorded for the changed production files.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and policy reads recorded
- ✅ Design Principles: compliant
- ✅ Module & File Structure: one test file at the advisory tier, inherited from main; no file above 800
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
- ✅ Toolchain: one parallel gate run after the last fix

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
- ✅ Python 96.99% line and 94.16% branch against 85% and 75%
- ✅ PowerShell 94.05% line against 85%; new modules 98.22% and 95.56%
- ✅ Leak scan clean at head; 26 of 26 ledger fences replay
- ✅ Branch current with `origin/main`
- ❌ No green run of the modified workflow for the branch head

---

### Recommendation

**Wait for CI**

Open the PR or dispatch `ci.yml` on `feature/pester-static-leak-scan-1096` at `36372b6c6`, then re-check PA-1. No code change is required.

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
- `test_cli_part3.py` › `_PYTEST_STEP` with `-n auto`; Jest expected-failure repair
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

# Gate, per evidence/qa-gates/pytest-parallel.2026-11-07T17-08.md
PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov
```

**For PowerShell:**
```powershell
# Reviewer runs at head, check-only, over the 22 changed PowerShell files
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Leak scan and read-error probes, from the item worktree
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root .
Invoke-PoshQCLeakScan -Root . -ScanFolders tests/scripts -EnumerateFiles <nonexistent path seam>

# Ledger fence replay
Import-Module ./scripts/dev-tools/ProcessReductionLedger.psm1
Invoke-ProcessReductionRevert -Text <target text> -Block <block>
Test-ProcessReductionLedger -Ledger (Read-ProcessReductionLedger -LedgerPath docs/engineering/process-reductions)

# Gate, per evidence/qa-gates/pester-parallel.2026-11-07T17-04.md
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

**For CI state:**
```bash
gh run list -R drmoisan/drm-copilot --branch feature/pester-static-leak-scan-1096
gh pr list -R drmoisan/drm-copilot --head feature/pester-static-leak-scan-1096 --state all
git merge-base --is-ancestor origin/main HEAD
```

No suite was re-run by this review. Coverage figures were parsed from the existing artifacts.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
