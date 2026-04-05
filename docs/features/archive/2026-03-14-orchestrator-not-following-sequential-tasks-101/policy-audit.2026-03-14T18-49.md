# Policy Compliance Audit: orchestrator-not-following-sequential-tasks (#101)

**Audit Date:** 2026-03-14  
**Feature Folder:** `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101`  
**Feature Folder Selection Rule:** User-specified active folder for issue `#101`; it already exists, matches the issue suffix `-101`, and required no tie-break against any competing active folder.  
**Base Branch:** `development`  
**Code Under Test:** `.github/agents/csharp-orchestrator.agent.md`, `.github/prompts/orchestrate-csharp-work.prompt.md`, `.github/skills/csharp-change-budget-router/SKILL.md`, `.github/skills/csharp-orchestration-state-machine/SKILL.md`, bundled mirrors under `extensions/drm-copilot/resources/customizations/.github/**`, and `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 test file | Pytest suite | [✅] 873 pass, 0 fail | 83% total / 83% `scripts/dev_tools` | 83% total / 83% `scripts/dev_tools` | 100% targeted contract coverage for the new regression module (6/6 assertions exercised) |

## Executive Summary

This review evaluated the current live branch/worktree for issue `#101` against the repo’s general and Python policies, using refreshed PR-context artifacts plus the feature-folder evidence trail. The implementation changes the C# orchestration contract surface by updating root and bundled markdown customizations to require the sequential small-path lifecycle, and it adds a focused Python regression suite that proves the prior shortcut wording failed before the fix and passes after it. The live verification loop run in this session stayed green: `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info` all passed.

A noteworthy process caveat: the refreshed canonical `pr_context` against `development` reports an empty committed range because the #101 implementation is currently present in the working tree rather than in branch commits. That does not prevent a current-state policy review, but it does mean the branch should be committed and PR context refreshed again before opening a formal PR.

**Policy documents evaluated:**
- [✅] `.github/instructions/general-code-change.instructions.md`
- [✅] `.github/instructions/general-unit-test.instructions.md`
- [✅] `.github/instructions/python-code-change.instructions.md`
- [✅] `.github/instructions/python-unit-test.instructions.md`
- [✅] `.github/instructions/python-suppressions.instructions.md`

