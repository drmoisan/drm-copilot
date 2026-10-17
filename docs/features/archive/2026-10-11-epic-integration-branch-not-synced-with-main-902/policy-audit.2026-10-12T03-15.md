# Policy Compliance Audit: Epic Integration Branch Pre-Wave Main-Sync Step (#902)

---

**Audit Date:** 2026-10-12
**Code Under Test:**
- `.claude/skills/epic-orchestrate/SKILL.md` (MODIFIED, Markdown runtime procedure)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (MODIFIED, bundled mirror)
- `.agents/skills/epic-orchestrate/SKILL.md` (MODIFIED, Codex counterpart)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` (MODIFIED, bundled Codex mirror)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (MODIFIED, test-support module)
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` (NEW, contract tests)

**Review scope:** full branch diff `origin/main...HEAD`, merge base `12b2454256cfa11ff809d5d2333ddaf988574e21`, head `15e8c2a46`. Work mode: `minor-audit` (reduced audit).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (test code under tests/) | 111 tests (13 new + 98 regression) | PASS 111 pass, 0 fail | 4.20% lines scripts.dev_tools slice (740/17636); 100% lines support module (34/34) | 4.20% lines scripts.dev_tools slice (740/17636); 100% lines support module (34/34) | 100% (support module 34/34; no production line changed) |
| Markdown | 4 files | 13 contract nodes plus 6 parity nodes | PASS (all nodes pass) | N/A (prose surface; no line-coverage tool) | N/A (prose surface; no line-coverage tool) | N/A (prose surface) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch
- PowerShell baseline coverage artifact: N/A - no PowerShell file changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell file changed on the branch
- Per-language comparison summary: section 1.2.1 of this audit; executor artifacts `evidence/baseline/baseline-pytest-coverage.2026-10-11T10-38.md`, `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`, `evidence/baseline/baseline-support-coverage.2026-10-11T10-38.md`, `evidence/qa-gates/final-support-coverage.2026-10-11T10-38.md`

---

## Executive Summary

The branch adds a pre-wave main-sync step to the "Epic Integration Branch Lifecycle" section of the epic-orchestrate skill, mirrors it into the Claude bundle copy, adds a condensed equivalent paragraph to the Codex skill and its bundle copy, re-pins the frozen skill digest in the parallel-orchestrator surface expectations module, and adds a 13-node pytest contract module. No production Python, TypeScript, PowerShell, C#, hook, rule, or instruction file changed.

