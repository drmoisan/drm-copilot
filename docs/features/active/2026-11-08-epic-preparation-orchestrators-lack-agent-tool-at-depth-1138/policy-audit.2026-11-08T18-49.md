# Policy Compliance Audit: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Audit Date:** 2026-11-08
**Code Under Test:** merge base `a90d522c6ac239bca858d7bc800d52860e823219` of `origin/main` and reviewed head `88cbdb8eaf22197b1e74ba262affcbeb019e9b12`; the diff between them lists the changed files (65 paths). Re-audit after light remediation cycle 1 (prior review `*.2026-11-08T18-16.md`, cycle commit `88cbdb8ea`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (2 hooks plus 2 bundle copies), 3 test | 20120 | PASS 20110 pass, 0 fail, 10 skipped | 95.62% lines | 95.64% lines | 100% (new helper, 19/19), 90.79% (origin hook, 69/76) |
| Python | 0 production, 2 test | 16566 | PASS 16560 pass, 0 fail, 6 skipped | 97.11% lines | 97.11% lines | N/A - no Python production file changed |
| JSON | 1 file | N/A | PASS pack manifest contract tests | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-08T17-38.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-11-08 18:35 UTC by the cycle-1 gate; parsed directly: helper LINE 19 covered, 0 missed, including the edited lines 113 and 114; root LINE 36056 covered, 1645 missed)
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-08T17-40.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (written 18:39 UTC by the cycle-1 gate; totals recomputed: 34296 of 35317 lines, 12648 of 13404 branches)
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are recorded for PowerShell and Python, the two languages with changed files.

---

## Executive Summary

Cycle 1 closed F1: the four coordinator agents (live and bundle) now halt and record `spawn_agent_unavailable` when an `Agent(orchestrator)` call is denied with a reason beginning `NESTING_DEPTH_INSUFFICIENT:`, a new contract `It` asserts the sentence, and the `epic-orchestrator.md` pin was re-baselined with an extended #1138 comment block. The orchestrator-added P0-T2 change parses the limit with `[long]::TryParse`; a real-process probe by the reviewer confirmed `99999999999` and `9223372036854775807` allow, `-99999999999` and `2` deny with the below-3 reason, and the helper stays at 19 of 19 lines.

