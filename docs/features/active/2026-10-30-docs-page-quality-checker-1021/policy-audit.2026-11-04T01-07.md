# Policy Compliance Audit: Documentation page quality checker (#1021)

**Audit Date:** 2026-11-04
**Reviewer:** feature-review agent
**Audit Type:** Re-audit after remediation cycle 1
**Feature Folder:** `docs/features/active/2026-10-30-docs-page-quality-checker-1021`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `fd6ee4e5a`)
**Head Branch:** `feature/docs-page-quality-checker-1021-r2` (head `f1801651672aa225e55aac11965e6f50a38b02c1`; working tree clean; no pull request exists yet)
**Merge base:** `fd6ee4e5a0815fa69b03fc56c0ea82d49b2f5ee3`, as recorded in `artifacts/pr_context.summary.txt` (generated 2026-11-04 01:02:20 UTC for head `f18016516`). The item diff is `git diff fd6ee4e5a...HEAD` (118 paths).

**Code Under Test (branch diff, 118 paths):**

- 7 new PowerShell modules under `.claude/lib/docs/` (`DocsPageMarkdown`, `DocsPageFrontMatter`, `DocsPageMetadata`, `DocsPageLinks`, `DocsPageDiataxis`, `DocsPageOrphans`, `DocsPageCheck`) and 3 edited 1020 files (`Invoke-DocsCommand.ps1`, `DocsSchema.psm1`, `DocsProfileCommands.psm1`).
- 1 new schema (`schemas/docs/v1/page-metadata.schema.json`) and its runtime copy; 5 page-check templates (JSON, INI, two YAML, one zero-byte text file).
- Byte-identical bundle copies of all 16 `.claude/lib/docs/` paths under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, and the edited `pack-manifests/core.json`.
- 11 new and 4 edited Pester suites under `tests/scripts/claude-lib/docs/` (cycle 1 added `DocsPageCheck.LinkMap.Tests.ps1` and extended `DocsPageFrontMatter.Tests.ps1`).
- Feature-folder Markdown: spec, user story, plan, the cycle-0 review artifacts, the cycle-1 remediation plan, and evidence files.

Cycle 1 (`95aa64e64..f18016516`) changed `DocsPageFrontMatter.psm1` and `DocsPageCheck.psm1`, their bundle copies, `DocsPageFrontMatter.Tests.ps1`, the new `DocsPageCheck.LinkMap.Tests.ps1`, and feature-folder Markdown.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production (+10 mirror), 15 test files | 771 (docs suites plus module-convention suite) | 771 pass, 0 fail (reviewer re-run) | 92.66% lines (P0-T8, full `tests/scripts`, merge base) | 92.88% lines (derived: initial full-tree 22666 of 24403 plus the cycle-1 delta of 5 covered of 5 added lines, 22671 of 24408) | 100% for each of the 7 new modules; edited files 87.42% to 100% |
| JSON | 4 new, 1 modified | N/A | push-down contract pytest 34 of 34 pass | N/A (schema, template and manifest files; no coverage tool) | N/A (schema, template and manifest files) | N/A |
| YAML | 4 new (2 templates, 2 mirrors) | N/A | `DocsPageTemplates.Tests.ps1` passes in the reviewer run | N/A (Vale rule templates; no coverage tool) | N/A (Vale rule templates) | N/A |

Python, TypeScript, C#, and Bash: zero changed files on the branch (verified with `git diff --name-only fd6ee4e5a...HEAD` filtered by `.py`, `.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.cs`, `.sh`, `.bats`: no match), so no coverage row applies.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-03T22-19.md` (full `tests/scripts` run at the merge base, 92.66%, 21914 of 23651); cycle-1 baseline `evidence/remediation-baseline/baseline-pester-coverage.2026-11-04T00-45.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, written 2026-11-04T00:55Z by the cycle-1 `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib` run), summarized in `evidence/qa-gates/qa-pester-coverage.2026-11-04T00-55.md` and `evidence/qa-gates/coverage-delta.2026-11-04T00-55.md`
- Per-language comparison summary: section 1.2.1 of this audit

Artifact freshness: the four cycle-1 source and test files were last written between 00:45:27Z and 00:47:31Z, before the coverage artifact (00:55:03Z); `git status --porcelain` is empty, and commit `f18016516` (01:02:09Z) was created from those working-tree files. The artifact therefore describes HEAD for every changed production file.