**Temporary artifacts cleanup:**
- [✅] No temporary throwaway scripts were introduced by this change.
- [✅] Supporting evidence is stored inside the feature folder’s canonical `evidence/` tree.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [✅] PASS | `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` is file-content based and does not share mutable state between tests. |
| Isolation | [✅] PASS | Each test checks one contract seam: small-path lifecycle wording, prompt wording, checkpoint fields, router wording, mirror parity, or large-path preservation. |
| Fast Execution | [✅] PASS | Targeted evidence `evidence/other/csharp-orchestration-contracts-green.2026-03-14T18-42-49.md` records `6 passed in 0.04s`. The full in-session Pytest pass completed `873` tests in `2.99s`. |
| Determinism | [✅] PASS | Tests read checked-in repository files only; they avoid network, time, temp files, and external process dependencies. |
| Readability & Maintainability | [✅] PASS | Test names are descriptive and align directly to issue/spec acceptance language. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | [✅] PASS | `evidence/baseline/python-pytest.2026-03-14T18-34-25.md` records the baseline Pytest run with coverage fields and output summary. |
| No Coverage Regression | [✅] PASS | `evidence/qa-gates/python-coverage-delta.2026-03-14T18-45-04.md` records `83% → 83%` total coverage and `83% → 83%` `scripts/dev_tools` coverage. |
| New Code Coverage ≥90% | [✅] PASS | No production Python runtime module was added; the changed Python surface is the new regression module, and the targeted suite exercised all `6/6` contract assertions while aggregate coverage remained stable. |
| Comprehensive Coverage | [✅] PASS | Red evidence exists for every intended contract gap: `csharp-orchestrator-small-path-red`, `orchestrate-csharp-work-prompt-red`, `csharp-state-machine-red`, `csharp-change-budget-router-red`, and `csharp-customization-bundle-red`; green evidence records the full consolidated suite passing. |
| Positive Flows | [✅] PASS | The final targeted suite proves the required lifecycle wording, checkpoint-field wording, mirror parity, and large-path preservation all exist post-fix. |
| Negative Flows | [✅] PASS | The fail-before artifacts capture the missing lifecycle wording and parity failures before the contract updates. |
| Edge Cases | [✅] PASS | Mirror-parity coverage ensures the bundled customization tree stays aligned with root files, including the newly added bundled `acceptance-criteria-tracking` skill. |
| Error Handling | [✅] PASS | Contract checks fail fast with direct assertions when required wording or mirrored files are absent. |
| Concurrency | [N/A] N/A | The reviewed contract tests do not model concurrent behavior. |
| State Transitions | [N/A] N/A | No runtime state machine implementation changed; the review scope is contract documentation plus tests. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | [✅] PASS | Each red artifact records the exact missing string or parity assertion that failed. |
| Arrange-Act-Assert Pattern | [✅] PASS | Tests read the relevant file text, then assert presence/absence of the specific contract signals. |
| Document Intent | [✅] PASS | The module docstring and test names clearly communicate why each contract matters. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | [✅] PASS | New tests depend only on checked-in files under the repo root. |
| Use Mocks/Stubs | [N/A] N/A | No external dependencies needed isolation for this test surface. |
| Environment Stability | [✅] PASS | No temporary files are created; tests use `Path.read_text()` against committed repository content. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | [✅] PASS | This document serves as the required policy audit for the #101 review run. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | [✅] PASS | `issue.md` and `spec.md` clearly define the small-path lifecycle regression and the required contract alignment. |
| Read existing change plans | [✅] PASS | `plan.2026-03-14T18-08.md` exists, is fully checked, and references the approved execution sequence. |
| Document the plan | [✅] PASS | The feature folder contains `issue.md`, `spec.md`, the approved plan, baseline evidence, regression evidence, and final QA evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | [✅] PASS | The fix updates a small set of canonical markdown contracts and adds one focused regression module instead of broadening into runtime code changes. |
| Reusability | [✅] PASS | Root-to-bundled mirror parity is treated as a reusable contract and enforced by tests. |
| Extensibility | [✅] PASS | The updated contracts add `plan-path`, `work-mode`, bootstrap metadata, and reduced-audit language without changing the large-path thresholds. |
| Separation of concerns | [✅] PASS | Contract definition stays in agent/prompt/skill markdown, while verification is isolated in Python tests and feature-folder evidence. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | [✅] PASS | Each changed markdown file owns one contract layer: agent, prompt, router skill, or state-machine skill. |
| Under 500 lines | [✅] PASS | Changed non-document files remain well under the 500-line policy: `.github/agents/csharp-orchestrator.agent.md` `269`, prompt `52`, router skill `34`, state-machine skill `44`, bundled `atomic-plan-contract` mirror `117`, test file `106`. |
| Public vs internal | [✅] PASS | The change narrows and clarifies orchestration-facing contract text; it does not widen runtime public APIs. |
| No circular dependencies | [✅] PASS | The update changes content only; no new import graph or runtime dependency cycle is introduced. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | [✅] PASS | New contract labels such as `Build minimal-audit atomic plan (preflight all clear)` and `Validate small-path delivery and post-QC docs` are explicit and scenario-specific. |
| Docs/docstrings | [✅] PASS | The contract surface is implemented as documentation-first markdown plus a documented Python regression module. |
| Comment why, not what | [✅] PASS | The updated prompt/skill wording explains the lifecycle intent and fail-closed behavior, not just procedural mechanics. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | [✅] PASS | In-session run: `poetry run black .` → `165 files left unchanged.` |
| 2. Linting | [✅] PASS | In-session run: `poetry run ruff check` → `All checks passed!` |
| 3. Type checking | [✅] PASS | In-session run: `poetry run pyright` → `0 errors, 0 warnings, 0 informations` |
| 4. Testing | [✅] PASS | In-session run: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info` → `873 passed in 2.99s`, total coverage `83%`. |
| Full toolchain loop | [✅] PASS | The live review pass succeeded in one clean loop with no file mutations after the formatting step. |
| Explicit reporting | [✅] PASS | Commands and outcomes are recorded in this audit and in feature-folder evidence files. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | [✅] PASS | `spec.md`, `plan.2026-03-14T18-08.md`, and `evidence/qa-gates/csharp-orchestration-contract-summary.2026-03-14T18-42-49.md` summarize the implemented contract changes. |
| Design choices explained | [✅] PASS | `spec.md` explains why the fix aligns C# behavior to the generic/Python/PowerShell short-path lifecycle rather than inventing a C#-only path. |
| Update supporting documents | [✅] PASS | The feature folder contains up-to-date issue, spec, plan, baseline, regression, and QA artifacts. |
| Provide next steps | [✅] PASS | No code remediation is required; operationally, the current working-tree changes should be committed and PR context refreshed before opening a PR. |

## 3. Python-Specific Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Black | [✅] PASS | `poetry run black .` passed in-session and baseline/final evidence exists under `evidence/baseline/` and `evidence/qa-gates/`. |
| Linting with Ruff | [✅] PASS | `poetry run ruff check` passed in-session. |
| Type checking with Pyright | [✅] PASS | `poetry run pyright` passed in-session with zero diagnostics. |
| Testing with Pytest | [✅] PASS | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info` passed in-session with `873` tests. |
| Strong typing | [✅] PASS | The new regression file uses explicit annotations, `Path`, and no new `Any` or suppression comments. |
| Dataclasses for value objects | [N/A] N/A | No new value objects were introduced. |
| Protocols/ABCs for interfaces | [N/A] N/A | No Python interface layer was added in this scope. |
| Avoid utility classes | [✅] PASS | The change uses plain functions, not static-method-only utility classes. |
| Specific exceptions | [✅] PASS | The new tests raise no broad exception-handling concerns. |
| Logging over print | [✅] PASS | No new ad-hoc printing was introduced in Python code. |
| Invariants at construction | [N/A] N/A | No new class constructors were added. |