Policy compliance is met for the branch content. One blocking finding remains and is new in this re-audit: `origin/main` advanced 31 commits past the merge base (PR #1140, issue #1136), and `git merge-tree --write-tree origin/main HEAD` reports a content conflict in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, where both sides re-baselined `PINNED_FROZEN_SURFACE_HASHES`. A conflicting pull request receives no CI checks, so the S9 gate cannot pass until main is merged and the pin re-derived. Recorded as code-review F2.

The repo-wide pytest branch figure (94.36% versus 94.37% at baseline) was adjudicated as not attributable to this branch; see section 1.2.1.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `quality-tiers.md` (`.claude/hooks` is classified T3 in `quality-tiers.yml`)

**Language-specific policies evaluated:**
- PASS `powershell.md` (code and unit test)
- PASS `python.md` (test-only edits)
- N/A TypeScript, C#, Bash: zero changed files
- PASS JSON: one `core.json` entry, covered by the pack-manifest contract tests

**Temporary artifacts cleanup:**
- PASS Scratch launchers are outside the repository; `git status --porcelain` was empty at the reviewed head before this review wrote its artifacts.

---

## Rejected Scope Narrowing

None. The caller asked for the full branch diff against the merge base of `origin/main` and HEAD. The instruction not to re-run format, lint, and type checks follows the evidence model (the cycle-1 static artifacts were read instead) and does not narrow scope; every language with changed files has an explicit coverage verdict below.

## Evidence Location Compliance

No branch-diff file lies under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `scripts/dev_tools/validate_evidence_locations.py --root .` run from the worktree root exited 0. Cycle-1 evidence is under `<FEATURE>/evidence/qa-gates/` with the `2026-11-08T18-42` stamp. No EVIDENCE_LOCATION_OVERRIDE_REJECTED event.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each `It` mocks `Get-SubagentSpawnDepthSetting` itself; the new contract `It` reads files in place |
| **Isolation** - Each test targets single behavior | PASS | The new `It` asserts only the deny-halt sentence in the Startup Protocol preflight |
| **Fast Execution** - Tests complete quickly | PASS | Pure in-memory decisions and in-place file reads |
| **Determinism** - Consistent results | PASS | No clock, randomness, network, or environment mutation |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `It` names and `-Because` messages naming the file, region, and literal |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | 95.62% lines PowerShell, 97.11% lines and 94.37% branches Python (Phase 0 baseline artifacts) |
| **No Coverage Regression** | PASS | PowerShell 95.62% to 95.64%; helper 100% unchanged; Python lines unchanged; the one-branch Python difference lies in a file outside the branch diff (section 1.2.1) |
| **Changed Files Meet Thresholds** | PASS | Line threshold 85%: helper 100%, origin hook 90.79%; branch threshold not applicable to PowerShell |
| **New Code Coverage >=90%** | PASS | Helper 19 of 19 lines; the two edited lines (113, 114) carry `ci="1"` |
| **Comprehensive Coverage** | PASS | All three helper functions |
| **Positive Flows** | PASS | Unset, empty, whitespace, `3`, `4`, `10`, ` 4 `, `99999999999` allow |
| **Negative Flows** | PASS | `2`, `1`, `0`, `-1`, `-99999999999` deny with remedy text; `two`, `2.5` deny with the parse message |
| **Edge Cases** | PASS | Int32-overflow integers on both signs added in cycle 1 |
| **Error Handling** | PASS | Guarded import failure denies |
| **Concurrency** | N/A | Stateless read-only helper |
| **State Transitions** | N/A | No stateful component |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.62% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.64% lines. Change: +0.02% lines. New/changed-code coverage: 100% new helper (19 of 19, including the cycle-1 lines), 90.79% origin hook (69 of 76, baseline 90.41%). Disposition: PASS. Evidence: `evidence/baseline/pester-baseline.2026-11-08T17-38.md`, `evidence/qa-gates/pester-final.2026-11-08T18-42.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 97.11% lines, 94.37% branches -> Post-change: 97.11% lines, 94.36% branches. Change: 0 lines, -0.01% branches (12649 to 12648 of 13404). New/changed-code coverage: No Python production file changed on the branch; the two edited files are test-support and test modules. Adjudication: the reviewer compared the baseline, prior final, and cycle-1 coverage JSON reports file by file; the only differing file is `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py`, and the only differing arc is 395 to 362, the loop-back from the idle-timeout check to the next `q.get(timeout=0.1)` poll. That arc runs only when a poll iteration finds the process still running within its idle window, so it depends on subprocess timing in the test. The file is not in the branch diff, its lines are 194 of 235 in all three runs, and no Python production line changed, so the drop is not a per-file drop attributable to this change and is not a regression on changed lines. Repo-wide figures remain above the 85% line and 75% branch thresholds. Disposition: PASS. Evidence: `evidence/baseline/pytest-baseline.2026-11-08T17-40.md`, `evidence/qa-gates/pytest-final.2026-11-08T18-42.md`, `artifacts/python/lcov.info`.

### 1.3 Test Structure and Diagnostics

PASS. The new `It` reuses `Get-StartupPreflightText` and `Assert-ContractLiteral`, so a failure names the file, region, and literal.

### 1.4 External Dependencies and Environment

PASS. No test sets an environment variable or writes a file (cycle-1 `Invoke-PoshQCLeakScan`: 0 failures).

### 1.5 Policy Audit Requirement

PASS. This audit is the artifact.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes
PASS. Phase 0 baselines exist under `evidence/baseline/`; cycle-1 gate evidence under `evidence/qa-gates/` (`2026-11-08T18-42`).

### 2.2 Design Principles
PASS. The cycle-1 hook change is a type change on one local and one parse call.

### 2.3 Module & File Structure
PASS. Helper 126 lines, origin hook 295 lines, largest changed covered file 499 lines. No covered file reaches 700 lines; `config/file-size-baseline.json` is unchanged.

### 2.4 Naming, Docs, and Comments
PASS. The pin comment block was extended with the cycle-1 reason.

### 2.5 After Making Changes - Toolchain Execution
PASS. `poshqc-static-final.2026-11-08T18-42.md`: 0 of 3 files need formatting, 0 analyzer findings, leak scan 0 failures. `python-static-final.2026-11-08T18-42.md`: Black, Ruff, Pyright 0 findings; Codex generator `--check` exit 0.

### 2.6 Summarize and Document
PASS. The cycle commit message and the remediation-inputs task lines record the change.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

PASS. The only cycle-1 Python edit is the `epic-orchestrator.md` digest and its comment in a test-support module.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline
PASS. Formatter and analyzer clean per the cycle-1 static artifact.

#### 3B.2 PowerShell Design & Safety
PASS. `[long]::TryParse` with `NumberStyles.Integer` and invariant culture; a value outside the Int64 range or a non-integer still fails closed (probe: `9223372036854775808`, `1e3`, `0x10` deny with the parse message).

#### 3B.3 Structure, Naming, and Comments
PASS.

#### 3B.4 Running the Toolchain
PASS. One parallel Pester gate: 20120 tests, 0 failed.

### Documentation Surface Check
N/A. `docs/documentation-estate/docs-profile.json` is absent at the head, so the check produces no finding.

### Tier classification
PASS. `quality-tiers.yml` exists; the changed production files are under `.claude/hooks`, classified T3.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

PASS. `test_frozen_epic_surface_matches_pinned_baseline_digest` passed in the cycle-1 gate with the re-baselined digest, which equals the SHA-256 of the head `epic-orchestrator.md` (`5ff9c66f…`).

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope
PASS. Pester 6.x through `Invoke-PoshQCParallelTest`.

#### 4B.2 Test Style and Structure
PASS. The new `It` follows the file's existing pattern.

#### 4B.3 Naming and Readability
PASS.

#### 4B.4 Running the Toolchain
PASS. Cycle-1 gate green.

---

## 5. Test Coverage Detail

### epic-invocation-nesting-depth.ps1 (helper)
Cycle 1 added `99999999999` to the allow case and `-99999999999` to the deny case. The allow value discriminates the change: under the prior `[int]::TryParse` it returns the parse-message deny, so the `Should -BeNullOrEmpty` assertion would fail.

### Coordinator agents (contract)
The new `It` asserts `NESTING_DEPTH_INSUFFICIENT:` and `halt with that reason` in the Startup Protocol preflight of the four coordinators, live and bundle. `halt with that reason` occurs once in each coordinator file and only in the new sentence, so removing the sentence fails the `It`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 20120 Pester, 16566 pytest | PASS |
| Tests Passed | 20110 Pester (10 skipped), 16560 pytest (6 skipped) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 571.82 s Pester (8 workers), 256.99 s pytest | PASS |
| Average Time per Test | N/A (parallel gate) | N/A |
| Discovery Time | N/A | N/A |
| Functions/Classes Tested | 3/3 helper functions plus the origin decision function | PASS |
| Test File Size | 499 logical lines largest | PASS |
| Code Coverage | 95.64% PowerShell lines; 97.11% Python lines, 94.36% Python branches | PASS |

---

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PSScriptAnalyzer | PASS 0 findings (cycle-1 artifact) |
| Invoke-Formatter check | PASS 0 drift (cycle-1 artifact) |
| Leak scan | PASS 0 failures (local) |
| Black, Ruff, Pyright | PASS 0 findings (cycle-1 artifact) |
| Mergeability with `origin/main` | FAIL content conflict in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (code-review F2) |

## CI Cross-check

No pull request and no CI run exist for the branch yet (`gh pr list --head bug/epic-subagent-nesting-depth --state all` returned empty). The rows below record the local evidence the review relies on; CI confirmation is pending-CI at S9, and it requires the merge conflict in F2 to be resolved first.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| Pester suite | pass | 20120 tests, 0 failed | 88cbdb8eaf22197b1e74ba262affcbeb019e9b12 | `evidence/qa-gates/pester-final.2026-11-08T18-42.md` |
| `poshqc / PowerShell QC static` (format, analyze, leak scan) | pass | 0 findings, 0 leak failures | 88cbdb8eaf22197b1e74ba262affcbeb019e9b12 | `evidence/qa-gates/poshqc-static-final.2026-11-08T18-42.md` |
| `Enforce Python coverage thresholds` | pass | 97.11% lines, 94.36% branches | 88cbdb8eaf22197b1e74ba262affcbeb019e9b12 | `evidence/qa-gates/pytest-final.2026-11-08T18-42.md`, `artifacts/python/lcov.info` |
| Python static | pass | 0 findings | 88cbdb8eaf22197b1e74ba262affcbeb019e9b12 | `evidence/qa-gates/python-static-final.2026-11-08T18-42.md` |

---

## 8. Gaps and Exceptions

### Identified Gaps
- F2 (blocking): merge conflict with `origin/main` in the pin module; after the merge, the `.claude/skills/epic-orchestrate/SKILL.md` digest must be recomputed from the merged file (reviewer computed `2e67dae3dd5a015693696125374e341f8c21963f36145bcf5fa8265ff8be924e` from the `git merge-tree` result tree, which equals neither side's pin).
- AC9 CI confirmation on the PR head is pending-CI and is not a finding.

### Approved Exceptions
- Fail-before exception dossier `evidence/regression-testing/fail-before-exception.2026-11-08T17-25.md`.

### Removed/Skipped Tests
None.

---

## 9. Summary of Changes

Cycle 1 added the `NESTING_DEPTH_INSUFFICIENT:` halt sentence to four coordinator agents and their bundle copies, a contract `It` for it, the `epic-orchestrator.md` pin re-baseline, an Int64 parse in the helper and its bundle copy, and two test values.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

No policy violation was found in the branch content. The review verdict is REMEDIATION_REQUIRED because of code-review finding F2 (base drift merge conflict), recorded in `remediation-inputs.2026-11-08T18-49.md`.

**Fail-closed reminder:** All required baseline, QA, and coverage artifacts were present.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

**For Python:**
- PASS Test-only edits, static checks clean

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 20110/20120 Pester tests passing (10 skipped); 16560 pytest passing (6 skipped)
- PASS 95.64% PowerShell line coverage; 97.11% Python line coverage
- PASS Proper file organization
- PASS All code quality checks on the branch content

---

### Recommendation

**Merge `origin/main`, resolve the pin conflict by recomputing both digests from the merged files, re-run the gates, then re-review.**

---

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` (new; cycle 1 added two values)
- `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1` (new; cycle 1 added one `It`)
- `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (setup-only seam mock)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (pin re-baseline, extended in cycle 1)
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (heading count 16 to 17)

## Appendix B: Toolchain Commands Reference

PowerShell: PoshQC format and analyze with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `Invoke-PoshQCLeakScan`, and `Invoke-PoshQCParallelTest`. Python: Black `--check`, Ruff, Pyright, and `pytest -n auto --cov --cov-branch`. As recorded in the cycle-1 QA-gate evidence artifacts. Reviewer checks: `git merge-tree --write-tree --name-only origin/main HEAD`, `cmp` of live and bundle copies, coverage JSON comparison, and a real-process probe of the helper.
