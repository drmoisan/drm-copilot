# Policy Compliance Audit: Documentation page quality checker (#1021)

**Audit Date:** 2026-11-04
**Reviewer:** feature-review agent
**Audit Type:** Initial feature review
**Feature Folder:** `docs/features/active/2026-10-30-docs-page-quality-checker-1021`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `fd6ee4e5a`)
**Head Branch:** `feature/docs-page-quality-checker-1021-r2` (head `95aa64e64`; working tree clean; no pull request exists yet)
**Merge base:** `fd6ee4e5a0815fa69b03fc56c0ea82d49b2f5ee3`; `git merge-base --all HEAD origin/epic/documentation-estate-tooling-integration` returns this single commit, which equals the epic tip. The item diff is `git diff fd6ee4e5a...HEAD` (95 paths).

**Code Under Test (branch diff, 95 paths):**

- 7 new PowerShell modules under `.claude/lib/docs/` (`DocsPageMarkdown`, `DocsPageFrontMatter`, `DocsPageMetadata`, `DocsPageLinks`, `DocsPageDiataxis`, `DocsPageOrphans`, `DocsPageCheck`) and 3 edited 1020 files (`Invoke-DocsCommand.ps1`, `DocsSchema.psm1`, `DocsProfileCommands.psm1`).
- 1 new schema (`schemas/docs/v1/page-metadata.schema.json`) and its runtime copy; 5 page-check templates (JSON, INI, two YAML, one zero-byte text file).
- Byte-identical bundle copies of all 16 `.claude/lib/docs/` paths under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, and the edited `pack-manifests/core.json`.
- 10 new and 4 edited Pester suites under `tests/scripts/claude-lib/docs/`.
- Feature-folder Markdown: spec, user story, plan, and 44 evidence files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production (+10 mirror), 14 test files | 800 (docs suites plus two gate suites) | 800 pass, 0 fail (reviewer re-run) | 92.66% lines (P0-T8, full `tests/scripts`) | 92.88% lines (P6-T6, full `tests/scripts`, artifact parsed by reviewer) | 100% for each of the 7 new modules; edited files 87.42% to 100% |
| JSON | 4 new, 1 modified | N/A | push-down contract pytest 34 of 34 pass | N/A (schema, template and manifest files; no coverage tool) | N/A (schema, template and manifest files) | N/A |
| YAML | 4 new (2 templates, 2 mirrors) | N/A | `DocsPageTemplates.Tests.ps1` 9 of 9 | N/A (Vale rule templates; no coverage tool) | N/A (Vale rule templates) | N/A |

Python, TypeScript, C#, and Bash: zero changed files on the branch (verified against `git diff --name-only fd6ee4e5a...HEAD`), so no coverage row applies.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-03T22-19.md` (full `tests/scripts` run, 92.66%, 21914 of 23651)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, written 2026-11-04T00:06Z by the P6-T6 full `tests/scripts` `Invoke-PoshQCTest` run), summarized in `evidence/regression-testing/isolation-single-process.2026-11-04T00-15.md` and `evidence/qa-gates/coverage-delta.2026-11-04T00-15.md`
- Per-language comparison summary: section 1.2.1 of this audit

Artifact freshness: every changed `.psm1`, `.ps1` and test file in the worktree has a modification time earlier than the coverage artifact (latest source write 23:35:48Z for `DocsPageCheck.Tests.ps1`), `git status --porcelain` is empty, and the head commit `95aa64e64` was created after the artifact from those same working-tree files. The artifact therefore describes HEAD.

---

## Executive Summary

The branch adds the documentation page checker (`-Command check`) as seven PowerShell modules, a page-metadata schema, optional markdownlint and Vale templates, the push-down copies and manifest rows, and 14 Pester suites. The reviewer re-ran the docs suites and two gate suites (800 of 800), PSScriptAnalyzer (0 findings over 32 files), Invoke-Formatter (0 differences over 32 files), the push-down contract pytest (34 passed), the evidence-location validator (exit 0), byte-identity of the 16 mirrored paths and the runtime schema copy, and parsed the coverage artifact directly (100% for each new module, 92.88% overall).

