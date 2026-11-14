# Policy Compliance Audit: planner-worktree-removal-authorization (Issue #1161)

**Audit Date:** 2026-11-14
**Audit Type:** Initial feature review (S7) of PR #1176.
**Code Under Test:** merge base `eb73f1dff52e7175228a03740b53281c81e1c00c` of the base branch `main` (equal to `origin/main` after a fetch at review time) and reviewed head `6c8f1d9faf651b8244f997fd05c5b21ffb1390fb` on branch `feature/planner-worktree-removal-authorization-1161`; the diff lists 118 changed files (7782 insertions, 45 deletions), 45 of them under the feature folder; 23 commits.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 36 files (7 production, 7 bundle mirrors, 22 test) | 22679 tests | ✅ 22669 pass, 0 fail, 10 disabled | 95.80% lines | 95.86% lines | 93.33% lines minimum per new file (Codex adapter 42/45) |
| Python | 2 files (1 production, 1 test) | 16720 tests | ✅ 16714 pass, 0 fail, 6 skipped | 97.11% lines, 94.38% branches | 97.13% lines, 94.42% branches | 100.00% lines (every changed production line covered) |
| TypeScript | 4 files (2 production, 1 test, 1 Jest config) | 5563 tests (root configuration) | ✅ 5563 pass, 0 fail | 97.15% lines, 93.87% branches | 98.29% lines, 93.68% branches (root report) | 100.00% lines (172/172), 100.00% branches (44/44) |
| JSON | 18 files (16 corpus fixtures, 2 pack manifests) | N/A | ✅ corpus parity and pack-manifest completeness tests pass | N/A (fixture and manifest files) | N/A (fixture and manifest files) | N/A |
| Markdown and TOML | 13 files outside the feature folder (skills, agents, rule, mirrors) plus 45 feature-folder files | N/A | ✅ wording contract `planner-worktree-removal-contract.Tests.ps1` passes | N/A (documentation) | N/A (documentation) | N/A |

The post-change figures were parsed by the reviewer from the canonical artifacts in the item worktree: `artifacts/pester/powershell-coverage.xml` root LINE counter 38941 covered, 1683 missed (95.86%); `artifacts/python/lcov.info` 34573 of 35594 lines and 12784 of 13540 branches; `coverage/lcov.info` (worktree root) 70196 of 71416 lines (98.29%) and 10489 of 11197 branches (93.68%). The TypeScript baseline is the extension report of the `Phase 0 baseline` (`evidence/baseline/jest-gate.2026-11-10T03-38.md`); no root baseline was recorded, and the extension post-change figure is 97.18% lines, 93.95% branches.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/baseline/jest-gate.2026-11-10T03-38.md` (extension, 97.15% lines, 93.87% branches)
- TypeScript post-change coverage artifact: `coverage/lcov.info` (item worktree root, written 2026-11-14T00:29:40Z by the reviewer's root run), summarized in `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/qa-gates/jest-root-gate.2026-11-14T00-29.md`; supporting extension report `extensions/drm-copilot/coverage/lcov.info`, summarized in `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/qa-gates/jest-gate.2026-11-13T20-09.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/baseline/pester-gate.2026-11-10T04-07.md` (95.80% lines)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (item worktree, written 2026-11-13T20:34:32Z by the `Invoke-PoshQCParallelTest` run), summarized in `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/qa-gates/pester-gate.2026-11-13T20-34.md`
- Python baseline coverage artifact: `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/baseline/pytest-gate.2026-11-10T03-33.md` (97.11% lines, 94.38% branches)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (item worktree, written 2026-11-13T20:07:57Z), summarized in `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/qa-gates/pytest-gate.2026-11-13T20-08.md`
- Per-language comparison summary: section 1.2.1 of this audit

Freshness: the newest commit that changes a Python or TypeScript file is `f9a12f0e6` (2026-11-13T18:37:54Z); the newest commit that changes a PowerShell file is `5dcf646ab` (2026-11-13T20:14:02Z, one test row). The Python report (20:07:57Z), the extension Jest report (20:09:32Z), the Pester report (20:34:32Z), and the root Jest report (2026-11-14T00:29:40Z) were all written after the newest commit of their language. The worktree is clean apart from this review's own files.

Scope source: `artifacts/pr_context.summary.txt` was generated at 2026-11-14 00:23:07 UTC for head `6c8f1d9fa`, range `eb73f1dff..6c8f1d9fa`, and matches the reviewed head. The reviewer also took the file list directly from `git diff eb73f1dff..6c8f1d9fa`.

Reviewer run disclosure: the coverage contract is evidence-only, but the worktree-root `coverage/lcov.info` did not exist at review start (the executor's Jest gate ran in `extensions/drm-copilot`). The reviewer ran the root Jest configuration once (`node run-jest.cjs --coverage`, normal workers, one suite on the machine, about 17 s) and recorded it as new evidence `evidence/qa-gates/jest-root-gate.2026-11-14T00-29.md`. No other suite was rerun.

---

## Executive Summary

The branch adds a planner allow branch to the three worktree-removal gates (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`). The branch is a byte-identical pure helper `hook-planner-worktree-removal.ps1` behind a Claude adapter and a Codex adapter. It also adds key-gated validation of `planner_worktrees` to the Python and TypeScript epic-planner validators, a 16-file shared corpus, the recording protocol in both epic-plan skills and both epic-planner agents, and a planner sentence in the parallel-orchestrate skill and rule.