Assumption (repo-wide figure): the cycle-1 artifact comes from a `tests/scripts/claude-lib` scan, so its root LINE counter (8553 of 24408, 35.04%) keeps the full-tree denominator but counts only the claude-lib suites; it is not a repo-wide figure. The repo-wide figure is derived from the last full-tree artifact parsed in the initial review (22666 of 24403, 92.88%) plus the cycle-1 per-file delta: the root denominator grew by exactly 5 lines (24403 to 24408), which equals the 3 added lines of `DocsPageFrontMatter.psm1` (180 to 183) and 2 of `DocsPageCheck.psm1` (157 to 159), all covered. Derived repo-wide: 22671 of 24408 = 92.88%. No other production file changed in cycle 1.

---

## Executive Summary

The branch adds the documentation page checker (`-Command check`) as seven PowerShell modules, a page-metadata schema, optional markdownlint and Vale templates, the push-down copies and manifest rows, and 15 Pester suites. Remediation cycle 1 fixed F1 (escaped backslash at the end of a double-quoted flow-sequence item) and the optional N1 (one link-map build per run), each with a regression test that was red before the source change.

The reviewer re-ran at head `f18016516`: the docs suites and the module-convention gate suite (771 pass, 0 fail), PSScriptAnalyzer (0 findings over 41 files), Invoke-Formatter (0 differences over 41 files), the push-down contract pytest (34 passed), the evidence-location validator (exit 0), byte-identity of both cycle-1 bundle pairs, direct probes of the flow-sequence parser, and a direct parse of the coverage artifact (100% for each new module).

