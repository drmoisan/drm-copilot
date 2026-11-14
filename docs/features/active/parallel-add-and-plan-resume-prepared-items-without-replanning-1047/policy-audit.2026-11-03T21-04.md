# Policy Compliance Audit: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Audit Date:** 2026-11-03
**Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `49c54e3de3a725c6a17d8b8fceca7d0ab768dce5`
**Base:** `origin/main` @ `01706c697f3ad4a53b4a771d99d851afc7417ea9` (merge base equals the base head)
**Audit Type:** Remediation re-audit after cycle 1 (`remediation-plan.2026-11-03T18-43.md`); previous review set `*.2026-11-03T18-43.md`
**Code Under Test:**

- PowerShell (new): `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`, `.claude/lib/parallel-admission/ParallelAdmission.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1` (added in cycle 1), and their byte-equal bundle copies under `extensions/drm-copilot/resources/claude-customizations/`.
- PowerShell (modified): `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` and its bundle copy.
- PowerShell tests (new or modified): six suites under `tests/scripts/claude-lib/parallel-admission/` (`ParallelAdmissionJson.Tests.ps1` added in cycle 1) and `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`.
- Python (modified, test-support only): `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (unchanged in cycle 1).
- JSON: `.claude/settings.json` (and bundle copy), `pack-manifests/core.json`, five fixtures under `tests/fixtures/parallel_admission/`.
- YAML: `quality-tiers.yml`.
- Markdown: two agents, one rule, three skills (each with bundle copy), feature-folder documents and evidence.
- TypeScript, C#, bash: zero changed files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 production (plus 5 bundle copies), 7 test files | 282 touched-suite tests (review re-run at HEAD); 13946 full single-process tests (executor) | PASS for every suite the branch adds or changes: 282 pass, 0 fail (review); full single-process run 13527 pass, 409 fail, all failures pre-existing and outside the diff (see Section 8) | 92.59% repo-wide LINE (21572/1726) and helpers file 100.00% per `evidence/remediation-baseline/pester-coverage-baseline.2026-11-03T19-45.md` | 92.61% repo-wide LINE (21594 covered, 1724 missed), read by this review from `artifacts/pester/powershell-coverage.xml` | 100.00% (ParallelAdmission.psm1), 100.00% (ParallelAdmissionPrecedence.psm1), 100.00% (ParallelAdmissionJson.psm1), 96.44% (Invoke-ParallelAdmission.ps1), helpers file 100.00% |
| Python | 1 test-support file under `tests/` | full suite 16063 passed, 6 skipped (executor, `-n auto --cov --cov-branch`) | PASS | 96.67% line, 93.64% branch per `evidence/remediation-baseline/python-coverage-baseline.2026-11-03T19-32.md` | 96.67% line (LH 32257 / LF 33367), 93.64% branch (BRH 11720 / BRF 12516), read by this review from `artifacts/python/lcov.info` | N/A - no production Python changed; `tests/*` is omitted from measurement by `[tool.coverage.run] omit` |
| JSON | 8 files | contract tests | PASS (push-down and manifest contract tests in the full pytest run) | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- PowerShell baseline coverage artifact: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/remediation-baseline/pester-coverage-baseline.2026-11-03T19-45.md` (evidence record of the pre-edit full run at `5000b6455`)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` is present (JaCoCo, written 2026-11-03 20:56 UTC by the loop-pass-3 run); this review parsed it directly.
- Python baseline coverage artifact: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/remediation-baseline/python-coverage-baseline.2026-11-03T19-32.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` is present (written 2026-11-03 20:40 UTC); this review summed its LF, LH, BRF, and BRH records.
- Per-language comparison summary: section 1.2.1 below.

---

## Executive Summary

Cycle 1 cleared both blocking findings of the previous review (R1 and R2, canonical coverage artifacts absent) and delivered the three Minor items the orchestrator brought into the cycle: the `reuse-edges` subcommand (M1), accurate `git fetch` side-effect wording (M2), and git stderr in failure messages (M3). To keep `Invoke-ParallelAdmission.ps1` below the 700-line advisory tier, the four pure JSON functions moved unchanged into the new sibling module `ParallelAdmissionJson.psm1`; the script fell from 699 to 621 logical lines.

The review read both canonical coverage artifacts directly. PowerShell repo-wide LINE coverage is 92.61% and every branch production file is at or above 96.44%; Python repo-wide coverage is 96.67% line and 93.64% branch. The review confirmed that the missed-line numbers in the PowerShell artifact map to the committed HEAD content of `Invoke-ParallelAdmission.ps1` (the git seam body, the file-read seam, one defensive return, and the guarded entry body), and that the working tree is clean, so the figures describe the branch head.

The review re-ran the touched Pester suites plus `ClaudeLibModuleConvention.Tests.ps1` (282/282) and `FileSizePolicy.RepoGate.Tests.ps1` (5/5) on Linux at HEAD, PSScriptAnalyzer and `Invoke-Formatter` over the 12 changed PowerShell files (0 findings, 0 formatting differences), and exercised the real git seam and the `reuse-edges` CLI read-only.

The executor's full-tree Pester runs on this Linux host report failures in suites the branch does not add or change. The review assessed that evidence (Section 8): the failures are host-dependent and pre-existing at the merge base, and no changed path lies under the failing suites' trees. They are recorded as a non-blocking observation; the authoritative Windows result comes from the `windows-latest` CI shards at the CI green gate.

Result: zero blocking findings. Verdict PASS.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists on the base; `.claude/lib/parallel-admission` is classified T3 and covers the new module)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (test-support module only)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no bash file changed
- ✅ JSON: strict JSON confirmed by contract tests

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helper scripts ran from the session scratchpad and are not in the diff. The review's probe scripts ran from its own scratchpad.
- ✅ No new ongoing tooling script outside the delivered helper.

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The audit covers the full branch diff against the merge base `01706c697f3ad4a53b4a771d99d851afc7417ea9` (146 files).

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path.
- The branch diff contains no path under `artifacts/` at all, and therefore none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence records are under `<FEATURE>/evidence/<kind>/`.
- Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Seeded shuffled file-order runs with seeds 11, 23, 47 (214 tests each, 0 failures, `evidence/regression-testing/pester-shuffle.2026-11-03T20-30.md`); reversed pytest order (`python-reversed.2026-11-03T20-31.md`); serial and `-n auto` pytest (`pytest-serial.2026-11-03T20-31.md`, `pytest-n-auto.2026-11-03T20-40.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One Describe per function or subcommand; each It asserts one outcome. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 282 touched Pester tests in 9.4 s in one review process. |
| **Determinism** - Consistent results | ✅ PASS | Git, file read, and clock go through mocked seams. A grep for `Get-Date`, `Start-Sleep`, and `$global:` over the six admission suites returned no match. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Describe names match function and subcommand names; It names state scenario and outcome. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** repo-wide 92.59%; `Invoke-ParallelAdmission.ps1` 96.15%; helpers 100.00%; Python 96.67% line, 93.64% branch<br>**Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts`; `poetry run pytest -n auto --cov --cov-branch`<br>**Timestamp:** 2026-11-03 19:45 and 19:32 (`evidence/remediation-baseline/`) |
| **No Coverage Regression** | ✅ PASS | Read from the canonical artifacts: repo-wide PowerShell 92.59% to 92.61%; `Invoke-ParallelAdmission.ps1` 96.15% to 96.44%; helpers file 100.00% to 100.00%; Python unchanged at 96.67% line and 93.64% branch. |
| **New Code Coverage (governing threshold 85% line)** | ✅ PASS | `ParallelAdmission.psm1` 100.00% (141/0), `ParallelAdmissionPrecedence.psm1` 100.00% (179/0), `ParallelAdmissionJson.psm1` 100.00% (55/0), `Invoke-ParallelAdmission.ps1` 96.44% (217/8), read from `artifacts/pester/powershell-coverage.xml`. |
| **Comprehensive Coverage** | ✅ PASS | The eight missed lines of the CLI are lines 73-74 (real git call), 86 (real file read), 324 (`Get-ParallelAdmissionPlannerItem` defensive return), and 614-620 (guarded entry body under `pwsh -File`). The review exercised lines 73-74 directly with real git (Section 2.5). |
| **Positive Flows** - Valid inputs | ✅ PASS | Includes `reuse-edges` reuse on a matching plan hash and default-ref reading. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `reuse-edges` usage errors for missing `-Slug`, `-IssueNum`, `-PlanHash`, a slug with `/` or whitespace, and a non-positive `-IssueNum`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Non-object scheduling record rejection; seam result without a `Stderr` property; blank stderr lines skipped. |
| **Error Handling** - Error paths | ✅ PASS | `Invoke-ParallelAdmissionGitChecked` message cases with and without stderr; `assess` surfaces the stderr line when the branch cannot be listed. |
| **Concurrency** - If applicable | N/A | Single-process CLI with no shared state. |
| **State Transitions** - If applicable | ✅ PASS | Unchanged from the previous review; stage-to-action table and barrier states covered. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.59% repo-wide LINE -> Post-change: 92.61% repo-wide LINE. Change: +0.02% (21572 to 21594 covered, 1726 to 1724 missed). New/changed-code coverage: 96.44% (Invoke-ParallelAdmission.ps1, the lowest branch production file; the other four are 100.00%). Branch threshold not applicable (Pester measures no branch coverage). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` parsed by this review; `evidence/qa-gates/pester-coverage.2026-11-03T20-57.md`; `evidence/qa-gates/coverage-delta.2026-11-03T20-57.md`.
- Python: Baseline: 96.67% line, 93.64% branch -> Post-change: 96.67% line, 93.64% branch. Change: +0.00% line, +0.00% branch. New/changed-code coverage: N/A - the only changed Python file is under `tests/`, which `[tool.coverage.run] omit` excludes. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (LF 33367, LH 32257, BRF 12516, BRH 11720, 366 SF records) summed by this review; `evidence/qa-gates/python-coverage.2026-11-03T20-40.md`.
- TypeScript: zero changed files. Disposition: N/A.
- C#: zero changed files. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions compare exact rejection and usage lines and exact thrown messages such as `git show ... exited 128: fatal: ...`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Mocks in BeforeAll/BeforeEach; one call per It; assertions follow. |
| **Document Intent** | ✅ PASS | `ParallelAdmissionJson.Tests.ps1` carries a header naming the module and issue. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No live git, network, or GitHub call in any suite; `reuse-edges` tests mock `Invoke-ParallelAdmissionGit` and assert that no `fetch` is issued. |
| **Use Mocks/Stubs** | ✅ PASS | Seams mocked: git, JSON file read, clock. |
| **Environment Stability** | ✅ PASS | A grep for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `TEMP`, `Set-Content`, `Out-File`, `New-Item`, `WriteAllText`, and `Remove-Item` over the six admission suites returned no match. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, `code-review.2026-11-03T21-04.md`, and `feature-audit.2026-11-03T21-04.md` form the review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-03T18-43.md` items R1, R2, M1-M3. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-03T19-22.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-11-03T18-43.md` with preflight clearance (`5000b6455`). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | `reuse-edges` is a 13-line wrapper over the existing tested `Get-ParallelAdmissionRecordedEdge`. |
| **Reusability** | ✅ PASS | The JSON functions moved without change into one module the script imports. |
| **Extensibility** | ✅ PASS | New subcommand added through the `$script:AdmissionRequiredOption` table and an explicit dispatch arm. |
| **Separation of concerns** | ✅ PASS | `ParallelAdmissionJson.psm1` is pure (no filesystem, process, network, or clock); I/O stays in the three seams of the script. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Admission, precedence, and JSON concerns are separate modules. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines (`@(Get-Content -LiteralPath).Count`): `Invoke-ParallelAdmission.ps1` 621, `ParallelAdmission.psm1` 508, `ParallelAdmissionPrecedence.psm1` 508, `ParallelAdmissionJson.psm1` 141, `enforce-parallel-cohort-barrier-helpers.ps1` 344, `Invoke-ParallelAdmission.Tests.ps1` 692, `enforce-parallel-cohort-barrier.Tests.ps1` 537, `ParallelAdmission.Tests.ps1` 418, `ParallelAdmissionPrecedence.Tests.ps1` 392, `Invoke-ParallelAdmission.Integration.Tests.ps1` 229, `ParallelAdmissionJson.Tests.ps1` 129, `ParallelAdmission.Manifest.Tests.ps1` 81, `parallel_orchestrator_surface_expectations.py` 421. No file is at or above 700 lines; `config/file-size-baseline.json` is not in the diff. `FileSizePolicy.RepoGate.Tests.ps1` 5/5 at HEAD. |
| **Public vs internal** | ✅ PASS | Explicit `Export-ModuleMember -Function` lists in all three modules. |
| **No circular dependencies** | ✅ PASS | The script imports the three modules; no module imports the script or another admission module except `ParallelAdmission.psm1` importing `../blast-radius/*`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Invoke-ParallelAdmissionEdgeReuse`, `ConvertTo-ParallelAdmissionJson`. |
| **Docs/docstrings** | ✅ PASS | The header now states that `assess` runs `git fetch --quiet origin`, updates remote-tracking refs and the object store, and needs network access (M2 resolved). |
| **Comment why, not what** | ✅ PASS | Line 72 explains the `2>&1` stream split; line 230 explains the `Stderr` property check under strict mode. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter -ScriptDefinition` with `pssa.settings.psd1` over 12 files (review); `black --check` (executor)<br>**Result:** 0 differences (review); `poshqc-format.2026-11-03T20-28.md`, `black-final.2026-11-03T20-31.md` |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 12 files (review)<br>**Result:** 0 findings (review); `poshqc-analyze.2026-11-03T20-28.md`, `ruff-final.2026-11-03T20-31.md` |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <py>`<br>**Result:** 0 errors (`pyright-final.2026-11-03T20-31.md`); N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** review re-run of the touched suites (282/282) and `FileSizePolicy.RepoGate.Tests.ps1` (5/5); executor targeted run (`pester-targeted.2026-11-03T20-29.md`, 936/936); pytest `-n auto` 16063 passed<br>**Result:** every suite the branch adds or changes passes. The full-tree Linux run carries pre-existing host failures outside the diff (Section 8, non-blocking). |
| **Full toolchain loop** | ✅ PASS | Three loop passes; pass 2 found the CLI below its coverage baseline (95.18%) and the loop restarted; pass 3 is clean (`coverage-delta.2026-11-03T20-57.md`). |
| **Explicit reporting** | ✅ PASS | Every gate has a timestamped evidence file with command and exit code. |

Review probe of the real git seam (not mocked), run read-only against the item worktree: `Invoke-ParallelAdmissionGit -GitArgs show origin/nonexistent-ref-xyz:foo.json` returned exit 128, zero stdout lines, and the stderr line `fatal: invalid object name 'origin/nonexistent-ref-xyz'.`; `Invoke-ParallelAdmissionGitChecked` threw `git show origin/nonexistent-ref-xyz:foo.json exited 128: fatal: invalid object name 'origin/nonexistent-ref-xyz'.`; `rev-parse HEAD` returned `49c54e3de...` with no stderr line. `reuse-edges -Slug no-such-run-xyz -IssueNum 1047 -PlanHash abc` exited 0 with `{action: recompute, edges: [], reason: record_missing}`.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `49c54e3de`; self-review `evidence/qa-gates/self-review.2026-11-03T20-59.md`. |
| **Design choices explained** | ✅ PASS | `remediation-plan.2026-11-03T18-43.md` records the JSON-module split rationale (file-size headroom). |
| **Update supporting documents** | ✅ PASS | Rule `## Prepared-Item Admission (issue #1047)`, `parallel-plan/SKILL.md` step 7, and the spec `## API / CLI Surface` table name `reuse-edges`. |
| **Provide next steps** | ✅ PASS | CI-dependent criterion S14 named in `scope-diff.2026-11-03T20-58.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`<br>**Result:** exit 0 (`black-final.2026-11-03T20-31.md`) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check <same file>`<br>**Result:** exit 0 |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <same file>`<br>**Result:** exit 0 |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto -q -p no:cacheprovider --cov --cov-branch`<br>**Result:** 16063 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Constants annotated `tuple[str, ...]`; no Python change in cycle 1. |
| **Dataclasses for value objects** | N/A | No value object added. |
| **Protocols/ABCs for interfaces** | N/A | No interface added. |
| **Avoid utility classes** | ✅ PASS | Module-level constants only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No executable logic added. |
| **Logging over print** | N/A | No executable logic added. |
| **Invariants at construction** | N/A | No class added. |

Repository rule check: no added `.py` path, no Python production file edited, and no Python leg in any hook. `git diff --name-only 793096c82 HEAD -- '*.py' config pyproject.toml quality-tiers.yml` is empty, so cycle 1 changed no Python, coverage configuration, or tier file. PASS.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter -ScriptDefinition` with `pssa.settings.psd1`<br>**Result:** 0 differences over 12 files (review) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings over 12 files (review); the one justified `PSUseLiteralInitializerForHashtable` suppression moved with its function |
| **Fix all findings** | ✅ PASS | No open finding. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The helper is pwsh-only by design (System.Text.Json; invoked through `pwsh -NoProfile -NonInteractive -File`). The `2>&1` capture in `Invoke-ParallelAdmissionGit` relies on PowerShell 7 not applying `$ErrorActionPreference` to redirected native stderr; the review confirmed the behavior under pwsh 7 on Linux. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function. |
| **Parameter validation** | ✅ PASS | `-Slug` and `-IssueNum` validated in `Get-ParallelAdmissionUsageError` (exit 2). `-Ref`, `-Branch`, and `-Main` are passed to git without a leading-dash check; see the Minor finding in the code review. |
| **Avoid global state** | ✅ PASS | Script-scoped constants only. |
| **Error handling** | ✅ PASS | Strict mode and `Stop` in all four files; non-object scheduling records throw; git failures carry the first stderr line. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest production file 621 logical lines; largest test file 692. |
| **Approved verbs** | ✅ PASS | ConvertFrom, ConvertTo, Write, Invoke, Get. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `poshqc-format.2026-11-03T20-28.md`; review re-check |
| **Step 2: Analyze** | ✅ PASS | `poshqc-analyze.2026-11-03T20-28.md`; review re-check |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `pester-targeted.2026-11-03T20-29.md`; review re-run 282/282 |
| **Rerun loop if needed** | ✅ PASS | Three passes; third pass clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | The cycle 1 `pack-manifests/core.json` edit is one inserted line in the existing array; push-down contract tests pass. |
| **Schema validation** | ✅ PASS | Fixtures unchanged in cycle 1; validator runs from the previous review stand. |
| **Required $schema** | N/A | The changed JSON files are not `$schema`-governed. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Parsed by `System.Text.Json` and by the Python contract tests. |
| **Deterministic key order** | ✅ PASS | `Write-ParallelAdmissionJsonValue` sorts keys ordinally; unchanged by the move. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | The pins are consumed by `test_parallel_orchestrator_surface_contracts.py`. |
| **Coverage expectation** | ✅ PASS | `artifacts/python/lcov.info` present; repo-wide 96.67% line and 93.64% branch. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Two parametrized obligation cases. |
| **Mocking sparingly** | ✅ PASS | No mock added. |
| **Organization** | ✅ PASS | Pins beside existing fragment tuples. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `KICKOFF_PLAN_HASH_FRAGMENTS`, `MERGE_ON_GREEN_TURN_GAP_FRAGMENTS`. |
| **Docstrings/comments** | ✅ PASS | Issue-referenced comments. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto -q -p no:cacheprovider --cov --cov-branch`<br>**Result:** 16063 passed, 6 skipped, exit 0 (`python-coverage.2026-11-03T20-40.md`) |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5.9.1. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>No configuration change (`config/poshqc-coverage.json` not in the cycle 1 diff). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 56 / 51 / 78 / 12 / 12 / 5 tests across the six admission suites; 62 in the hook suite. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions target exit codes, stdout JSON, stderr lines, and git argument arrays. |
| **Mocking Used Sparingly** | ✅ PASS | Only the I/O seams are mocked. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-lib/parallel-admission/*.Tests.ps1`<br>**Code files:** `.claude/lib/parallel-admission/*`<br>Mirrors the production layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All six suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per function or subcommand. |
| **Logical Grouping** | ✅ PASS | Grouped by module and subcommand. |
| **Docstrings/Comments** | ✅ PASS | Suite header comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts`<br>**Result:** coverage artifact written; branch suites pass (full-tree host failures in Section 8) |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC; the review re-run used `Invoke-Pester` with coverage disabled so the canonical artifact was not overwritten. |

---

## 5. Test Coverage Detail

### ParallelAdmissionJson.psm1 (12 tests, new in cycle 1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| ConvertFrom-ParallelAdmissionJson case-distinct keys, Int64, Double, booleans, null, array root, timestamp string | Positive / Edge Case | 21-73 | ✅ |
| ConvertTo-ParallelAdmissionJson ordinal key order, pscustomobject, round trip, no carriage return | Positive | 75-134 | ✅ |
| Unserializable value throws | Error Handling | 75-112 (`Write-ParallelAdmissionJsonValue` final throw) | ✅ |

**Coverage:** 100.00% (55/55 executable lines), read from the artifact.

**Not covered:** None.

### Invoke-ParallelAdmission.ps1 (78 unit + 12 integration tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| reuse-edges usage errors and dispatch | Negative / Positive | 172-217, 535-602 | ✅ |
| Invoke-ParallelAdmissionGitChecked stderr message rule | Error Handling | 261-278 | ✅ |
| assess fetch-once and stderr surfacing | Positive / Error Handling | 374-395 | ✅ |

**Coverage:** 96.44% (217/225), read from the artifact.

**Not covered:** lines 73-74 (real git call), 86 (real file read), 324 (defensive return in `Get-ParallelAdmissionPlannerItem`), 614, 618-620 (guarded entry body).

### ParallelAdmission.psm1, ParallelAdmissionPrecedence.psm1, enforce-parallel-cohort-barrier-helpers.ps1

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Unchanged in cycle 1; suites 56, 51, and 62 tests | Positive / Negative / Edge Case | all executable lines | ✅ |

**Coverage:** 100.00% (141/141), 100.00% (179/179), 100.00% (97/97), read from the artifact.

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 282 touched Pester + 5 file-size gate (review); 13946 Pester full (executor); 16063 pytest (executor) | ✅ |
| Tests Passed | 282 and 5 (100%); 13527 of 13946 full-tree on this Linux host; 16063 (100% of non-skipped) | ✅ |
| Tests Failed | 0 in branch suites; 409 full-tree single-process and 89 sharded, all pre-existing host failures outside the diff | ⚠️ non-blocking |
| Execution Time | 9.4 s touched Pester (review); pytest 562.51 s with coverage | ✅ Fast |
| Average Time per Test | not measured by the review | N/A |
| Discovery Time | not measured by the review | N/A |
| Functions/Classes Tested | every exported function and every subcommand | ✅ |
| Test File Size | largest 692 logical lines | ✅ PASS |
| Code Coverage (if applicable) | PowerShell 92.61% repo-wide; Python 96.67% line, 93.64% branch | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <py>` | exit 0 | ✅ |
| Ruff Linting | `poetry run ruff check <py>` | exit 0 | ✅ |
| Pyright Type Checking | `poetry run pyright <py>` | exit 0 | ✅ |
| Pytest Tests | `poetry run pytest -n auto --cov --cov-branch` | 16063 passed, 6 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` with `pssa.settings.psd1` | 0 differences (review) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` | 0 findings (review) | ✅ |
| Pester Tests | `Invoke-Pester` touched suites (review) | 282 pass | ✅ |

**Notes:** Mirrors: 12 primary and bundle pairs compared with `cmp -s` by the review, all byte-equal, including `ParallelAdmissionJson.psm1`; `pack-manifests/core.json` lists the new module; `ParallelAdmission.Manifest.Tests.ps1` 5/5.

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap.

Non-blocking observation (assessed per the caller's request): full-tree Pester failures on this Linux host.

- Evidence: `evidence/regression-testing/pester-full.2026-11-03T20-57.md` (single process, 13946 tests, 409 failed), `evidence/regression-testing/pester-parallel-shards.2026-11-03T20-08.md` and `.2026-11-03T20-39.md` (eight shards, 89 failed, identical per-shard counts in both passes), `evidence/remediation-baseline/pester-coverage-baseline.2026-11-03T19-45.md` (pre-edit, 409 failed).
- Attribution checks performed by this review: (1) `git diff --name-only 01706c697 HEAD -- tests/scripts/dev-tools scripts/dev-tools tests/scripts/powershell scripts/powershell scripts/dev_tools config` is empty, so no file under the failing suites' trees, the PoshQC module, or its configuration differs from the merge base; (2) the PATH-leak source named in the evidence exists at the merge base: `tests/scripts/dev-tools/run-actionlint.Tests.ps1` line 497 assigns `$env:PATH = '/existing'` inside an It block; (3) every suite the branch adds or changes passes in isolation and in the review re-run; (4) the evidence records a merge-base checkout comparison of all 17 failing sharded suites with identical failed-test sets or counts (89 = 59 + 30).
- Assessment: the 89 sharded failures are Windows-host fixtures (C: drive roots, backslash paths, Windows prompt strings) and fail identically at the merge base; the additional failures in the single-process run are order-dependent victims of the `run-actionlint.Tests.ps1` PATH leak. None is attributable to this branch. The authoritative host for these suites is `windows-latest` (`.github/workflows/_poshqc.yml` shard jobs), and the CI green gate at S9 will report that result.
- Classification: not a review finding against this branch. If CI on `windows-latest` failed in these suites, the condition would be awaiting CI, not autonomous remediation in this item. The PATH leak is a pre-existing test-isolation defect in an unrelated module; it should be filed as a separate issue rather than fixed in this item, because the suite is outside the feature's scope.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **ee983c672** through **793096c82** - initial delivery, QA loop, main merges, and review evidence (21 commits; listed in `policy-audit.2026-11-03T18-43.md` Section 9)
2. **c878af760** - docs(1047): record the full feature review after the Codespace resume
3. **047259cd3** - docs(1047): open remediation cycle 1 in design mode with the Minor findings in scope
4. **51c7547ca** - docs(1047): add the remediation plan for cycle 1
5. **5000b6455** - docs(1047): clear preflight for the cycle 1 remediation plan
6. **49c54e3de** - feat(parallel-admission): add reuse-edges subcommand and surface git stderr

### Files Modified

1. **`.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`** (MODIFIED in cycle 1) - `reuse-edges` subcommand, `-Slug`/`-IssueNum`/`-PlanHash`/`-Ref` options, stderr capture, side-effect wording; JSON functions removed.
2. **`.claude/lib/parallel-admission/ParallelAdmissionJson.psm1`** (NEW in cycle 1) - the four pure JSON functions.
3. **`.claude/skills/parallel-plan/SKILL.md`**, **`.claude/rules/parallel-orchestration.md`** (MODIFIED in cycle 1) - step 7 and the rule name `reuse-edges`.
4. **`extensions/drm-copilot/resources/claude-customizations/**`** - byte-equal copies; `pack-manifests/core.json` entry for the new module.
5. **`tests/scripts/claude-lib/parallel-admission/*`** - `ParallelAdmissionJson.Tests.ps1` added; CLI and integration suites extended.
6. Earlier cycle-0 files are unchanged in cycle 1 and described in the previous policy audit.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Code, tests, mirrors, scope, and coverage comply. Both previous blocking findings are resolved with figures read from the canonical artifacts. The full-tree Linux host failures are pre-existing and outside the diff (non-blocking, Section 8).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation plan and preflight recorded
- ✅ Design Principles: pure JSON module, seams unchanged
- ✅ Module & File Structure: largest production file 621 lines
- ✅ Naming, Docs, Comments: side-effect wording corrected
- ✅ Toolchain Execution: three loop passes, third clean
- ✅ Summarize & Document: commit and self-review

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: no Python change in cycle 1; tools clean
- ✅ Python Design & Typing: annotated constants only
- ✅ Error Handling: N/A (no logic)

**For PowerShell:**
- ✅ Tooling & Baseline: formatter and analyzer clean (review re-check)
- ✅ PowerShell Design & Safety: strict mode, explicit failures
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: branch suites pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: shuffle, reversed, serial, and `-n auto` runs passed
- ✅ Coverage & Scenarios: canonical artifacts present and above thresholds
- ✅ Test Structure: AAA and exact assertions
- ✅ External Dependencies: seams mocked, no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest; coverage 96.67% line, 93.64% branch
- ✅ Test Style & Structure: parametrized obligation cases
- ✅ Naming & Readability: issue-referenced comments
- ✅ Toolchain: full suite with coverage

**For PowerShell:**
- ✅ Framework & Scope: Pester 5.9.1 through PoshQC
- ✅ Test Style & Structure: seam mocks only
- ✅ Naming & Readability: `*.Tests.ps1`, Describe per function
- ✅ Toolchain: 282 touched tests passing at HEAD

---

### Metrics Summary

- ✅ 282/282 touched Pester tests passing on Linux at HEAD (review re-run)
- ✅ 5/5 file-size repo gate tests passing at HEAD (review re-run)
- ✅ 16063 pytest tests passing under strict addopts, `-n auto`, and coverage (executor)
- ✅ Coverage: PowerShell 92.61% repo-wide, new files 96.44% to 100.00%; Python 96.67% line, 93.64% branch
- ✅ Proper file organization: tests mirror `.claude/lib/` under `tests/scripts/claude-lib/`
- ✅ All static quality checks passing

---

### Recommendation

**Ready for PR**

Proceed to the PR creation gate. At the CI green gate, confirm the `windows-latest` PoshQC shards and the `poshqc / PowerShell hook suites (Linux)` job, then check off spec criterion S14.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1` - 56 tests
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1` - 51 tests
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1` - 12 tests (new in cycle 1)
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` - 78 tests (21 added in cycle 1 for `reuse-edges`, stderr messages, and fetch wording)
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1` - 12 tests (one `reuse-edges` scenario added in cycle 1)
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1` - 5 tests
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` - 62 tests
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` - two parametrized obligation cases from the fragment pins

---

## Appendix B: Toolchain Commands Reference

Commands run by this review (check-only):

```bash
git -C <worktree> diff --name-status --no-renames 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD
git -C <worktree> diff 793096c82 HEAD -- .claude/lib .claude/rules .claude/skills
cmp -s <primary> extensions/drm-copilot/resources/claude-customizations/<primary>   # 12 pairs
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
awk '/^LF:/{...} /^LH:/{...} /^BRF:/{...} /^BRH:/{...}' artifacts/python/lcov.info
python3 -I <scratch>/cov.py artifacts/pester/powershell-coverage.xml <five files>    # JaCoCo LINE counters and missed lines
```

```powershell
$c = New-PesterConfiguration
$c.Run.Path = @('tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1', 'tests/scripts/claude-lib/parallel-admission', 'tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1')
$c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $false; $c.Run.PassThru = $true
Invoke-Pester -Configuration $c          # also run for tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
@(Get-Content -LiteralPath <file>).Count
```

Commands recorded by the executor and inspected by this review:

```bash
poetry run pytest -n auto -q -p no:cacheprovider --cov --cov-branch --cov-report=term-missing
```

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <worktree>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-03
**Policy Version:** Current (as of audit date)
