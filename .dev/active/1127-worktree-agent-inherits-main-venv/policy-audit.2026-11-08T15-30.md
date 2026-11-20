# Policy Compliance Audit: Worktree Poetry Virtual-Environment Guard (Issue #1127)

**Audit Date:** 2026-11-08
**Branch:** `bug/worktree-own-venv` @ `3c8e5375a543d90b6d19cb1bc46f09e88b496b3d`
**Base:** `main`; merge base `cdcff3871765396183590128e142a929cf78327b`, which equals `origin/main` after `git fetch`. `git merge-tree --write-tree origin/main HEAD` exits 0 (clean). `artifacts/pr_context.summary.txt` (generated 2026-11-08 15:25:55 UTC) names head `3c8e5375a543d90b6d19cb1bc46f09e88b496b3d`, so it is current for this head.
**Work Mode:** full-bug (AC source: `spec.md`, AC1 to AC22)
**Code Under Test:** merge base `cdcff3871765396183590128e142a929cf78327b` of `main` and reviewed head `3c8e5375a543d90b6d19cb1bc46f09e88b496b3d`; the diff between them lists the changed files. The head includes a plain merge of `origin/main`; only the branch's own changes are reviewed.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 new production (2 Claude, 2 Codex) plus 4 bundle copies; 5 test files (3 new incl. one case table, 2 modified) | gate run: 0 failures | PASS | 95.56% lines repo-wide (Phase 0) | 95.60% lines repo-wide (35614 covered, 1640 missed) | 100% on all four new files (117/117, 35/35, 117/117, 38/38) |
| Python | 1 test file (+23 lines, one test and one heading) | pytest gate run: 0 failures | PASS | 97.11% lines, 94.37% branches (Phase 0) | 97.11% lines, 94.37% branches | N/A - no production Python |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A |

PowerShell verdict: PASS. Python verdict: PASS (test-only change). The root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern; Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester-parallel.2026-11-08T14-22.md` (95.56% repo-wide lines).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-08 10:18 local by the final gate recorded in `evidence/qa-gates/pester-parallel.2026-11-08T15-20.md`. The reviewer parsed the root LINE counter (35614 covered, 1640 missed) and the per-file counters of the four new files (all missed 0).
- Python artifact: `artifacts/python/lcov.info` (written 10:05 local) for the repo-wide row; the branch changes no production Python file.
- Artifact provenance note: both coverage artifacts predate the merge of `origin/main` at `3c8e5375a`. The orchestrator verified that the merge changed no file this branch touches, and the reviewer confirms with `git diff --name-only 3c8e5375a^1 3c8e5375a` (the paths brought in by main) against `git diff --name-only <merge-base> HEAD` (the branch paths) that the two sets share no path. The artifacts therefore describe the branch's code, and freshness is recorded, not failed.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.

---

## Executive Summary

The branch adds a PreToolUse guard that denies mutating Poetry commands (`install`, `sync`, `add`, `remove`, `update`) when the hook process `VIRTUAL_ENV` names an environment outside the target project, with a pure dot-sourced helper, a Codex twin, registrations, bundle copies, manifest entries, six identical `execution-environment` skill copies carrying a new `## Worktree Python Environment` section, and Pester and pytest tests.

Reviewer checks at this head:

