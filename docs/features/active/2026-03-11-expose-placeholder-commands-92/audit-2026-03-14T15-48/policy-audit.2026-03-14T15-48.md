# Policy Compliance Audit: expose-placeholder-commands feature branch

**Audit Date:** 2026-03-14  
**Base Branch:** `origin/development` (from `artifacts/pr_context.summary.txt`)  
**Feature Folder:** `docs/features/active/2026-03-11-expose-placeholder-commands-92`  
**Feature folder selection rule:** Selected this folder because `artifacts/pr_context.summary.txt` identifies `docs/features/active/2026-03-11-expose-placeholder-commands-92/spec.md` and `user-story.md` as the primary scoping docs changed, and the folder suffix matches issue `#92`.

**Code Under Test:**
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`
- `extensions/drm-copilot/resources/templates/potential_to_issue.py`
- `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`
- `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`
- `extensions/drm-copilot/resources/scripts/dev_tools/**`
- `scripts/dev_tools/new_active_feature_folder_*.py`
- `scripts/dev_tools/potential_to_issue*.py`
- `scripts/dev_tools/prompt_mode_contract.py`
- `scripts/dev-tools/new-potential-entry.ps1`
- `extensions/drm-copilot/test/*.ts`
- `tests/extensions/drm_copilot/resources/templates/*.py`
- `tests/scripts/dev_tools/*.py`
- `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 6 `.ts` files in PR range | 74 | [✅] 74 pass, 0 fail | **Missing for feature #92** — baseline artifact `evidence/baseline/typescript-test.2026-03-11T22-17.md` recorded test counts only, not coverage | 89.30% statements / 89.30% lines from `npm --prefix extensions/drm-copilot run test:unit -- --coverage` on 2026-03-14 | 90.48% statements for `extensions/drm-copilot/src/extension.ts` (current changed-runtime proxy) |
| Python | 28 `.py` files in PR range | 843 | [✅] 843 pass, 0 fail | 82% overall (`evidence/baseline/python-test.2026-03-11T22-18.md`) | 82% overall (`poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, 2026-03-14) | **68% minimum across changed modules** (`scripts/dev_tools/new_active_feature_folder_models.py`), with other changed modules at 82% and 86%; fails repo ≥90% target for new modules |
| PowerShell | 2 changed production `.ps1` files plus tests in PR range | 224 | [✅] 224 pass, 0 fail | 43.5% commands (`evidence/baseline/powershell-test.2026-03-11T22-19.md`) | 42.98% commands (`Invoke-PoshQCTest -Root .`, 2026-03-14) | Not isolated for changed code in current feature evidence; overall regression observed |

## Executive Summary

This branch **substantially implements** the live command replacement feature, and the fresh TypeScript, Python, and PowerShell toolchain runs all completed successfully on the current branch tip. However, the branch is **not fully policy-compliant** for PR readiness.

The main blockers are:
- the `new_potential_bug_entry.py` extension template is a **full logic copy**, not a thin wrapper, so one feature acceptance criterion is not actually met;
- changed Python modules do **not** satisfy the repo’s `>= 90%` new-code coverage expectation;
- TypeScript feature baseline coverage was not captured for feature `#92`, and PowerShell overall coverage regressed slightly from `43.5%` to `42.98%`.

**Policy documents evaluated:**
- [✅] `.github/instructions/general-code-change.instructions.md`
- [✅] `.github/instructions/general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `.github/instructions/typescript-code-change.instructions.md` + `.github/instructions/typescript-unit-test.instructions.md`
- [✅] `.github/instructions/python-code-change.instructions.md` + `.github/instructions/python-unit-test.instructions.md`
- [✅] `.github/instructions/powershell-code-change.instructions.md` + `.github/instructions/powershell-unit-test.instructions.md`
- [N/A] Bash
- [N/A] Separate governed JSON policy

**Temporary artifacts cleanup:**
- [✅] No throwaway development scripts were left behind in the reviewed feature implementation.
- [✅] Ongoing tooling scripts kept in the branch remain under test.
- Deleted `extensions/drm-copilot/coverage/**` artifacts were cleaned from version control; verification now lives in feature evidence instead.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [✅] [PASS] | Fresh Jest run passed 74/74 tests across 5 suites; fresh Pytest run passed 843/843 tests; fresh Pester run passed 224/224 tests. Changed tests use local mocks (`showInputBox`, `showQuickPick`, `showOpenDialog`, `spawn`) and do not share mutable cross-test state in the reviewed files. |
| Isolation | [✅] [PASS] | `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`, `extension.potential-to-issue.test.ts`, and wrapper-import Pytests each target discrete command or wrapper behaviors. PowerShell regression tests remain focused on `new-potential-entry.ps1` behaviors. |
| Fast Execution | [✅] [PASS] | Current runs completed quickly for the changed surfaces: Jest coverage run took ~1.11s; Pytest completed in 3.24s; Pester completed in 11.41s. |
| Determinism | [✅] [PASS] | Reviewed TypeScript and Python tests use deterministic mocks and fixed inputs. No temporary files are created by the newly added TypeScript or Python tests. |
| Readability & Maintainability | [✅] [PASS] | Test names clearly express outcomes, e.g. active-editor reuse, prompt retention, placeholder absence, and wrapper import behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | [⚠️] [PARTIAL] | Python baseline (`82%`) and PowerShell baseline (`43.5%`) are documented in feature evidence. TypeScript baseline for feature `#92` did **not** record coverage, only test counts, so the feature review cannot issue a PASS-grade coverage verdict for that language. |
| No Coverage Regression | [❌] [FAIL] | PowerShell overall coverage regressed from `43.5%` in `evidence/baseline/powershell-test.2026-03-11T22-19.md` to `42.98%` in the fresh `Invoke-PoshQCTest -Root .` run on 2026-03-14. |
| New Code Coverage ≥90% | [❌] [FAIL] | Fresh Pytest coverage shows changed Python modules below target: `scripts/dev_tools/new_active_feature_folder_models.py` = `68%`, `scripts/dev_tools/potential_to_issue_content.py` = `82%`, `scripts/dev_tools/prompt_mode_contract.py` = `86%`. |
| Comprehensive Coverage | [⚠️] [PARTIAL] | TypeScript command handlers are well covered (`extension.ts` 90.48% statements), but changed Python helper modules do not meet the repo’s new-module bar. |
| Positive Flows | [✅] [PASS] | Fresh Jest and Pytest runs cover normal command registration, valid input collection, delegation, and wrapper import success. |
| Negative Flows | [✅] [PASS] | Reviewed tests cover cancelled prompts, missing runtimes, and non-zero subprocess exits. |
| Edge Cases | [✅] [PASS] | `potentialToIssue` tests cover active-editor reuse vs picker fallback; PowerShell regression tests cover missing directory creation and VS Code reuse-window behavior. |
| Error Handling | [✅] [PASS] | Tests explicitly exercise missing runtime and non-zero exit handling across all four extension commands. |
| Concurrency | [N/A] [N/A] | No concurrent behavior is introduced by the reviewed feature commands. |
| State Transitions | [N/A] [N/A] | The reviewed commands are stateless subprocess launchers. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | [✅] [PASS] | Jest matchers assert on exact command IDs/argv pairs; Pytest wrapper tests include direct assertion messages for import-path insertion. |
| Arrange-Act-Assert Pattern | [✅] [PASS] | Sampled changed tests follow clear setup → handler call/import → assertion structure. |
| Document Intent | [✅] [PASS] | Python wrapper tests include docstrings; TypeScript test names are scenario-specific and descriptive. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | [✅] [PASS] | The changed TypeScript, Python, and PowerShell tests for this feature use mocks and local filesystem abstractions rather than real network/API calls. |
| Use Mocks/Stubs | [✅] [PASS] | Changed TypeScript tests mock VS Code APIs and subprocess spawning; Python wrapper tests patch `importlib.import_module`. |
| Environment Stability | [✅] [PASS] | No newly added test in the reviewed feature depends on mutable machine-specific state beyond mocked runtime discovery. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | [✅] [PASS] | This audit plus the fresh toolchain runs provide the required review artifact. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | [✅] [PASS] | Objective captured in `issue.md`, `spec.md`, and `user-story.md` for issue `#92`. |
| Read existing change plans | [✅] [PASS] | `plan.2026-03-11T21-40.md` exists and records phase/task completion. |
| Document the plan | [✅] [PASS] | The feature plan and evidence tree document implementation order and QA gates. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | [⚠️] [PARTIAL] | `extension.ts` keeps command wiring reasonably thin, but `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` duplicates business logic instead of delegating like the other wrappers. |
| Reusability | [⚠️] [PARTIAL] | Bundled `dev_tools` modules are reused for `new_active_feature_folder` and `potential_to_issue`, but `new_potential_bug_entry` remains duplicated in the template layer. |
| Extensibility | [✅] [PASS] | Command specs and prompt helpers make the extension command surface easy to extend. |
| Separation of concerns | [⚠️] [PARTIAL] | Most command handlers are thin orchestration, but the bug-entry template blends CLI boundary and domain logic in a packaged entry file. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | [✅] [PASS] | Reviewed files remain purpose-specific (`extension.ts`, dedicated wrapper files, dedicated tests). |
| Under 500 lines | [✅] [PASS] | Sampled changed production files are under the 500-line repo limit. |
| Public vs internal | [✅] [PASS] | The extension public surface is limited to command IDs and bundled entry points. |
| No circular dependencies | [✅] [PASS] | No cycle evidence surfaced in type-checking or from inspected imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | [✅] [PASS] | Command IDs, helper names, and wrapper filenames describe behavior clearly. |
| Docs/docstrings | [✅] [PASS] | Sampled Python modules and wrappers include docstrings, including the wrapper tests. |
| Comment why, not what | [✅] [PASS] | Sampled wrappers explain delegation intent rather than line-by-line mechanics. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | [✅] [PASS] | `npm --prefix extensions/drm-copilot run format`, `poetry run black .`, and `Invoke-PoshQCFormat -Root .` all completed cleanly on 2026-03-14. |
| 2. Linting | [✅] [PASS] | `npm --prefix extensions/drm-copilot run lint`, `poetry run ruff check`, and `Invoke-PoshQCAnalyze -Root .` all passed. |
| 3. Type checking | [✅] [PASS] | `npm --prefix extensions/drm-copilot run typecheck` and `poetry run pyright` both passed; PowerShell type checking is not applicable per repo policy. |
| 4. Testing | [✅] [PASS] | Fresh Jest coverage, Pytest coverage, and Pester runs all passed. |
| Full toolchain loop | [✅] [PASS] | Each language loop passed in a single clean pass during this review. |
| Explicit reporting | [✅] [PASS] | Commands and results are recorded in this audit and the feature evidence tree. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | [✅] [PASS] | `artifacts/pr_context.summary.txt` and feature docs summarize the feature and subsequent merged fixes in range. |
| Design choices explained | [✅] [PASS] | `spec.md` documents the command wiring strategy and wrapper/delegation model. |
| Update supporting documents | [✅] [PASS] | `issue.md`, `spec.md`, `user-story.md`, `plan.2026-03-11T21-40.md`, and evidence artifacts were updated. |
| Provide next steps | [⚠️] [PARTIAL] | The branch lacks a clean merge-ready state because of unmet acceptance/policy items, so remediation steps are still required. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Prettier | [✅] [PASS] | `npm --prefix extensions/drm-copilot run format` reported all files unchanged on 2026-03-14. |
| Linting with ESLint | [✅] [PASS] | `npm --prefix extensions/drm-copilot run lint` passed with no findings. |
| Type checking with TSC | [✅] [PASS] | `npm --prefix extensions/drm-copilot run typecheck` passed. |
| Testing with Jest | [✅] [PASS] | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` passed 74/74 tests. |
| Strong typing | [✅] [PASS] | No `any`, `as any`, or `console.log` usage surfaced in `extensions/drm-copilot/src/extension.ts`; command handlers are typed and TSC-clean. |
| Separation of concerns | [✅] [PASS] | `extension.ts` keeps UI/input gathering separate from runtime execution via `executeBundledScript`. |

### Section 3B: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Black | [✅] [PASS] | `poetry run black .` passed; 160 files unchanged. |
| Linting with Ruff | [✅] [PASS] | `poetry run ruff check` passed. |
| Type checking with Pyright | [✅] [PASS] | `poetry run pyright` returned `0 errors`. |
| Strong typing | [✅] [PASS] | No `Any` surfaced in the sampled changed Python modules. |
| Specific exceptions | [⚠️] [PARTIAL] | `scripts/dev_tools/new_active_feature_folder_io.py` still contains `except Exception:` around updated-date parsing, and the bundled mirror repeats it. |
| Logging over print | [✅] [PASS] | CLI-facing prints are limited to user-facing command output in CLI entrypoints; no ad-hoc debugging prints were observed in the reviewed modules. |

### Section 3C: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Invoke-Formatter | [✅] [PASS] | Direct `Invoke-PoshQCFormat -Root .` run reported reviewed files already formatted. |
| Linting with PSScriptAnalyzer | [✅] [PASS] | Direct `Invoke-PoshQCAnalyze -Root .` run passed with no findings. |
| Fix all findings | [✅] [PASS] | No PSScriptAnalyzer findings were reported in the fresh review run. |
| PowerShell 7+ compatible | [✅] [PASS] | The repo-standard PoshQC pipeline passed under `pwsh`. |
| Toolchain loop | [⚠️] [PARTIAL] | Commands passed, but branch-level PowerShell coverage regressed slightly and changed-code coverage was not isolated in feature evidence. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | [✅] [PASS] | Changed Python tests run under Pytest and passed in the fresh coverage run. |
| Coverage expectation | [❌] [FAIL] | Fresh coverage output shows changed Python modules below the required `>= 90%` target for new modules. |
| Focused unit tests | [✅] [PASS] | Wrapper import tests and feature-folder tests are targeted and deterministic. |
| Mocking sparingly | [✅] [PASS] | Wrapper tests patch only `importlib.import_module` and keep scope narrow. |
| No alternative test runners | [✅] [PASS] | Only Pytest was used for Python verification. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pester v5.x | [✅] [PASS] | Fresh verification used `Invoke-PoshQCTest -Root .` per repo policy. |
| Use PoshQC configuration | [✅] [PASS] | Verification used the repo-standard PoshQC entrypoint. |
| Focused unit tests | [✅] [PASS] | The changed `new-potential-entry.Tests.ps1` regression scenarios remain targeted. |
| Organization mirrors code | [✅] [PASS] | `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` mirrors `scripts/dev-tools/new-potential-entry.ps1`. |
| No alternative test runners | [✅] [PASS] | Only Pester via PoshQC was used. |

---

## 5. Test Coverage Detail

### `extensions/drm-copilot/src/extension.ts`

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `registers newPotentialBugEntry` | Positive | [✅] |
| `newPotentialBugEntry passes the bundled script path and short-name args` | Positive | [✅] |
| `newPotentialEntry passes the bundled script path and short-name args` | Positive | [✅] |
| `reuses the active potential editor path before falling back to the file picker` | Edge Case | [✅] |
| `passes the bundled script path and omits --issue-number when blank` | Edge Case | [✅] |
| cancellation / missing-runtime / non-zero-exit scenarios across all commands | Negative / Error Handling | [✅] |

**Coverage:** 90.48% statements / 92.42% branches in the fresh Jest coverage run.

### Changed Python helpers under `scripts/dev_tools/`

| Module | Current Coverage | Status |
|--------|------------------|--------|
| `new_active_feature_folder_models.py` | 68% | [❌] |
| `potential_to_issue_content.py` | 82% | [❌] |
| `prompt_mode_contract.py` | 86% | [❌] |
| `new_active_feature_folder_flow.py` | 91% | [✅] |
| `potential_to_issue.py` | 90% | [✅] |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| TypeScript tests | 74 passed / 74 total | [✅] |
| Python tests | 843 passed / 843 total | [✅] |
| PowerShell tests | 224 passed / 224 total (7 skipped) | [✅] |
| Jest execution time | 1.111s | [✅] |
| Pytest execution time | 3.24s | [✅] |
| Pester execution time | 11.41s | [✅] |
| TypeScript coverage | 89.30% statements overall | [✅] |
| Python coverage | 82% overall | [✅] |
| PowerShell coverage | 42.98% overall | [⚠️] |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Extension formatting | `npm --prefix extensions/drm-copilot run format` | Passed; all files unchanged | [✅] |
| Extension lint | `npm --prefix extensions/drm-copilot run lint` | Passed | [✅] |
| Extension type-check | `npm --prefix extensions/drm-copilot run typecheck` | Passed | [✅] |
| Extension Jest + coverage | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | 74/74 tests passed; 89.30% stmts overall | [✅] |
| Python formatting | `poetry run black .` | Passed; 160 files unchanged | [✅] |
| Python lint | `poetry run ruff check` | Passed | [✅] |
| Python type-check | `poetry run pyright` | 0 errors | [✅] |
| Python Pytest + coverage | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | 843/843 tests passed; 82% total coverage | [✅] |
| PowerShell format | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` | Passed; already formatted | [✅] |
| PowerShell analyze | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` | Passed; no findings | [✅] |
| PowerShell test | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` | 224 passed; 42.98% overall coverage | [⚠️] |

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **Thin-wrapper criterion not met for `newPotentialBugEntry`.** `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` is a full implementation file, and there is no bundled `resources/scripts/dev_tools/new_potential_bug_entry.py` to delegate to.
2. **Python new-module coverage policy is not met.** Changed modules under `scripts/dev_tools/` are below the repo’s `>= 90%` target.
3. **TypeScript feature baseline coverage is missing for feature `#92`.** The feature’s baseline evidence recorded only test counts, not coverage.
4. **PowerShell coverage regressed slightly.** Fresh overall coverage (`42.98%`) is lower than the feature baseline (`43.5%`).
5. **Typed error handling could be tighter.** `new_active_feature_folder_io.py` still uses a broad `except Exception:` in updated-date parsing.

### Approved Exceptions

**None.** No explicit policy exceptions were documented for these gaps.

### Removed/Skipped Tests

**None identified** in the reviewed feature implementation.

---

## 9. Summary of Changes

### Commits in This PR/Branch

See `artifacts/pr_context.appendix.txt` for the full range. High-signal commits in range include:
1. `f12dd9c` - `(feat(extension-commands)): replace placeholder workflows with live handlers`
2. `ae5e432` / `485c2ff` - template-resolution follow-up fixes merged into this branch
3. `fd3e911` - PowerShell `new-potential-entry` fix merged into this branch
4. `603d6c7` - potential-to-issue active-file auto-resolution fix merged into this branch

### Files Modified

- `extensions/drm-copilot/src/extension.ts` — live command registration and input gathering
- `extensions/drm-copilot/package.json` — live command contributions
- `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` — packaged bug-entry CLI implementation (currently too heavy for a wrapper)
- `extensions/drm-copilot/resources/templates/new_active_feature_folder.py` — thin wrapper
- `extensions/drm-copilot/resources/templates/potential_to_issue.py` — thin wrapper
- `extensions/drm-copilot/resources/scripts/dev_tools/**` — bundled Python implementation modules
- `scripts/dev_tools/*.py` and `scripts/dev-tools/new-potential-entry.ps1` — source implementations mirrored into extension resources
- `extensions/drm-copilot/test/*.ts`, `tests/extensions/...`, `tests/scripts/dev_tools/...` — unit and wrapper tests

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The branch is functionally strong but not policy-clean enough for merge as a feature `#92` PR. Fresh QC is green, yet the branch misses one acceptance criterion, violates the Python new-module coverage target, lacks TypeScript baseline coverage evidence for the feature, and shows a small PowerShell coverage regression.

### Policy-by-Policy Summary

- General Code Change Policy: ⚠️ PARTIAL
- TypeScript Code Change Policy: ✅ PASS
- Python Code Change Policy: ⚠️ PARTIAL
- PowerShell Code Change Policy: ⚠️ PARTIAL
- General Unit Test Policy: ⚠️ PARTIAL
- Python Unit Test Policy: ❌ FAIL
- PowerShell Unit Test Policy: ⚠️ PARTIAL

### Metrics Summary

- [✅] 74/74 extension Jest tests passing with 89.30% statement coverage
- [✅] 843/843 Python tests passing with 82% overall coverage
- [✅] 224/224 PowerShell tests passing
- [❌] Changed Python modules below `>= 90%` new-code coverage target
- [❌] PowerShell overall coverage regressed from 43.5% to 42.98%
- [❌] TypeScript feature baseline coverage missing from feature `#92` evidence

### Recommendation

**Needs revision**

Before opening or merging a PR for feature `#92`, remediate the non-thin `newPotentialBugEntry` template, raise changed Python-module coverage to policy minimums, and restore complete language coverage evidence (including a comparable TypeScript baseline and a non-regressing PowerShell result).

---

## Appendix A: Test Inventory

- `extensions/drm-copilot/test/extension.test.ts`
- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
- `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
- `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`
- `extensions/drm-copilot/test/extension.integration.test.ts`
- `tests/extensions/drm_copilot/resources/templates/test_new_active_feature_folder.py`
- `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder_part3.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder_markdown_escape.py`
- `tests/scripts/dev_tools/test_new_potential_bug_entry.py`
- `tests/scripts/dev_tools/test_potential_to_issue.py`
- `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`

## Appendix B: Toolchain Commands Reference

- `npm --prefix extensions/drm-copilot run format`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

**Audit Completed By:** GitHub Copilot (`GPT-5.4`)  
**Audit Date:** 2026-03-14  
**Policy Version:** Current as of audit date
