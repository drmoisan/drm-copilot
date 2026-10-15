# Policy Audit: root-format-check-fails-on-test-fixtures (Issue #848)

- Timestamp: 2026-10-09T07-30
- Branch: bug/root-format-check-fails-on-test-fixtures-848
- Base: origin/main
- Work Mode: minor-audit
- Review scope: full branch diff against origin/main (24 files, 719 insertions, 0 deletions)
- Template note: the MCP policy-audit template asset resolver was not available to this agent; the canonical section headings from the policy-audit-template-usage skill are preserved manually. Template resolution is recorded as a limitation, not a policy failure of the change.

## Rejected Scope Narrowing

None. The caller prompt described the change as the single new `.prettierignore` plus evidence, plan, issue.md and the promoted lifecycle record. That matches the full branch diff, so no narrowing was applied or rejected.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` exited 0 with no output.
- No branch-diff file is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence is under `<FEATURE>/evidence/baseline/`, `evidence/qa-gates/`, or `evidence/regression-testing/`.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events.

## Executive Summary

Overall verdict: PASS. Blocking findings: 0 (FAIL: 0, blocking-PARTIAL: 0). The change adds one root `.prettierignore` (comment line plus `tests/fixtures/`). No production source, test source, script, manifest, lockfile, or fixture file changed (verified: `git diff --name-only origin/main -- tests/fixtures package.json package-lock.json` printed nothing; `git status --porcelain` is clean).

## 1. General Unit Test Policy Compliance

- Verdict: PASS (not applicable to new tests). The change is configuration-only and adds no test code. No temporary files, wall-clock waits, or colocated tests were introduced.
- Existing Pester suites that consume the protected fixture were re-run as regression guards: 20 passed / 0 failed (model-routing-receipt) and 18 passed / 0 failed (pr-author-skill), equal to baseline counts.

### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (the change is one ignore file, `.prettierignore`; no TypeScript source changed, so no baseline coverage figure applies)
- TypeScript post-change coverage artifact: N/A (no TypeScript source changed; no post-change coverage figure applies)
- PowerShell baseline coverage artifact: N/A (no PowerShell source changed; the Pester suites were run only as regression guards and no coverage figure applies)
- PowerShell post-change coverage artifact: N/A (no PowerShell source changed; no post-change coverage figure applies)
- Per-language comparison summary: N/A for all languages (zero changed files in TypeScript, Python, PowerShell, and C#; see 1.2.1)

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 0 | 0 | N/A (no change) | N/A (no source changed) | N/A (no source changed) | N/A (no new code) |
| Python | 0 | 0 | N/A (no change) | N/A (no source changed) | N/A (no source changed) | N/A (no new code) |
| PowerShell | 0 | 0 | N/A (regression suites only: 20 and 18 passed) | N/A (no source changed) | N/A (no source changed) | N/A (no new code) |
| C# | 0 | 0 | N/A (no change) | N/A (no source changed) | N/A (no source changed) | N/A (no new code) |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: N/A. Zero changed files; the change is one ignore file. Disposition: N/A. Evidence: branch diff contains no TypeScript file.
- Python: N/A. Zero changed files. Disposition: N/A. Evidence: branch diff contains no Python file.
- PowerShell: N/A. Zero changed files. Disposition: N/A. Evidence: branch diff contains no PowerShell file.
- C#: N/A. Zero changed files. Disposition: N/A. Evidence: branch diff contains no C# file.

## 2. General Code Change Policy Compliance

- Simplicity: PASS. One two-line file serves both `format` and `format:check` because both scripts run from the repository root.
- Scope and blast radius: PASS. Changed paths outside the feature folder are `.prettierignore` and the promoted lifecycle record only.
- File size limit (500 lines): PASS. `.prettierignore` has 2 lines. Markdown documentation is exempt.
- Dependencies: PASS. None added.
- Public API compatibility: PASS. Package scripts unchanged.
- Exclusion policy (`general-unit-test.md` Coverage Exclusion Policy): PASS. `.prettierignore` governs formatting only, not coverage measurement, and `tests/fixtures/` is a non-production path.

## 3. Language-Specific Code Change Policy Compliance

- Changed files by language: TypeScript 0, Python 0, PowerShell 0, C# 0, GitHub Actions 0. The only non-documentation file is `.prettierignore`.
- Verdict: PASS (no language-specific rule is triggered).
- Line endings: PASS. `prettierignore-no-cr` artifact records count 0 with the expected exit 1; the file read shows two lines and a final newline.

## 4. Language-Specific Unit Test Policy Compliance

- Verdict: PASS (no language-specific test files changed).

## 5. Test Coverage Detail

| Language | Changed files | Coverage artifact | Verdict |
|---|---|---|---|
| TypeScript | 0 | not required | PASS (zero changed files; nothing in the denominator changed) |
| Python | 0 | not required | PASS (zero changed files) |
| PowerShell | 0 | not required | PASS (zero changed files) |
| C# | 0 | not required | PASS (zero changed files) |

No production source line changed, so there is no changed-line coverage regression. Repo-wide coverage is unaffected by a formatter ignore file.

## 6. Test Execution Metrics

| Check | Result | Evidence |
|---|---|---|
| Root `npm run format:check` (branch head) | exit 0, "All matched files use Prettier code style!", no warn or error lines | `evidence/qa-gates/root-format-check.2026-10-09T06-30.md` |
| Token `tests/fixtures/` in output | 0 occurrences (re-verified by grep during review) | `root-format-check-no-fixture-lines.2026-10-09T06-30.md` |
| Read-only listing of write-script file set | exit 0, no paths | `format-script-file-set.2026-10-09T06-30.md` |
| Pester model-routing-receipt WorktreeResolution | 20 passed, 0 failed | `evidence/regression-testing/pester-model-routing-receipt.2026-10-09T06-30.md` |
| Pester pr-author-skill WorktreeResolution | 18 passed, 0 failed | `evidence/regression-testing/pester-pr-author-skill.2026-10-09T06-30.md` |

Reviewer verification was by artifact inspection and read-only git commands; no tool was re-run.

## 7. Code Quality Checks

- Formatting stage: PASS (root Prettier check exit 0). Lint, type-check, unit-test and integration stages are not re-run by the plan because no file they read changed; this is consistent with the plan's testing statement and the changed-files proof. Verdict: PASS.

## 8. Gaps and Exceptions

1. Baseline warn-line count: the baseline artifact records 216 `[warn]` lines against the plan and issue estimate of 214. Reviewer count by grep of `[warn] tests/fixtures` in the baseline artifact: 216. Every warn and the single parse error path begins with `tests/fixtures/`, so the plan's P0-T7 acceptance (all failing paths under the fixtures directory) holds. The 214 figure came from a #830 baseline taken on an earlier main; fixtures added to main since then are the likely cause (not confirmed by diff of the two baselines). Assessment: not a blocking deviation; no AC depends on the count, and the condition that would have been blocking (a failing path outside `tests/fixtures/`) did not occur. Severity: informational.
2. Stale metadata (non-blocking, advisory): `issue.md` line 5 Status still reads "Promoted -> docs/features/active/root-format-check-fails-on-test-fixtures/", which differs from the actual folder name; plan `Status` still reads "Draft" although all tasks are checked off.
3. Evidence precision (non-blocking, advisory): `changed-files.2026-10-09T06-30.md` abbreviates paths ("(8 artifacts)", "...") instead of listing them verbatim. The union was independently confirmed in this review from `git diff --stat`.
4. CI does not run root `format:check`; this is explicitly out of scope per the issue scope note.

## 9. Summary of Changes

- Added: `.prettierignore` (2 lines).
- Added: 17 evidence artifacts, plan, research note, promoted lifecycle record.
- Modified: `issue.md` (AC checkboxes only, per ac-checkoff evidence).
- No deletions.

## 10. Compliance Verdict

PASS. Blocking findings: 0. Remediation inputs are not required.

## Appendix A: Test Inventory

No tests added or modified. Regression suites run: `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` (20), `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` (18).

## Appendix B: Toolchain Commands Reference

- `npx --yes npm@11 run format:check` (root)
- `npx prettier --no-error-on-unmatched-pattern --list-different <six root globs>`
- `Invoke-Pester -Path <suite> -Output Detailed` (via scratchpad `sh` wrapper)
- `git diff --name-only origin/main -- tests/fixtures package.json package-lock.json`
- `validate_evidence_locations.py --root .`