| Check | Result |
|---|---|
| Real-process probe of the Claude hook with `VIRTUAL_ENV=C:/Users/x/repo/.venv` and a worktree `cwd` | `poetry install` denies (exit 0, deny JSON). A commit message naming `poetry install`, a `gh pr create --body "run poetry install"`, a trailing `# poetry install` comment, `poetry run pytest`, and bare `poetry` allow with no output and exit 0. Non-JSON stdin allows with no output and exit 0 (fail open). |
| Real-process probe of the Codex twin | Non-JSON stdin exits 2 with a `WORKTREE_VENV_BLOCKED:` stderr line; empty stdin exits 2 with the same prefix; a valid non-Poetry payload exits 0 with no output. |
| Byte comparison, hook and helper against bundle copies | `cmp` identical for all four pairs (Claude hook, Claude helper, Codex hook, Codex helper). The Claude and Codex helpers are byte-identical to each other. The Claude and Codex hooks differ in the header and the payload-read and exit path, as the spec states. |
| `md5sum` of the six `execution-environment/SKILL.md` copies | One digest, `aa524014de5884b273b4dae80e899032`, for all six. |
| `.claude/settings.json` and `.codex/config.toml` against their bundle copies | `cmp` identical. |
| Manifests | Both `core.json` files list the hook and the helper (Claude pack in `.claude/hooks/`, Codex pack in `.codex/hooks/`). |
| `git diff` of `hook-command-*` files | None changed; the shared option tables are untouched, so AC19 holds without a parser suite change. |

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (applicability: `quality-tiers.yml` is not modified, no project is added; no tier obligation is triggered)
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (four new production files, test files)
- PASS `.claude/rules/python.md` (one test file)
- N/A TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- `git status --short` at head is empty. The reviewer wrote probe scripts only to the session scratchpad. The worktree `.venv` is gitignored and predates the review.

---

## Rejected Scope Narrowing

The audit covers the full diff `cdcff3871765..3c8e5375a`. Caller statements considered:

- "Scope the diff to the merge base of origin/main and HEAD ... review only the branch's own changes." This is the authoritative scope source, not a narrowing.
- "The merge brought no change to any file this branch touches (verified by the orchestrator), so record that rather than failing on freshness." Recorded under the provenance note. It removes no coverage check.

