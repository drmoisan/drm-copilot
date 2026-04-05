# Policy Compliance Audit: expose-placeholder-commands (#92)

**Audit Date:** 2026-03-11  
**Code Under Test:**
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`
- `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`
- `extensions/drm-copilot/resources/templates/vscode-cli.helpers.ps1`
- `extensions/drm-copilot/resources/templates/potential_to_issue.py`
- `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder*.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue*.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/prompt_mode_contract.py`
- `extensions/drm-copilot/test/extension.test.ts`
- `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
- `tests/scripts/dev_tools/test_extension_bundled_templates.py`

- **Base branch assumption:** `main` (defaulted because `PRBaseBranch` input was not provided)
- **Feature folder selection rule:** Used the explicit active folder `docs/features/active/2026-03-11-expose-placeholder-commands-92/`, which also matches issue suffix `-92`.
- **Scope note:** The implementation under review currently exists as working-tree changes, so this audit uses direct file inspection and fresh toolchain runs as primary evidence.

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 2 source + 3 Jest files reviewed | Jest | [✅] 66 pass, 0 fail | Not recorded in canonical evidence | Not recorded in canonical evidence | UNVERIFIED |
| Python | 12 production + 1 Pytest file reviewed | Pytest | [✅] 830 pass, 0 fail | 82% lines (`evidence/baseline/python-test.2026-03-11T22-18.md`) | 82% lines (fresh run + `evidence/qa-gates/python-test.2026-03-11T22-40.md`) | UNVERIFIED |
| PowerShell | 2 production files reviewed | Pester | [✅] 222 pass, 0 fail, 7 skipped | 43.5% command coverage (`evidence/baseline/powershell-test.2026-03-11T22-19.md`) | 43.5% command coverage (`evidence/qa-gates/powershell-test.2026-03-11T22-40.md`) | UNVERIFIED |
| JSON | 1 reviewed (`package.json`) | N/A | [✅] structural inspection only | N/A | N/A | N/A |

## Executive Summary

**Overall status:** **⚠️ PARTIALLY COMPLIANT / NEEDS REVISION**

The branch is strong on source-level implementation quality and toolchain hygiene: TypeScript, Python, and PowerShell checks all pass; tests are deterministic and focused; bundled Python imports are correctly rewritten; the PowerShell helper is co-located correctly; and user-cancellation flows are handled cleanly. However, two branch-blocking compliance gaps remain:

1. The packaged extension runtime is stale: `extensions/drm-copilot/package.json` loads `./out/extension.js`, but that file still contains the retired placeholder command infrastructure.
2. The push-down rewrite catalog still emits placeholder command IDs for the four workflows, which contradicts the feature’s intended live command surface.

**Policy documents evaluated:**
- [✅] `.github/instructions/general-code-change.instructions.md`
- [✅] `.github/instructions/general-unit-test.instructions.md`
- [✅] `.github/instructions/typescript-code-change.instructions.md`
- [✅] `.github/instructions/typescript-unit-test.instructions.md`
- [✅] `.github/instructions/python-code-change.instructions.md`
- [✅] `.github/instructions/python-unit-test.instructions.md`
- [✅] `.github/instructions/powershell-code-change.instructions.md`
- [✅] `.github/instructions/powershell-unit-test.instructions.md`

**Temporary artifacts cleanup:**
- [✅] No throwaway scripts created during this audit.
- [⚠️] The feature introduces durable bundled resources; they are intentionally kept and reviewed as production assets.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence | [✅] PASS | Jest and Pytest files reset mocks/state between cases; the new Python wrapper tests restore `sys.path` and module state. |
| Isolation | [✅] PASS | New tests focus on one behavior per case: registration, args, cancellation, missing runtime, or exit handling. |
| Fast Execution | [✅] PASS | Fresh TypeScript suite finished in ~0.54s; Python suite in ~1.07s; PowerShell tests in ~4.62s. |
| Determinism | [✅] PASS | Runtime/process behavior is mocked in Jest; wrapper tests load modules from fixed file paths without network or temp-file dependencies. |
| Readability & Maintainability | [✅] PASS | Test names clearly describe scenario + expectation. |
| Coverage and scenarios | [⚠️] PARTIAL | Source-level coverage is good for the new handlers, but no test guards the packaged `out/extension.js` entry point or the push-down rewrite catalog, which allowed delivery drift. |
| External dependencies avoided | [✅] PASS | Unit suites use mocks/fakes instead of live extension host or external services. |
| Environment stability | [✅] PASS | No prohibited temp files were created; test state is controlled via mocks and in-memory structures. |
| Pre-submission review documented | [✅] PASS | This artifact documents the review. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Clarify the objective | [✅] PASS | Issue, spec, user story, and plan all clearly define the placeholder-command replacement objective. |
| Read existing change plans | [✅] PASS | `plan.2026-03-11T21-40.md` exists and matches the implementation scope. |
| Document the plan | [✅] PASS | The feature folder includes plan/spec/user-story/research docs. |
| Simplicity first | [✅] PASS | Command handlers remain thin and delegate to shared launch helpers or bundled scripts. |
| Reusability | [✅] PASS | Shared prompt helpers were introduced in `src/extension.ts`; bundled Python code reuses the existing module structure. |
| Separation of concerns | [✅] PASS | UI collection stays in the extension layer; business logic remains in bundled Python/PowerShell resources. |
| Cohesive modules | [✅] PASS | New production files are logically scoped by command/workflow. |
| Naming, docs, comments | [✅] PASS | Names are descriptive and wrappers include intent-level docstrings. |
| Toolchain loop completed | [✅] PASS | Fresh review run passed TypeScript, Python, and PowerShell loops without failures. |
| Supporting docs updated accurately | [❌] FAIL | `README.md` and `extensions/drm-copilot/README.md` claim live rewrite behavior, but `push_down_copilot_customizations_rewrites.py` still emits placeholder command IDs. |
| Provide clear next steps | [✅] PASS | Remediation inputs and plan are generated by this audit. |

