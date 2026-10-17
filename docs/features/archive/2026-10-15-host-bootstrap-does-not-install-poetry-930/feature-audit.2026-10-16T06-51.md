# Feature Audit: Host bootstrap installs poetry (Issue #930), remediation cycle 2 re-audit

- Timestamp: 2026-10-16T06-51
- Work Mode: minor-audit

## Scope and Baseline

- Branch: bug/host-bootstrap-does-not-install-poetry-930, head bafae6260989c349d6bbc481cf5282b6debeeab5.
- Baseline: merge-base with origin/main. Diff covers `scripts/dev-tools/HostBootstrap.psm1` (+3), `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (+57), feature documents, and 44 evidence files.
- AC source: the `## Acceptance Criteria` section of `issue.md` only.
- CI: PR #950 shows 17 of 17 checks passing (`gh pr checks 950`), including `poshqc / PowerShell QC` (run 38861578476, job 116844832272) and `poshqc / PowerShell hook suites (Linux)`. `gh run view 38861578476` reports conclusion success, status completed, headSha bafae6260989c349d6bbc481cf5282b6debeeab5. The PoshQC log reports Tests Passed 10371, Failed 0, Skipped 10, and "Covered 89.61% / 0%. 26,457 analyzed Commands in 203 Files".

## Acceptance Criteria Inventory

Eleven criteria, AC-1 through AC-11, all checked in `issue.md`.

## Acceptance Criteria Evaluation

| AC | Result | Evidence |
|----|--------|----------|
| AC-1 apply mode invokes `Install-PoetryWithPip` once with `ApplyMode` | PASS | Test AC930-APPLY-INVOKES-POETRY-INSTALL uses `-Times 1 -Exactly -ParameterFilter { $ApplyMode }`; production line 369. |
| AC-2 dry run invokes it once without `ApplyMode` | PASS | AC930-DRYRUN-INVOKES-POETRY-INSTALL uses `{ -not $ApplyMode }`. |
| AC-3 call after Process-scope PATH refresh and before `Invoke-HostBootstrapPoetry` and Graphite | PASS | AC930-POETRY-INSTALL-ORDER asserts `PathRefresh,PoetryInstall,ProjectPoetry`; module lines 365, 369, 372. |
| AC-4 throw propagates; project poetry not invoked | PASS | AC930-POETRY-INSTALL-FAILURE-PROPAGATES. |
| AC-5 `-SkipProjectPoetryInstall` does not suppress the tool install | PASS | AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL. |
| AC-6 manifest unchanged; winget fallback retained | PASS | Manifest absent from the branch diff; `manifest-unchanged.2026-10-16T03-22.md`; AC06 tests pass in CI. |
| AC-7 BeforeEach mocks the seam; pre-existing tests unmodified | PASS | One added mock line, no removed lines in the test diff. |
| AC-8 expect-fail before fix, pass after; MCP results recorded | PASS | `prefix-new-tests-expect-fail` (FAILURES=5), `postfix-new-tests-pass` (FAILURES=0); MCP dispositions recorded. |
| AC-9 files at or under 500 lines | PASS | `wc -l`: module 465, test file 348. |
| AC-10 format, analyze, test report zero findings and failures | PASS | Formatter no rewrite; analyzer 0 findings; tests 0 failures; module coverage 155/155. |
| AC-11 `poshqc / PowerShell QC` passes on PR head with line coverage at or above threshold | PASS | CI run 38861578476, job 116844832272 concluded success on head bafae6260; the log reports 89.61% command coverage and 0 test failures. |

## Evidence Schema Verification (cycle 2)

- Cycle 2 target: `other/rem1-phase0-instructions-read.2026-10-16T04-53.md` now carries Timestamp, Command, EXIT_CODE (0), and Output Summary (ALL-7-PRESENT), plus a note that the command is the verifying command run when the fields were added. Result: PASS.
- Full scan of 44 files under `evidence/`: four separate line-anchored `grep -rLE` runs (Timestamp, Command, EXIT_CODE, Output Summary) each listed zero files. All 44 carry all four fields. Result: PASS.
- Commit bafae6260 changed only that evidence file and `remediation-plan.2026-10-16T05-34.md`; no cycle-2 file lacks the fields.
- Scope check: no `SCRATCH/`, `.claude/`, `artifacts/`, or manifest path appears in the branch diff; no hyperbolic wording in the feature folder.

## Summary

All eleven acceptance criteria are verified PASS from the diff, tests, and CI on the current head. The cycle 1 re-audit finding (evidence-schema fields) is resolved. No blocking finding remains.

## Acceptance Criteria Check-off

### Acceptance Criteria Status
- Source: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/issue.md
- Total AC items: 11
- Checked off (delivered): 11
- Remaining (unchecked): 0
- Items remaining: none

Newly checked off by this review: none. All eleven were already checked and were confirmed PASS.