No statement narrowed the audit, and none was applied as a narrowing.

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <worktree>` exited 0 with no output. All evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, `qa-gates/`, and `regression-testing/`.

## File Size

Logical line counts of changed covered files: helper 361, Claude hook 125, Codex hook 139, case table 112, Claude test 222, Codex test 127, brief contract test 594. None reaches 700. `config/file-size-baseline.json` is not in the diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The case table injects `Command`, `Cwd`, and `VirtualEnv`; no shared mutable state; the hook-script route restores `[Console]::In` and `[Console]::Error` in `finally`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One case per `It`; helper path functions have their own `Describe`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | In-process string checks. |
| **Determinism** - Consistent results | ✅ PASS | No clock, network, environment write, or temporary file; `VIRTUAL_ENV` is injected through a parameter and a mocked read seam. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Case names state each scenario; the table is grouped by comment headers. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester-parallel.2026-11-08T14-22.md`, `pytest-parallel.2026-11-08T14-24.md`. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 95.56% to 95.60%. `OrchestratorState.psm1` shows 112/113 lines against 113/113 at baseline; the file is not in the branch diff, so no changed line regressed (see CR-I1 in the code review). |
| **New Code Coverage** | ✅ PASS | 100% line coverage on each of four new files, against the 85% default. |
| **Modified Files** | ✅ PASS | No existing production file is modified; modified files are tests, JSON/TOML registrations, and skill text. |
| **Comprehensive Coverage** | ✅ PASS | 55-row case table covering the deny, neutralized, override, path-variant, and payload shapes. |
| **Positive Flows** | ✅ PASS | Reproduction deny rows for the five mutating subcommands. |
| **Negative Flows** | ✅ PASS | Unset, empty, main-checkout, non-mutating, and non-Poetry allow rows. |
| **Edge Cases** | ✅ PASS | Trailing separators, case variants, `.venv-old` sibling, missing `cwd`, `~` and `$` targets. |
| **Error Handling** | ✅ PASS | Malformed payload: Claude exits 0 with no output; Codex exits 2. |
| **Concurrency** | N/A | Stateless per-call logic. |
| **State Transitions** | N/A | No state machine. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.56% repo-wide lines (Phase 0) -> Post-change: 95.60% repo-wide lines. Change: +0.04 points. New/changed-code coverage: 100% (all four new files). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-parallel.2026-11-08T14-22.md`, `evidence/qa-gates/pester-parallel.2026-11-08T15-20.md`.
- Python: Baseline: 97.11% lines and 94.37% branches -> Post-change: 97.11% lines and 94.37% branches. Change: +0.00 points. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/baseline/pytest-parallel.2026-11-08T14-24.md`, `evidence/qa-gates/pytest-parallel.2026-11-08T15-07.md`.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` on the per-case assertions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Section comments in each `It`. |
| **Document Intent** | ✅ PASS | The case table header states what a case carries. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No process, network, or Poetry call; leak scan reports 0 failures (`evidence/qa-gates/leak-scan.2026-11-08T14-58.md`). |
| **Use Mocks/Stubs** | ✅ PASS | One mock, the `Get-WorktreePoetryVenvProcessValue` read seam. |
| **Environment Stability** | ✅ PASS | No temporary file; no environment variable set. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-08T15-30.md` and `feature-audit.2026-11-08T15-30.md`; executor self-review `evidence/qa-gates/self-review.2026-11-08T15-22.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1127, `spec.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-08T08-08.md`. |
| **Document the plan** | ✅ PASS | Plan and `research/research.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One hook, one pure helper; the shared scanner is reused unchanged. |
| **Reusability** | ✅ PASS | `Read-CommandLineInvocationSegment` reused; the Codex twin reuses the helper unchanged. |
| **Extensibility** | ✅ PASS | The subcommand and directory-option lists are script-level constants. |
| **Separation of concerns** | ✅ PASS | Pure decision logic in the helper; I/O (payload read, `VIRTUAL_ENV` read, exit code) in the hook. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Tests mirror the hook directories under `tests/scripts/`. |
| **At or below the 800-line hard limit** | ✅ PASS | See File Size. |
| **Public vs internal** | ✅ PASS | No existing public function changes. |
| **No circular dependencies** | ✅ PASS | The hook dot-sources the helper; the helper dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs and descriptive nouns. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; the header records that the hook is a guard and not a security control (AC9). |
| **Comment why, not what** | ✅ PASS | Header explains why an allow writes nothing. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `evidence/qa-gates/poshqc-format.2026-11-08T14-55.md`, `black.2026-11-08T14-56.md`. |
| **2. Linting** | ✅ PASS | `pssa.2026-11-08T14-55.md` (0 findings), `ruff.2026-11-08T14-56.md`. |
| **3. Type checking** | ✅ PASS | `pyright.2026-11-08T14-56.md`; PowerShell has no type-check stage. |
| **4. Testing** | ✅ PASS | Pester and pytest gate artifacts, 0 failures. |
| **Full toolchain loop** | ✅ PASS | One pass; no gate weakened. |
| **Explicit reporting** | ✅ PASS | Artifacts carry timestamp, command, exit code, summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit log by plan task. |
| **Design choices explained** | ✅ PASS | `spec.md` Proposed Fix, including the Codex exit-2 note. |
| **Update supporting documents** | ✅ PASS | Six skill copies, manifests, hook-dependency table rows, worktree-cleanup exemption row. |
| **Provide next steps** | ✅ PASS | `spec.md` Rollout names the push-down refresh after release (AC22). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

