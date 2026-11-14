# Policy Compliance Audit: cd-chained-command-recurring-deny (Issue #1165)

**Audit Date:** 2026-11-10
**Code Under Test:** merge base `ff9d8afc0a61ac723cd449b0c0658ea42680cd2e` of the base branch `main` and reviewed head `eaf42f48d8792c7099ef5c411025d43413f0dca2` on branch `bug/cd-chained-command-recurring-deny-1165`; the diff between them lists 50 changed files (2439 insertions, 31 deletions).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 12 files (8 production incl. 4 bundle mirrors, 4 test) | 21311 tests | ✅ 21301 pass, 0 fail, 10 skipped | 95.79% lines | 95.80% lines | 100.00% |
| Python | 3 files (test-only) | 8852 tests | ✅ 8852 pass, 0 fail, 6 skipped | 0% lines - no lcov artifact recorded for this branch | 0% lines - no lcov artifact recorded for this branch | 0% - no Python production file changed; no lcov artifact |
| JSON | 2 files | N/A | ✅ pack-manifest contract tests pass | N/A (config files) | N/A (config files) | N/A |
| Markdown | 33 files | N/A | ✅ surface contract tests pass | N/A (documentation) | N/A (documentation) | N/A |

The Python row records 0% because the required artifact `artifacts/python/lcov.info` does not exist in the item worktree; the value is the fail-closed reading, not a measured figure (finding PA-1).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files on the branch
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files on the branch
- PowerShell baseline coverage artifact: `docs/features/active/cd-chained-command-recurring-deny-1165/evidence/baseline/pester-gate.2026-11-10T00-26.md` (Phase 0 figures quoted in the final gate record)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (item worktree, written 2026-11-10T00:52Z), summarized in `docs/features/active/cd-chained-command-recurring-deny-1165/evidence/qa-gates/pester-gate.2026-11-10T00-54.md`
- Per-language comparison summary: section 1.2.1 of this audit

Baseline coverage is read from the plan's `Phase 0 baseline` artifact. The PowerShell artifact was parsed directly by the reviewer (JaCoCo root LINE counter covered 37557, missed 1646).

---

## Executive Summary

The branch changes guidance only: a new pure PowerShell helper `.claude/hooks/bash-command-shape-guidance.ps1` selects intent-specific rewrite text for the cd-chained deny of `.claude/hooks/validate-bash.ps1`; a launch-loaded rule `.claude/rules/bash-command-shape.md` and its Codex skill and Copilot instruction equivalents carry the intent-to-form table; the six `execution-environment` brief copies gain a preferred-forms table; the `WORKTREE_VENV_BLOCKED:` reason gains a `poetry -C` form; and `parallel-orchestrate` replaces a hook-denied `reset --hard` with `reset --keep`. The allow/deny decision set is unchanged.

The reviewer verified the following directly at head: all 13 mirror pairs are byte-identical (`git rev-parse HEAD:<path>` blob identity); 145 touched pytest cases pass under `pytest -n auto`; `generate_codex_agent_variants.py --check` exits 0; `validate_evidence_locations.py --root` exits 0; `git merge-tree` against `origin/main` is clean; the Pester coverage artifact shows 100% line coverage for the new helper and no change to the uncovered lines of `validate-bash.ps1`; a direct-call probe of 17 command shapes reproduced each intent reason named in the spec.