Findings: one autonomous blocking finding (F1: a JSON double-quoted flow-sequence item that ends in an escaped backslash is reported as `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED`, contrary to the spec value-form table) and one `awaiting_ci` blocking finding (F2: the CI-dependent criteria S20 and U10). Overall verdict: REMEDIATION_REQUIRED.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ✅ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/lib/docs` is classified T3 at line 58)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no shell file changed
- ✅ JSON and YAML: schema and templates validated by their Pester suites

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helper scripts are referenced as `SCRATCH/...` and live outside the repository
- ✅ The reviewer runs left the worktree clean (`git status --porcelain` empty after each run)

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The prompt names the full branch diff (`git diff fd6ee4e5a...HEAD`) as the scope and does not exclude any language or file. The instruction to list S20 and U10 as pending-CI is consistent with the acceptance-criteria tracking rule for CI-dependent criteria and does not narrow the audit.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Seeded shuffled file-order runs (seeds 1021, 20261030, 7), 767 of 767 each (`evidence/regression-testing/isolation-shuffled.2026-11-03T23-46.md`). |
| **Isolation** | ✅ PASS | Each suite targets one module; command tests use an in-memory command context. |
| **Fast Execution** | ✅ PASS | Reviewer run of 800 tests completed within one Pester invocation of a few minutes. |
| **Determinism** | ✅ PASS | Property-style tests use `[System.Random]::new(<fixed seed>)` and print the seed through `-Because`; no clock, timer or sleep in the new suites (token search). |
| **Readability & Maintainability** | ✅ PASS | Arrange/Act/Assert comments and descriptive `It` names; suite headers describe scope. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `baseline-pester-coverage.2026-11-03T22-19.md`: 92.66% (21914 of 23651). |
| No coverage regression on changed lines | ✅ PASS | Edited files: `Invoke-DocsCommand.ps1` 87.33% to 87.42% (added dispatch row covered), `DocsSchema.psm1` 100% to 100%, `DocsProfileCommands.psm1` 97.10% to 97.30% (five added rows covered). |
| New-file line coverage >= 85% | ✅ PASS | All seven new modules 100% (reviewer parse). |
| Repo-wide line coverage >= 85% | ✅ PASS | 92.88% (22666 of 24403), root LINE counter of the full-tree artifact. |
| Branch coverage | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell. |
| Coverage exclusions | ✅ PASS | No coverage configuration file is in the branch diff; every new module appears as a sourcefile in the artifact. |
| Positive, negative, edge, error flows | ✅ PASS | Finding-code catalog exercised per code; BOM, CRLF, oversize, invalid UTF-8, unterminated block and read-failure paths tested. One spec value form is untested and defective (F1). |
| Concurrency / state transitions | N/A | No concurrent or stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.66% (P0-T8, full `tests/scripts`). Post-change: 92.88% (P6-T6, full `tests/scripts`). Change: +0.22 points. Disposition: PASS. New/changed-code coverage: 100% for each of the seven new modules (744 of 744 lines); edited files 87.42% minimum (`Invoke-DocsCommand.ps1`, 132 of 151). Evidence: `artifacts/pester/powershell-coverage.xml` parsed per sourcefile by the reviewer; `evidence/qa-gates/coverage-delta.2026-11-04T00-15.md`; `evidence/regression-testing/isolation-single-process.2026-11-04T00-15.md`.

Per-file line coverage (reviewer parse of the artifact written at 00:06Z):

| File | Covered / Total | Line % |
|---|---|---|
| `.claude/lib/docs/DocsPageMarkdown.psm1` | 102 / 102 | 100% |
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | 180 / 180 | 100% |
| `.claude/lib/docs/DocsPageMetadata.psm1` | 109 / 109 | 100% |
| `.claude/lib/docs/DocsPageLinks.psm1` | 114 / 114 | 100% |
| `.claude/lib/docs/DocsPageDiataxis.psm1` | 54 / 54 | 100% |
| `.claude/lib/docs/DocsPageOrphans.psm1` | 28 / 28 | 100% |
| `.claude/lib/docs/DocsPageCheck.psm1` | 157 / 157 | 100% |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 132 / 151 | 87.42% |
| `.claude/lib/docs/DocsSchema.psm1` | 129 / 129 | 100% |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 72 / 74 | 97.30% |

The 19 uncovered lines of `Invoke-DocsCommand.ps1` are the 1020 process and write seams already attributed in the 1020 review; the 1021 change adds one covered line to that file.

Full-tree run status: the P6-T6 single-process `tests/scripts` run on this Linux host reports 409 failures and 6 failed blocks. The executor's comparison shows the sorted failing set is identical to the P0-T8 baseline at the merge base (0 new, 0 removed), no failing test lies under `tests/scripts/claude-lib/docs`, and no changed path lies under a failing suite. The failures are recorded host defects (#1066 `$env:PATH` leak, #1067 Windows-style fixtures). They are treated as non-blocking for this item; `windows-latest` CI on the PR head is authoritative and is covered by F2.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | Sections present in the new suites. |
| Clear failure messages | ✅ PASS | `-Because` texts name the seed, round, code or pointer. |
| Clean test output | ✅ PASS | Reviewer run output contained only the import-closure listing and the two pre-existing 1020 `-WhatIf` messages. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | No network or process in the new suites; command tests use in-memory contexts. |
| No temporary files | ✅ PASS | Reviewer token search for `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `$env:TEMP` over the changed suites: no match. |
| No mutable global state | ✅ PASS | Modules hold only read-only `$script:` constants (patterns, next-action maps). |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | One responsibility per module; a shared line model feeds links, anchors and Diataxis rules. |
| Reusability | ✅ PASS | Findings, JSON and schema handling reuse the 1020 modules. One duplicated computation is noted in the code review (N1, non-blocking). |
| Extensibility | ✅ PASS | The command is registered through the 1020 anchor table; templates through the init anchor. |
| Separation of concerns | ✅ PASS | Rule functions are pure over in-memory page maps; all reads go through command-context members. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | Largest covered file 696 logical lines (`DocsPageCheck.Tests.ps1`); production maximum 463 (`Invoke-DocsCommand.ps1`); `config/file-size-baseline.json` is not in the diff. |
| 700-line advisory tier | ✅ PASS | No covered file at or above 700 logical lines. |
| Spec 500-line limit for new `DocsPage*.psm1` modules | ✅ PASS | Maximum 428 (`DocsPageCheck.psm1`). |
| Explicit exports | ✅ PASS | Each module ends with `Export-ModuleMember -Function`. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at module scope; the two catches are typed (`DecoderFallbackException`, `ItemNotFoundException`) and map to findings; other read failures throw to the exit-3 boundary. |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer `Invoke-Formatter` with `pssa.settings.psd1` over 32 files: 0 differences. |
| 2. Linting | ✅ PASS | Reviewer `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 32 files: 0 findings. |
| 3. Type checking | N/A | PowerShell. |
| 4. Architecture-boundary tests | ✅ PASS | `DocsPageImportIsolation.Tests.ps1` 12 of 12, `ClaudeLibModuleConvention.Tests.ps1` 6 of 6, `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33 (reviewer run). |
| 5. Unit tests | ✅ PASS (docs scope) | Reviewer run 800 of 800; executor claude-lib run 4162 tests, 0 failures (`qa-pester-coverage.2026-11-03T23-42.md`); full-tree host status in section 1.2.1. |
| 6. Contract / schema checks | ✅ PASS | `DocsSchemaContract.Tests.ps1` 49 of 49, `DocsPageMetadataSchema.Tests.ps1` 15 of 15, `Docs.Manifest.Tests.ps1` 7 of 7; push-down contract pytest 34 passed. |
| 7. Integration tests | ✅ PASS | `check` through `Invoke-DocsCommandCli` with an in-memory context, including the 1024-shape fixture page set, inside `DocsPageCheck.Tests.ps1`. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting / PSScriptAnalyzer | ✅ PASS | See 2.4. |
| Advanced functions (`[CmdletBinding()]`) | ✅ PASS | Present on every function in the seven modules. |
| Parameter validation | ✅ PASS | `Mandatory`, `AllowEmptyCollection`, `ValidateRange` on public functions. |
| Approved verbs | ✅ PASS | PSSA `PSUseApprovedVerbs` reports none. |
| No global state | ✅ PASS | Only read-only module constants. |
| Suppressions justified | ✅ PASS | `PSUseShouldProcessForStateChangingFunctions` on in-memory factories and one `PSUseSingularNouns` on the spec-fixed name `ConvertFrom-DocsPageBytes`, each with a justification. |
| ShouldProcess for state-changing actions | ✅ PASS | Inspected by hand: the new modules write no file and change no system state; repository reads go through context members. The `init` writes for the templates use the 1020 write primitive, which is ShouldProcess-gated. |
| PowerShell 7 built-ins only (spec) | ✅ PASS | No YAML module and no `ConvertFrom-Json` in the new modules (reviewer search). |