Only a test file changed (one added test and one heading). Black, Ruff, and Pyright artifacts are clean. No production rule applies.

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions with `CmdletBinding()`** | ✅ PASS | Every function carries `[CmdletBinding()]` and `[OutputType()]`. |
| **Allow* attributes on nullable inputs** | ✅ PASS | Helper parameters. |
| **No global mutable state** | ✅ PASS | Constants only at script scope. |
| **Error handling explicit** | ✅ PASS | Claude hook fails open by documented design; Codex wraps the read in `try`/`catch`, writes the reason to stderr, exits 2. |
| **No `Invoke-Expression`, no Python invocation** | ✅ PASS | Enforcement-hooks-no-Python suite passes in the gate. |
| **Approved verbs** | ✅ PASS | PSScriptAnalyzer reports none. |
| **Design seams** | ✅ PASS | Environment read through one seam; payload read through an injectable `ReadPayload` scriptblock. |

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed. Not applicable.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework and scope** | ✅ PASS | One pytest function with docstring and Arrange-Act-Assert comments. |
| **Location** | ✅ PASS | `tests/scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Run through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | `Invoke-PoshQCParallelTest`. |
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, `*.Tests.ps1`; the case table is a helper script. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed. Not applicable.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Deny and allow decision table | `WorktreePoetryVenv.Cases.ps1` (55 rows) run by Claude and Codex suites | Deny, neutralize, override, path variants, payload shapes | ✅ |
| Quoted prose | rows `commit message naming poetry install`, `echo argument naming poetry install` | Over-matching | ✅ |
| Registration | Claude `settings.json` and Codex `config.toml` registration tests | Both registered | ✅ |
| Bundle and probe | `codex-bundle-hook-probe.Tests.ps1`, dependency-failure tables | Bundle parity, dependency failure | ✅ |
| Skill section | `test_brief_worktree_python_environment_section_states_bootstrap` | Required text present | ✅ |

**Reviewer probes.** Real-process runs of both hooks (Executive Summary table) for the quoted-prose, comment, `gh pr create --body`, non-mutating, malformed, and empty payload shapes.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester | single `Invoke-PoshQCParallelTest` gate, 0 failures | ✅ |
| pytest | single `pytest -n auto` gate, 0 failures | ✅ |
| Fail-before | `evidence/regression-testing/fail-before.2026-11-08T14-29.md` | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format | `Invoke-PoshQCFormat` | Already formatted (artifact) | ✅ |
| PSScriptAnalyzer | PoshQC analyze | 0 findings (artifact) | ✅ |
| Black, Ruff, Pyright | one changed test file | clean (artifacts) | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <worktree>` | exit 0 (reviewer) | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan` | 0 failures (artifact) | ✅ |

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **No blocking finding.**
2. **Non-blocking items** are recorded in the code review (CR-I1, CR-N1, CR-N2).
3. **CI on this head** has not run; CI-only criteria (AC17 on the Linux hook-suite job) are pending-CI and not a finding.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.**

---

## 9. Summary of Changes

The branch adds a Claude hook, a Codex twin, and a shared pure helper that deny a mutating Poetry command aimed at an outside `VIRTUAL_ENV`, registers both, bundles them with manifest entries, adds the `## Worktree Python Environment` skill section in six copies, and adds tests. The branch log and the diff from merge base `cdcff3871765` to reviewed head `3c8e5375a`, named under **Code Under Test**, carry the commits and files.

---

## 10. Compliance Verdict

### Overall Status: ✅ PASS

No blocking finding.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design, structure, documentation, toolchain loop

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell production files; Python test file

#### General Unit Test Policy (Section 1)
- ✅ Core principles, scenario coverage, 100% new-file coverage, Phase 0 comparison

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Pester and pytest

### Metrics Summary

- ✅ 0 failures across Pester and pytest
- ✅ PowerShell 95.60% repo-wide lines; new files 100%
- ✅ Python unchanged

### Recommendation

**Ready to merge once CI is green.**

---

## Appendix A: Test Inventory

Pester (new): `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1`, `tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1`, case table `tests/scripts/claude-hooks/WorktreePoetryVenv.Cases.ps1`. Pester (modified): `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`. pytest (modified): `test_execution_environment_brief_contracts.py`.

---

## Appendix B: Toolchain Commands Reference

```sh
git -C <worktree> fetch origin main
git -C <worktree> merge-base origin/main HEAD
git -C <worktree> merge-tree --write-tree origin/main HEAD
git -C <worktree> diff --name-status <merge-base>..HEAD
cmp <source hook> <bundle copy>      # four pairs
md5sum <six execution-environment/SKILL.md copies>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
```

Reviewer probes: the Claude and Codex hooks run in real `pwsh` processes from a scratchpad shell script with `VIRTUAL_ENV` exported; parsing of `artifacts/pester/powershell-coverage.xml`.

Template note: the structure follows the prior accepted policy-audit in this repository, and the MCP validator checked this file.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-08
**Policy Version:** Current (as of audit date)