Findings: no autonomous finding remains. One `awaiting_ci` blocking finding remains (F2: the CI-dependent criteria S20 and U10, listed as pending-CI). Overall verdict: AWAITING_CI.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ✅ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/lib/docs` is classified T3)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no shell file changed
- ✅ JSON and YAML: schema and templates validated by their Pester suites

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helper scripts are referenced as `SCRATCH/...` and live outside the repository
- ✅ The reviewer runs left the worktree clean (`git status --porcelain` lists only the four review artifacts of this re-audit)

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The prompt names the full branch against the resolved base `origin/epic/documentation-estate-tooling-integration` (merge base `fd6ee4e5a`) as the scope and does not exclude any language or file. The instruction to record S20 and U10 as pending-CI matches the acceptance-criteria tracking rule for CI-dependent criteria and does not narrow the audit. The prior remediation inputs and plan were read as context only; the audit was not limited to the cycle-1 files.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Seeded shuffled file-order runs (seeds 1021, 20261030, 7), 765 of 765 each, new link-map suite present in every order (`evidence/regression-testing/isolation-shuffled.2026-11-04T00-58.md`). |
| **Isolation** | ✅ PASS | Each suite targets one module; the link-map suite uses an in-memory command context and an `It`-scoped mock. |
| **Fast Execution** | ✅ PASS | Reviewer docs-scope run completed in one Pester process. |
| **Determinism** | ✅ PASS | Property-style tests use `[System.Random]::new(<fixed seed>)` and print the seed through `-Because`; the cycle-1 tests use fixed inputs and no clock, timer or sleep. |
| **Readability & Maintainability** | ✅ PASS | Arrange/Act/Assert comments and descriptive `It` names in both cycle-1 tests. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `baseline-pester-coverage.2026-11-03T22-19.md` (92.66%) and cycle-1 `baseline-pester-coverage.2026-11-04T00-45.md` (per-module 100%). |
| No coverage regression on changed lines | ✅ PASS | Cycle 1: 3 added lines of `DocsPageFrontMatter.psm1` and 2 of `DocsPageCheck.psm1`, all covered (reviewer parse: no `ci="0"` line in either file). Earlier edited files unchanged in cycle 1: `Invoke-DocsCommand.ps1` 87.42%, `DocsSchema.psm1` 100%, `DocsProfileCommands.psm1` 97.30% (same figures in the cycle-1 artifact). |
| New-file line coverage >= 85% | ✅ PASS | All seven new modules 100% (reviewer parse of the cycle-1 artifact). |
| Repo-wide line coverage >= 85% | ✅ PASS | 92.88% derived (22671 of 24408); see the assumption above. |
| Branch coverage | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell. |
| Coverage exclusions | ✅ PASS | No coverage configuration file is in the branch diff; every new module appears as a sourcefile in the artifact. |
| Positive, negative, edge, error flows | ✅ PASS | F1 value form now tested in value and block form, with the unterminated negative case; N1 tested for call count and output equality. |
| Concurrency / state transitions | N/A | No concurrent or stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.66% (P0-T8, full `tests/scripts` at the merge base). Post-change: 92.88% (derived from the initial full-tree artifact plus the cycle-1 delta). Change: +0.22 points. Disposition: PASS. New/changed-code coverage: 100% for each of the seven new modules (749 of 749 lines); cycle-1 changed lines 5 of 5 covered; edited 1020 files 87.42% minimum (`Invoke-DocsCommand.ps1`, 132 of 151). Evidence: `artifacts/pester/powershell-coverage.xml` parsed per sourcefile by the reviewer; `evidence/qa-gates/qa-pester-coverage.2026-11-04T00-55.md`; `evidence/qa-gates/coverage-delta.2026-11-04T00-55.md`; `evidence/qa-gates/coverage-delta.2026-11-04T00-15.md`.

Per-file line coverage (reviewer parse of the artifact written at 00:55Z):

| File | Covered / Total | Line % |
|---|---|---|
| `.claude/lib/docs/DocsPageMarkdown.psm1` | 102 / 102 | 100% |
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | 183 / 183 | 100% |
| `.claude/lib/docs/DocsPageMetadata.psm1` | 109 / 109 | 100% |
| `.claude/lib/docs/DocsPageLinks.psm1` | 114 / 114 | 100% |
| `.claude/lib/docs/DocsPageDiataxis.psm1` | 54 / 54 | 100% |
| `.claude/lib/docs/DocsPageOrphans.psm1` | 28 / 28 | 100% |
| `.claude/lib/docs/DocsPageCheck.psm1` | 159 / 159 | 100% |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 132 / 151 | 87.42% |
| `.claude/lib/docs/DocsSchema.psm1` | 129 / 129 | 100% |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 72 / 74 | 97.30% |

The 19 uncovered lines of `Invoke-DocsCommand.ps1` (208, 210-224, 247-249) are the 1020 process and write seams attributed in the 1020 review; the 1021 change adds one covered line to that file. The 2 uncovered lines of `DocsProfileCommands.psm1` (167-168) are pre-existing 1020 lines.

Full-tree run status: the last single-process `tests/scripts` run on this Linux host (`evidence/regression-testing/isolation-single-process.2026-11-04T00-15.md`) reports 409 failures and 6 failed blocks, a set identical to the merge-base baseline, with no failing suite under a changed path. Cycle 1 touched only `.claude/lib/docs` and `tests/scripts/claude-lib/docs`, and the cycle-1 `tests/scripts/claude-lib` run reports 4166 tests, 0 failures. The host failures are recorded defects (#1066, #1067) and are non-blocking for this item; `windows-latest` CI on the PR head is authoritative and is covered by F2.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | Sections present in the cycle-1 tests. |
| Clear failure messages | ✅ PASS | Assertions compare full item lists and ordered finding keys. |
| Clean test output | ✅ PASS | Reviewer run output contained only the import-closure listing and pre-existing `-WhatIf` messages. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | No network or process in the changed suites. |
| No temporary files | ✅ PASS | The cycle-1 tests build pages in memory and use `New-DocsTestContext`; no temporary-file API in the changed suites. |
| No mutable global state | ✅ PASS | Modules hold only read-only `$script:` constants; the new test file sets only `$script:` fixtures inside its own container. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | F1 replaces one look-back expression with a two-state flag; N1 passes an existing value through an optional parameter. |
| Reusability | ✅ PASS | N1 removes the duplicated link-map computation. |
| Extensibility | ✅ PASS | `-LinkMap` is optional with a `$null` default; existing callers are unaffected. |
| Separation of concerns | ✅ PASS | Rule functions remain pure over in-memory page maps. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | Largest covered file 696 logical lines (`DocsPageCheck.Tests.ps1`); `config/file-size-baseline.json` is not in the diff. |
| 700-line advisory tier | ✅ PASS | No covered file at or above 700 logical lines. |
| Spec 500-line limit for new `DocsPage*.psm1` modules | ✅ PASS | Maximum 434 (`DocsPageCheck.psm1`); `DocsPageFrontMatter.psm1` 426. |
| Explicit exports | ✅ PASS | Unchanged `Export-ModuleMember -Function` lists. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | No error-handling change in cycle 1; strict mode and `Stop` preference at module scope. |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer `Invoke-Formatter` with `pssa.settings.psd1` over 41 files: 0 differences; executor `qa-format.2026-11-04T00-48.md`. |
| 2. Linting | ✅ PASS | Reviewer `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 41 files: 0 findings; executor `qa-pssa.2026-11-04T00-48.md`. |
| 3. Type checking | N/A | PowerShell (`qa-typecheck.2026-11-04T00-48.md`). |
| 4. Architecture-boundary tests | ✅ PASS | `DocsPageImportIsolation.Tests.ps1` and `ClaudeLibModuleConvention.Tests.ps1` in the reviewer run. |
| 5. Unit tests | ✅ PASS (docs scope) | Reviewer run 771 pass, 0 fail; executor claude-lib run 4166 tests, 0 failures (`qa-pester-coverage.2026-11-04T00-55.md`). |
| 6. Contract / schema checks | ✅ PASS | `DocsSchemaContract`, `DocsPageMetadataSchema`, `Docs.Manifest` suites in the reviewer run; push-down contract pytest 34 passed (reviewer). |
| 7. Integration tests | ✅ PASS | `check` through `Invoke-DocsCommandCli` with in-memory contexts in `DocsPageCheck.Tests.ps1`, and `Invoke-DocsCheckCommand` end to end in `DocsPageCheck.LinkMap.Tests.ps1`. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting / PSScriptAnalyzer | ✅ PASS | See 2.4. |
| Advanced functions (`[CmdletBinding()]`) | ✅ PASS | Unchanged in cycle 1. |
| Parameter validation | ✅ PASS | New `-LinkMap` typed `[hashtable]` with `[AllowNull()]`. |
| Approved verbs | ✅ PASS | No new function in production code. |
| No global state | ✅ PASS | Only read-only module constants. |
| Suppressions justified | ✅ PASS | The three `PSUseShouldProcessForStateChangingFunctions` suppressions in the new test file are on in-memory fixture factories, each with a justification. |
| ShouldProcess for state-changing actions | ✅ PASS | Inspected by hand: no cycle-1 function writes a file or changes system state. |
| PowerShell 7 built-ins only (spec) | ✅ PASS | No YAML module and no `ConvertFrom-Json` added. |

