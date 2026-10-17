# Policy Compliance Audit: Issue #928 — SubagentStop validator uncaught error exits 1 (re-audit after remediation cycle 3)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T07-53, UTC, `date -u` at write time)
**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main` @ `a880c46b919ca58b1144a925d54488ce51f02bfb`; merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (the branch is 34 commits ahead and 55 behind; see PA-N2)
**Head reviewed:** `a210f5cf92fbbc09679dab9fa3b2756538b076f0` (pushed; `git ls-remote` equals `HEAD`; PR #954 open against `main`)
**Code head:** `b43188f8377b5c2bbbfd5484f52b7fc226876353` (`a210f5cf9` adds only `spec.md` checkbox edits and one evidence file; `git diff --name-status b43188f83 a210f5cf9` by this review)
**Review scope:** full branch diff `5bc97774..a210f5cf` (140 files, +4849/-51), not only remediation cycle 3
**Work mode:** `full-bug` (`issue.md` line 12; AC source: `spec.md`, section `## Acceptance Criteria`, AC1-AC16)
**Code Under Test:** eight SubagentStop validators under `.claude/hooks/` (tail `try`/`catch` plus one `.NOTES` sentence each), `.claude/hooks/subagentstop-envelope.ps1` (citation only), `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment only), new suite `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` (159 lines), three edited Pester files, the Python test-support module `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (cycle 3 digest re-baseline), four Markdown documentation corrections, and byte-identical bundle mirrors.
**Prior review:** `policy-audit.2026-10-16T06-36.md` (head `2f6b9600`); CI-failure inputs `remediation-inputs.2026-10-16T07-05.md`; remediation plan `remediation-plan.2026-10-16T07-05.md`.

## Total Blocking Findings: 2

Both blocking findings concern the local coverage artifacts that the review procedure and the `validate-feature-review-coverage.ps1` SubagentStop gate evaluate. Neither indicates a coverage defect in the code:

- PA-B1 (PowerShell): `artifacts/pester/powershell-coverage.xml` reports 52.00% repo-wide line coverage (6387/12283). This is below the 85% floor, so the verdict is FAIL. The file comes from a local run scoped to two test folders. The PR-head CI artifact for the same PowerShell code reports 90.45%.
- PA-B2 (Python): `artifacts/python/lcov.info` is absent. The procedure rule "coverage artifact absent for Python; coverage verification is mandatory for all languages with changed files" applies, so the verdict is FAIL. The PR-head CI run reports 93.72% lines, and its 85/75 threshold step passed.

An initial draft of this audit substituted the CI artifacts for the local ones and recorded PASS. The SubagentStop gate rejected that draft, and the substitution is not the defined verification model, so the verdicts were corrected to FAIL. The local artifacts were not overwritten to satisfy the gate.

