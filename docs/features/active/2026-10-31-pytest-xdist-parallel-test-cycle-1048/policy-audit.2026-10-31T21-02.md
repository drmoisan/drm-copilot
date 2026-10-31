# Policy Compliance Audit: pytest-xdist and concurrent Pester test cycle (Issue #1048)

---

**Audit Date:** 2026-10-31
**Code Under Test:**
- PowerShell production: `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` (new), `scripts/powershell/PoshQC/PoshQC.Shard.psm1`, `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.psd1`, and their byte-identical bundled copies under `extensions/drm-copilot/resources/powershell/PoshQC/`
- PowerShell tests (new): `tests/scripts/powershell/PoshQC/PoshQC.ParallelMerge.Tests.ps1`, `PoshQC.ParallelRunner.Tests.ps1`, `PoshQC.ShardWeights.Tests.ps1`, `PoshQC.TestingOutputPath.Tests.ps1`
- Python tests (modified): `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `test_resolve_hard_lock_prompt.py`, `test_execution_environment_brief_contracts.py`, `test_poshqc_bundled_parity.py`
- Python configuration: `pyproject.toml` (dev dependency `pytest-xdist`, `--strict-markers`, `--strict-config`, `xfail_strict`), `poetry.lock`
- CI workflow: `.github/workflows/_quality-checks.yml` (one token added to the `Run tests with Pytest` step)
- JSON: `config/poshqc-shard-weights.json` (new), `.vscode/tasks.json` (three tasks added; JSONC)
- Markdown: six execution-environment brief copies, `scripts/powershell/PoshQC/README.md` and its bundled copy, feature folder documents and evidence

Scope: full branch diff `58b81ca577943cd2944b62ee23ff3a3d1d737092..d817f4075c4c9f5a69b185173e53987ae8d0dd91` (base `main`, resolved with the pr-base-branch-merge-base procedure; `origin/main` equals the merge base and is an ancestor of `HEAD`, so the branch is current with `main`; `HEAD` equals `origin/feature/pytest-xdist-parallel-test-cycle-1048`). 78 files changed, 4501 insertions, 52 deletions.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 production modules (plus 5 bundled copies), 4 new test files | 13643 tests (full Pester run) | ✅ 0 failures, 0 errors, 10 disabled (pre-existing) | `PoshQC.Testing.psm1` 93.60% lines; `PoshQC.Shard.psm1` 100% lines | `PoshQC.Testing.psm1` 93.66% (192/205); `PoshQC.Shard.psm1` 100% (138/138); repo-wide 93.57% lines (21115/22566) | `PoshQC.Parallel.psm1` 96.00% (144/150); every changed line in the modified modules executed |
| Python | 4 test files, `pyproject.toml`, `poetry.lock`; no production Python | 15875 passed, 6 skipped (`-n auto`) | ✅ 0 failures | 96.6940% lines, 93.6298% branches (serial) | 96.6940% lines (32144/33243), 93.6378% branches (11686/12480) | No production Python changed; repo-wide figures above the 85% / 75% floors |
| JSON | `config/poshqc-shard-weights.json`, `.vscode/tasks.json` | N/A | ✅ weights parsed by `ConvertFrom-PoshQCShardWeightJson` (SW suites); `tasks.json` JSONC parse succeeds (55 tasks) | N/A (config files) | N/A (config files) | N/A |
| YAML (workflow) | `.github/workflows/_quality-checks.yml` | `test_quality_checks_workflow_contracts.py` | ✅ passes; branch-head CI run pending orchestrator step 9 | N/A | N/A | N/A |

Languages with zero changed files on the branch: TypeScript, C#, Bash. Coverage verdicts for those languages are N/A.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/evidence/baseline/pester-serial.2026-10-31T18-13.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, written 2026-10-31 20:53 UTC, after the last PowerShell test edit), summarized in `evidence/qa-gates/pester-coverage.2026-10-31T20-39.md`
- Python baseline coverage artifact: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/evidence/baseline/pytest-serial.2026-10-31T17-47.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (364 `SF:` records, written 2026-10-31 20:40 UTC by the final `-n auto` loop-restart run), summarized in `evidence/qa-gates/pytest-coverage.2026-10-31T19-58.md`
- Per-language comparison summary: Section 1.2.1 below

The counters were re-read during this review. JaCoCo: `PoshQC.Parallel.psm1` `LINE missed="6" covered="144"` with missed lines 263, 264, 266, 267 (body of `Invoke-PoshQCPwshExe`) and 408, 411 (the omitted-root and relative-root fallbacks in `Invoke-PoshQCParallelTest`); `PoshQC.Shard.psm1` `LINE missed="0" covered="138"`; `PoshQC.Testing.psm1` `LINE missed="13" covered="192"`, with the new lines 338 and 339 executed and every missed line outside the changed hunks; report total `LINE missed="1451" covered="21115"`. LCOV totals summed in this review: LH/LF 32144/33243 (96.6940%), BRH/BRF 11686/12480 (93.6378%). The origin/main merge commit (`d817f4075`) touched no PoshQC, `pyproject.toml`, or `poetry.lock` file, so the artifacts describe the branch's changed files at `HEAD`.

---

## Executive Summary

The branch adds `pytest-xdist` (CI step `-n auto`, two parallel VS Code tasks, `-n` kept out of `addopts`), fixes the `importlib.reload` leak in `test_resolve_hard_lock_prompt.py`, adopts `--strict-markers`, `--strict-config`, and `xfail_strict`, adds a local concurrent Pester runner (`PoshQC.Parallel.psm1`) with a pure JUnit merge, adds per-invocation output paths to `Invoke-PoshQCTest`, weighs CI shards by committed measured durations with median and size fallbacks, and updates the brief and the PoshQC README.

Repository-policy checks verified by command in this review all pass: toolchain evidence, coverage, file size, mirror parity, brief parity, no new Python script, no hook change, no `-n` in `addopts`, lock contents, and evidence locations.

One autonomous finding is open (F1): the spec criteria for `.vscode/tasks.json` require "governed-JSON validation", which the repository validator cannot perform on that file (Section 3D). Three findings await CI (A1 to A3): the Phase 9 measurements and the branch-head green run that the modified workflow requires, owned by orchestrator step 9.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted; `quality-tiers.yml` classifies `scripts/powershell/PoshQC` as T3 and `scripts/dev_tools` as T2; no property-test or mutation obligation applies to the T3 module, and no production Python changed)
- ⚠️ `.claude/rules/ci-workflows.md` (`modified-workflow-needs-green-run`: pending orchestrator step 9, finding A3)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`; test-only changes)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash: no shell file changed
- ⚠️ JSON: `config/poshqc-shard-weights.json` verified; `.vscode/tasks.json` criterion wording (F1)

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted or kept outside the repository (executor helpers are cited as `SCRATCH/issue-1048-*`; the branch diff contains none)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no tooling script added; the weights regeneration command is the exported, tested `Export-PoshQCShardWeight`)
- Scripts created during development: `SCRATCH/issue-1048-plugins/order_plugin.py`, `SCRATCH/issue-1048-tasks-check.py`, `SCRATCH/issue-1048-pester-*.ps1`, outside the worktree; none committed.

