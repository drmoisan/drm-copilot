# Policy Compliance Audit: Documentation profile and artifact schemas (#1020)

**Audit Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `5e535f7a6`)
**Head Branch:** `feature/docs-profile-and-artifact-schemas-1020-r2` (head `71217a14e`, pushed; no pull request exists yet)
**Merge bases:** `git merge-base --all` returns `01706c697` (origin/main tip, also the origin/main merge base) and `340627583` (epic integration commit). The PR-context collector resolved `01706c697`.

**Code Under Test (item change set, 108 paths in `git diff origin/epic/documentation-estate-tooling-integration HEAD`):**

- PowerShell production (new): `.claude/lib/docs/DocsAnalyzerRegistry.psm1`, `DocsFinding.psm1`, `DocsJson.psm1`, `DocsProfile.psm1`, `DocsProfileCommands.psm1`, `DocsSchema.psm1`, `DocsSchemaWalk.psm1`, `DocsSurface.psm1`, `Invoke-DocsCommand.ps1`
- PowerShell bundle mirror (new, byte-identical): the same nine files under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`
- PowerShell tests (new): 13 files under `tests/scripts/claude-lib/docs/` plus `fixtures/DocsAnalyzerFixture.psm1`
- JSON (new): 8 canonical schemas `schemas/docs/v1/*.schema.json`, 8 runtime copies `.claude/lib/docs/schemas/v1/`, 8 bundle copies, 7 examples `examples/docs/v1/*.example.json`
- JSON (modified): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (17 lines appended)
- YAML (modified): `quality-tiers.yml` (one `.claude/lib/docs` T3 entry)
- Markdown: the feature folder

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production (+9 mirror), 14 test files | 383 docs tests | 383 pass, 0 fail (re-run by reviewer); full tests/scripts on this host 409 fail, all pre-existing | 93.62% lines (P0-T6, other host) | 92.65% lines (P6-T6, current host, 21911 of 23650) | 85.91% minimum per file (Invoke-DocsCommand.ps1); 97.57% aggregate (929 of 952) |
| JSON | 32 new, 1 modified | N/A | contract suite 49 of 49 pass | N/A (config and schema files; no coverage tool) | N/A (config and schema files) | N/A |
| YAML | 1 modified | N/A | check_quality_tiers exit 0 | N/A (config file) | N/A (config file) | N/A |

Python, TypeScript, C#, and Bash: zero changed files on the branch (verified against the diff list), so no coverage row applies.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-03T12-09.md` (figures from `artifacts/pester/powershell-coverage.xml` of the P0-T6 run, 93.62%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, written 2026-11-03T19:08Z by the P6-T6 run; root LINE counter missed=1739 covered=21911), summarized in `evidence/qa-gates/coverage-delta.2026-11-03T20-06.md`
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

The branch adds the documentation tooling base library (nine PowerShell production files, eight v1 JSON schemas with runtime and bundle copies, seven examples), registers it in the core pack manifest and `quality-tiers.yml`, and adds fourteen Pester test files. No existing production line is modified. The reviewer re-ran the docs Pester suites (383 of 383 pass), PSScriptAnalyzer and Invoke-Formatter over the 23 docs PowerShell files (0 findings, 0 formatting differences), the module-convention, no-Python-invocation, and file-size gate suites (6, 33, and 5 tests, 0 failures), `check_quality_tiers` (exit 0), the push-down contract pytest files (32 passed), the quality-tiers contract tests (16 passed), and `validate_evidence_locations.py` (exit 0). Per-file coverage was parsed directly from the coverage artifact and matches the executor's evidence.

Findings: one blocking policy finding (PowerShell ShouldProcess not implemented on the state-changing write functions, class `autonomous`) and two blocking items that resolve only with CI (`awaiting_ci`): the P6-T6 single-process run on this host and the CI-dependent acceptance criteria. Overall verdict: REMEDIATION_REQUIRED.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ✅ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists, so tiers are adopted)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ⚠️ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (one PARTIAL: ShouldProcess)
- N/A Bash: no shell file changed
- ✅ JSON: `format_json` and `validate_json` are not CI gates; see section 3D for the key-order observation

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; the executor's helper scripts lived in its scratch directory (`SCRATCH/...` in evidence)
- ✅ No new tooling script was added outside the tested library

---

## Rejected Scope Narrowing

The caller prompt contains this text: "The item's own change set is `.claude/lib/docs/**`, its bundle mirror ..., the `core.json` pack-manifest additions, the `quality-tiers.yml` entry, and the feature folder." and "Exclude files that the merge base of `origin/main` and HEAD already holds identically."

Justification: this was checked against the full branch diff rather than adopted as a limit. The diff from the epic tip to HEAD (108 paths) equals that stated set plus one path that HEAD lacks (`docs/features/epics/documentation-estate-tooling/epic-status.md`, added on the epic branch after this branch last merged it; HEAD never touched it, so a three-way merge does not delete it). The additional sibling-feature documents in the `01706c697..HEAD` range are identical to the epic tip and carry no code. No language with changed files was excluded.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Three seeded shuffled file-order runs (seeds 1020, 20261030, 7), 389 of 389 each (`evidence/regression-testing/isolation-shuffled.2026-11-03T18-50.md`). The claude-lib single-process run (3784 tests, includes discovery-validation suites that share `DiscoveryEncoding`) had 0 failures, so the docs suites' `Remove-Module ... DiscoveryEncoding` does not break later suites. |
| **Isolation** | ✅ PASS | One suite per production module plus manifest, neutrality, and schema-contract suites. |
| **Fast Execution** | ✅ PASS | Reviewer run of all 383 docs tests completed in under one minute. |
| **Determinism** | ✅ PASS | Seeded `[System.Random]` property tests print the seed; `UtcNow` injected; no process start, timer, or wall-clock read in tests (token search over `tests/scripts/claude-lib/docs/` returned no match). |
| **Readability & Maintainability** | ✅ PASS | Describe/Context/It names state the scenario; shared builders in `Docs.TestSupport.psm1`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | 93.62% overall at P0-T6; no docs file existed at baseline. |
| No coverage regression on changed lines | ✅ PASS | No pre-existing PowerShell production line changed; every PowerShell production file in the diff is new. |
| New-file line coverage >= 85% | ✅ PASS | Nine files 85.91% to 100% (parsed from the artifact by the reviewer). |
| Repo-wide line coverage >= 85% | ✅ PASS | 92.65% (21911 of 23650). |
| Branch coverage | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell. |
| Coverage exclusions | ✅ PASS | `config/poshqc-coverage.json` unchanged on the branch; roots include `.claude/lib`; no docs file excluded. Bundle mirrors under `extensions/` are outside the roots, as for every existing bundled file at baseline. |
| Positive, negative, edge, error flows | ✅ PASS | Example validation, exit 0/1/2/3 paths, duplicate keys, unknown audience, empty file and BOM-only decode, digest range bounds, recursive `json-value`. |
| Concurrency / state transitions | N/A | No concurrent or stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.62% (P0-T6, earlier host). Post-change: 92.65% (P6-T6, current host). Change: -0.97 points overall; the 268 lost covered lines are in pre-existing scripts whose suites fail on this host on the unchanged merge base, and the docs files add 929 covered and 23 missed lines. Disposition: PASS. New/changed-code coverage: 85.91% minimum per file (Invoke-DocsCommand.ps1 128 of 149), 97.57% aggregate. Evidence: `artifacts/pester/powershell-coverage.xml` parsed per sourcefile by the reviewer; `evidence/qa-gates/coverage-delta.2026-11-03T20-06.md`; `evidence/qa-gates/qa-pester-coverage.2026-11-03T18-44.md`.

Per-file line coverage (reviewer parse of the artifact):

| File | Covered / Missed | Line % |
|---|---|---|
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 119 / 0 | 100% |
| `.claude/lib/docs/DocsFinding.psm1` | 88 / 0 | 100% |
| `.claude/lib/docs/DocsJson.psm1` | 102 / 0 | 100% |
| `.claude/lib/docs/DocsProfile.psm1` | 81 / 0 | 100% |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 67 / 2 | 97.1% |
| `.claude/lib/docs/DocsSchema.psm1` | 127 / 0 | 100% |
| `.claude/lib/docs/DocsSchemaWalk.psm1` | 87 / 0 | 100% |
| `.claude/lib/docs/DocsSurface.psm1` | 130 / 0 | 100% |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 128 / 21 | 85.91% |

Note: `Invoke-DocsCommand.ps1` is 0.91 points above the floor. Any remediation that adds unexecuted lines to `Write-DocsFileText` or `Invoke-DocsProcess` can push it below 85%; see the remediation inputs.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | Builders arrange in-memory contexts; one call acts; `Should` asserts. |
| Clear failure messages | ✅ PASS | Assertions compare finding codes, pointers, and digests. |
| Clean test output | ⚠️ Nit (non-blocking) | `DocsSchema.Tests.ps1:310` mocks `Test-Json` with `Write-Error`, which prints `The value does not match at '/name'` to the console in every run. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | No network or process; process and file-write seams mocked. |
| No temporary files | ✅ PASS | No match for `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `$env:TEMP` under `tests/scripts/claude-lib/docs/`. |
| No mutable global state | ✅ PASS | No `$env:` writes, `Set-Location`, or `[Environment]::Set*`; `$global:LASTEXITCODE` is set and read only inside one `It` block. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | Pure modules plus one entry script; dispatch and registry are data tables. |
| Reusability | ✅ PASS | Shared JSON, finding, and schema helpers. |
| Extensibility | ✅ PASS | Owner anchors for later children in the dispatch table and both registry tables. |
| Separation of concerns | ✅ PASS | I/O only in the entry script's context members; command modules take an injected context. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | Largest covered file 458 logical lines (`Invoke-DocsCommand.ps1`); no file at or above 700; `config/file-size-baseline.json` unchanged. |
| Spec 500-line limit for `.claude/lib/docs/` | ✅ PASS | Maximum 458. |
| Explicit exports | ✅ PASS | Each module ends with `Export-ModuleMember -Function`. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | `throw` with `DOCS_*` codes; the two catches return shaped results (`DOCS_PROCESS_START_FAILED`, `DOCS_CLI_RUNTIME` exit 3). |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer `Invoke-Formatter` over 23 files: 0 differences. |
| 2. Linting | ✅ PASS | Reviewer `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`: 23 files, 0 findings. |
| 3. Type checking | N/A | PowerShell. |
| 4. Architecture-boundary tests | ✅ PASS | `ClaudeLibModuleConvention.Tests.ps1` 6 of 6; `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33 (reviewer run). |
| 5. Unit tests | ✅ PASS (docs scope) | 383 of 383 (reviewer run); full-tree status in section 8. |
| 6. Contract / schema checks | ✅ PASS | `DocsSchemaContract.Tests.ps1` 49 of 49; push-down contract pytest 32 passed; quality-tiers contract 16 passed. |
| 7. Integration tests | N/A | No integration suite applies to this library. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting / PSScriptAnalyzer | ✅ PASS | See 2.4. |
| Advanced functions (`[CmdletBinding()]`) | ✅ PASS | Present on every function. |
| Parameter validation | ✅ PASS | `Mandatory`, `ValidateSet`, `AllowNull`, `AllowEmptyString` used per contract. |
| Approved verbs | ✅ PASS | PSSA reports no unapproved verb. |
| No global state | ✅ PASS | Script-scope tables are read-only data. |
| Version compatibility | ✅ PASS | 7.4 floor enforced through `DOCS_RUNTIME_UNSUPPORTED` exit 3. |
| Suppressions justified | ✅ PASS | Every `SuppressMessageAttribute` carries a justification. |
| **ShouldProcess for state-changing actions** | ⚠️ PARTIAL (blocking) | `.claude/rules/powershell.md` line 30: "Implement ShouldProcess/SupportsShouldProcess for state-changing actions." `.github/instructions/powershell-code-change.instructions.md` line 52: "For any state-changing action, implement ShouldProcess/SupportsShouldProcess and gate destructive behavior with `$PSCmdlet.ShouldProcess(...)`." `Write-DocsFileText` (`Invoke-DocsCommand.ps1` lines 226-245; creates directories and writes or, in `overwrite` mode, replaces files) and `Write-DocsContextText` (lines 316-326) declare plain `[CmdletBinding()]` without `SupportsShouldProcess` and never call `$PSCmdlet.ShouldProcess`. The `init` dry-run default and `-Write`/`-Force` opt-ins are a CLI-level safeguard and are retained, but the rule states no alternative and no approved exception is recorded. PSSA does not flag this because `PSUseShouldProcessForStateChangingFunctions` covers only the verbs New, Set, Remove, Start, Stop, Restart, Reset, Update; the suppression on `Write-DocsContextText` (line 321) is therefore inert and its justification restates the alternative rather than an exemption. Sibling precedent: `.claude/lib/discovery-validation/DiscoveryStart.psm1` line 78 uses `SupportsShouldProcess = $true`. |

### 3D JSON Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strict JSON | ✅ PASS | All docs JSON parses through `ConvertFrom-DocsJsonText` (duplicate-key and depth checks) in the contract suite. |
| Required `$schema` | ✅ PASS | Every artifact example carries its URN `$schema`; the envelope example carries none by design (spec D5). |
| Formatting with `format_json` (deterministic key order) | ⚠️ Minor (non-blocking) | Reviewer `poetry run python -m scripts.dev_tools.format_json --check --verbose examples`: the seven `examples/docs/v1/*.example.json` report `would reformat`; the seven discovery examples report `already formatted`. Gate status: no workflow under `.github/workflows/` invokes `format_json`; no pytest or Pester test checks it; no rule file under `.claude/rules/` or `.github/instructions/` governs JSON formatting. The only automated caller is the local developer tool `scripts/dev_tools/fix_all_branches.py` (line 89), which runs `format_json` in write mode, so the next local `fix_all` run would rewrite these seven files. Conclusion: not enforced by any repository gate. |
| Schema validation with `validate_json` | N/A | Not a CI gate; examples are validated by `DocsSchemaContract.Tests.ps1`. |

Python, TypeScript, C#, Bash sections: N/A, zero changed files of those languages.

---

## 4. Language-Specific Unit Test Policy Compliance

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5 | ✅ PASS | Pester 5.9.1 (reviewer run). |
| Location mirrors source | ✅ PASS | `.claude/lib/docs/<Module>` to `tests/scripts/claude-lib/docs/<Module>.Tests.ps1`. |
| File naming `*.Tests.ps1` | ✅ PASS | All 13 suites. |
| Mocking used sparingly | ✅ PASS | Process seam, write primitive, and `Test-Json` in `DocsSchema` module scope only. |
| PoshQC test command | ✅ PASS | Executor runs used `Invoke-PoshQCTest`; reviewer used `Invoke-Pester` without coverage output to avoid overwriting the coverage artifact. |

---

## 5. Test Coverage Detail

See section 1.2.1. Missed lines of `Invoke-DocsCommand.ps1` (21) lie inside `Invoke-DocsProcess` (16) and `Write-DocsFileText` (5) per `evidence/qa-gates/qa-pester-coverage.2026-11-03T18-44.md`; the two missed lines of `DocsProfileCommands.psm1` are the two defensive `DOCS_CLI_RUNTIME` exit 3 returns in `Invoke-DocsInitCommand`.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer, `tests/scripts/claude-lib/docs` | 383 | 383 | 0 | this review |
| Executor P6-T3, `tests/scripts/claude-lib` | 3784 | 3783 | 0 (1 skipped) | `qa-pester-coverage.2026-11-03T18-44.md` |
| Executor P6-T6, `tests/scripts` (this host) | 14106 | 13687 | 409 (6 errors) | `isolation-single-process.2026-11-03T20-06.md`; JUnit header in `artifacts/pester/pester-junit.xml` confirms the counts |
| Executor, merge base `01706c697` (this host) | 13723 | 13464 | 249 | `remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md` |

---

## 7. Code Quality Checks

- PSScriptAnalyzer: 0 findings over 23 files (reviewer).
- Formatter: 0 differences (reviewer).
- File size: maximum 458 logical lines; no Warning-tier file.
- Bundle mirror: `diff -r` of `.claude/lib/docs` against the bundle copy reports no difference; all eight runtime schema copies are byte-identical to `schemas/docs/v1/`.
- `check_quality_tiers`: `quality-tiers: OK (29 entries, 29 discovered projects)`.

### Evidence Location Compliance

`python3 -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`. The plan's recorded override of the spec's `evidence/coverage/` path to `evidence/qa-gates/` follows the non-overridable canonical kind list in `evidence-and-timestamp-conventions`, which has no `coverage` kind. No violation.

---

## 8. Gaps and Exceptions

1. **ShouldProcess (blocking, autonomous).** See section 3B.
2. **P6-T6 single-process `tests/scripts` run (blocking, awaiting_ci).** The run on this Linux Codespace failed 409 tests with 6 `BeforeAll` errors and a JUnit export throw. The reviewer found no docs-attributable failure: the docs suites pass 383 of 383 in isolation and inside the 3784-test claude-lib run; the failing suites are under `dev-tools`, `codex-hooks`, `codex-scripts`, `claude-hooks`, and `powershell/PoshQC`, none in the change set; the same-host merge-base reference reproduces the failing names (including the 160 order-dependent parity cases). The reviewer did not re-run the 19-minute full tree and relies on the executor's recorded comparison for the name-by-name match. Resolution: `poshqc / PowerShell QC` on `windows-latest` for the PR head.
3. **CI-dependent acceptance criteria (blocking, awaiting_ci).** Spec S26 and user-story U14 require CI on the PR head; no PR exists.
4. **Example key order (non-blocking, Minor).** See section 3D.
5. **Test console noise (non-blocking, Nit).** See section 1.3.
6. Pre-existing host defects reported by the executor (order-dependent `pwsh` resolution after `tests/scripts/dev-tools`, Linux-only `C:` and `/repo` fixtures, JUnit export failure on ANSI characters) are outside this feature and are not attributed to it.

No approved policy exception is claimed.

---

## 9. Summary of Changes

New documentation tooling library under `.claude/lib/docs/` (JSON parsing, findings and envelope, schema composition and structural walk, surface identities and declaration digests, analyzer registry, profile loading, `init` and `validate-profile` commands, entry script), eight v1 schemas with runtime and bundle copies, seven examples, core-pack manifest entries, a T3 tier entry, and fourteen Pester test files.

---

## 10. Compliance Verdict

**REMEDIATION_REQUIRED.** One autonomous policy finding (ShouldProcess on the two write functions) must be fixed in the item. Two items wait on CI. All other policy areas PASS with direct reviewer verification.

---

## Appendix A: Test Inventory

| Suite | Tests |
|---|---|
| `Docs.Manifest.Tests.ps1` | 7 |
| `DocsAnalyzerRegistry.Tests.ps1` | 30 |
| `DocsFinding.Tests.ps1` | 30 |
| `DocsJson.Tests.ps1` | 27 |
| `DocsNeutrality.Tests.ps1` | 35 |
| `DocsProfile.Tests.ps1` | 24 |
| `DocsProfileCommands.Tests.ps1` | 22 |
| `DocsSchema.Tests.ps1` | 37 |
| `DocsSchemaContract.Tests.ps1` | 49 |
| `DocsSchemaWalk.Tests.ps1` | 12 |
| `DocsSurface.Tests.ps1` | 66 |
| `Invoke-DocsCommand.Tests.ps1` | 44 |
| Total | 383 |

## Appendix B: Toolchain Commands Reference

- `pwsh -NoProfile -Command '$c = New-PesterConfiguration; $c.Run.Path = "tests/scripts/claude-lib/docs"; $c.Run.PassThru = $true; Invoke-Pester -Configuration $c'`
- `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (per file, 23 files)
- `Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (compare output with input)
- `poetry run python -m scripts.dev_tools.check_quality_tiers`
- `poetry run pytest -q --no-cov -o addopts="" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`
- `poetry run python -m scripts.dev_tools.format_json --check --verbose examples`
- `python3 -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
- `python3 -m scripts.dev_tools.pr_context.collector --base origin/epic/documentation-estate-tooling-integration --no-untracked` (regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`)
