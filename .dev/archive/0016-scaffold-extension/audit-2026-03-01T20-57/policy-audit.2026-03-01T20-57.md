# Policy Compliance Audit: scaffold-extension (Issue #16)

**Audit Date:** 2026-03-01  
**Base Branch:** `main`  
**Feature Folder Selection Rule:** User provided explicit folder `docs/features/active/2026-01-28-scaffold-extension-16`; this folder was used as authoritative scope.  
**Code Under Test:**
- `extensions/scaffold-extension/package.json`
- `extensions/scaffold-extension/src/extension.ts`
- `extensions/scaffold-extension/test/extension.test.ts`
- `extensions/scaffold-extension/test/extension.integration.test.ts`
- `extensions/scaffold-extension/README.md`
- `extensions/scaffold-extension/resources/templates/hello_python.py`
- `extensions/scaffold-extension/resources/templates/hello_pwsh.ps1`

## Executive Summary

The extension implementation itself is in good local shape (format/lint/typecheck/test all pass for `extensions/scaffold-extension`). However, relative to `main`, the committed PR range is docs-only; implementation files are currently untracked in working tree and therefore not PR-merge-ready. Acceptance coverage also has gaps (notably missing explicit missing-PowerShell runtime test and weak cross-platform integration evidence).

**Overall Status:** ❌ **NON-COMPLIANT (merge readiness)**

Policy documents evaluated:
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`
- [✅] `typescript-code-change.instructions.md`
- [✅] `typescript-unit-test.instructions.md`
- [✅] `python-code-change.instructions.md` (for bundled Python script review)
- [✅] `powershell-code-change.instructions.md` (for bundled PowerShell script review)

## 1) General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Clarify objective / plan docs | [✅] PASS | `issue.md`, `spec.md`, `user-story.md`, and `plan.2026-03-01T00-00.md` exist in feature folder. |
| Simplicity / separation | [✅] PASS | `src/extension.ts` uses focused helpers (`getWorkspaceRoot`, `detectRuntime`, `runCommandWithOutput`). |
| Cohesive modules | [✅] PASS | Extension logic and tests are separated cleanly under `extensions/scaffold-extension/`. |
| Public/internal boundaries | [✅] PASS | Public exports limited to `activate`, `deactivate`, and `detectRuntime` (test-targeted). |
| Merge-ready scope (base diff) | [❌] FAIL | `git diff --name-status origin/main...HEAD` contains docs-only changes for this feature; implementation files are untracked (`?? extensions/`). |

## 2) Toolchain Execution Evidence

### Extension toolchain (current run)

| Step | Command | Result |
|---|---|---|
| Formatting (check-only) | `Push-Location extensions/scaffold-extension; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location` | PASS (`All matched files use Prettier code style!`) |
| Linting | `npm --prefix extensions/scaffold-extension run lint` | PASS |
| Type checking | `npm --prefix extensions/scaffold-extension run typecheck` | PASS |
| Testing | `npm --prefix extensions/scaffold-extension run test` | PASS (`2 suites, 14 tests`) |

### Existing feature evidence consumed

- `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/typescript-toolchain.2026-03-01T00-00.md`
- `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/python-toolchain.2026-03-01T00-00.md`
- `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/powershell-toolchain.2026-03-01T00-00.md`

## 3) Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence / isolation | [✅] PASS | Jest tests use mocks and isolated handler maps per test setup. |
| Determinism | [✅] PASS | Runtime/process behavior mocked via `jest.mock` and deterministic event emitters. |
| Error coverage completeness | [⚠️] PARTIAL | No explicit test asserting missing PowerShell runtime message path. |
| Integration realism | [⚠️] PARTIAL | `extension.integration.test.ts` is still mock-driven; does not execute real subprocesses on both OS families. |

## 4) Language-Specific Notes

### TypeScript
- [✅] Toolchain quality gates pass for extension scope.
- [⚠️] PR/base diff mismatch with implementation scope (docs committed, implementation uncommitted).

### Python (bundled script)
- [✅] Script behavior is simple and deterministic for artifact output.
- [⚠️] Not included in pyright project include set; typed-Python policy impact should be explicitly resolved during remediation.

### PowerShell (bundled script)
- [✅] Script writes expected artifact.
- [⚠️] No focused analyzer/test evidence for script-level edge/error behavior in extension tests.

## 5) Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT

### Why
1. **Blocker:** Feature implementation is not represented in committed base diff to `main` (merge readiness failure).
2. **Major:** Acceptance test coverage is incomplete for required runtime-missing/error scenarios and platform-specific integration confidence.
3. **Minor:** README/platform notes do not yet fully satisfy AC wording for explicit Windows/macOS/Linux expectations.

### Recommendation
**Needs revision** before PR is safe to open/merge.

## Appendix B: Commands Executed in This Review

- `poetry run python -m scripts.dev_tools.pr_context.collector --base main`
- `Push-Location extensions/scaffold-extension; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location`
- `npm --prefix extensions/scaffold-extension run lint`
- `npm --prefix extensions/scaffold-extension run typecheck`
- `npm --prefix extensions/scaffold-extension run test`
- `git status --short`
- `git diff --name-status origin/main...HEAD`

**Audit Completed By:** GitHub Copilot (GPT-5.3-Codex)
