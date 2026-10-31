# Policy Compliance Audit: Parallel planner leaves scratch worktrees (Issue #1002)

---

**Audit Date:** 2026-10-31
**Base Branch:** `main` (merge base `c7b2850fda58ef2c80624952e582738b76a546f4`, from `git merge-base origin/main HEAD`)
**Head:** `bug/parallel-planner-leaves-scratch-worktrees-1002` at `589fef537`
**Scope:** full branch diff `c7b2850fd..HEAD` (31 files, 1244 insertions, 6 deletions). The PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree (gitignored); the scope was derived directly from `git diff` against the resolved merge base.

**Code Under Test (non-documentation files):**

- Markdown runtime surfaces (modified): `.claude/skills/parallel-plan/SKILL.md`, `.claude/agents/parallel-planner.md`, and their byte-identical bundled copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- Python test (new): `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` (292 logical lines, 14 test cases).
- Documentation: the feature folder (issue, spec, plan, research, evidence).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 0 production, 1 test | 14 new; 15871 in the full suite (reviewer run) | PASS 15871 passed, 0 failed, 6 skipped | 96.69% lines, 93.63% branches (repo-wide; equals head because no production Python line changed) | 96.69% lines, 93.63% branches (32144 of 33243 lines, 11685 of 12480 branches) | 100% of changed production Python lines (0 production lines changed; the test module is outside `[tool.coverage.run] source`) |
| PowerShell | 0 | - | - | N/A (no changed files) | N/A | N/A |
| TypeScript | 0 | - | - | N/A (no changed files) | N/A | N/A |
| C# | 0 | - | - | N/A (no changed files) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch).
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch).
- Python baseline coverage artifact: N/A as a separate artifact; no production Python file differs between the merge base and head, so the head measurement equals the baseline for every production line.
- Python post-change coverage artifact: `artifacts/python/lcov.info` and `artifacts/python/coverage.json`. The executor ran every pytest invocation with `--no-cov`, so no artifact existed in the reviewed worktree. The reviewer generated both with `poetry run python -m pytest --cov --cov-branch -q -p no:cacheprovider --cov-report=json:artifacts/python/coverage.json` at head (15871 passed, 6 skipped, 812 s); the files are gitignored and not part of the branch diff.
- PowerShell baseline coverage artifact: N/A (no PowerShell file changed on the branch).
- PowerShell post-change coverage artifact: N/A (no PowerShell file changed on the branch).
- Per-language comparison summary: Section 1.2.1.

`FEATURE` denotes `docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002`.

---

## Executive Summary

The branch fixes issue #1002 with a text-only change. The `parallel-plan` skill now tells the planner to author `parallel/<slug>-plan` in its own session checkout, to read item text by ref with `git fetch` and `git show`, and states in a **No planner worktrees.** paragraph that the planner runs no `git worktree add`. The `parallel-planner` agent gains a pointer sentence in `## Delegation Model` and Completion Requirements item 8. A 14-case contract module protects the wording. Bundled copies are byte-identical.

Reviewer verification at head:

- New module: 14 passed. Ten named contract modules including the new one: 116 passed, 0 failed.
- Black `--check`: 1 file unchanged. Ruff: All checks passed. Pyright: 0 errors, 0 warnings, 0 informations.
- `validate_evidence_locations.py --root .`: exit 0 with no output.
- Change set limited to the five Scope files plus the feature folder (31 files; no rule, hook, validator, `.agents`, `.codex`, `.github`, or `quality-tiers.yml` path).

The executor's pytest runs used `--no-cov`, so no Python coverage artifact existed. The reviewer generated one with a full-suite coverage run at head: 15871 passed, 6 skipped; repo-wide 96.69% lines and 93.63% branches, above the 85% and 75% defaults. The only Python file changed is a test module outside the coverage source set. No blocking finding was identified.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `origin/main`; no project is added or changed, so no classification entry is affected)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md`; PASS `.claude/rules/python-suppressions.md` (see Section 3A.1 on the `# fmt: off` directives)
- N/A PowerShell, TypeScript, C#, Bash: no changed files