Python, TypeScript, C#, Bash sections: N/A, zero changed files of those languages.

---

## 4. Language-Specific Unit Test Policy Compliance

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5 | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` in the new suite. |
| Location mirrors source | ✅ PASS | `tests/scripts/claude-lib/docs/DocsPageCheck.LinkMap.Tests.ps1` for `.claude/lib/docs/DocsPageCheck.psm1`, split to stay below the 700-line advisory tier. |
| File naming `*.Tests.ps1` | ✅ PASS | All new suites. |
| Mocking used sparingly | ✅ PASS | One mock of a private helper, returning the real map, to count calls. |
| PoshQC test command | ✅ PASS | Executor coverage runs used `Invoke-PoshQCTest`; the reviewer used `Invoke-Pester` without coverage so the coverage artifact was not overwritten. |

---

## 5. Test Coverage Detail

See section 1.2.1. Spec criterion S19 names `<FEATURE>/evidence/coverage/`; the canonical evidence kinds in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` have no `coverage` kind, so the figures are under `evidence/qa-gates/`. The convention is stated as non-overridable, so this placement is correct.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer, `tests/scripts/claude-lib/docs` plus module-convention suite | 771 | 771 | 0 | this review |
| Reviewer, push-down contract pytest | 34 | 34 | 0 | this review |
| Executor P3-T4, `tests/scripts/claude-lib` | 4166 | 4165 (1 skipped) | 0 | `qa-pester-coverage.2026-11-04T00-55.md` |
| Executor P3-T6 shuffled runs, three seeds | 765 each | 765 each | 0 | `isolation-shuffled.2026-11-04T00-58.md` |
| Executor P6-T6 (initial cycle), `tests/scripts` (Linux host) | 14484 | 14065 | 409 (6 failed blocks), identical to baseline | `isolation-single-process.2026-11-04T00-15.md` |

---

## 7. Code Quality Checks

- PSScriptAnalyzer: 0 findings over 41 files (reviewer).
- Formatter: 0 differences over 41 files (reviewer).
- File size: maximum 696 logical lines; no Warning-tier file; no baseline entry added.
- Bundle mirror: `sha256sum` of `DocsPageCheck.psm1` (`1fa57407...`) and `DocsPageFrontMatter.psm1` (`19ecde92...`) equals their bundle copies; the other 14 pairs are unchanged since the initial review, where all 16 matched.
- Tier: `.claude/lib/docs` is T3; no property-test density, mutation or golden-test obligation applies.