Python, TypeScript, C#, Bash sections: N/A, zero changed files of those languages.

---

## 4. Language-Specific Unit Test Policy Compliance

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5 | ✅ PASS | Pester 5 configuration API. |
| Location mirrors source | ✅ PASS | `tests/scripts/claude-lib/docs/<Module>.Tests.ps1` for `.claude/lib/docs/<Module>.psm1`. |
| File naming `*.Tests.ps1` | ✅ PASS | All 10 new suites. |
| Mocking used sparingly | ✅ PASS | Command tests inject in-memory contexts rather than mocking the functions under test. |
| PoshQC test command | ✅ PASS | Executor coverage runs used `Invoke-PoshQCTest`; the reviewer used `Invoke-Pester` without coverage so the coverage artifact was not overwritten. |

---

## 5. Test Coverage Detail

See section 1.2.1. Spec criterion S19 asks for the figures under `<FEATURE>/evidence/coverage/`; the canonical evidence kinds in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` have no `coverage` kind, so the figures are under `evidence/qa-gates/` and `evidence/regression-testing/`. The convention is stated as non-overridable, so this placement is correct.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer, `tests/scripts/claude-lib/docs` plus two gate suites | 800 | 800 | 0 | this review |
| Reviewer, push-down contract pytest | 34 | 34 | 0 | this review |
| Executor P6-T3, `tests/scripts/claude-lib` | 4162 | 4162 | 0 | `qa-pester-coverage.2026-11-03T23-42.md` |
| Executor shuffled runs, three seeds | 767 each | 767 each | 0 | `isolation-shuffled.2026-11-03T23-46.md` |
| Executor P6-T6, `tests/scripts` (Linux host) | 14484 | 14065 | 409 (6 failed blocks), identical to baseline | `isolation-single-process.2026-11-04T00-15.md` |

---

## 7. Code Quality Checks

- PSScriptAnalyzer: 0 findings over 32 files (reviewer).
- Formatter: 0 differences over 32 files (reviewer).
- File size: maximum 696 logical lines; no Warning-tier file; no baseline entry added.
- Bundle mirror: `sha256sum` of each of the 16 `.claude/lib/docs/` paths equals its bundle copy; `cmp` of `schemas/docs/v1/page-metadata.schema.json` and its runtime copy reports identical.
- Tier: `.claude/lib/docs` is T3; no property-test density, mutation or golden-test obligation applies. The seeded property-style tests required by spec S15 are present.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. No violation.

---

## 8. Gaps and Exceptions

1. **F1 Flow-sequence escaped backslash (blocking, autonomous).** `ConvertFrom-DocsPageFlowSequence` (`.claude/lib/docs/DocsPageFrontMatter.psm1` line 164) closes a double-quoted item only when the preceding character is not a backslash, so an item ending in an escaped backslash never closes. Reviewer probe: `["a\\", b]` returns `Ok=False Construct=unclosed flow sequence`, which becomes `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED`; `["a", b]` returns `a|b`. Spec `## Front-matter subset` value-form table (spec line 390) admits JSON double-quoted scalars in a flow sequence. Details in the code review.
2. **F2 CI-dependent acceptance criteria S20 and U10 (blocking, awaiting_ci).** No pull request and no CI run exist for head `95aa64e64`.
3. **N1 duplicated page parse (non-blocking, Minor).** See the code review.