## 3. Language-Specific Code Change Policy Compliance

### 3A. TypeScript

| Requirement | Status | Evidence |
|---|---|---|
| Formatting / lint / typecheck / Jest | [✅] PASS | Fresh review run passed all four extension-local commands. |
| Strong typing | [✅] PASS | No new `any`-style escape hatches introduced in reviewed files. |
| Thin VS Code wiring | [✅] PASS | New handlers gather input then delegate to `executeBundledScript`. |
| Public compatibility / delivery correctness | [❌] FAIL | The actual extension `main` entry point still points at stale `out/extension.js`, so packaged behavior does not match the reviewed source. |

### 3B. Python

| Requirement | Status | Evidence |
|---|---|---|
| Black / Ruff / Pyright / Pytest | [✅] PASS | Fresh review run: all clean, 830 tests passed. |
| Strong typing and structure | [✅] PASS | Protocols and dataclasses are used appropriately in the bundled helpers. |
| Import rewrite correctness | [✅] PASS | New bundled modules import `dev_tools...` rather than `scripts.dev_tools...`. |
| Behavior aligned to extension command surface | [❌] FAIL | `push_down_copilot_customizations_rewrites.py` still maps the four workflows to placeholder IDs/titles. |

### 3C. PowerShell

| Requirement | Status | Evidence |
|---|---|---|
| PoshQC format / analyze / Pester | [✅] PASS | Fresh review run passed all three direct commands. |
| Safe scripting practices | [✅] PASS | No `Invoke-Expression`; helper is co-located and sourced via `$PSScriptRoot`. |
| Workspace resolution update | [✅] PASS | Bundled `new-potential-entry.ps1` uses `(Get-Location).Path` as required. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| TypeScript uses Jest appropriately | [✅] PASS | The new command tests are Jest unit tests and do not require a live extension host. |
| Python uses Pytest appropriately | [✅] PASS | `tests/scripts/dev_tools/test_extension_bundled_templates.py` is a focused Pytest module. |
| PowerShell uses Pester appropriately | [✅] PASS | Existing PowerShell repo suite passes under direct `Invoke-PoshQCTest`. |
| New/changed behavior sufficiently covered | [⚠️] PARTIAL | Core handler flows are covered, but packaging drift and rewrite-catalog drift were not tested. |

## 5. Code Quality Checks

| Check | Command | Result | Status |
|---|---|---|---|
| TypeScript format | `npm --prefix extensions/drm-copilot run format` | Passed; unchanged files | [✅] |
| TypeScript lint | `npm --prefix extensions/drm-copilot run lint` | Passed | [✅] |
| TypeScript typecheck | `npm --prefix extensions/drm-copilot run typecheck` | Passed | [✅] |
| TypeScript tests | `npm --prefix extensions/drm-copilot run test:unit` | 66 passed | [✅] |
| Python format | `poetry run black .` | Passed; 155 unchanged | [✅] |
| Python lint | `poetry run ruff check` | Passed | [✅] |
| Python typecheck | `poetry run pyright` | Passed | [✅] |
| Python tests | `poetry run pytest --cov-report=term-missing` | 830 passed | [✅] |
| PowerShell format | `pwsh ... Invoke-PoshQCFormat -Root .` | Passed | [✅] |
| PowerShell analyze | `pwsh ... Invoke-PoshQCAnalyze -Root .` | Passed | [✅] |
| PowerShell tests | `pwsh ... Invoke-PoshQCTest -Root .` | 222 passed / 7 skipped | [✅] |

## 6. Gaps and Exceptions

### Identified Gaps

1. **Packaged runtime drift** — `out/extension.js` is stale even though `src/extension.ts` is updated.
2. **Rewrite-catalog drift** — push-down rewrite output still targets retired placeholder IDs.
3. **Spec UX gap** — `potentialToIssue` file picker lacks the documented default folder.
4. **Coverage gap** — no automated check validates the built extension artifact or rewrite catalog.

### Approved Exceptions

**None.** No policy exceptions were identified or approved.

### Removed/Skipped Tests

**None intentionally skipped during this audit.** The gap is missing coverage for package/runtime drift, not a consciously skipped test recorded in the plan.

## 7. Compliance Verdict

### Overall Status: **❌ NON-COMPLIANT**

The working-tree implementation is promising and toolchain-clean, but the branch is not policy-complete for delivery because the packaged extension runtime is stale and the documented rewrite behavior is not actually implemented in the rewrite catalog.

### Recommendation

**Needs revision**

Address the stale packaged runtime and rewrite-catalog drift first, then add regression coverage so the same mismatch cannot recur. After those fixes, the remaining file-picker default-folder gap can be closed quickly.

## Appendix B: Toolchain Commands Reference

### Commands run during this audit

- `npm --prefix extensions/drm-copilot run format`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit`
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov-report=term-missing`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

**Audit Completed By:** GitHub Copilot (GPT-5.4)  
**Policy Version:** Current as of 2026-03-11