The prior PA-B1 (`awaiting_ci`; AC14 coverage clause) is resolved as an acceptance-criterion matter by the CI coverage artifact of the code head `b43188f`, recomputed by this review. The CI-failure finding CI-1 (frozen epic-surface digests) is resolved by remediation cycle 3.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production (`.claude/hooks`) + 10 mirrors + 4 test files | 13 in new suite (U1 x9, U1-ST x2, U2, probe); scoped suites total 5334 | PASS (CI `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` success on `b43188f`; local 5334 run, 0 failed) | CI main run 38730332356: ten changed files 99.12% (901/909) | Local `artifacts/pester/powershell-coverage.xml`: repo 52.00% lines (6387/12283), FAIL (PA-B1; partial-scope run). CI PR run 38867388618 on `b43188f`: repo 90.45% lines (16434/18170); ten changed files 99.13% (909/917), each 98.08%-100.00% | 100% of new catch lines (8/8 covered; none in any missed list) |
| Python | 1 test-support file (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`); 0 production files | 50 local (`test_parallel_orchestrator_surface_contracts.py`, `test_push_down_claude_resource_contracts.py`); CI 7110 passed | PASS (CI `quality-checks7` 3.10-3.13 success on `b43188f`) | Merge-base CI job 116822909085 (3.12, commit `5bc97774`) TOTAL: 93.72% lines (16530/17638); 6368 branches, 504 partial; 92% combined | Local `artifacts/python/lcov.info`: absent, FAIL (PA-B2). CI job 116863252017 (3.12) TOTAL: 17638 statements, 1108 missed; 6368 branches, 504 partial; 92% combined; `check_python_coverage_thresholds --min-line 85 --min-branch 75` passed | 100.00% vacuously (0/0 changed production lines); the changed test-support file is excluded from measurement by configuration |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 4 documentation files + 3 mirrors, feature documents | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/remediation-baseline/poshqc-coverage.2026-10-16T04-51.md` (ci-main `poshqc-test-results`); original baseline `evidence/baseline/poshqc-coverage.2026-10-16T01-32.md`
- PowerShell post-change coverage artifact: CI run 38867388618 artifact `poshqc-test-results/powershell-coverage.xml` (PR head `b43188f`), summarized in `evidence/qa-gates/s9-ci-coverage.2026-10-16T07-48.md` and recomputed by this review from a fresh download
- Python baseline coverage artifact: merge-base CI job 116822909085 (`quality-checks7 / Code Quality & Tests (3.12)`, commit `5bc97774`) coverage report: 93.72% lines (16530/17638), 92% combined; the changed test-support file is omitted from measurement by `pyproject.toml` `[tool.coverage.run] omit`
- Python post-change coverage artifact: CI job 116863252017 (`quality-checks7 / Code Quality & Tests (3.12)`, run 38867388618) coverage report and threshold step; local `artifacts/python/lcov.info` is absent (FAIL, PA-B2)
- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch converts an unhandled terminating error in the validation call of eight SubagentStop validators from process exit 1 (which does not block a SubagentStop event) into `Exit-SubagentStopBlock` (exit 2 with a stderr reason). Each change is a two-line `try`/`catch` at the script tail after the S1 dependency tail, following the precedent in `validate-feature-review-coverage.ps1:202-203`.

Remediation cycle 3 (commit `b43188f8`) re-baselined the two frozen epic-surface digests in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`, lines 171-180; digests at lines 174 and 178) and appended a `RE-BASELINED by issue #928` entry to the comment block (lines 165-170), following the precedent entries. This review computed `sha256sum` of `.claude/agents/epic-orchestrator.md` (`c5b50974...d96d`) and `.claude/skills/epic-orchestrate/SKILL.md` (`b7af3a42...b83f`); both equal the new pins. `git diff --name-status e03d60829 HEAD` lists the expectations module, `spec.md`, and feature-folder Markdown only.

At S9, CI on `b43188f` reported 20 of 20 checks as success (`gh api .../commits/b43188f.../check-runs` by this review). The orchestrator checked off AC14 and AC15 in `a210f5cf9`. This review verified both check-offs against the CI coverage artifact and the check-run list (section 8.1).

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` (coverage clause only, on the local artifacts; PA-B1, PA-B2)
- PASS `.claude/rules/quality-tiers.md` (`.claude/hooks` is T3; no new project)
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (code change and unit test)
- PASS `.claude/rules/python.md` (one test-support module; Black, Ruff, and Pyright clean)
- N/A TypeScript, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (regenerated by this review at 2026-10-16 07:52:36 UTC for head `a210f5cf9`, base `origin/main` @ `a880c46b`, merge base `5bc97774`), `issue.md`, `spec.md`, `plan.2026-10-15T15-44.md`, the three remediation plans, the prior review set (`*.2026-10-16T06-36.md`), `remediation-inputs.2026-10-16T07-05.md`, and the `evidence/` tree.

**Temporary artifacts cleanup:**
- PASS No temporary files are committed. `git status --porcelain` is empty at `a210f5cf9`. The `SCRATCH/928/` token in evidence artifacts refers to session scratchpad helpers; no such path appears in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller prompt asked for a full-branch review against `origin/main`. It also asked that CR-N5, CR2-N1, CR2-N2, CR2-N5, CR3-N1, and CR3-N2 be recorded as accepted decisions, and that the `validate-planner-output.ps1` citation-path observation be recorded as out-of-loop. None of these requests removes a file of the branch diff from scope or waives a coverage or toolchain check. The caller's statement that the prior F1 "should now be resolved" was verified independently rather than accepted (section 8.1). The audit covered the full branch diff `5bc97774..a210f5cf`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (run by this review).
- No path in `git diff --name-only origin/main...HEAD` is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (checked by this review).
- Cycle-3 evidence is under `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and `evidence/other/`, all canonical kinds in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base. `.claude/hooks` is classified T3. The branch adds no project. T3 requires no property tests and no mutation score. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | `Invoke-ValidatorUnderTest` saves and restores `[Console]::In`, `[Console]::Error`, `$script:HookDependencyFailures`, `$script:HookDependencyGuardLoadFailed`, and `$global:LASTEXITCODE` in `finally` (test file lines 52-95). Unchanged since the prior review. |
| Isolation | PASS | Each U1 and U1-ST row exercises one validator's unhandled-error path; U2 is a separate completeness test. The digest test is parametrized per frozen file. |
| Fast execution | PASS | In-process `&` route; the two Python suites ran in 0.70 s locally (50 passed). |
| Determinism | PASS | No clock, RNG, or network use; envelope is a fixed JSON literal; digests are content hashes. |
| Readability | PASS | `.SYNOPSIS`/`.DESCRIPTION` header, Arrange-Act-Assert comments, `-Because` messages that print actual stderr; the re-baseline comment states cause and scope. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell) | FAIL (Blocking, PA-B1) | Local `artifacts/pester/powershell-coverage.xml`: 52.00% (6387/12283) line coverage; partial-scope run over `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`. For context, the CI run 38867388618 `powershell-coverage.xml` (PR head `b43188f`) reports 90.45% (16434/18170), recomputed by this review. |
| Line >= 85% per modified file (PowerShell) | PASS | Recomputed by this review: discovery 100.00% (64/64), executor 98.33% (118/120), orchestrator 99.10% (110/111), planner 99.50% (200/201), pr-author 100.00% (33/33), prd-feature 100.00% (66/66), required-artifact 98.39% (61/62), task-researcher 98.08% (102/104), subagentstop-envelope 100.00% (60/60), enforce-epic-wave-barrier 98.96% (95/96). |
| No regression on changed lines (PowerShell) | PASS | Each file is at or above its ci-main baseline (`s9-ci-coverage.2026-10-16T07-48.md`). Missed lines (executor 83, 180; orchestrator 235; planner 158; required-artifact 96; task-researcher 217, 276; wave-barrier 380) are pre-existing lines, not changed lines; every catch line (253, 322, 344, 440, 129, 118, 199, 290) is covered. |
| Branch >= 75% (PowerShell) | N/A | Pester measures no branch coverage (`.claude/rules/powershell.md`); no branch gate applies. |
| Python coverage artifact present | FAIL (Blocking, PA-B2) | `artifacts/python/lcov.info` is absent at review time; coverage verification is mandatory for all languages with changed files. |
| Line >= 85% / Branch >= 75% repo-wide (Python, CI) | PASS | CI job 116863252017 TOTAL 17638 statements, 1108 missed (93.72% lines); 6368 branches, 504 partial; 92% combined. The threshold step `check_python_coverage_thresholds --min-line 85 --min-branch 75` passed (job conclusion success on `b43188f`). |
| Per-file Python thresholds | PASS | No production Python file changed. The one changed file is under `tests/`, which `pyproject.toml` omits from measurement (permitted exclusion under the Coverage Exclusion Policy); the CI coverage report contains 0 rows for it. |
| Positive / negative / edge | PASS | Script-terminating error for all nine validators (U1); statement-terminating .NET exception for the two default-preference validators (U1-ST); characterization row for the already-compliant validator; completeness row (U2). Digest pin: fail-before (2 failed, `digest-fail-before-cycle3.2026-10-16T07-20.md`) and pass-after. |
| Coverage exclusion policy | PASS | No coverage configuration file is in the diff. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: ten changed files 99.12% (901/909, ci-main 38730332356) -> Post-change: 99.13% (909/917, CI PR run 38867388618). Change: +0.01 points aggregate; per file +0.00 to +0.03. Repo-wide post-change 90.45% (CI); local artifact 52.00% (partial scope). New/changed-code coverage: 100.00% (8/8 new catch lines covered). Disposition: FAIL (Blocking, PA-B1) on the local artifact's repo-wide line coverage; per-file and changed-line figures from CI pass. Evidence: `evidence/qa-gates/s9-ci-coverage.2026-10-16T07-48.md`; recomputed by this review from a fresh `gh run download 38867388618 --name poshqc-test-results`.
- Python: Baseline: 93.72% lines (16530/17638), 92% combined (merge-base CI job 116822909085) -> Post-change: 93.72% lines (16530/17638), 92% combined, threshold step passed (CI job 116863252017). Change: +0.00 points; the changed file is outside the coverage source. New/changed-code coverage: 100.00% vacuously (0/0 changed production lines; test-support file excluded by configuration). Disposition: FAIL (Blocking, PA-B2) because the local coverage artifact `artifacts/python/lcov.info` is absent; the CI figures pass. Evidence: CI log of job 116863252017 (TOTAL line and threshold step), `pyproject.toml` `[tool.coverage.run]`.
- TypeScript: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | Explicit `# Arrange`, `# Act`, `# Assert` sections in U1, U1-ST, and U2. |
| Actionable assertion messages | PASS | U1 and U1-ST print actual stderr on prefix mismatch; U2 prints the set difference; the digest test prints expected and found SHA-256 (`remediation-inputs.2026-10-16T07-05.md`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | `test-file-constraints.2026-10-16T05-22.md`: banned-token count 0. The Pester suite is unchanged since; the cycle-3 change edits constants and a comment only. |
| Test file location | PASS | `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`; `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (existing file). |
| File size <= 500 lines | PASS | `wc -l` by this review: `validate-planner-output.ps1` 442, `parallel_orchestrator_surface_expectations.py` 387, new suite 159. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 baselines exist under `evidence/baseline/`; cycle 3 baselines exist under `evidence/remediation-baseline/` (`phase0-instructions-read`, `git-state`, `frozen-digests-cycle3`, `pin-site-survey-cycle3`, `black`/`ruff`/`pyright`/`pytest-dev-tools` cycle 3).

### 2.2 Design Principles

PASS. The production change is the minimal per-validator tail wrapper. The cycle-3 change updates two string constants and documents the cause, matching the four precedent entries in the same comment block.

### 2.3 Module & File Structure

PASS. No new production module. All changed non-Markdown files are at most 442 lines.

### 2.4 Naming, Docs, and Comments

PASS. One `.NOTES` sentence per validator. The `RE-BASELINED by issue #928` entry names the edited line ranges and states that the pin stays live for both entries.

### 2.5 After Making Changes - Toolchain Execution

PASS.

- PowerShell (last code-bearing pass, cycle 1): format MCP ok (`poshqc-format.2026-10-16T05-27.md`), analyze MCP ok (`poshqc-analyze.2026-10-16T05-28.md`), test MCP ok, 5334 tests, 0 failures (`poshqc-test.2026-10-16T05-39.md`). No PowerShell file changed afterwards. CI `poshqc` jobs succeeded on `b43188f`.
- Python (cycle 3): Black, Ruff, Pyright, and the target and dev-tools pytest runs are recorded (`black-cycle3`, `ruff-cycle3`, `pyright-cycle3`, `pytest-target-cycle3`, and `pytest-dev-tools-cycle3.2026-10-16T07-26.md`, 7021 passed, 0 failed). This review re-ran `black --check` (exit 0), `ruff check` (exit 0), and `pyright` (0 errors, 0 warnings) on the changed file, and `pytest` on the two contract suites (50 passed).
- Architecture boundary, contract, and integration stages: no boundary, schema, or adapter changed.

### 2.6 Summarize and Document

PASS. `spec.md` AC14 and AC15 are checked off with evidence. `issue.md:11` `Last Updated: 2026-10-15` remains (CR3-N2, accepted).

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | PASS | `poshqc-format.2026-10-16T05-27.md`; CI `poshqc / PowerShell QC` success. |
| PSScriptAnalyzer | PASS | `poshqc-analyze.2026-10-16T05-28.md`: no finding. |
| Fail-closed hook policy | PASS | Each catch calls `Exit-SubagentStopBlock` with a message that always contains the non-empty S1 prefix (discovery :253, executor :322, orchestrator :344, planner :440, pr-author :129, prd-feature :118, required-artifact :199, task-researcher :290). |
| Bundle mirror parity | PASS | `cmp` by this review at `a210f5cf9`: all 12 changed `.claude` files are byte-identical to `extensions/drm-copilot/resources/claude-customizations/`; the `.agents` skill is byte-identical to its `codex-and-agents-customizations` mirror. `test_push_down_claude_resource_contracts.py` passed (included in the 50). |
| Excluded paths | PASS | `.codex`, the bundle `.codex`, both `settings.json` files, and `validate-feature-review-coverage.ps1` are not in the branch file list. |

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black | PASS | `black --check` exit 0 (this review). |
| Ruff | PASS | `ruff check` exit 0 (this review). |
| Pyright | PASS | 0 errors, 0 warnings (this review). |
| Pin correctness | PASS | `sha256sum` of both frozen files equals the new pins (this review). |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5, data-driven rows | PASS | `-ForEach $script:ValidatorRows` and `-ForEach $script:StatementTerminatingRows`, built in `BeforeDiscovery`. |
| Mocks at the I/O boundary | PASS | `Mock Read-SubagentStopEnvelope`, `Mock Import-Module`; `Should -Invoke ... -Times 1 -Exactly`. |
| Epic-state isolation guard (#737) | PASS | Baseline seam mocks in `BeforeAll`; interception probe inside an `It`. |
| Fail-before / fail-after | PASS | `fail-before.2026-10-16T02-03.md`, `lastexitcode-fail-before.2026-10-16T05-10.md`, `poshqc-test.2026-10-16T05-39.md` (13 passed). U1-ST rows are characterization rows (CR2-N1, accepted). |
| Updated existing tests | PASS | REG-4 and E-RA-10 expect two `Exit-SubagentStopBlock` calls. |

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail-before evidence | PASS | `digest-fail-before-cycle3.2026-10-16T07-20.md`: exactly the two CI-1 node IDs failed. |
| Pass-after evidence | PASS | `pytest-target-cycle3.2026-10-16T07-25.md`; `pytest-dev-tools-cycle3.2026-10-16T07-26.md` (fail set empty); CI `quality-checks7` 3.10-3.13 success. |
| Pin remains live | PASS | The pinned-digest test still parametrizes both entries (50 passed locally includes them). |

## 5. Test Coverage Detail

### subagentstop-uncaught-error.Tests.ps1 (13 tests)

Not measured (test file). The suite executes the new catch line of each of the eight changed validators; all eight catch lines are covered in the CI PR-head report.

### parallel_orchestrator_surface_expectations.py

Not measured (test-support file under `tests/`, omitted by configuration).

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New Pester suite | 13 passed, 0 failed |
| Full scoped Pester suites | 5334 tests, 0 failures |
| Python contract suites (this review) | 50 passed |
| Python dev-tools suite (cycle 3) | 7021 passed, 6 skipped, 0 failed |
| CI on `b43188f` | 20 of 20 checks success |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format / analyze / test | ok / no finding / 0 failures |
| Black / Ruff / Pyright | clean |
| PowerShell coverage (85% line), local artifact | FAIL (52.00% repo, partial scope; PA-B1). CI: 90.45% repo; 98.08%-100.00% per changed file |
| Python coverage (85% line, 75% branch), local artifact | FAIL (artifact absent; PA-B2). CI: threshold step success |

## 8. Gaps and Exceptions

### 8.1 Prior Findings Disposition

| Prior finding | Status | Evidence (verified by this review) |
|---|---|---|
| PA-B1 / CR-B1 / FA-B1 (F1, `awaiting_ci`: PowerShell coverage and AC14 coverage clause) | Resolved | Fresh download of CI run 38867388618 `poshqc-test-results` (PR head `b43188f`): repo 90.45%, ten changed files 909/917 (99.13%), each >= 98.08% and >= baseline, catch lines covered. Matches `s9-ci-coverage.2026-10-16T07-48.md`. |
| CI-1 (frozen epic-surface digests, `remediation-inputs.2026-10-16T07-05.md`) | Resolved | New pins equal current `sha256sum`; local pytest 50 passed; CI `quality-checks7` 3.10-3.13 success on `b43188f`. |
| CR-N5 (literal halt sentence in four validators) | Accepted (orchestrator decision) | Literals unchanged at discovery :253, pr-author :129, prd-feature :118, task-researcher :290. |
| CR2-N1 (U1-ST rows not run against pre-fix validators) | Accepted (orchestrator decision) | Characterization rows. |
| CR2-N2 (uneven rewrap, `subagentstop-envelope.Tests.ps1:9-11`) | Accepted (orchestrator decision) | Widths within limits. |
| CR2-N5 (`validate-bash.ps1` exit 1 fail-open) | Accepted as unrelated (orchestrator decision) | File not in the branch diff. |
| CR3-N1 (`remediation-plan.2026-10-16T06-40.md` stamp later than its commit) | Accepted (orchestrator decision) | No change required for this item. |
| CR3-N2 (`issue.md:11` `Last Updated: 2026-10-15`) | Accepted (orchestrator decision) | Still `2026-10-15` at `a210f5cf9`. |

### 8.2 Identified Gaps

- **PA-B1 (Blocking, Remediability: autonomous): local PowerShell coverage artifact below the repo-wide floor.**
  - `artifacts/pester/powershell-coverage.xml` (local, written 2026-10-16 05:38 UTC) reports 52.00% repo-wide line coverage (6387/12283), below 85%.
  - The run was scoped to `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`. Six changed hooks are absent from it: executor, pr-author, prd-feature, required-artifact, task-researcher, and subagentstop-envelope.
  - No PowerShell file changed after that run, so the shortfall comes from the run's scope, not from the code. The CI artifact for the same PowerShell code (run 38867388618) reports 90.45% repo-wide and 98.08%-100.00% for each changed file.
  - Resolution: regenerate `artifacts/pester/powershell-coverage.xml` with a full-scope PoshQC coverage run at the code head and re-run the review. Alternatively, the operator may accept the PR-head CI artifact as the coverage source of record; that decision is outside this reviewer's authority.
- **PA-B2 (Blocking, Remediability: autonomous): local Python coverage artifact absent.**
  - `artifacts/python/lcov.info` does not exist. The branch changes one Python file, a test-support module under `tests/` that coverage configuration excludes.
  - The CI run on `b43188f` reports 93.72% lines, and its `--min-line 85 --min-branch 75` threshold step passed.
  - Resolution: generate `artifacts/python/lcov.info` with `poetry run pytest --cov --cov-branch` (the `pyproject.toml` `addopts` writes the lcov report) at the code head and re-run the review, or apply the same operator decision as PA-B1.
- **PA-N1 (Non-blocking, Info): CI re-run on head `a210f5cf9` was in progress at review time.** `gh pr checks 954` at 2026-10-16 07:50 UTC listed 12 checks passed and 8 pending (`poshqc` x2, `quality-checks7` x4, `shell-coverage`, `Publish to Marketplace`). `a210f5cf9` changes only `spec.md` lines 219-220 and adds `evidence/qa-gates/s9-ci-coverage.2026-10-16T07-48.md` relative to the all-green `b43188f`, so no code-level outcome change is expected. Per the CI-dependent criteria protocol, the orchestrator must re-run the CI green gate so that `ci_gate.head_sha` equals the final PR head before DONE.
- **PA-N2 (Non-blocking, Info): branch is 55 commits behind `origin/main`.** `gh pr view 954` reports `mergeStateStatus: BEHIND`, `mergeable: MERGEABLE`. None of the 186 files changed on `main` since the merge base overlaps the branch file list. `main` changed no `.claude/hooks/` file, no `tests/scripts/claude-hooks/` file, and neither frozen epic surface. `git grep` on `origin/main` finds the same nine hooks that dot-source `subagentstop-envelope.ps1`, so U2 and the digest pins remain valid after an update. Update the branch from `main` before merge and re-run the CI gate on the resulting head.

### 8.3 Out-of-Loop Observation (accepted; not a finding of this branch's diff)

- `.claude/hooks/validate-planner-output.ps1:186` requires a citation path to contain at least one `/` (`(?:/[^/\\|\s]+)+`), so a `CITATION:` record naming a root-level file such as `CLAUDE.md` is rejected. The line is pre-existing: this branch changes only lines 33 and 439-440 of the file. The issue was noted during cycle 3 planning. The loop guard (three completed remediation attempts) prevents another cycle; record for separate follow-up.

### Approved Exceptions

None. The accepted decisions in section 8.1 are design or scope choices, not exceptions to a policy.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch

34 commits ahead of the merge base: the original delivery, two merges of `origin/main`, remediation cycles 1-3, the review artifact sets, the CI-failure inputs (`fa84f1641`), the cycle-3 digest re-baseline (`b43188f83`), and the S9 AC check-off (`a210f5cf9`).

### Files Modified

- Eight validators under `.claude/hooks/` and their bundle mirrors
- `.claude/hooks/subagentstop-envelope.ps1` and `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment-help text only) and mirrors
- `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md`, and mirrors where applicable
- `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` (new); three edited Pester files
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (two pinned digests and one comment entry)
- Feature folder documents and evidence (Markdown)

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT (local coverage artifacts only)

### Policy-by-Policy Summary

- General Unit Test Policy: FAIL on the coverage clause as evaluated against the local artifacts (PA-B1, PA-B2); all other items PASS
- General Code Change Policy: PASS
- PowerShell code change and unit test policy: PASS
- Python code change and unit test policy: PASS
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Tonality: PASS

### Metrics Summary

PowerShell local artifact 52.00% (partial scope), CI 90.45% repo and 99.13% (909/917) on changed files. Python local artifact absent; CI threshold step passed (93.72% lines). 2 blocking findings (PA-B1, PA-B2; both autonomous, artifact state only), 2 non-blocking findings (Info). The prior awaiting_ci item and CI-1 are resolved, six prior items are accepted per orchestrator decision, and one out-of-loop observation is recorded.

### Recommendation

Regenerate the local PowerShell (full scope) and Python coverage artifacts at the code head and re-run the review. No code change is indicated. Because the remediation loop guard has been reached, the operator may instead accept the PR-head CI artifacts as the coverage source of record. Before reporting DONE, confirm that the CI re-run on the final PR head succeeds. If branch protection requires an up-to-date branch, update from `main` first and gate on the resulting head.

---

## Appendix A: Test Inventory

| Test file | Tests | Change | Result |
|-----------|-------|--------|--------|
| `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | probe, U1 x9, U1-ST x2, U2 | New | 13 passed |
| `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` | REG-4 x4 (edited) | Expected call count 1 to 2 | passed |
| `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1` | E-RA-10 (edited) | Expected call count 1 to 2 | passed |
| `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | header comment only | Citation | passed |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | pinned-digest test (2 params) | Data module edited | passed (this review) |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | unchanged | Bundle parity | passed (this review) |

## Appendix B: Toolchain Commands Reference

| Stage | Command | Evidence |
|-------|---------|----------|
| Format (PowerShell) | `mcp__drm-copilot__run_poshqc_format` | `evidence/qa-gates/poshqc-format.2026-10-16T05-27.md` |
| Lint (PowerShell) | `mcp__drm-copilot__run_poshqc_analyze` | `evidence/qa-gates/poshqc-analyze.2026-10-16T05-28.md` |
| Unit tests (PowerShell) | `mcp__drm-copilot__run_poshqc_test` | `evidence/qa-gates/poshqc-test.2026-10-16T05-39.md` |
| Format / lint / type (Python) | `poetry run black --check`, `poetry run ruff check`, `poetry run pyright` on the changed file | Run by this review, all clean |
| Unit tests (Python) | `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | Run by this review, 50 passed |
| Coverage (PowerShell) | JaCoCo LINE parse of CI run 38867388618 `powershell-coverage.xml` | `evidence/qa-gates/s9-ci-coverage.2026-10-16T07-48.md`; recomputed by this review |
| Coverage (Python) | CI `pytest --cov --cov-branch` and `check_python_coverage_thresholds --min-line 85 --min-branch 75` | CI job 116863252017 log |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | Run by this review, exit 0 |
| PR context | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main` | Run by this review, exit 0 |

## Appendix C: Assumptions

- The timestamp `2026-10-16T07-53` is UTC (`date -u` at write time) and sorts after every earlier review, plan, and evidence artifact in the feature folder.
- Coverage was assessed from existing local artifacts (the verdict source) and existing CI artifacts (context); coverage generation was not rerun, and no local artifact was modified.
- `a210f5cf9` is treated as code-equivalent to `b43188f` for coverage and CI purposes because the only differences are Markdown under the feature folder (verified by `git diff --name-status b43188f83 a210f5cf9`).