**Temporary artifacts cleanup:**
- PASS No temporary script is committed.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope. The caller named a production surface and plan for orientation; the audit covered the full diff against the merge base of `origin/main` and `HEAD`, which matches the stated comparison.

---

## Evidence Location Compliance

- Diff file list filtered for `^artifacts/(baselines|qa|evidence|coverage)/`: no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- All committed evidence is under `FEATURE/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Reversed-order single-process run, 136 passed (`FEATURE/evidence/regression-testing/isolation.2026-10-31T13-01.md`); every test reads committed files only. |
| **Isolation** - Each test targets one behavior | PASS | One contract per test; parametrization only for the skill/agent and canonical/bundle pairs. |
| **Fast Execution** | PASS | 14 tests in 0.12 s (reviewer). |
| **Determinism** | PASS | No clock, RNG, network, or process use; repository root resolved by the shared test-support module. |
| **Readability & Maintainability** | PASS | Docstrings on every test; Arrange/Act/Assert comments; assertion messages name the missing fragment. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | No production Python line changed, so the head measurement (96.69% lines, 93.63% branches) equals the baseline. |
| **No Coverage Regression** | PASS | No production Python line changed; the test module is not in the coverage source set. |
| **New Code Coverage >= 85% line / 75% branch** | PASS | The new file is a test module, outside `[tool.coverage.run] source`; 0 changed production lines. Repo-wide 96.69% lines and 93.63% branches meet both thresholds. |
| **Comprehensive Coverage** | PASS | Each Required Behavior (1 to 4) and each Wording Constraint has at least one test. |
| **Positive Flows** | PASS | Fragment-present tests for the skill and agent. |
| **Negative Flows** | PASS | Forbidden-fragment and `pinned` absence test; `paragraph_from_marker` raises `AssertionError` for an absent marker. |
| **Edge Cases** | PASS | Count equality between `git worktree add` occurrences and prohibition fragments; whitespace-collapsed matching. |
| **Error Handling** | PASS | Missing marker and missing numbered item produce explicit failures. |
| **Concurrency** | N/A | No concurrent behavior. |
| **State Transitions** | N/A | Stateless text assertions. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.69% lines, 93.63% branches -> Post-change: 96.69% lines, 93.63% branches (32144 of 33243 lines, 11685 of 12480 branches). Change: 0.00 points lines, 0.00 points branches (no production Python line changed). New/changed-code coverage: 100% of changed production Python lines (0 changed); the new file is a test module outside `[tool.coverage.run] source = ["src", "scripts/dev_tools", "packages/discovery-runtime/src"]`. Thresholds: root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern and are met. Disposition: PASS. Evidence: `artifacts/python/lcov.info` and `artifacts/python/coverage.json`, generated by the reviewer at head.
- PowerShell: no changed files. Disposition: N/A.
- TypeScript: no changed files. Disposition: N/A.
- C#: no changed files. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Every `assert` carries a message naming the document, fragment, or count. |
| **Arrange-Act-Assert Pattern** | PASS | Comments in every test. |
| **Document Intent** | PASS | Docstrings and the module docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Reads committed repository files only. |
| **Use Mocks/Stubs** | N/A | None needed. |
| **No temporary files** | PASS | Reviewer read of the module: no `tmp_path`, `tempfile`, or write call; matches executor token scan (0 for five tokens). |
| **Test file location** | PASS | `tests/scripts/dev_tools/` mirrors the `scripts/dev_tools` test convention used by sibling contract modules. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md`, `spec.md`, research. |
| **Read existing change plans** | PASS | `FEATURE/evidence/baseline/phase0-instructions-read.2026-10-31T12-49.md`. |
| **Document the plan** | PASS | `plan.2026-10-30T06-59.md` with plan-validation evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Text-only change; the rejected hook alternative is recorded in the spec. |
| **Reusability** | PASS | The test reuses `parallel_orchestrator_surface_test_support` helpers. |
| **Extensibility** | PASS | Helpers take the marker or fragment tuple as arguments. |
| **Separation of concerns** | PASS | Pure text assertions; file reads go through the shared helper. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size (tiered policy)** | PASS | Logical counts: new test module 292; no covered file at or above 500. `config/file-size-baseline.json` unchanged. Markdown files are exempt. |
| **No circular dependencies** | PASS | Test imports only the shared support module. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Test names state the contract; two are long because the plan fixes them. |
| **Docs/docstrings** | PASS | Module and per-function docstrings. |
| **Comment why, not what** | PASS | The `# fmt: off` regions carry a comment stating why. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check` on the module: 1 file would be left unchanged (reviewer). |
| **2. Linting** | PASS | `poetry run ruff check` on the module: All checks passed (reviewer). |
| **3. Type checking** | PASS | `poetry run pyright` on the module: 0 errors, 0 warnings, 0 informations (reviewer). |
| **4. Architecture-boundary tests** | PASS | No import-graph change. |
| **5. Unit tests** | PASS | 116 passed across the ten named modules (reviewer). |
| **6. Contract / schema checks** | PASS | Push-down contract, Codex agents customization, and skill-bundle contract modules are in the 116; executor Codex generator `--check` evidence at `FEATURE/evidence/qa-gates/codex-generator-check.2026-10-31T13-01.md`. |
| **7. Integration tests** | PASS | Executor jest kickoff-seam evidence at `FEATURE/evidence/qa-gates/jest-kickoff-seam.2026-10-31T13-01.md`. |
| **Full toolchain loop** | PASS | Executor final loop restarted after the docstring reword and finished clean. |
| **Explicit reporting** | PASS | Evidence folder. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages and `FEATURE/evidence/qa-gates/self-review.2026-10-31T13-02.md`. |
| **Update supporting documents** | PASS | Skill, agent, and both bundle copies updated together. |
| **Provide next steps** | PASS | Spec `## Rollout and Follow-up`; live `/parallel-plan` check recorded as a manual note. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py`<br>**Result:** 1 file would be left unchanged. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <same file>`<br>**Result:** All checks passed. No `# noqa` is present. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <same file>`<br>**Result:** 0 errors, 0 warnings, 0 informations. |
| **Suppression policy (`# fmt: off` / `# fmt: on`)** | PASS | `.claude/rules/python-suppressions.md` governs `# noqa` and `# type: ignore` suppressions. A Black `# fmt: off` region is a formatter directive and is not within that rule's enumerated scope. The branch adds no `# noqa` and no `# type: ignore`. Repository precedent exists: `tests/scripts/dev_tools/test_potential_to_issue.py` uses the same directive for the same reason. The scope is narrow (two functions) and each region carries a why-comment. Recorded as Info in the code review because the form `def \` plus a backslash continuation is unusual and leaves two function bodies unchecked by Black. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Type hints** | PASS | All functions annotated, `-> None` on tests. |
| **Simple design** | PASS | Four small helpers; no class. |
| **Import hygiene** | PASS | `from __future__ import annotations`; imports sorted (Ruff clean). |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Explicit failures** | PASS | `paragraph_from_marker` raises `AssertionError` with the missing marker rather than returning an empty string. |