No approved policy exception is claimed.

---

## 9. Summary of Changes

The branch adds the `check` command and its six rule modules plus the page-metadata split module, the page-metadata schema and runtime copy, the base markdownlint and Vale templates written by `init`, the manifest rows and bundle copies, and the Pester suites with seeded property-style tests.

---

## 10. Compliance Verdict

**REMEDIATION_REQUIRED.** One autonomous finding (F1) requires a source and test change. F2 resolves through CI on the PR head.

---

## Appendix A: Test Inventory

| Suite | Tests |
|---|---|
| `Docs.Manifest.Tests.ps1` | 7 |
| `DocsAnalyzerRegistry.Tests.ps1` | 30 |
| `DocsFinding.Tests.ps1` | 30 |
| `DocsJson.Tests.ps1` | 27 |
| `DocsNeutrality.Tests.ps1` | 49 |
| `DocsPageCheck.Tests.ps1` (new) | 77 |
| `DocsPageDiataxis.Tests.ps1` (new) | 28 |
| `DocsPageFrontMatter.Tests.ps1` (new) | 107 |
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
| `enforcement-hooks-no-python-invocation.Tests.ps1` | 33 |
| Total | 800 |

## Appendix B: Toolchain Commands Reference

- `pwsh -NoProfile -File <scratch>/runpester.ps1 -Root <worktree>` (`Invoke-Pester` over `tests/scripts/claude-lib/docs`, `ClaudeLibModuleConvention.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`; coverage and JUnit off)
- `pwsh -NoProfile -File <scratch>/pssa.ps1 -Root <worktree>` (per-file `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`)
- `pwsh -NoProfile -File <scratch>/fmt.ps1 -Root <worktree>` (per-file `Invoke-Formatter` comparison)
- `pwsh -NoProfile -File <scratch>/probe.ps1 -Root <worktree>` (F1 probe of `ConvertFrom-DocsPageYamlScalar`)
- `poetry run pytest -q --no-cov -o addopts="" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`
- `python3 -I <scratch>/cov.py <worktree> <file names>` (JaCoCo root and sourcefile LINE counters)
- `sha256sum` of each `.claude/lib/docs/` path and its bundle copy; `cmp` of the schema and its runtime copy
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
- Logical line counts with Python `len(text.splitlines())`, equivalent to `@(Get-Content -LiteralPath <path>).Count`
