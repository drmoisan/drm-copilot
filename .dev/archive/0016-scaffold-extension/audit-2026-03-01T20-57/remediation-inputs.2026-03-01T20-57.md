# Remediation Inputs — scaffold-extension (Issue #16)

## Required Fixes (authoritative)

1. **Commit feature implementation into PR-visible scope**
   - **Files:**
     - `extensions/scaffold-extension/**`
     - any related root wiring files required by extension tests/build
   - **Expected behavior:** `git diff --name-status origin/main...HEAD` must include extension implementation files, not only docs.
   - **Acceptance criteria:** Feature delivery is present in merge diff.
   - **Verification:**
     - `git diff --name-status origin/main...HEAD`
     - `git status --short`

2. **Add explicit missing-PowerShell runtime error test**
   - **Files:** `extensions/scaffold-extension/test/extension.test.ts`
   - **Expected behavior:** Test asserts actionable error when both `pwsh` and `powershell` are absent.
   - **Acceptance criteria:** Error-case AC includes missing PowerShell runtime.
   - **Verification:** `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "missing PowerShell"`

3. **Strengthen integration evidence for Windows and POSIX**
   - **Files:** `extensions/scaffold-extension/test/extension.integration.test.ts` (+ CI config if needed)
   - **Expected behavior:** At least one non-trivial integration path validates behavior with platform-specific runtime assumptions and no-copy invariant under realistic execution constraints.
   - **Acceptance criteria:** Integration tests cover end-to-end execution of both commands on Windows and POSIX platforms.
   - **Verification:**
     - `npm --prefix extensions/scaffold-extension run test`
     - platform-matrix CI evidence artifact (Windows + Linux/macOS)

4. **Complete README acceptance content**
   - **Files:** `extensions/scaffold-extension/README.md`
   - **Expected behavior:** README includes:
     - explicit per-platform runtime notes (Windows/macOS/Linux)
     - first-run workflow steps
     - dedicated section describing production-foundation value
   - **Acceptance criteria:** Documentation AC items are fully satisfied.
   - **Verification:** manual doc review + `grep` checks in CI/review.

5. **Re-run final extension toolchain after remediation**
   - **Files:** extension code/tests/docs touched by remediation
   - **Expected behavior:** clean pass of format/lint/typecheck/test in one final pass.
   - **Acceptance criteria:** no quality-gate regressions.
   - **Verification:**
     - `Push-Location extensions/scaffold-extension; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location`
     - `npm --prefix extensions/scaffold-extension run lint`
     - `npm --prefix extensions/scaffold-extension run typecheck`
     - `npm --prefix extensions/scaffold-extension run test`

## Do Not Do

- Do not weaken policy gates (no disabling lint/type/test rules to force green).
- Do not re-scope into unrelated refactors.
- Do not remove acceptance criteria from feature docs to match incomplete implementation.
- Do not silently skip missing-platform evidence; mark constraints explicitly when unavoidable.

## Unmet Acceptance Criteria (minimum delta required)

1. **Feature present in PR diff to `main`** — commit/stage implementation files.
2. **Missing PowerShell runtime error case tested** — add and pass explicit test.
3. **Cross-platform integration confidence** — provide stronger Windows + POSIX verification.
4. **README completeness** — add platform notes + first-run workflow + production-foundation section.