### Section 3B: PowerShell, 3C: Bash, 3D: JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Applicable** | N/A | No `.ps1`, `.psm1`, `.sh`, `.bats`, or `.json` file changed. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | PASS | 14 passed for the new module; 116 for the ten modules. |
| **Arrange-Act-Assert** | PASS | Comments present. |
| **Descriptive names** | PASS | Names match the spec acceptance criteria one for one. |
| **Expect-fail evidence** | PASS | `FEATURE/evidence/regression-testing/expect-fail.2026-10-31T12-53.md`: ExpectedExitCode 1, EXIT_CODE 1, 10 failed and 4 passed before the text change. |
| **Post-fix evidence** | PASS | `FEATURE/evidence/regression-testing/post-fix.2026-10-31T13-01.md`. |

---

## 5. Test Coverage Detail

| Test | Scenario | Status |
|------|----------|--------|
| `test_skill_artifact_home_states_planner_runs_no_worktree_add` | Prohibition fragment in the No planner worktrees paragraph | PASS |
| `test_skill_no_planner_worktrees_names_runtime_as_remover` | Runtime creates and removes; outside removal-gate records and sweep | PASS |
| `test_skill_artifact_home_contains_plan_home_checkout_command` | Fetch, create, resume, push commands | PASS |
| `test_skill_plan_home_checkout_is_ordered_after_preparation_children` | Ordering | PASS |
| `test_skill_plan_home_checkout_stops_on_refusal_without_stash_force_or_reset` | Refusal handling | PASS |
| `test_skill_read_access_names_planner_and_git_show` | By-ref reads | PASS |
| `test_every_git_worktree_add_occurrence_is_inside_prohibition_sentence` (skill, agent) | No creating instruction | PASS |
| `test_agent_delegation_model_points_to_no_worktree_prohibition` | Agent pointer | PASS |
| `test_agent_completion_requirements_new_item_requires_no_worktree_and_pushed_plan_branch` | Item 8 and item 2 intact | PASS |
| `test_skill_contains_no_pinned_word_and_no_forbidden_fragments` | Wording constraints | PASS |
| `test_edited_sections_exclude_preparation_fan_out_item_intake_and_kickoff_artifact_changes` | Untouched sections keep fragments | PASS |
| `test_bundled_copies_are_byte_identical_to_canonical` (skill, agent) | Mirror parity | PASS |