Two blocking findings, both `autonomous` and evidence-only. PA-1: the Python coverage artifact `artifacts/python/lcov.info` is absent although the branch changes three Python test files. PA-2: the Stop-hook freshness gate rejects the PowerShell coverage artifact because it predates the commit. The reviewer confirmed from file modification times that the artifact measured the head content.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (test-only Python changes)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no `.sh` or `.bats` file in the branch diff
- ✅ JSON: pack manifests validated by the push-down manifest contract tests

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; the executor's helper scripts lived under the issue SCRATCH directory outside the repository tree (`git status --short` is clean at head).
- ✅ No new tooling script was added to the repository.
- Reviewer probe scripts (`cov1165.py`, `probe1165.ps1`) live in the session scratchpad outside the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Both new Pester files dot-source the hook inside `BeforeAll` and use in-memory strings; the full suite ran sharded across 8 workers with 0 failures, and `Invoke-PoshQCLeakScan` reported 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | `bash-command-shape-guidance.Tests.ps1` (22 tests) targets the two helper functions; `validate-bash.CdChainGuidance.Tests.ps1` separates the decision-regression Context (60 rows) from the reason-shape Context (8 tests). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The 145 touched pytest cases ran in 7.52 s; the new Pester files are pure string tests. |
| **Determinism** - Consistent results | ✅ PASS | No clock, network, process, or file access in the new tests; fixtures are literal strings. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Table-driven `-ForEach` rows with `-Because` messages; Python tests carry docstrings stating intent. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.79% lines (covered 37491, missed 1646) from the Phase 0 run<br>**Command:** `Invoke-PoshQCParallelTest`<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-10T00-26.md`<br>**Timestamp:** 2026-11-10 00:26 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.80% lines<br>**Change:** +0.01% lines<br>**Status:** No regression; `validate-bash.ps1` 94.17% to 94.23%, both venv policy copies 100% to 100%. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% line (root `CLAUDE.md` states no threshold; defaults govern; Pester has no branch gate)<br>**Status:** `validate-bash.ps1` 94.23%, `bash-command-shape-guidance.ps1` 100%, both `worktree-poetry-venv-policy.ps1` copies 100%. |
| **New Code Coverage ≥90%** | ✅ PASS | **New file:** `.claude/hooks/bash-command-shape-guidance.ps1` 65 of 65 lines = 100%<br>**Changed lines:** `validate-bash.ps1` lines 48-49 and 345 are not in the JaCoCo missed set (missed lines 320, 443, 445, 446, 447, 450 are pre-existing entry-point tail and a sed-branch continue). |
| **Comprehensive Coverage** | ✅ PASS | `Get-CdChainedToolMention`, `Get-CdChainedCommandIntent`, `Get-CdChainedRewriteGuidance` each exercised by direct tests and through `Get-BashBlockReason`. |
| **Positive Flows** - Valid inputs | ✅ PASS | Plain read, git, poetry, npm, npx, and multi-step intents asserted by exact substrings. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Empty and `$null` command input return a defined intent without an exception; null intent to the guidance function returns the plain-read text. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Wrapper-led raw leg (`bash -c "cd /x && git log ..."`), tool behind `env`, path-component and hyphenated tool mentions, CdTarget from both legs. |
| **Error Handling** - Error paths | ✅ PASS | The helper load failure path is covered by `hook-dependency-guard-completeness.Tests.ps1` (731 of 731). |
| **Concurrency** - If applicable | N/A | Pure string functions with no shared state. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.79% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.80% lines. Change: +0.01% lines. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester-gate.2026-11-10T00-54.md`, `evidence/baseline/pester-gate.2026-11-10T00-26.md`.
- Python: Baseline: 0% lines (no lcov artifact recorded for this branch) -> Post-change: 0% lines (no lcov artifact recorded for this branch). Change: none measurable. New/changed-code coverage: 0% (no Python production file changed; no artifact to read). Disposition: FAIL. Evidence: `artifacts/python/lcov.info` absent in the item worktree; `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` records a run without `--cov`; merge-base CI run 42703258177 step `Enforce Python coverage thresholds` succeeded.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Every reason-shape assertion carries `-Because "the <intent> reason names <token>"`; Python assertions join defect lists into the message. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Rows supply inputs, one call acts, assertions follow. |
| **Document Intent** | ✅ PASS | File-level `.SYNOPSIS`/`.DESCRIPTION` blocks and descriptive `It` names. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, process, or database use. Python surface tests read committed repository files, the established pattern of the existing contract suites. |
| **Use Mocks/Stubs** | N/A | Pure functions need no mocks. |
| **Environment Stability** | ✅ PASS | No temporary files; no global state beyond script-scope constants loaded in `BeforeAll`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the pre-submission policy review; PA-1 is outstanding. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (issue #1165). |
| **Read existing change plans** | ✅ PASS | `research/research.2026-11-09T22-58.md`; plan `plan.2026-11-09T17-40.md`. |
| **Document the plan** | ✅ PASS | Plan and preflight-fix records under `evidence/other/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The hook change is two lines: a guarded dot-source and one concatenation replacing the final sentence. |
| **Reusability** | ✅ PASS | The helper reuses `Read-CommandLineSegment` and `Test-CommandLineSegmentRawScan` from `hook-command-scanner.ps1` instead of re-parsing. |
| **Extensibility** | ✅ PASS | Tool forms live in one table (`$toolForms`); adding a tool is a one-entry change plus the name list. |
| **Separation of concerns** | ✅ PASS | Detection stays in `Get-CdChainedReadCommandMatch`; the helper only builds text. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The helper holds only cd-chained guidance functions. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts: `validate-bash.ps1` 450, helper 178, venv policy 361, test files 135 to 630 (largest `test_execution_environment_brief_contracts.py` 630). No file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | Three functions, all consumed by the hook or tests. |
| **No circular dependencies** | ✅ PASS | The helper dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs (`Get-`), descriptive nouns. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on each function and the file. |
| **Comment why, not what** | ✅ PASS | Pattern comments state why path components are excluded. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` with `pssa.settings.psd1`<br>**Result:** 0 differences on 12 PowerShell files (`evidence/qa-gates/powershell-static.2026-11-10T00-38.md`); Python formatting in `evidence/qa-gates/python-static.2026-11-10T00-39.md` |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`<br>**Result:** 0 findings; Ruff clean per python-static record |
| **3. Type checking** | ✅ PASS | **Command:** Pyright per python-static record<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto tests/scripts/dev_tools`<br>**Result:** 21301 Pester pass, 8852 pytest pass, 0 failures |
| **Full toolchain loop** | ✅ PASS | Final static and test gates recorded in one pass after the last edit. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `eaf42f48d` message and `spec.md` status Implemented. |
| **Design choices explained** | ✅ PASS | Spec decisions D-1165-4, D-1165-5. |
| **Update supporting documents** | ✅ PASS | Brief copies, rule surfaces, and `parallel-orchestrate` updated. |
| **Provide next steps** | ✅ PASS | Spec `## Rollout & Follow-up` records D-1165-5 for the owner. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

No Python production file is added or modified (scope-check CHECK 1: "no .py outside tests/ added or modified"). The constraint "no new Python" in `issue.md` is met.

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on all three functions. |
| **Parameter validation** | ✅ PASS | `[AllowNull()][AllowEmptyString()]` on the optional inputs; `Mandatory` on required ones. |
| **ShouldProcess** | N/A | No state-changing function. |
| **Strict mode and error handling** | ✅ PASS | The guarded dot-source routes a load failure to `Add-HookDependencyFailure`. |
| **PSScriptAnalyzer** | ✅ PASS | 0 findings. |

### Section 3D: JSON Configuration Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Manifest entries sorted and complete** | ✅ PASS | One or two alphabetical insertions per manifest; `test_push_down_*_pack_manifest_completeness` and dependency-closure tests pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Coverage expectation** | ❌ FAIL | The coverage artifact `artifacts/python/lcov.info` is absent for this branch (PA-1). Merge-base CI `Enforce Python coverage thresholds` succeeded; the branch adds only test code, so the repo-wide total is expected to hold, but no local artifact exists. |
| **Focused unit tests** | ✅ PASS | Each test asserts one surface contract. |
| **Mocking sparingly** | ✅ PASS | No mocks. |
| **Organization** | ✅ PASS | Tests under `tests/scripts/dev_tools/`, following the existing contract-suite layout. |

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 5+ syntax** | ✅ PASS | `Describe`/`Context`/`It` with `BeforeAll`; `#Requires -Modules Pester 5.0.0`. |
| **Test location** | ✅ PASS | `tests/scripts/claude-hooks/` mirrors the existing hook test layout. |
| **Coverage** | ✅ PASS | New helper 100%; no changed-line regression. |

---

## 5. Test Coverage Detail

### bash-command-shape-guidance.ps1 (22 tests)

- `Get-CdChainedCommandIntent`: plain read, git, poetry behind `env`, npm, npx, multi-step, CdTarget on the walk leg and the raw leg, empty and `$null`.
- `Get-CdChainedRewriteGuidance`: zero, one, and several tools; null intent.
- `Get-CdChainedToolMention`: whole-word matching; path components and hyphenated words excluded.

### validate-bash.ps1 cd-chained guidance (68 tests)

- Decision regression corpus: 60 rows, identical outcome before (baseline run) and after the hook edit.
- Reason shape: 6 intents plus `reset --keep` allowed and `reset --hard` denied.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Skipped | Source |
|-----|-------|--------|--------|---------|--------|
| Pester full tree (executor) | 21311 | 21301 | 0 | 10 | `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` |
| pytest dev_tools (executor) | 8858 | 8852 | 0 | 6 | `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` |
| pytest touched modules (reviewer, head) | 145 | 145 | 0 | 0 | reviewer run, `pytest -n auto`, 7.52 s |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PowerShell format | PASS | `evidence/qa-gates/powershell-static.2026-11-10T00-38.md` |
| PowerShell lint | PASS | same record, 0 findings |
| Leak scan | PASS | 741 files, 0 failures |
| Python static (Black, Ruff, Pyright) | PASS | `evidence/qa-gates/python-static.2026-11-10T00-39.md` |
| Codex variant generator check | PASS | reviewer run, exit 0 |
| Evidence-location validator | PASS | reviewer run, exit 0 |
| Merge-tree against origin/main | PASS | reviewer run, exit 0 (base unchanged at `ff9d8afc0`) |

## CI Cross-check

No pull request exists for the branch yet, so no CI run exists at the reviewed head; outcomes below are from local evidence.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter differences, 0 analyzer findings | eaf42f48d | `evidence/qa-gates/powershell-static.2026-11-10T00-38.md` |
| poshqc / PowerShell QC | pass | 21301 passed, 0 failed; 95.80% lines | eaf42f48d | `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` |
| poshqc / PowerShell hook suites (Linux) | pass | named hook suites 0 failures (Windows run) | eaf42f48d | `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 8852 passed, 0 failed; Python total not measured locally | eaf42f48d | `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` |

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence is under `docs/features/active/cd-chained-command-recurring-deny-1165/evidence/<kind>/`.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope; the audit covers the full `ff9d8afc0..eaf42f48d` diff.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists; the new helper lies under the classified path `.claude/hooks`. No new project folder was added.

---

## 8. Gaps and Exceptions

### Identified Gaps

- PA-1 (blocking, `autonomous`): Python coverage artifact `artifacts/python/lcov.info` is absent although three Python test files changed. Remedy: one `env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch` run in the item worktree that writes `artifacts/python/lcov.info`, recorded append-only under `evidence/qa-gates/`, with the repo-wide line and branch figures.

- PA-2 (blocking, `autonomous`): the stop hook `validate-feature-review-coverage` rejects `artifacts/pester/powershell-coverage.xml` as stale, because it was written at 2026-11-10T00:52:23Z, before the only commit (`eaf42f48d`, 2026-11-10T01:07:06Z) that touches PowerShell files. The reviewer checked the content: every changed `.ps1` file was last modified between 00:27:24Z and 00:30:58Z, before the coverage write. The worktree is clean, and the branch has one commit. So the measured content equals the head content, and the figures in this audit stand. The finding is procedural: the freshness gate blocks completion of the review and of any re-review until the artifact is newer than the commit. Remedy: one `Invoke-PoshQCParallelTest` run in the item worktree, recorded append-only under `evidence/qa-gates/`.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed. The 10 Pester skips and 6 pytest skips match the Phase 0 baseline counts.

---

## 9. Summary of Changes

- New: `.claude/hooks/bash-command-shape-guidance.ps1`, `.claude/rules/bash-command-shape.md`, `.agents/skills/bash-command-shape/SKILL.md`, `.github/instructions/bash-command-shape.instructions.md`, and their bundle copies; three new test files.
- Edited: `validate-bash.ps1` (2 hunks), four `worktree-poetry-venv-policy.ps1` copies, six `execution-environment/SKILL.md` copies, two `parallel-orchestrate/SKILL.md` copies, two pack manifests, three existing test files.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

### Policy-by-Policy Summary

- General code change: PASS
- General unit test: PASS for PowerShell; FAIL for Python coverage evidence (PA-1)
- PowerShell code change and unit test: PASS
- Python code change: PASS (no production code); Python unit test coverage evidence: FAIL (PA-1)

### Metrics Summary

- PowerShell repo-wide line coverage 95.80% (threshold 85%); new helper 100%.
- Pester 21301 passed, 0 failed; pytest 8852 passed, 0 failed.
- Blocking findings: 2 (PA-1, PA-2).

### Recommendation

Run one Python coverage gate (PA-1) and one PowerShell parallel coverage gate (PA-2) in the item worktree, record both under `evidence/qa-gates/`, and re-review. No code change is required.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1` (new, 22 tests)
- `tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1` (new, 68 tests)
- `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1` (modified, 89 tests)
- `tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1` (modified, 63 tests)
- `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py` (new, 6 tests)
- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (modified, 9 tests)
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (modified, 23 tests)

## Appendix B: Toolchain Commands Reference

- PowerShell tests and coverage: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>`
- PowerShell static: `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `Invoke-PoshQCLeakScan`
- Python tests: `env -u VIRTUAL_ENV poetry -C <item worktree root> run pytest -n auto <modules>`
- Python coverage (remedy for PA-1): `env -u VIRTUAL_ENV poetry -C <item worktree root> run pytest -n auto --cov --cov-branch`
- Generator check: `poetry run python scripts/dev_tools/generate_codex_agent_variants.py --check`
- Evidence locations: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree root>`