## 4. Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | [✅] PASS | The new regression suite is implemented in `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` and executed with Pytest. |
| Coverage expectation | [✅] PASS | Aggregate coverage stayed stable at `83%`, and the new contract test surface is fully exercised by the targeted suite. |
| Focused unit tests | [✅] PASS | Each test maps to one acceptance-relevant contract seam. |
| Mocking sparingly | [✅] PASS | No mocks were needed because the suite inspects checked-in text files only. |
| Organization | [✅] PASS | The new test file sits under the existing `tests/scripts/dev_tools/` contract-test area. |
| Naming conventions | [✅] PASS | Test names clearly state the exact contract being enforced. |
| Docstrings/comments | [✅] PASS | The module and helper function include concise explanatory docstrings. |
| No alternative test runners | [✅] PASS | Verification used Pytest only. |

## 5. Gaps and Exceptions

### Identified Gaps

**None.** No policy gap in the implementation or verification evidence requires code remediation.

### Approved Exceptions

**None.** No policy exceptions were needed.

### Removed/Skipped Tests

**None.** The planned regression tests were added, captured as red first, and then passed green.

## 6. Summary of Changes

### Commits in This PR/Branch

- The refreshed `pr_context` against `development` reports an empty committed range because the reviewed #101 changes are currently uncommitted in the working tree.

### Files Modified

1. **`.github/agents/csharp-orchestrator.agent.md`** (MODIFIED)
   - Replaces the old direct small-path shortcut with an explicit sequential short-path lifecycle.
2. **`.github/prompts/orchestrate-csharp-work.prompt.md`** (MODIFIED)
   - Aligns prompt instructions with `minor-audit` promotion, Phase 0-only execution, and reduced audit.
3. **`.github/skills/csharp-change-budget-router/SKILL.md`** and **`.github/skills/csharp-orchestration-state-machine/SKILL.md`** (MODIFIED)
   - Document the short-path lifecycle requirements and new checkpoint continuity fields.
4. **`extensions/drm-copilot/resources/customizations/.github/**`** (MODIFIED/ADDED)
   - Sync bundled mirrors and add the missing bundled `acceptance-criteria-tracking` skill.
5. **`tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`** (NEW)
   - Adds focused regression coverage for the updated contract surface.
6. **`docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/**`** (NEW/UPDATED)
   - Records issue, spec, plan, baseline evidence, red evidence, green evidence, and QA artifacts.

## 7. Compliance Verdict

### Overall Status: ✅ COMPLIANT

The #101 implementation is policy-compliant as reviewed in the current working tree. The contract updates are cohesive, mirror parity is enforced, the Python regression suite is strongly typed and deterministic, and the full repo-root Python quality loop passed cleanly in this session.

### Recommendation

**Ready for PR review after committing the current working-tree changes and refreshing PR context.** No code or test remediation is required.

## Appendix A: Hard-Requirement Checks

| Requirement | Status | Evidence |
|---|---|---|
| Feature folder selection documented | [✅] PASS | This audit and the companion code review record the user-specified folder rule. |
| PR context refreshed against selected base branch | [✅] PASS | Ran `poetry run python -m scripts.dev_tools.pr_context.collector --base development`; summary now reflects `development` and the supplied merge-base `dc0502de6e7b02ea76720fb898c038f01ad13f92`. |
| Phase 0 policy-read artifact exists | [✅] PASS | `evidence/baseline/phase0-instructions-read.md` exists with policy order, files read, work mode, AC source, and target plan path. |
| Baseline evidence exists for approved plan | [✅] PASS | Baseline Black/Ruff/Pyright/Pytest artifacts exist under `evidence/baseline/`. |
| Fail-before evidence exists | [✅] PASS | Five red artifacts exist under `evidence/regression-testing/`. |
| Green regression evidence exists | [✅] PASS | `evidence/other/csharp-orchestration-contracts-green.2026-03-14T18-42-49.md` records all six targeted tests passing. |
| Final QA evidence exists | [✅] PASS | `evidence/qa-gates/python-black.2026-03-14T18-45-04.md`, `python-ruff...`, `python-pyright...`, `python-pytest...`, and `python-coverage-delta...` exist. |

## Appendix B: Toolchain Commands Reference

- `git branch --show-current`
- `git rev-parse HEAD`
- `git merge-base HEAD development`
- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info`
- `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`

**Audit Completed By:** GitHub Copilot (GPT-5.4)  
**Policy Version:** Current as of 2026-03-14