---

## Rejected Scope Narrowing

None detected. The caller prompt directs a review of the full feature branch against the resolved base and names the CI-dependent Phase 9 items so they are classified as awaiting CI rather than autonomous; it does not narrow the audit to a plan, phase, file subset, or language, and it does not ask for any toolchain or coverage check to be skipped. The audit covers the full branch diff against `main`. The PR context artifacts in this worktree (`artifacts/pr_context.summary.txt`, generated 2026-10-29 for `bug/standalone-orchestration-merge-on-green-997`) are stale and belong to another branch; no collection tool is available to this reviewer, so the full `git diff` from the merge base is the scope source.

---

## Evidence Location Compliance

Command: `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` exited 0 with no reported paths. `git diff --name-only <merge-base> HEAD` lists no file under `artifacts/` at all; every evidence file is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. Result: PASS, no violations.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Python: reversed run, seeded shuffles (seeds 1048, 20261031, 7), three `-n auto` runs and one `-n 4` run with 0 failures (`evidence/regression-testing/pytest-reversed`, `pytest-shuffled`, `pytest-xdist-runs`). Pester: 8-worker concurrent run and seeded shuffled orders (seeds 1048, 20261031, 7) with 0 failures (`pester-concurrent-vs-serial`, `pester-shuffled`); leakers and victims fixed in test code (`pytest-isolation-fixes`, `pester-isolation-fixes`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | OP01-OP04, SW01-SW07, PM01-PM11, PR01-PR09 each assert one behavior; the new Python tests assert one property each. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | New suites start no process and read no file; no sleeps (searched in this review: no `Start-Sleep`, `sleep`, or wall-clock waits in the new or changed tests). |
| **Determinism** - Consistent results | ✅ PASS | Clock, process, file, and reader seams are injected; PR tests use a queued fake clock with fixed `DateTime` values; no `Get-Date`, `UtcNow`, `Get-Random`, or environment-variable writes in the new suites (searched in this review). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Case ids in `It` names; Arrange/Act/Assert comments; docstrings on new Python tests. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell `PoshQC.Testing.psm1` 93.60%, `PoshQC.Shard.psm1` 100% (`evidence/baseline/pester-serial.2026-10-31T18-13.md`); Python 96.6940% lines / 93.6298% branches (`evidence/baseline/pytest-serial.2026-10-31T17-47.md`)<br>**Commands:** `Invoke-PoshQCTest -Root <worktree>`; `poetry run pytest --cov-branch --cov` (serial) |
| **No Coverage Regression** | ✅ PASS | **Post-change:** Testing 93.66% (+0.06), Shard 100% (+0.00); Python 96.6940% (+0.0000) lines, 93.6378% (+0.0080) branches<br>**Status:** No regression; no changed line is unexecuted except the six `PoshQC.Parallel.psm1` lines in a new file. |
| **New Code Coverage** | ✅ PASS | **New file:** `PoshQC.Parallel.psm1` 96.00% (144/150) against the 85% line threshold (root `CLAUDE.md` states no threshold, so the defaults govern; Pester measures no branch coverage, so no branch threshold applies to PowerShell).<br>**Deviation D2 reviewed:** the four uncovered wrapper lines (`Invoke-PoshQCPwshExe` body) stay in the coverage denominator; no coverage exclusion was added (`scripts/powershell/PoshQC/settings/` and `config/poshqc-scan.json` are unchanged on the branch). This matches the Coverage Exclusion Policy: host-bound process start is isolated in the thinnest wrapper and its cost remains visible in the metric. |
| **Comprehensive Coverage** | ✅ PASS | Worker count PM01-PM03; merge PM04-PM08; weights PM09-PM11 and SW01-SW07; runner PR01-PR09; output paths OP01-OP04. Gap noted (non-blocking, code review Minor CR-2): the `-Root` omitted and relative fallbacks (lines 408, 411) are untested though testable through the existing seams. |
| **Positive Flows** - Valid inputs | ✅ PASS | PM04, PM05, PM09, PM10, PR02, SW01, OP01, OP02. |
| **Negative Flows** - Invalid inputs | ✅ PASS | PM08 (malformed XML, foreign root, empty list); SW04 (malformed weights documents including non-object and non-relative key); PR07 rejects `-WorkerCount 0`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | PM02 cap of 8, PM03 floor of 1, PM07 empty shard, SW02 median for unlisted file, SW03 absent file, PM09 path without anchor segment. |
| **Error Handling** - Error paths | ✅ PASS | PR03 failed shard, PR04 missing output, PR05 incomplete manifests, PR06 merge failure: each returns exit code 1 and writes no merged artifact. |
| **Concurrency** - If applicable | ✅ PASS | The runner starts every shard before waiting (PR01); the 8-worker local run matched the serial totals (13643 tests, 0 failures); the `Wait-Process` defect found by the first concurrent run is fixed (D5). |
| **State Transitions** - If applicable | N/A | The runner's start, wait, and merge sequence is covered by PR01-PR08; no other stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: `PoshQC.Testing.psm1` 93.60% lines, `PoshQC.Shard.psm1` 100% lines -> Post-change: 93.66% and 100% lines. Change: +0.06 and +0.00 percentage points. Repo-wide post-change: 93.57% lines (21115/22566). New/changed-code coverage: 96.00% (`PoshQC.Parallel.psm1`, 144/150); every changed line of the modified modules executed. Branch coverage: not applicable to PowerShell (Pester measures no branch coverage). Disposition: PASS. Evidence: `evidence/baseline/pester-serial.2026-10-31T18-13.md`, `evidence/qa-gates/pester-coverage.2026-10-31T20-39.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 96.6940% lines, 93.6298% branches -> Post-change: 96.6940% lines, 93.6378% branches. Change: +0.0000 and +0.0080 percentage points. New/changed-code coverage: 100% (no production Python line changed; the changed files are tests, which are outside the coverage source). Disposition: PASS. Evidence: `evidence/baseline/pytest-serial.2026-10-31T17-47.md`, `evidence/qa-gates/pytest-coverage.2026-10-31T19-58.md`, `artifacts/python/lcov.info`.
- TypeScript, C#, Bash: zero changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` texts and assertion messages name the expectation (for example `expected one -n token`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New Pester and Python tests carry the three sections. |
| **Document Intent** | ✅ PASS | Suite header comments state scope and the no-file-I/O rule. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no real process, no temp files: a search of the four new Pester files for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `Temp:`, `Start-Process`, and `Start-Sleep` returned no match; the Python diff adds no `tmp_path`, `tempfile`, or `sleep`. |
| **Use Mocks/Stubs** | ✅ PASS | Seams plus named-cmdlet mocks; the external `pwsh` start is mocked through the wrapper `Invoke-PoshQCPwshExe` (repository wrapper-seam rule; `check-powershell-test-purity.ps1` denies `Start-Process` in test files). |
| **Environment Stability** | ✅ PASS | Roots built from `[IO.Path]::GetPathRoot($PSScriptRoot)`; no environment variables changed. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-10-31T21-00.md` (re-verified by command here rather than relied on). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1048; `spec.md` (full-feature); `user-story.md`; `owner-decisions.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-31T17-33.md`; `research/research.2026-10-31T13-15.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-31T13-02.md`; Phases 0-8 and 10 checked; Phase 9 (5 tasks, P9-T1 to P9-T5) unchecked and owned by orchestrator step 9. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One runner, one pure merge, one weights converter; process-per-shard on top of the existing `-ShardIndex -ShardCount` path. |
| **Reusability** | ✅ PASS | Reuses `Merge-PoshQCCoverageReport`, `Test-PoshQCShardCompleteness`, `Convert-PoshQCCoverageToRelative`, and `Get-PoshQCShardSlice`. |
| **Extensibility** | ✅ PASS | New `Invoke-PoshQCTest` parameters are optional; existing callers unchanged (OP03). |
| **Separation of concerns** | ✅ PASS | Pure functions (`Merge-PoshQCJunitReport`, `ConvertTo-PoshQCShardWeight`, `Get-PoshQCParallelWorkerCount`) separated from the seam-driven runner. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | New logic in `PoshQC.Parallel.psm1`; `PoshQC.Testing.psm1` gained only two parameters and four lines. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts re-measured in this review (awk `NR`): `PoshQC.Testing.psm1` 491, `test_execution_environment_brief_contracts.py` 486, `test_resolve_hard_lock_prompt.py` 456, `PoshQC.Parallel.psm1` 452, `PoshQC.Shard.psm1` 394, `test_quality_checks_workflow_contracts.py` 280, `PoshQC.ParallelRunner.Tests.ps1` 263, others lower; bundled copies identical. No covered file is at or above 700 lines. `config/file-size-baseline.json` is not changed. |
| **Public vs internal** | ✅ PASS | Five exported functions; helpers `ConvertFrom-PoshQCJunitXml`, `Get-PoshQCParallelShardArgument`, `Invoke-PoshQCParallelMerge`, `Invoke-PoshQCPwshExe`, `ConvertFrom-PoshQCShardWeightJson` stay internal. |
| **No circular dependencies** | ✅ PASS | `PoshQC.Parallel.psm1` calls Shard, CoverageMerge, and Testing functions at run time within the one module scope. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs Get, Merge, ConvertTo, ConvertFrom, Export, Invoke, Select. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new function; new parameters documented in `Invoke-PoshQCTest` help. |
| **Comment why, not what** | ✅ PASS | Comments explain the wait-on-object choice, the first-report capture order, and the anchor rule. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check .`; PoshQC format through MCP<br>**Result:** unchanged (`evidence/qa-gates/black.2026-10-31T19-55.md`, `poshqc-format.2026-10-31T19-59.md`) |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check .`; `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** `All checks passed!`; 0 findings (`ruff.2026-10-31T19-55.md`, `pssa.2026-10-31T19-59.md`) |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors (`pyright.2026-10-31T19-55.md`); PowerShell has no type-check stage |
| **4. Testing** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov-branch --cov`; `Invoke-PoshQCTest -Root <worktree>`<br>**Result:** 15875 passed, 0 failed; 13643 Pester tests, 0 failures. Re-run in this review: the four modified Python test files, 48 passed. |
| **Full toolchain loop** | ✅ PASS | Loop restarted from P10-T1 after the SW04 addition (D6); every gate record carries the restart note. Contract stage: workflow, brief, and parity contract tests pass. |
| **Explicit reporting** | ✅ PASS | Each gate has an evidence file with `Command:` and `EXIT_CODE:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Conventional commit messages per phase (Section 9). |
| **Design choices explained** | ✅ PASS | Deviations D1-D6 in `evidence/other/execution-deviations.2026-10-31T19-18.md`; strictness decisions; owner decisions. |
| **Update supporting documents** | ✅ PASS | Brief `## Test Runtime` and `## Test Isolation Checks` in six copies (one SHA-256, `1fa5f0b0...`, re-computed in this review); PoshQC README and bundled copy byte-identical. |
| **Provide next steps** | ✅ PASS | Phase 9 owned by orchestrator step 9; follow-ups FU-1 to FU-7 in `evidence/other/follow-ups.2026-10-31T19-07.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black / Ruff / Pyright** | ✅ PASS | Clean (Section 2.5). |
| **No new Python script** | ✅ PASS | `git diff --name-status --diff-filter=A <merge-base> HEAD` lists no `.py` file; the four changed `.py` files are under `tests/` and are modifications. The language rule (avoid new Python) is met. |
| **Dependencies** | ✅ PASS | `pytest-xdist = "^3"` added under dev dependencies (owner-approved in the spec); `poetry.lock` has one `name = "pytest-xdist"` entry and its transitive `execnet`; `name = "psutil"` count is 0 at both the merge base and `HEAD`; `poetry check --lock` exits 0 (re-run in this review). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Typed helpers, no suppressions** | ✅ PASS | New test helpers fully typed; no `# noqa` or `# type: ignore` added. |
| **`addopts` constraint** | ✅ PASS | `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config"`: no `-n`, `--numprocesses`, or `--dist` token; existing tokens first. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Error handling** | N/A | No production Python changed. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | No changes (`poshqc-format.2026-10-31T19-59.md`). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings (`pssa.2026-10-31T19-59.md`). |
| **Fix all findings** | ✅ PASS | None outstanding. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | `PSUseCompatibleSyntax` reports no finding; the weights parser avoids `ConvertFrom-Json -AsHashtable`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` on every new function. |
| **Parameter validation** | ✅ PASS | `ValidateRange(1, [int]::MaxValue)` on `-WorkerCount`; `Mandatory` and `AllowEmptyCollection` where applicable. |
| **Avoid global state** | ✅ PASS | No script-scope state added beyond the existing `$script:ModuleRoot` read. |
| **Error handling** | ✅ PASS | Merge and completeness failures logged and returned as exit code 1; parsers throw messages naming the input; the runner never calls `exit`. |
| **Wrapper seam for external executables** | ✅ PASS | `Invoke-PoshQCPwshExe -PwshArgs <string[]> -LogPath <string>`; the extra `-LogPath` and the `Start-Process` call are needed for an asynchronous child with redirected output, which a splatted synchronous call cannot provide. Recorded as Info CR-4 in the code review. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest changed PowerShell file 491 logical lines. |
| **Approved verbs** | ✅ PASS | See Section 2.4. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | No changes. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Full run 13643 tests, 0 failures; single-process `tests/scripts` run 0 failures (`pester-single-process.2026-10-31T20-59.md`). |
| **Rerun loop if needed** | ✅ PASS | Restarted after D6. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **`config/poshqc-shard-weights.json`** | ✅ PASS | Generated by `Export-PoshQCShardWeight` from CI run 41209645365 JUnit artifacts; `version` 1, `unit` `ms`; no key begins with `/` or a drive letter (re-checked); parsed by `ConvertFrom-PoshQCShardWeightJson` in SW suites. Not in the governed globs. |
| **`.vscode/tasks.json` governed-JSON validation (D1)** | ⚠️ PARTIAL | `scripts/dev_tools/json_config.py` `GOVERNED_GLOBS` are `scripts/**/*.json`, `docs/**/*.json`, `examples/**/*.json`, and the module states that `.vscode` files are JSONC and excluded. An explicit `poetry run python -m scripts.dev_tools.validate_json .vscode/tasks.json` exits 1 with `invalid JSON (Expecting value: line 1 column 1 (char 0))` at `HEAD` and gives the same message for the merge-base copy, because the file begins with a `//` comment. The validator therefore cannot pass `tasks.json` in any version; the spec wording is unsatisfiable rather than the file being defective. A JSONC parse (full-line comments removed, then `JSON.parse`) succeeds with 55 tasks, and all five required labels are present. Classified as an AC wording defect: finding F1 (autonomous). |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Required `$schema`** | N/A | Neither changed JSON file is in the governed globs. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | ✅ PASS | New tests in the existing mirrored `tests/scripts/dev_tools/` files. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Leak fixed in test code** | ✅ PASS | `importlib.reload` removed; `test_clipboard_tests_leave_module_bindings_intact` pins identity; fail-before in `hard-lock-reload-fail-before.2026-10-31T18-17.md`. |
| **Contract tests can fail** | ✅ PASS | `test_addopts_xdist_check_rejects_injected_flag` feeds an in-memory `addopts` carrying `-n auto` and asserts the check reports it. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names and docstrings** | ✅ PASS | `test_pytest_step_runs_xdist_workers`, `test_pyproject_addopts_carries_no_xdist_flag`. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Full suite** | ✅ PASS | 15875 passed under `-n auto`; serial, reversed, and shuffled runs 0 failures. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester `>= 5.9.0, < 6.0.0` unchanged. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root <worktree>`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged) |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 31 new cases across four files (OP 4, SW 7, PM 11, PR 9). |
| **Mocking Used Sparingly** | ✅ PASS | Only process, file, and clock boundaries are mocked. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/powershell/PoshQC/*.Tests.ps1`<br>**Code files:** `scripts/powershell/PoshQC/*.psm1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All four end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per suite with case-id `It` names. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | 13643 tests, 0 failures. |

---

## 5. Test Coverage Detail

### PoshQC.Parallel.psm1 (20 tests: PM01-PM11, PR01-PR09)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| PM01-PM03 worker default, cap, floor | Positive / Edge Case | `Get-PoshQCParallelWorkerCount` | ✅ |
| PM04-PM08 JUnit merge sums, time, failing, empty, malformed | Positive / Negative | `Merge-PoshQCJunitReport`, `ConvertFrom-PoshQCJunitXml` | ✅ |
| PM09-PM11 weights normalize, sort, export seam | Positive | `ConvertTo-PoshQCShardWeight`, `Export-PoshQCShardWeight` | ✅ |
| PR01-PR08 runner start, merge, failures, override, summary | Positive / Error Handling | `Invoke-PoshQCParallelTest`, `Invoke-PoshQCParallelMerge`, `Get-PoshQCParallelShardArgument` | ✅ |
| PR09 default seams | Positive | default seam bodies | ✅ |

**Coverage:** 96.00% (144/150).

**Not covered:** lines 263-267 (`Invoke-PoshQCPwshExe` body; D2) and 408, 411 (`-Root` fallbacks).

### PoshQC.Shard.psm1 and PoshQC.Testing.psm1 (11 tests: SW01-SW07, OP01-OP04)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| SW01-SW07 measured weights, median, size fallback, malformed, default reader | Positive / Negative / Edge Case | `Get-PoshQCShardTestFileWeight`, `ConvertFrom-PoshQCShardWeightJson`, `Select-PoshQCShardTestFile` | ✅ |
| OP01-OP04 output-path overrides | Positive / Edge Case | `Invoke-PoshQCTest` lines 338-339 | ✅ |

**Coverage:** Shard 100% (138/138); Testing 93.66% (192/205).

**Not covered:** None in changed lines.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 13643 Pester; 15881 pytest (15875 passed, 6 skipped) | ✅ |
| Tests Passed | all executed | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Pester 1144.3 s serial; pytest 152.54 s under `-n auto` (24 local workers) | ✅ |
| Functions/Classes Tested | 9/9 new PoshQC functions; 2/2 modified functions | ✅ |
| Test File Size | largest 486 logical lines | ✅ PASS at or below 800 lines; no file at or above 700 |
| Code Coverage (if applicable) | Parallel 96.00%, Shard 100%, Testing 93.66%; Python 96.69% / 93.64% | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check .` | unchanged | ✅ |
| Ruff | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright | `poetry run pyright` | 0 errors | ✅ |
| Pytest | `poetry run pytest -n auto --cov-branch --cov` | 15875 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `run_poshqc_format` | 0 files changed | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root <worktree>` | 13643 tests, 0 failures | ✅ |

**Notes:** The toolchain was executed by the executor. This review re-ran: `poetry check --lock` (exit 0); the four modified Python test files (48 passed); `cmp` on all six PoshQC source/bundled pairs (identical); SHA-256 of the six brief copies (one digest); logical line counts; the lock and `addopts` greps; the JaCoCo and LCOV counter reads; the JSONC parse of `tasks.json`; `validate_json` on `tasks.json` at `HEAD` and at the merge base; and the evidence-location validator. PowerShell was not re-run because the worktree isolation guard refuses command text that launches `pwsh`; the persisted artifacts were inspected instead.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F1 (autonomous): spec criteria for `.vscode/tasks.json` require governed-JSON validation that the repository validator cannot perform on a JSONC file outside the governed globs. Remedy: amend the two criteria's wording to the verifiable check, citing the evidence, then check them off.
- A1 to A3 (awaiting CI): Phase 9 tasks P9-T1 to P9-T5 and the criteria that depend on them; owned by orchestrator step 9 (the plan carries five Phase 9 tasks, not nine).
- Non-blocking: code-review CR-2 (Minor, untested `-Root` fallbacks), CR-3 and CR-4 (Info).
- Hook untouched: `git diff --name-status <merge-base> HEAD` lists no path under `.claude/hooks/` or `.codex/hooks/`, and `.github/workflows/_poshqc.yml` is unchanged.

### Approved Exceptions

**None.** No coverage exclusion, suppression, or skipped test was introduced.

### Removed/Skipped Tests

**None.** Three `importlib.reload` calls were removed from clipboard tests (the leak fix); their assertions are unchanged.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **973df98b2** - docs(features): record #1048 research, spec, plan and preflight
2. **bd1346c8c** - docs(features): record potential entries for issues 1049, 1050 and 1051
3. **beb0ca53b** - docs(features): record #1048 phase 0 policy reads and baselines
4. **85aaa1864** - ci(pytest): run the CI pytest step with pytest-xdist workers (#1048)
5. **168ba4172** - test(pytest): remove the module reload leak and adopt strict pytest options (#1048)
6. **73ecc4d8b** - feat(poshqc): add output-path parameters to Invoke-PoshQCTest (#1048)
7. **05816fe4d** - feat(poshqc): weigh shard test files by measured durations (#1048)
8. **94bdeee64** - feat(poshqc): add the local concurrent Pester runner (#1048)
9. **3f221c801** - docs(poshqc): mirror PoshQC changes, add the parallel Pester task and README (#1048)
10. **73669ce82** - chore(poshqc): commit measured shard weights from CI run 41209645365 (#1048)
11. **0f70f5a55** - fix(poshqc): wait on the shard process object in the parallel runner (#1048)
12. **6e65c5e89** - docs(features): record #1048 Pester isolation, slow-file profile, and file count
13. **297fe83c6** - docs(brief): document parallel pytest and Pester runs in the execution-environment brief (#1048)
14. **647c909d4** - test(poshqc): cover weights-document guards and record the #1048 final QA loop
15. **d817f4075** - Merge origin/main into feature/pytest-xdist-parallel-test-cycle-1048

### Files Modified

1. **`scripts/powershell/PoshQC/PoshQC.Parallel.psm1`** (NEW) and bundled copy - runner, JUnit merge, weights conversion and export.
2. **`scripts/powershell/PoshQC/PoshQC.Shard.psm1`** (MODIFIED) and bundled copy - measured weights with median and size fallbacks.
3. **`scripts/powershell/PoshQC/PoshQC.Testing.psm1`** (MODIFIED) and bundled copy - `-TestResultPath`, `-CoverageOutputPath`.
4. **`PoshQC.psm1`, `PoshQC.psd1`, `README.md`** (MODIFIED) and bundled copies - registration, exports, documentation.
5. **`config/poshqc-shard-weights.json`** (NEW).
6. **`pyproject.toml`, `poetry.lock`, `.github/workflows/_quality-checks.yml`, `.vscode/tasks.json`** (MODIFIED).
7. **Six execution-environment brief copies** (MODIFIED).
8. **Four Python test files** (MODIFIED) and **four Pester suites** (NEW).
9. **Feature folder documents and evidence** (NEW).

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage, file size, evidence location, mirror parity, brief parity, language, determinism, and dependency requirements are met. Open: F1 (AC wording defect, autonomous) and the CI-dependent items A1 to A3, including the green branch-head run that the modified workflow requires.

**Fail-closed reminder:** every required baseline artifact, QA artifact, coverage metric, and coverage-comparison artifact is present.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: research, spec, owner decisions, plan
- ✅ Design Principles: reuse of existing merge and completeness functions
- ✅ Module & File Structure: all files below 500 logical lines
- ✅ Naming, Docs, Comments: complete
- ✅ Toolchain Execution: clean after the D6 restart
- ✅ Summarize & Document: deviations and follow-ups recorded

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling: Black, Ruff, Pyright clean; no new Python script
- ✅ Dependencies: `pytest-xdist` locked; no `psutil`

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ Design & Safety: seams, validation, no exit calls
- ✅ Structure & Naming: approved verbs, sizes within limits

**For JSON:**
- ⚠️ `.vscode/tasks.json` criterion wording (F1)

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: order independence proven for both runners
- ✅ Coverage & Scenarios: thresholds met; no exclusion added
- ✅ Test Structure: AAA, clear messages
- ✅ External Dependencies: no process, network, temp file, or sleep

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Pytest; leak fixed in test code

**For PowerShell:**
- ✅ Pester 5 via PoshQC; focused cases

---

### Metrics Summary

- ✅ 13643 Pester tests, 0 failures; 15875 pytest passed, 0 failures
- ✅ 11/11 new or modified functions tested
- ✅ 96.00%, 100%, 93.66% line coverage on the three PoshQC modules; 93.57% repo-wide PowerShell; Python 96.69% lines / 93.64% branches
- ✅ Proper file organization
- ⚠️ CI-dependent checks pending orchestrator step 9

---

### Recommendation

**Requires remediation**

Run one remediation cycle for F1 (amend the wording of the two `tasks.json` criteria with the evidence and check them off; optionally close CR-2 in the same cycle), then let orchestrator step 9 complete A1 to A3 on the PR head.

---

## Appendix A: Test Inventory

### Complete Test List

1. PoshQC.TestingOutputPath › OP01-OP04
2. PoshQC.ShardWeights › SW01-SW07
3. PoshQC.ParallelMerge › PM01-PM11
4. PoshQC.ParallelRunner › PR01-PR09
5. test_quality_checks_workflow_contracts › `test_pytest_step_runs_xdist_workers`, `test_pyproject_addopts_carries_no_xdist_flag`, `test_addopts_xdist_check_rejects_injected_flag`
6. test_resolve_hard_lock_prompt › `test_clipboard_tests_leave_module_bindings_intact`
7. test_execution_environment_brief_contracts › extended token tuples
8. test_poshqc_bundled_parity › two new parity paths

---

## Appendix B: Toolchain Commands Reference

**Commands run during this review (read-only):**
```bash
git diff --name-status 58b81ca577943cd2944b62ee23ff3a3d1d737092 HEAD
git diff 58b81ca577943cd2944b62ee23ff3a3d1d737092 HEAD -- pyproject.toml .github/workflows/_quality-checks.yml
grep -c 'name = "pytest-xdist"' poetry.lock; grep -c 'name = "psutil"' poetry.lock
poetry check --lock
cmp scripts/powershell/PoshQC/<file> extensions/drm-copilot/resources/powershell/PoshQC/<file>
sha256sum <six execution-environment brief copies>
awk 'END{print NR}' <changed covered files>
poetry run pytest <four modified test files> -q -p no:cacheprovider --no-cov
poetry run python -m scripts.dev_tools.validate_json .vscode/tasks.json
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-31
**Policy Version:** Current (as of audit date)