The reviewer verified the following directly at head:
- All 13 changed runtime files have byte-identical bundle mirrors (`cmp`), and the four copies of the pure helper are identical.
- Both Claude gates are at exactly 500 logical lines (cap 500). No covered file reaches 700 lines, and `config/file-size-baseline.json` is unchanged.
- Per-file Pester line coverage of every changed hook file is at or above 93.33%, and the parsed figures equal the evidence.
- `validate_evidence_locations --root <item worktree>` exits 0.
- `origin/main` after a fetch equals the merge base, so there is no base drift.
- A cross-runtime probe (esbuild bundle of the TypeScript module against the Python function) found that the two validators disagree on `recorded_at` values made only of U+FEFF, U+001F, or U+0085. This is finding PA-1 (blocking, autonomous).

One blocking finding: PA-1. CI on the PR head is still in progress (Python quality checks, PowerShell QC shards, shell coverage). The completed checks are green. CI is a pending-CI item owned by the S9 gate, not a finding.

Owner directive OD-10 (`accept_nonblocking_deviation`) accepts the drive-rooted synthetic value quoted in `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md` as a non-blocking exception to AC-27 (checkpoint `accepted_deviations` DEV-1). The reviewer recorded it as an approved exception (section 8), not as a FAIL.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `quality-tiers.md` (repository has adopted tiers; `quality-tiers.yml` exists and classifies `.claude/hooks`, `.codex/hooks`, and `scripts/dev_tools`)

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- ⚠️ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`): parity finding PA-1 touches the Python rule set
- ⚠️ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (`.claude/rules/typescript.md`): parity finding PA-1
- N/A C#: no C# file in the branch diff
- N/A Bash: no bash file in the branch diff

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; executor helpers lived under the issue SCRATCH directory outside the repository.
- ✅ Reviewer probe files (`lcov.awk`, `rootjest.sh`, `pw.cjs`, `probe.cjs`, `probe.py`) live in the session scratchpad outside the repository.
- Note: `evidence/qa-gates/pytest-gate.2026-11-13T20-08.md` records that the pytest JSON report was first written beneath a directory at the drive root outside the repository and then moved into SCRATCH. Nothing is in the branch diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Parallel gates only: 8-worker `Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest workers, all 0 failed; leak scan 768 files, 0 failures. Two order-dependence fixes (`Reset-EpicStateProbeModuleBinding` in `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` and `hook-command-invocation.Issue824Regression.Tests.ps1`) repair the leaker binding and are recorded in `scope-check.2026-11-13T20-36.md`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One row per refusal code, per U condition, per status value, per corpus file. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The new suites are in-memory; the helper suite reports 220 tests. |
| **Determinism** - Consistent results | ✅ PASS | Synthetic forward-slash roots and a synthetic UNC pair; git and file reads go through mocked seams; no clock. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Behavior-named rows citing the AC (for example `allows a prepared record whose HEAD is on the integration ref (AC-5)`). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.80% lines; Python 97.11% lines, 94.38% branches; TypeScript extension 97.15% lines, 93.87% branches<br>**Command:** `Invoke-PoshQCParallelTest`, `pytest -n auto --cov-branch --cov`, `node run-jest.cjs --coverage` in `extensions/drm-copilot`<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-10T04-07.md`, `evidence/baseline/pytest-gate.2026-11-10T03-33.md`, `evidence/baseline/jest-gate.2026-11-10T03-38.md`<br>**Timestamp:** 2026-11-10 03:33 to 04:07 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.86%; Python 97.13% / 94.42%; TypeScript extension 97.18% / 93.95%, root 98.29% / 93.68%<br>**Status:** every modified gate file rises (Claude epic gate 94.92% to 95.24%, Claude parallel gate 95.58% to 95.93%, Codex gate 98.73% to 100.00%, resolution sibling 96.23% to 96.55%); `validate_epic_planner_state.py` stays at 100.00% lines and rises to 99.21% branches; `epic-planner-state-core.ts` unchanged at 100.00% / 96.85%. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% line and 75% branch (root `CLAUDE.md` states no threshold, so the defaults govern; Pester has no branch gate)<br>**Status:** lowest changed production file `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` 93.33% lines. |
| **New Code Coverage ≥90%** | ✅ PASS | **New files:** `hook-planner-worktree-removal.ps1` 100% (130/130) in both copies; `enforce-worktree-removal-gate-planner.ps1` 93.88% (46/49); `enforce-epic-worktree-removal-gate-planner.ps1` 93.33% (42/45); `epic-planner-state-planner-worktrees.ts` 100% lines and branches<br>**Changed lines:** all added lines of `validate_epic_planner_state.py` covered; the one partial branch is pre-existing (176 to 180, baseline 175 to 179). |
| **Comprehensive Coverage** | ⚠️ PARTIAL | 16-file corpus covers every error string; the corpus has no row whose `recorded_at` is made only of non-ASCII or control whitespace, which is where the runtimes diverge (PA-1). |
| **Positive Flows** - Valid inputs | ✅ PASS | `valid-every-preparation-status.json`, `valid-optional-fields-absent.json`, `valid-key-absent.json`; allow rows for `prepared` and `fanned_in` on each gate, integration ref and branch ref. |
| **Negative Flows** - Invalid inputs | ✅ PASS | 13 rejecting corpus files; one refusal row per code on each gate. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Detached stanza, bare stanza, bare `locked` line, case-variant status and purpose, absent `integration_branch`, `path` mismatch, `--force` with U3 and with DIRTY. |
| **Error Handling** - Error paths | ✅ PASS | `GIT_FAILED` rows for listing, status, rev-parse, and merge-base exits other than 0 or 1. |
| **Concurrency** - If applicable | N/A | Hook decisions are per-call and stateless. |
| **State Transitions** - If applicable | ✅ PASS | Each `preparation_status` value tested for eligibility (AC-17). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.86% lines. Change: +0.06% lines. New/changed-code coverage: 93.33% lines (lowest new file). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester-gate.2026-11-13T20-34.md`, `evidence/baseline/pester-gate.2026-11-10T04-07.md`.
- Python: Baseline: 97.11% lines, 94.38% branches (from the `Phase 0 baseline` artifact) -> Post-change: 97.13% lines, 94.42% branches. Change: +0.02% lines, +0.04% branches. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/pytest-gate.2026-11-13T20-08.md`, `evidence/baseline/pytest-gate.2026-11-10T03-33.md`.
- TypeScript: Baseline: 97.15% lines, 93.87% branches (from the `Phase 0 baseline` extension artifact) -> Post-change: 98.29% lines, 93.68% branches (root report `coverage/lcov.info`; extension report 97.18% lines, 93.95% branches). Change: +0.03% lines, +0.08% branches against the extension baseline. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `coverage/lcov.info`, `evidence/qa-gates/jest-root-gate.2026-11-14T00-29.md`, `evidence/qa-gates/jest-gate.2026-11-13T20-09.md`, `evidence/baseline/jest-gate.2026-11-10T03-38.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Corpus tests compare full expected error lists by file name; the pin row carries a `-Because` reason. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Facts hashtables or checkpoint text, one call, one assertion per row. |
| **Document Intent** | ✅ PASS | Rows name the AC and condition label. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No live git: `Invoke-PlannerWorktreeGitExe` and `Invoke-CodexPlannerWorktreeGitExe` are mocked with `param([string[]]$GitArgs)`; sentinel rows assert the throwing seams are not reached on unrecorded denies. |
| **Use Mocks/Stubs** | ✅ PASS | Wrapper seams per `.claude/rules/powershell.md`; the baseline helper registers `Get-PlannerWorktreeCheckpointText` for every Claude suite. |
| **Environment Stability** | ✅ PASS | Reviewer scan of the new test files found no temporary-file, sleep, or process API use outside AST assertions that forbid them. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-14T00-20.md` (EXIT_CODE 0, no open finding) and this audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` (D1 to D20, AC-1 to AC-34), `user-story.md`. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-11-09T21-36.md`, `plan.2026-11-09T16-33.md` with R1 to R7 readings. |
| **Document the plan** | ✅ PASS | `plan.2026-11-09T16-33.md`, every task checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One pure decision function evaluated in spec order; the adapter loop collects one pending git fact at a time. |
| **Reusability** | ✅ PASS | One helper shared by both surfaces and both Claude gates; Claude path comparison reuses `Test-WorktreeRunPathEqual` and `Test-WorktreeRunRecordedPathMatchesTarget`. |
| **Extensibility** | ✅ PASS | `purpose` kept as a field so later purposes are additive (D3). |
| **Separation of concerns** | ✅ PASS | The helper performs no I/O (asserted by an AST row); I/O lives in two seams per adapter. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Helper, Claude adapter, Codex adapter, TypeScript validator module each own one concern. |
| **At or below the 800-line hard limit** | ✅ PASS | Reviewer logical line counts at head: both Claude gates 500 (cap 500 under `session-root-reads-850.Constraints.Tests.ps1`); helper 482; `epic-planner-state-core.ts` 499; `validate_epic_planner_state.py` 498; `jest.config.cjs` 582; `legacy-codex-hook-contracts.Tests.ps1` 517. No file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | Python `_validate_planner_worktrees` is private; TypeScript exports only `validatePlannerWorktrees`. |
| **No circular dependencies** | ✅ PASS | The TypeScript module imports nothing; the core imports it once. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-PlannerWorktreeRemovalDecision`, `ConvertFrom-PlannerWorktreePorcelain`, `validatePlannerWorktrees`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; Python docstrings; TSDoc on every function; gate `.DESCRIPTION` paragraphs (AC-24). |
| **Comment why, not what** | ✅ PASS | For example the `-NoEnumerate` comment and the integration-ref fall-through comment. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` check over hooks and the 22 changed test files; `black --check`; `prettier --check`<br>**Result:** 0 differences (`pwsh-static.2026-11-13T20-15.md`, `python-static.2026-11-13T18-55.md`, `typescript-static.2026-11-13T18-55.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with repo settings; `ruff check`; ESLint<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`; `tsc --noEmit` for both tsconfig files<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto`; Jest (extension, and root by the reviewer)<br>**Result:** 22669, 16714, 5546, and 5563 passed; 0 failures |
| **Full toolchain loop** | ✅ PASS | Final static loop restarted after the P4-T6 test-row change (`pwsh-static.2026-11-13T20-15.md`), then the Pester gate re-run (`pester-gate.2026-11-13T20-34.md`); Python and TypeScript files unchanged since their gates. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes under `evidence/qa-gates/` and `evidence/other/task-check.*.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages and the plan task list. |
| **Design choices explained** | ✅ PASS | Spec decisions D1 to D20 and plan readings R1 to R7. |
| **Update supporting documents** | ✅ PASS | `## Preparation Worktree Records` in both epic-plan skills; `planner_worktrees` in both agent checkpoint sections; planner sentence in `parallel-orchestrate` and `parallel-orchestration.md`. |
| **Provide next steps** | ✅ PASS | PA-1 remediation in `remediation-inputs.2026-11-14T00-34.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No new Python production file** | ✅ PASS | `scripts/dev_tools/validate_epic_planner_state.py` extended in place (permitted by the spec constraint); the new test module is permitted by D18. |
| **Type hints** | ✅ PASS | `_validate_planner_worktrees(state: dict[str, Any], indexed_features: list[tuple[int, dict[str, Any]]]) -> list[str]`; Pyright 0 errors. |
| **Suppressions** | ✅ PASS | No `noqa`, `type: ignore`, or `pyright: ignore` in the added lines. |
| **Cross-runtime parity** | ❌ FAIL | PA-1: `recorded.strip()` treats U+001F and U+0085 as whitespace and U+FEFF as content; TypeScript `trim()` does the opposite for all three. |

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every function carries `[CmdletBinding()]`, `[OutputType()]`, and named parameters. |
| **Wrapper seam** | ✅ PASS | `Invoke-PlannerWorktreeGitExe -GitArgs` and `Invoke-CodexPlannerWorktreeGitExe -GitArgs`; the wrappers redirect stderr to `$null` rather than `2>&1`, so git warnings cannot be read as dirty status output (code review Info row). |
| **ShouldProcess** | N/A | No state-changing function; the gates only allow or deny. |
| **Guarded imports** | ✅ PASS | Each dot-source and import is wrapped in `try` with `Add-HookDependencyFailure`. |
| **PSScriptAnalyzer** | ✅ PASS | 0 findings over `.claude/hooks`, `.codex/hooks`, and the 22 test files. |

### Section 3C: TypeScript Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **New production module** | ✅ PASS | `epic-planner-state-planner-worktrees.ts` with its own `coverageThreshold` entry `{ lines: 85, branches: 75 }`. |
| **Escape hatches** | ✅ PASS | No `any`, `as any`, `ts-ignore`, or `eslint-disable` in the added lines. |
| **Parity port** | ❌ FAIL | Corpus reproduced by both runtimes, but the reviewer probe shows a divergence on whitespace-only `recorded_at` values outside the corpus (PA-1). |

### Section 3D: JSON and Documentation Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pack manifests** | ✅ PASS | Two new Claude hook files in the Claude `core.json`; two new Codex hook files in the Codex `core.json`. |
| **Mirrors** | ✅ PASS | 13 of 13 mirror pairs byte-identical (reviewer `cmp`). |
| **Frozen surfaces** | ✅ PASS | `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.claude/settings.json`, and `.codex/config.toml` are not in the diff. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Coverage expectation** | ✅ PASS | `validate_epic_planner_state.py` 239/239 lines, 125/126 branches. |
| **Focused unit tests** | ✅ PASS | One parametrized case per corpus file, plus a key-absent equality row. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`; corpus under `tests/fixtures/`. |

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester syntax and location** | ✅ PASS | New suites under `tests/scripts/claude-hooks/`, `tests/scripts/codex-hooks/`, `tests/scripts/claude-runtime/`. |
| **Mock signature parity** | ✅ PASS | Git seam mocks declare `param([string[]]$GitArgs)`. |
| **Coverage** | ✅ PASS | Per-file figures in section 5; no changed-line regression. |

