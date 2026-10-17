# Feature Audit: Hook coverage attribution gaps (#936)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936`
**Base Branch:** `origin/main`
**Head Branch:** `bug/hook-coverage-attribution-gaps-936`
**Work Mode:** `minor-audit`

**Total blocking findings: 0.**

---

## Scope and Baseline

- **Base branch:** `origin/main`; **head:** `d30a6625a`.
- **Evidence sources:** `git diff origin/main...HEAD` (stat, name-only, and the `tests/` hunks) read directly by the reviewer; evidence files under `evidence/qa-gates/` and `evidence/baseline/`.
- **Requirements source:** `issue.md` `## Acceptance Criteria` only (`minor-audit`); `spec.md` and `user-story.md` are absent by design.
- **Scope note:** the pull request does not exist yet, so CI-dependent AC-5 is pending.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md` (AC-1 to AC-8, checkbox format)

### Acceptance criteria

AC-1 to AC-8 as written in `issue.md` lines 40-47.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | FailClosed header note (modes.ps1 line 41, H2 codex deny rows, line-unique assertion, Pester 5.x cause, #936) | PASS | Added header paragraph names all required items | `git diff origin/main...HEAD -- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | All five required elements present |
| AC-2 | Decision header note (epic-scope lines 183, 190, 191, 206, 207, 209; ES-D1, ES-D2; exact-reason assertion; cause; #936) | PASS | Added header paragraph names all required items | `git diff origin/main...HEAD -- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` | All required elements present |
| AC-3 | Diff of the two test files changes only `.DESCRIPTION` text; each file under 500 lines | PASS | Diff shows 10 and 11 added lines, 0 removed, all inside the `<# #>` block; no `It`/`Describe`/`Mock`/assertion line touched; 90 and 108 lines | `git diff origin/main...HEAD -- tests/`; `wc -l` | Verified independently by the reviewer |
| AC-4 | Evidence of `.codex/hooks` `<line>` elements `ci>=1` for modes.ps1:41 and epic-scope 206, 207 in scoped run | PASS | `evidence/qa-gates/isolated-coverage-attribution.2026-10-16T01-28.md`: CODEX-PACKAGE-COUNT=1, lines 41, 206, 207 `ci=1` | Read of evidence file | The record states the elements come from the `.codex/hooks` package |
| AC-5 | PR head `poshqc / PowerShell QC` passes; evidence from CI `poshqc-test-results` artifact | PENDING-CI | No PR exists yet; the criterion is CI-dependent | N/A | Left unchecked per the CI-dependent protocol; the item's own orchestrator checks it off at S9. Not a defect |
| AC-6 | H2 codex deny rows, ES-D1, ES-D2 pass | PASS | `evidence/qa-gates/scoped-junit.2026-10-16T01-28.md`: 2/2, 1/1, 1/1 Passed; full run FAILED=0 | Read of evidence file | |
| AC-7 | PoshQC format and analyze report no findings on the two files | PASS | `final-format` (hashes unchanged, status clean) and `final-analyze` (ok true) | Read of evidence files | |
| AC-8 | Diff changes only the two test files and files under the feature folder | PASS | `git diff --name-only origin/main...HEAD` filtered to exclude the feature folder returns exactly the two test files | `git diff --name-only origin/main...HEAD` | No production hook, `config/poshqc-coverage.json`, `pester.runsettings.psd1`, or workflow file changed |

## Baseline Comparison

Repo-wide PowerShell line coverage is 94.57% before and after (missed=667, covered=11613). The change added no executable line, so no regression is possible on changed lines.

## Out-of-Scope Decision

Switching Pester to `UseBreakpoints=$false` is a coordinator decision, filed separately as a follow-up. It is not evaluated as a defect.

## Summary

Seven of eight criteria are PASS and AC-5 is PENDING-CI. The diff is header-only (verified by `git diff`), no file outside the two test files and the feature folder changed, and the scoped coverage run attributes the three target lines. No blocking finding.

## Acceptance Criteria Check-off

AC-1 to AC-4 and AC-6 to AC-8 are already checked in `issue.md`; the reviewer confirmed each as PASS and made no change. AC-5 stays unchecked (PENDING-CI).

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md`
- Total AC items: 8
- Checked off (delivered): 7
- Remaining (unchecked): 1
- Items remaining: AC-5 (PR head `poshqc / PowerShell QC` job passes and CI evidence recorded; PENDING-CI)
