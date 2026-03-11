# Code Review — scaffold-extension (Issue #16)

**Base:** `main`  
**Feature Folder Selection Rule:** Explicitly provided by user (`docs/features/active/2026-01-28-scaffold-extension-16`).

## Executive Summary

What changed:
- Implemented a new extension scaffold under `extensions/scaffold-extension` with command registration, runtime probing, bundled script execution, and Jest tests.
- Added documentation and scoped feature artifacts under active feature folder.

Top 3 risks:
1. **Blocker:** Implementation files are untracked and absent from committed base diff (`origin/main...HEAD`), so PR delta is not delivering the feature yet.
2. **Major:** Integration tests are mock-based and do not provide true cross-platform runtime execution confidence.
3. **Major:** Acceptance error-path coverage is incomplete (no explicit missing-PowerShell runtime test assertion).

**Go/No-Go for PR readiness:** **NO-GO** until remediation items are completed.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | Repository scope | git range | Feature implementation not in committed PR range to `main`. | Stage/commit extension implementation files and regenerate PR context. | Merge would carry docs but not functional code. | `git diff --name-status origin/main...HEAD` (docs-only for this feature), `git status --short` shows `?? extensions/`. |
| Major | `extensions/scaffold-extension/test/extension.test.ts` | runtime error tests | Missing explicit test for missing PowerShell runtime error path. | Add test for `detectRuntime("powershell")` when neither `pwsh` nor `powershell` exists. | AC requires explicit runtime validation errors for both runtimes. | Current tests include missing Python case only. |
| Major | `extensions/scaffold-extension/test/extension.integration.test.ts` | entire file | “Integration” tests are fully mocked and not true E2E on Windows/POSIX. | Add real subprocess-backed integration checks (or explicit platform matrix CI tests with stronger evidence). | Current suite validates orchestration shape but not actual runtime execution in both OS families. | All runtime/fs/child_process behavior is mocked in test file. |
| Minor | `extensions/scaffold-extension/README.md` | platform guidance | README lacks explicit per-platform runtime notes (Windows/macOS/Linux expectations). | Add platform section with runtime names and expected availability caveats per OS. | AC explicitly requests platform notes. | README currently lists runtimes globally only. |
| Minor | `extensions/scaffold-extension/README.md` | feature positioning | README does not clearly include a dedicated “foundation for production extensions” section heading. | Add explicit section showing how scaffold pattern scales to production. | AC explicitly calls for this narrative. | README has concise summary but no dedicated section. |

## Typed Python Audit

Python files in scope:
- `extensions/scaffold-extension/resources/templates/hello_python.py`

Assessment:
- No `Any` usage.
- Minimal function is deterministic and type-annotated (`main() -> None`).
- No broad exception handling.

Concern:
- This file is outside normal pyright include paths in current repo configuration; typed-Python governance evidence is therefore **partial** for this specific script path.

## Test Quality Audit

- Deterministic: ✅
- Isolated: ✅
- Fast: ✅
- Failure diagnostics: ✅
- Completeness versus AC: ⚠️ partial (missing explicit missing-PowerShell runtime test, true cross-platform E2E evidence)

## Security / Correctness Checks

- Uses `spawn(executable, args, { shell: false })`: ✅ avoids shell-string concatenation.
- Runtime lookup based on PATH scanning: ✅ explicit checks, actionable errors.
- Workspace guard exists: ✅ (`No workspace folder is open.`)
- Secret leakage: no hardcoded secrets observed.

## Recommendation

**NO-GO (needs revision).**

Promote to GO after:
1. Implementation is committed and present in PR diff to `main`.
2. Missing-PowerShell runtime error test exists and passes.
3. Cross-platform integration evidence is strengthened to satisfy AC language.
4. README platform and production-foundation sections are completed.