The template was taken from the bundled policy-audit asset at `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the file the MCP template-resolver serves (`extensions/drm-copilot/src/policy-audit-template-assets.ts`). The MCP tool itself was not in this reviewer's tool set, so the file was read directly from the same path.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- PASS `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` (Python test code)
- N/A PowerShell, TypeScript, C#, Bash, JSON: no file of these languages changed on the branch

The reviewer re-ran the check-only toolchain on the two changed Python files (Black `--check`, Ruff, Pyright) and the 111-node pytest regression set; all passed. The executor's Python coverage evidence shows no regression and 100% line coverage of the modified test-support module. Coverage verdict for Python: PASS (delta basis; see section 5 note and finding N-1).

**Temporary artifacts cleanup:**
- PASS No temporary scripts were added to the branch; the only non-feature-folder files are the six scope files.
- PASS The executor's coverage config `evidence/other/coveragerc-902.ini` is an evidence input stored under the feature folder, not a reusable script.
- Reviewer scratch files (Pyright output, baseline skill copy) were written to the session scratchpad only.

---

## Rejected Scope Narrowing

No scope narrowing was applied. The caller text "The merge commit 94a55ff5c from origin/main is not part of this change's review scope." was assessed. It does not narrow the audit: the merge base is `12b2454` (the `origin/main` commit merged by `94a55ff5c`), so `git diff 12b2454 HEAD` already contains no content from that merge. The audit covers the full 39-file branch diff against `origin/main`. The caller's instruction to treat the CI-only Pester parity suites as a CI-pending dependency does not narrow coverage scope: no PowerShell file changed on the branch.

Note: the local `main` ref in this worktree is stale (`2ef8d361e`). The resolved base was `origin/main @ 12b2454`, matching `artifacts/pr_context.summary.txt`.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 33 evidence files live under `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each of the 13 tests reads committed files independently through `read_section`; no shared mutable state, no fixtures with side effects. |
| **Isolation** - Each test targets single behavior | PASS | Presence (4 parametrized surfaces), ordering (2), numbering (2), removal-sensitivity (2), pre-change rejection (1), and two helper-contract tests (`remove_block`, `section_body`). |
| **Fast Execution** - Tests complete quickly | PASS | 13 nodes in 0.07s (`evidence/regression-testing/contract-tests-pass.2026-10-11T10-38.md`); 111-node set re-run by reviewer in 1.37s. |
| **Determinism** - Consistent results | PASS | Pure string operations over committed repository text; no clock, RNG, network, or subprocess use. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `test_*` names, one-line docstrings, `# Arrange / # Act / # Assert` markers, `pytest.param` ids (`claude-skill`, `claude-bundle`, `codex-skill`, `codex-bundle`). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline: 4.20% lines scripts.dev_tools slice (740/17636 statements, 6366 branches, 20 partial) and 100% lines for `parallel_orchestrator_surface_expectations.py` (34/34). Files: `evidence/baseline/baseline-pytest-coverage.2026-10-11T10-38.md`, `evidence/baseline/baseline-support-coverage.2026-10-11T10-38.md`. |
| **No Coverage Regression** | PASS | Post-change totals identical: 740/17636 statements covered (4.20%), support module 34/34 (100%). Change: 0.00 percentage points. |
| **New Code Coverage at or above threshold** | PASS | No production line changed (`git diff --name-only origin/main...HEAD -- scripts src extensions/drm-copilot/src` empty). Modified test-support module: 34/34 statements = 100%; it has 0 branches. The new test module is excluded by `[tool.coverage.run] omit = ["tests/*", ...]`, a permitted exclusion. |
| **Comprehensive Coverage** | PASS | All six helpers in the new module (`normalize_whitespace`, `contains_phrase`, `section_body`, `assert_main_sync_fragments`, `remove_block`, `read_section`) are exercised; `remove_block` and `section_body` negative paths have dedicated tests. |
| **Positive Flows** - Valid inputs | PASS | `test_main_sync_step_present_in_lifecycle_section` x4, ordering x2, numbering x2. |
| **Negative Flows** - Invalid inputs | PASS | `test_contract_fails_when_claude_main_sync_step_removed`, `test_contract_fails_when_codex_main_sync_paragraph_removed`, `test_contract_fails_on_pre_change_lifecycle_text`. |
| **Edge Cases** - Boundary conditions | PASS | Whitespace normalization prevents reflow from voiding assertions; `section_body` returns `None` for an absent heading; numbering test pins exactly six steps. |
| **Error Handling** - Error paths | PASS | `test_remove_block_rejects_missing_start_marker` asserts `ValueError`; `read_section` asserts on an absent heading with a path-specific message. |
| **Concurrency** - If applicable | N/A | Tests are pure, read-only, and single-threaded. |
| **State Transitions** - If applicable | N/A | No stateful component under test. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 4.20% lines (scripts.dev_tools slice, 740/17636) and 100% lines for the test-support module (34/34). Post-change: 4.20% lines (740/17636, identical totals) and 100% lines for the test-support module (34/34). Change: 0.00 percentage points on both measurements; no production Python line changed. New/changed-code coverage: 100% (test-support module 34/34; 0 branches in that module). Disposition: PASS (no regression; delta basis per section 5). Evidence: `evidence/baseline/baseline-pytest-coverage.2026-10-11T10-38.md`, `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`, `evidence/baseline/baseline-support-coverage.2026-10-11T10-38.md`, `evidence/qa-gates/final-support-coverage.2026-10-11T10-38.md`, `artifacts/python/lcov-902.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Messages name the surface and the absent fragment (`{label}: missing main-sync fragment: {fragment}`), the out-of-order condition, and the observed step list. Fail-before evidence shows these messages (`evidence/regression-testing/fail-before.2026-10-11T10-38.md`). |
| **Arrange-Act-Assert Pattern** | PASS | Every test carries explicit AAA comments. |
| **Document Intent** | PASS | Module docstring cites issue #902 and states the read-only contract; each test has a one-line docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, subprocess, database, or external service. Tests read committed repository Markdown, consistent with the repository's text-fragment contract-test convention. |
| **Use Mocks/Stubs** | N/A | No collaborator requires substitution. |
| **Environment Stability** | PASS | No temporary file is created or written; no global state; paths resolve from `Path(__file__).resolve().parents[3]`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review for the branch. Outstanding item: CI-only Pester parity suites (finding N-5). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` states the problem (epic #852 integration branch 278 commits behind main) and operator decision (A). |
| **Read existing change plans** | PASS | `research/research.2026-10-11T10-45.md` identifies parity surfaces and the digest pin; `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | PASS | `plan.2026-10-11T10-38.md`, 49 of 49 tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One inserted numbered step (Claude) and one paragraph (Codex); no new mechanism, no hook change. |
| **Reusability** | PASS | The test module shares one fragment tuple across all four surfaces and reuses `section_body`/`read_section` across tests. |
| **Extensibility** | PASS | Adding a surface is a single `pytest.param` entry. |
| **Separation of concerns** | PASS | Text helpers are pure functions; file I/O is confined to `read_section`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The new module covers one contract (issue #902). |
| **Under 500 lines** | PASS | `test_epic_orchestrate_main_sync_contract.py` 312 lines; `parallel_orchestrator_surface_expectations.py` 381 lines (reviewer `wc -l`). |
| **Public vs internal** | PASS | Test module only; no public API surface added. |
| **No circular dependencies** | PASS | The new module imports only `re`, `pathlib`, and `pytest`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `MAIN_SYNC_FRAGMENTS`, `PRE_CHANGE_LIFECYCLE_TEXT`, `test_main_sync_step_sits_between_integration_fetch_and_child_branching`. |
| **Docs/docstrings** | PASS | Google-style docstrings with Args/Returns/Raises on every helper. |
| **Comment why, not what** | PASS | The re-baseline comment in the expectations module records why the skill digest moved (issue #902) and that the agent digest did not. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `poetry run black --check <two files>`<br>**Result:** reviewer re-run: "2 files would be left unchanged." Executor pass 2: `evidence/qa-gates/final-black.2026-10-11T10-38.md`. |
| **2. Linting** | PASS | **Command:** `poetry run ruff check <two files>`<br>**Result:** reviewer re-run: "All checks passed!" Executor pass 1 had 5 E501 errors, fixed without suppression (commit `e9e35d70a`). |
| **3. Type checking** | PASS | **Command:** `poetry run pyright <two files>`<br>**Result:** reviewer re-run exit 0, "0 errors, 0 warnings, 0 informations". |
| **4. Architecture-boundary tests** | N/A | No production module or import graph changed. |
| **5. Testing** | PASS | **Command:** `poetry run pytest <9 contract/parity modules> -q -p no:cacheprovider`<br>**Result:** reviewer re-run: 111 passed in 1.37s. |
| **6. Contract / schema checks** | PASS | Bundle-parity nodes and the frozen-digest pin pass (`evidence/qa-gates/final-parity-nodes.2026-10-11T10-38.md`, 6 passed). |
| **7. Integration tests** | N/A | No adapter or external integration changed. |
| **Full toolchain loop** | PASS | Pass 1 failed at Ruff; loop restarted from formatting; pass 2 clean across all stages. |
| **Explicit reporting** | PASS | Commands, exit codes, and outputs recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages `93f0bf377`, `e9e35d70a`, `15e8c2a46`; `evidence/other/small-audit-handoff.2026-10-11T10-38.md`. |
| **Design choices explained** | PASS | The Claude step explains why the sync child's `features[]` row is written first (`enforce-epic-wave-barrier.ps1` denies a delegation whose feature record is absent; verified at hook lines 319-331). |
| **Update supporting documents** | PASS | All four skill surfaces updated; persona classification recorded in `evidence/other/persona-parity-classification.2026-10-11T10-38.md`. |
| **Provide next steps** | PASS | CI Pester handoff in `evidence/other/pester-ci-handoff.2026-10-11T10-38.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`<br>**Result:** 2 files unchanged. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <same two files>`<br>**Result:** All checks passed. No `noqa` suppression added. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <same two files>`<br>**Result:** 0 errors. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest <9 modules> -q -p no:cacheprovider`<br>**Result:** 111 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All helpers and tests are annotated; `from __future__ import annotations`; no `Any`; `str | None` return for `section_body`. |
| **Dataclasses for value objects** | N/A | No value objects introduced. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces introduced. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | `remove_block` raises `ValueError` with the absent marker in the message; no broad `except`. |
| **Logging over print** | PASS | No `print` calls. |
| **Invariants at construction** | N/A | No classes. |

### Section 3B: Markdown Runtime Surfaces

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Bundle byte parity** | PASS | Reviewer `git hash-object`: Claude skill and bundle `7a21440358463eabc98f7a6c874e96a87be6d357`; Codex skill and bundle `c708d88dd34c984267f19e656c86d2ec1e2ef686`. |
| **Line endings** | PASS | All four files `i/lf w/lf` (`evidence/qa-gates/final-parity-eol.2026-10-11T10-38.md`). |
| **Frozen digest re-pin** | PASS | Pin updated to `0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2` with an explanatory comment; persona digest unchanged and its node passes. |
| **No stale cross-references after renumbering** | PASS | Repository grep for references to lifecycle steps 3-5 outside `docs/features/` found none; remaining "step 6" references in the skill target S9, not the lifecycle. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Function-style pytest tests with `pytest.mark.parametrize` and `pytest.raises`. |
| **Coverage expectation** | PASS | Test-support module 34/34 lines (100%), no regression in the scripts.dev_tools slice (740/17636 before and after); no production Python line changed. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | Each test asserts one contract property. |
| **Mocking sparingly** | PASS | No mocks. |
| **Organization** | PASS | Located in `tests/scripts/dev_tools/` alongside the other skill-surface contract tests (`test_parallel_orchestrator_surface_contracts.py`, `test_epic_run_kickoff_discovery_contract.py`). |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_<subject>_<expected behavior>` naming throughout. |
| **Docstrings/comments** | PASS | One-line docstrings per test; module docstring describes the contract. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py -v -p no:cacheprovider`<br>**Result:** 13 passed (executor); included in the reviewer's 111-node run. |
| **No Alternative Test Runners** | PASS | Pytest only. |

---

## 5. Test Coverage Detail

### `test_epic_orchestrate_main_sync_contract.py` (13 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_main_sync_step_present_in_lifecycle_section[claude-skill]` | Positive | 227-235 | PASS |
| `test_main_sync_step_present_in_lifecycle_section[claude-bundle]` | Positive | 227-235 | PASS |
| `test_main_sync_step_present_in_lifecycle_section[codex-skill]` | Positive | 227-235 | PASS |
| `test_main_sync_step_present_in_lifecycle_section[codex-bundle]` | Positive | 227-235 | PASS |
| `test_main_sync_step_sits_between_integration_fetch_and_child_branching[claude-skill]` | Positive (ordering) | 238-255 | PASS |
| `test_main_sync_step_sits_between_integration_fetch_and_child_branching[claude-bundle]` | Positive (ordering) | 238-255 | PASS |
| `test_lifecycle_steps_are_numbered_one_through_six[claude-skill]` | Edge Case | 258-266 | PASS |
| `test_lifecycle_steps_are_numbered_one_through_six[claude-bundle]` | Edge Case | 258-266 | PASS |
| `test_contract_fails_when_claude_main_sync_step_removed` | Negative | 269-277 | PASS |
| `test_contract_fails_when_codex_main_sync_paragraph_removed` | Negative | 280-288 | PASS |
| `test_contract_fails_on_pre_change_lifecycle_text` | Negative | 291-295 | PASS |
| `test_remove_block_rejects_missing_start_marker` | Error Handling | 298-302 | PASS |
| `test_section_body_returns_none_for_absent_heading` | Error Handling | 305-312 | PASS |

**Coverage:** The test module itself is excluded from measurement by `[tool.coverage.run] omit` (`tests/*`), a permitted exclusion under `.claude/rules/general-unit-test.md`. Every helper and branch in it is exercised by at least one test above; the fail-before run (10 failed, 3 passed) shows the presence, ordering, numbering, and removal tests are sensitive to the absence of the step.

**Not covered:** None identified.

### `parallel_orchestrator_surface_expectations.py` (36 tests in `test_parallel_orchestrator_surface_contracts.py`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-0b1a629a...]` | Positive | 165-174 (pin tuple) | PASS |
| `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-d5e5e3b0...]` | Positive | 165-174 (pin tuple) | PASS |

**Coverage:** 34/34 statements (100%), 0 branches (`evidence/qa-gates/final-support-coverage.2026-10-11T10-38.md`; `artifacts/python/lcov-902.info` LF:34 LH:34).

**Python coverage verdict note.** The two changed Python files are test code. No production Python file changed, so the change cannot alter the repo-wide Python line or branch figure. The executor's scripts.dev_tools measurement (4.20%) is a slice produced by a targeted test subset to prove that totals did not move; it is not a repo-wide Python figure. Consistent with the precedent in the #900 review, the repo-wide threshold is evaluated on the change delta, which is zero. The canonical file `artifacts/python/lcov.info` does not exist in the worktree. The executor wrote its LCOV output to `artifacts/python/lcov-902.info`, and the second coverage run overwrote the first, so that file holds only the support-module record. The numeric figures for both runs are preserved verbatim in the qa-gates evidence. This is recorded as non-blocking finding N-1. Python coverage verdict: PASS.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 111 (reviewer re-run of the 9-module set) | PASS |
| Tests Passed | 111 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 1.37s total (reviewer); 0.95s (executor) | PASS Fast |
| Average Time per Test | about 12ms | PASS Fast |
| Discovery Time | not separately reported by pytest `-q` | PASS |
| Functions/Classes Tested | 6/6 helpers in the new module (100%) | PASS |
| Test File Size | 312 lines (new module) | PASS Maintainable |
| Code Coverage | test-support module 100% lines, 0 branches; scripts.dev_tools slice unchanged at 4.20% | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <two files>` | 2 files would be left unchanged | PASS |
| Ruff Linting | `poetry run ruff check <two files>` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <two files>` | 0 errors, 0 warnings, 0 informations | PASS |
| Pytest Tests | `poetry run pytest <9 modules> -q -p no:cacheprovider` | 111 passed | PASS |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:**
- The CI-only Pester suites `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` and `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` were not run locally (operator constraint). Their epic-skill assertions target the `## Epic-Level Checkpoint` section, which this branch does not modify, and the byte-identity property was verified locally by hash equality. Result is CI-pending (finding N-5).

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap. Non-blocking findings:

- N-1 (Minor): The Python coverage artifact is at `artifacts/python/lcov-902.info`, not the canonical `artifacts/python/lcov.info`, and it retains only the last run (support module). The numeric baseline and post-change figures for both runs are preserved in the qa-gates evidence. Recommended practice for future runs: write to the canonical path, or keep one LCOV file per run.
- N-2 (Info): No repo-wide Python coverage figure was produced. The change adds no production line, so the repo-wide figure is unchanged; the 85% line and 75% branch gates remain the responsibility of the pipeline that owns them.
- N-5 (Info): Pester parity suites are CI-pending; no PR exists yet for the branch (`artifacts/pr_context.summary.txt`).

### Approved Exceptions

None. No exceptions needed.

### Removed/Skipped Tests

None. All planned tests implemented (13 nodes, matching the plan's Test Inventory).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **a19ef768c** - docs(902): create active feature folder with issue acceptance criteria
2. **1fc1f3819** - docs(902): add research on epic integration main-sync parity surfaces
3. **e78ba1747** - docs(902): author minimal-audit atomic plan
4. **af1eabeec** - docs(902): revise plan per preflight round 1
5. **94a55ff5c** - Merge remote-tracking branch 'origin/main' (brings the branch up to the merge base; contributes no diff relative to `12b2454`)
6. **c0d5d56b6** - docs(902): record phase 0 baseline evidence and plan
7. **93f0bf377** - fix(902): add pre-wave main-sync step to epic integration branch lifecycle
8. **e9e35d70a** - fix(902): wrap pre-change lifecycle literal to satisfy E501
9. **15e8c2a46** - docs(902): record final QC evidence and check off acceptance criteria

### Files Modified

1. **`.claude/skills/epic-orchestrate/SKILL.md`** (MODIFIED) - new lifecycle step 3 (fetch main, `rev-list --count`, chore-child main-sync route, checkpoint pre-registration, merge-before-launch, one sync per wave); former steps 3-5 renumbered 4-6.
2. **`extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`** (MODIFIED) - byte-identical mirror.
3. **`.agents/skills/epic-orchestrate/SKILL.md`** (MODIFIED) - condensed equivalent paragraph in `## Integration Branch and Child Worktrees`.
4. **`extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`** (MODIFIED) - byte-identical mirror.
5. **`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`** (MODIFIED) - skill digest re-pinned with #902 comment.
6. **`tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`** (NEW) - 13-node contract module.
7. Feature folder documents and 33 evidence files under `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/` (NEW).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT (with non-blocking notes)

All applicable policies pass. No hook, rule, or instruction file was modified. The toolchain is clean on reviewer re-run. Python coverage shows no regression, and the only modified measurable module is at 100% line coverage. Three non-blocking notes remain: N-1, N-2, and N-5.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue, research, and plan present.
- PASS Design Principles: minimal text insertion; no new mechanism.
- PASS Module & File Structure: 312 and 381 lines.
- PASS Naming, Docs, Comments: descriptive names, full docstrings, rationale comment on the re-pin.
- PASS Toolchain Execution: clean pass 2 after one Ruff-driven restart.
- PASS Summarize & Document: handoff and evidence complete.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline: Black, Ruff, Pyright, and Pytest clean.
- PASS Python Design & Typing: fully annotated; no escape hatches.
- PASS Error Handling: specific `ValueError`; no broad catch.

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios (delta basis; N-1 and N-2 advisory)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 111/111 tests passing (100%)
- PASS 6/6 new helpers exercised
- PASS Test-support module coverage 100% (34/34); no regression in the scripts.dev_tools slice (740/17636)
- PASS Test file in `tests/scripts/dev_tools/` beside the existing contract tests
- PASS All code quality checks passing
- PASS Test execution time 1.37s

---

### Recommendation

**Ready for merge** once the PR CI run (including the two Pester parity suites) is green at the orchestrator's S9 gate.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[claude-skill]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[claude-bundle]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[codex-skill]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[codex-bundle]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_sits_between_integration_fetch_and_child_branching[claude-skill]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_sits_between_integration_fetch_and_child_branching[claude-bundle]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_lifecycle_steps_are_numbered_one_through_six[claude-skill]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_lifecycle_steps_are_numbered_one_through_six[claude-bundle]`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_contract_fails_when_claude_main_sync_step_removed`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_contract_fails_when_codex_main_sync_paragraph_removed`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_contract_fails_on_pre_change_lifecycle_text`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_remove_block_rejects_missing_start_marker`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_section_body_returns_none_for_absent_heading`
- Regression set (98 nodes) across `test_parallel_orchestrator_surface_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_full_migration_inventory.py`, `test_skill_bundle_contract_repo.py`, `test_epic_bounded_child_return_contract.py`, `test_orchestrator_state_remediation_docs.py`, `test_epic_run_kickoff_discovery_contract.py`.

---

## Appendix B: Toolchain Commands Reference

**Reviewer-run commands (check-only):**
```bash
git diff --stat 12b2454256cfa11ff809d5d2333ddaf988574e21 HEAD
git log --oneline 12b2454256cfa11ff809d5d2333ddaf988574e21..HEAD
poetry run black --check tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run ruff check tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run pyright tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run pytest tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py -q -p no:cacheprovider
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
git hash-object <four skill surfaces>
git diff --name-only 12b2454 HEAD -- .claude/hooks .codex/hooks .claude/rules .github/instructions .claude/agents .codex/agents
wc -l tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
```

**Executor coverage commands (from evidence, not re-run):**
```bash
COVERAGE_FILE=artifacts/.coverage-902 poetry run pytest <8 regression modules> --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov-902.info --cov-fail-under=0 -q -p no:cacheprovider
poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py --cov=tests.scripts.dev_tools.parallel_orchestrator_surface_expectations --cov-branch --cov-config=docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/evidence/other/coveragerc-902.ini --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov-902.info -q -p no:cacheprovider
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-12
**Policy Version:** Current (as of audit date)