---

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New module (reviewer) | 14 passed, 0.12 s |
| Ten named modules (reviewer) | 116 passed, 0 failed |
| Reversed-order run (executor) | 136 passed |
| Full suite with coverage (reviewer) | 15871 passed, 6 skipped, 812 s |
| Python line / branch coverage (repo-wide) | 96.69% / 93.63% |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| Black / Ruff / Pyright | PASS | Reviewer runs on the new module |
| Mirror parity | PASS | Byte-identity tests pass; executor `mirror-parity.2026-10-31T13-01.md` |
| Scope check | PASS | `git diff --name-only` limited to Scope files plus the feature folder |
| Hook, rule, validator, `.agents`, `.codex`, `.github`, `quality-tiers.yml` untouched | PASS | Diff file list |
| Run Closing in `parallel-orchestrate/SKILL.md` untouched | PASS | Not in the diff |
| Coverage exclusions | PASS | No `exclude` entry added |
| Evidence-location validator | PASS | exit 0 |
| Tier classification | PASS | `quality-tiers.yml` exists on `origin/main`; no project added or changed |

---

## 8. Gaps and Exceptions

### Identified Gaps

- Info: the executor's evidence records `--no-cov` runs only, so the Python coverage figures come from the reviewer's run. Future cycles should record one coverage-enabled run.
- The PR context artifacts were absent; scope was derived from `git diff` against the merge base, which is the authoritative scope source.

### Approved Exceptions

- None.

### Removed/Skipped Tests

- None removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

- `8bedbebfb` docs(features): record issue 1002 wording-constraint inventory
- `40cccd749` test(parallel): add planner no-scratch-worktree contract tests for issue 1002
- `8ebc1b814` fix(parallel-plan): stop the planner creating scratch worktrees (issue 1002)
- `74dd6cf11` fix(parallel-planner): require no planner worktree in the agent surface (issue 1002)
- `589fef537` docs(features): complete issue 1002 final QA loop, self-review, and AC check-off

### Files Modified

- Runtime Markdown: skill and agent (plus 2 bundle copies).
- Tests: 1 Python module added.
- Documentation: feature folder.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policy checks pass.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

- PASS: design, structure, naming, file size, toolchain.

#### Language-Specific Code Change Policy (Section 3)

- PASS: Python; N/A: PowerShell, Bash, JSON, TypeScript, C#.

#### General Unit Test Policy (Section 1)

- PASS: principles, coverage (Python PASS), scenarios, environment.

#### Language-Specific Unit Test Policy (Section 4)

- PASS: Pytest.

### Metrics Summary

| Metric | Value |
|--------|-------|
| Blocking findings | 0 |
| Non-blocking findings | 0 Minor, 2 Info (code review) |
| Largest changed covered file | 292 lines |

### Recommendation

Proceed to the PR creation gate. Merge remains subject to the S9 CI green gate on the final PR head.

---

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` (14 cases)

---

## Appendix B: Toolchain Commands Reference

```bash
poetry run black --check tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py
poetry run ruff check tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py
poetry run pyright tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py
poetry run python -m pytest -q -p no:cacheprovider <ten named contract modules>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
git merge-base origin/main HEAD
```