---

## Evidence Location Compliance

`poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`. No violation.

---

## 8. Gaps and Exceptions

1. **F1 (closed).** Resolved in `f18016516`; reviewer probes confirm `["a\\", b]` resolves to `a\`, `b` and the unterminated `["a\", b]` still reports `unclosed flow sequence`.
2. **N1 (closed).** Resolved in `f18016516`.
3. **F2 CI-dependent acceptance criteria S20 and U10 (blocking, awaiting_ci).** No pull request and no CI run exist for head `f18016516`; both criteria are pending-CI.

No approved policy exception is claimed.

---

## 9. Summary of Changes

The branch adds the `check` command and its six rule modules plus the page-metadata split module, the page-metadata schema and runtime copy, the base markdownlint and Vale templates written by `init`, the manifest rows and bundle copies, and the Pester suites with seeded property-style tests. Cycle 1 corrected the flow-sequence escape handling and removed the duplicated link-map build.

---

## 10. Compliance Verdict

**AWAITING_CI.** No autonomous finding remains. F2 resolves through CI on the PR head at S9.

---

## Appendix A: Test Inventory

Reviewer run at head `f18016516` (`Invoke-Pester`, coverage off).

| Suite | Tests |
|---|---|
| `Docs.Manifest.Tests.ps1` | 7 |
| `DocsAnalyzerRegistry.Tests.ps1` | 30 |
| `DocsFinding.Tests.ps1` | 30 |
| `DocsJson.Tests.ps1` | 27 |
| `DocsNeutrality.Tests.ps1` | 49 |
| `DocsPageCheck.LinkMap.Tests.ps1` (new, cycle 1) | 2 |
| `DocsPageCheck.Tests.ps1` (new) | 77 |
| `DocsPageDiataxis.Tests.ps1` (new) | 28 |
| `DocsPageFrontMatter.Tests.ps1` (new; +2 in cycle 1) | 109 |
| `DocsPageImportIsolation.Tests.ps1` (new) | 12 |
| `DocsPageLinks.Tests.ps1` (new) | 45 |
| `DocsPageMarkdown.Tests.ps1` (new) | 31 |
| `DocsPageMetadata.Tests.ps1` (new) | 26 |
| `DocsPageMetadataSchema.Tests.ps1` (new) | 15 |
| `DocsPageOrphans.Tests.ps1` (new) | 9 |
| `DocsPageTemplates.Tests.ps1` (new) | 9 |
| `DocsProfile.Tests.ps1` | 24 |
| `DocsProfileCommands.Tests.ps1` (edited) | 22 |
| `DocsSchema.Tests.ps1` (edited) | 39 |
| `DocsSchemaContract.Tests.ps1` (edited) | 49 |
| `DocsSchemaWalk.Tests.ps1` | 12 |
| `DocsSurface.Tests.ps1` | 66 |
| `Invoke-DocsCommand.Tests.ps1` (edited) | 47 |
| `ClaudeLibModuleConvention.Tests.ps1` | 6 |
| Total | 771 |

`enforcement-hooks-no-python-invocation.Tests.ps1` (33 of 33 in the initial review) was not re-run; cycle 1 changed no hook and no Python-invocation surface.

## Appendix B: Toolchain Commands Reference

- `pwsh -NoProfile -File <scratch>/review.ps1 -Root <worktree>` (per-file `Invoke-ScriptAnalyzer` and `Invoke-Formatter` comparison with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/lib/docs` and `tests/scripts/claude-lib/docs`; `Invoke-Pester` over `tests/scripts/claude-lib/docs` and `ClaudeLibModuleConvention.Tests.ps1` with coverage and JUnit off; flow-sequence probes of `ConvertFrom-DocsPageYamlScalar` in module scope)
- `poetry -C <worktree> run pytest -q --no-cov -o addopts="" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`
- `python3 -I <scratch>/cov.py <artifact> <file names>` (JaCoCo root and sourcefile LINE counters and missed line numbers)
- `sha256sum` of each cycle-1 module and its bundle copy
- `poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
- Logical line counts with `grep -c ''`, equivalent to `@(Get-Content -LiteralPath <path>).Count` for these files