### Section 4C: TypeScript Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Jest structure** | ✅ PASS | One case per corpus file in `epic-planner-state-planner-worktrees.test.ts`. |
| **Coverage** | ✅ PASS | 172/172 lines, 44/44 branches, enforced by its own threshold entry. |

---

## 5. Test Coverage Detail

Per-file figures parsed by the reviewer from the canonical artifacts at head:

- PowerShell (lines): `.claude/hooks/hook-planner-worktree-removal.ps1` 130/130; `.codex/hooks/hook-planner-worktree-removal.ps1` 130/130; `.claude/hooks/enforce-worktree-removal-gate-planner.ps1` 46/49; `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` 42/45; `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` 120/126; `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` 118/123; `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` 87/87; `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` 56/58.
- Python (lines, branches): `scripts/dev_tools/validate_epic_planner_state.py` 239/239, 125/126.
- TypeScript (lines, branches): `epic-planner-state-planner-worktrees.ts` 172/172, 44/44; `epic-planner-state-core.ts` 499/499, 123/127 (the four missed branches are the baseline's four).

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Skipped | Source |
|-----|-------|--------|--------|---------|--------|
| Pester full tree, final | 22679 | 22669 | 0 | 10 | `evidence/qa-gates/pester-gate.2026-11-13T20-34.md` |
| pytest full tree, final | 16720 | 16714 | 0 | 6 | `evidence/qa-gates/pytest-gate.2026-11-13T20-08.md` |
| Jest extension, final | 5546 | 5546 | 0 | 0 | `evidence/qa-gates/jest-gate.2026-11-13T20-09.md` |
| Jest root configuration (reviewer) | 5563 | 5563 | 0 | 0 | `evidence/qa-gates/jest-root-gate.2026-11-14T00-29.md` |
| Fail-before planner allow cases | 21658 | 21613 | 45 | 0 | `evidence/regression-testing/planner-allow-fail-before.2026-11-11T05-00.md` (ExpectedExitCode 1) |
| Reviewer cross-runtime probe | 8 values | 5 identical | 3 differ | 0 | SCRATCH `probe.cjs` and `probe.py` against the esbuild bundle of the head module |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PowerShell format, lint, leak scan | PASS | `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md` |
| Python static (Black, Ruff, Pyright) | PASS | `evidence/qa-gates/python-static.2026-11-13T18-55.md` |
| TypeScript static (Prettier, ESLint, tsc) | PASS | `evidence/qa-gates/typescript-static.2026-11-13T18-55.md` |
| Codex agent generator check | PASS | `evidence/other/codex-generator-check.2026-11-11T05-43.md` |
| Mirror byte-equality | PASS | reviewer `cmp` of 13 pairs and the four helper copies |
| Evidence-location validator | PASS | reviewer run, exit 0 |
| Base drift | PASS | `origin/main` after fetch equals the merge base `eb73f1dff` |
| Python and TypeScript validator parity | FAIL | PA-1 |

## CI Cross-check

PR #1176 exists for head `6c8f1d9fa`. At review time the completed checks were green (Change scope, CI full run, Extension Tests on ubuntu and windows, drm-copilot Extension Tests, Root TypeScript Tests, docs-validation, security-scan, build-check, NPM audit gates). `quality-checks7` (3.11, 3.12, 3.13), `poshqc` (static, three shards, Linux hook suites), and `shell-coverage` were in progress. The table records the local evidence the review relies on.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter differences, 0 analyzer findings, leak scan 0 failures | 5dcf646ab | `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md` |
| poshqc / PowerShell QC | pass | 22669 passed, 0 failed; 95.86% lines | 5dcf646ab | `evidence/qa-gates/pester-gate.2026-11-13T20-34.md` |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 16714 passed, 0 failed; 97.13% lines, 94.42% branches | 2fa854b7c | `evidence/qa-gates/pytest-gate.2026-11-13T20-08.md` |
| Enforce Python coverage thresholds | pass | 97.13% lines, 94.42% branches | 2fa854b7c | `artifacts/python/lcov.info` parsed by the reviewer |
| drm-copilot Extension Tests | pass | 5546 passed; 97.18% lines, 93.95% branches | 2fa854b7c | `evidence/qa-gates/jest-gate.2026-11-13T20-09.md` |
| Root TypeScript Tests | pass | 5563 passed; 98.29% lines, 93.68% branches | 6c8f1d9fa | `evidence/qa-gates/jest-root-gate.2026-11-14T00-29.md` |

`5dcf646ab` and `2fa854b7c` carry the same Python and TypeScript tree as head, and `5dcf646ab` carries the same PowerShell tree as head (`git diff --stat 5dcf646ab HEAD` lists only feature-folder files). The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

---

## Evidence Location Compliance

`validate_evidence_locations --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence and the reviewer's new evidence file are under `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/<kind>/`.

## Rejected Scope Narrowing

None. The caller supplied the base, merge base, head, feature folder, and AC sources. The caller also instructed the reviewer to record OD-10 as an accepted non-blocking exception to AC-27. That directive narrows no changed file's verification and is recorded under Approved Exceptions. This audit covers the full `eb73f1dff..6c8f1d9fa` diff.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists and is unchanged by the branch. The changed production files lie under the classified paths `.claude/hooks`, `.codex/hooks`, `scripts/dev_tools`, and the existing extension `src/lib/validate` folder; no new project folder was added.

## Workflow Rule

No path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` changed, so `modified-workflow-needs-green-run` does not fire. No path under `docs/engineering/process-reductions/` changed.

## Owner Directive Decisions

```text
OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | 2026-11-14T00:28:00Z | Scheduling direction only; the review runs as one delegation against the full branch diff and changes no gate or scope.
OWNER-DIRECTIVE-DECISION: OD-2 | scheduling | honored | 2026-11-14T00:28:33Z | Standalone execution acknowledged; the review touches no parallel manifest or sibling checkpoint.
OWNER-DIRECTIVE-DECISION: OD-3 | scheduling | honored | 2026-11-14T00:28:33Z | Review runs in the existing sibling worktree and branch; no worktree or branch is created.
OWNER-DIRECTIVE-DECISION: OD-4 | scheduling | honored | 2026-11-14T00:28:33Z | All commands use git -C, absolute-path reads, or sh scratch scripts; no cd-chained read commands.
OWNER-DIRECTIVE-DECISION: OD-5 | scheduling | honored | 2026-11-14T00:28:33Z | The review reruns no suite; coverage and test results are read from existing gate artifacts and evidence.
OWNER-DIRECTIVE-DECISION: OD-6 | scheduling | honored | 2026-11-14T00:28:33Z | No evidence file is edited, back-dated, or deleted; review artifacts are new files with a clock-read timestamp.
OWNER-DIRECTIVE-DECISION: OD-7 | scheduling | refused | 2026-11-14T00:28:33Z | Merging origin/main is an orchestrator action outside the read-only review role; base drift is reported, not merged.
OWNER-DIRECTIVE-DECISION: OD-8 | scheduling | honored | 2026-11-14T00:28:33Z | Related findings are reported as blocking remediation inputs for this item rather than as separate issues.
OWNER-DIRECTIVE-DECISION: OD-9 | scheduling | honored | 2026-11-14T00:28:33Z | Single review delegation, no new Python, timestamps read from the clock, no absolute paths written into artifacts.
OWNER-DIRECTIVE-DECISION: OD-10 | accept_nonblocking_deviation | honored | 2026-11-14T00:28:33Z | AC-27 drive-rooted quotation in pwsh-static.2026-11-13T20-15.md is recorded as an accepted non-blocking exception (DEV-1).
```

Correction to the OD-5 decision text: the reviewer ran one suite, the root Jest configuration, after writing that decision (section "Reviewer run disclosure"). The run stays within OD-5 because it was a single parallel-worker suite and the only suite running on the machine. Base drift under OD-7: none (`origin/main` equals the merge base).

---

## 8. Gaps and Exceptions

### Identified Gaps

- Blocking (PA-1): Python and TypeScript disagree on whether a `recorded_at` made only of U+FEFF, U+001F, or U+0085 is blank. Python `str.strip()` strips U+001F and U+0085 but not U+FEFF; ECMAScript `String.prototype.trim()` strips U+FEFF but not U+001F or U+0085. Probe results: `"﻿"` gives Python no error and TypeScript the `recorded_at` error; `"\u001f"` and `"\u0085"` give Python the error and TypeScript none. U+00A0 and U+200B agree. The spec (D11, `### Validator error strings`) and user-story criterion 1 require byte-identical results; the corpus has no row that pins the whitespace definition.
- Non-blocking: CI on PR head `6c8f1d9fa` is in progress for Python, PowerShell, and shell jobs; pending-CI, owned by S9.
- Non-blocking: AC-31's "passes unchanged" is read as "assertions unchanged" (plan R5). Seven existing suites gain one baseline-mock line, and two gain an order-dependence reset. Each change is listed in `## Existing Test Dispositions` and `scope-check.2026-11-13T20-36.md`, and no assertion changed.

### Approved Exceptions

- DEV-1 under owner directive OD-10 (`accept_nonblocking_deviation`, recorded 2026-11-14T00:14:39Z): `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md` quotes the drive-rooted synthetic test value that P4-T6 removed from `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1`. The value is synthetic and carries no host data. The evidence file is append-only and stays unedited. AC-27's second clause is satisfied apart from this accepted exception (`evidence/qa-gates/scope-check.2026-11-14T00-18.md`, hit E1).

### Removed/Skipped Tests

None removed. The 10 Pester skips and 6 pytest skips match the Phase 0 baseline counts.

---

## 9. Summary of Changes

- New production files: `.claude/hooks/hook-planner-worktree-removal.ps1`, `.codex/hooks/hook-planner-worktree-removal.ps1`, `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`, and the bundle mirrors.
- Edited production files: the three removal gates, `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `extensions/drm-copilot/jest.config.cjs`, two pack manifests.
- Documentation: both epic-plan skills, both epic-planner agents, `parallel-orchestrate` skill, `parallel-orchestration` rule, with mirrors.
- Tests: 8 new test files, 14 edited test files, 16 corpus fixtures.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

### Policy-by-Policy Summary

- General code change: PASS
- General unit test: PASS (with PA-1 noted under comprehensive coverage)
- PowerShell code change and unit test: PASS
- Python code change and unit test: FAIL on cross-runtime parity (PA-1)
- TypeScript code change and unit test: FAIL on cross-runtime parity (PA-1)

### Metrics Summary

- PowerShell 95.86% lines; Python 97.13% lines, 94.42% branches; TypeScript 98.29% lines, 93.68% branches (root).
- Pester 22669, pytest 16714, Jest 5546 (extension) and 5563 (root) passed; 0 failures.
- Blocking findings: 1 (PA-1, autonomous).

### Recommendation

Remediate PA-1: define the whitespace set for `recorded_at` identically in both validators, then add corpus rows for U+FEFF, U+001F, and U+0085 so the shared corpus pins it. Then re-review.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1` (new, 220 tests, run against both helper copies)
- `tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1` (new)
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.PlannerWorktree.Tests.ps1` (new)
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.PlannerWorktree.Tests.ps1` (new)
- `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-planner-worktree.Tests.ps1` (new)
- `tests/scripts/claude-runtime/planner-worktree-removal-contract.Tests.ps1` (new)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py` (new)
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts` (new)
- Edited: `CleanupWorktreeManifestGateMatrix.Tests.ps1`, `EpicStateIsolation.Baseline.Helpers.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, the epic gate `Diagnostics`, `RelativeRecord`, `TriggerScoping`, `WorktreeResolution` suites, the parallel gate `EpicAuthorization`, `RelativeRecord`, base, `TriggerScoping`, `WorktreeResolution` suites, `hook-command-invocation.Issue824Regression.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`
- Corpus: `tests/fixtures/epic_planner_state_planner_worktrees/` (16 files)

## Appendix B: Toolchain Commands Reference

- PowerShell tests and coverage: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>`
- PowerShell static: `Invoke-Formatter` and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `Invoke-PoshQCLeakScan -Root <item worktree root>`
- Python tests and coverage: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`
- Python static: `black --check`, `ruff check`, `pyright`
- TypeScript: `node run-jest.cjs --coverage` in `extensions/drm-copilot` and at the root; Prettier check; ESLint; `tsc --noEmit`
- Evidence locations: `python scripts/dev_tools/validate_evidence_locations.py --root <item worktree root>`
- Reviewer probe: esbuild bundle of `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts` at head, called with eight single-entry checkpoints, compared with `_validate_planner_worktrees` on the same entries
