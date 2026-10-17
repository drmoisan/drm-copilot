# Feature Audit: Host bootstrap installs poetry (Issue #930)

- Timestamp: 2026-10-16T03-25
- Work Mode: minor-audit

## Scope and Baseline

- Branch: bug/host-bootstrap-does-not-install-poetry-930, head 4470de936.
- Baseline: merge-base with origin/main. Diff covers `scripts/dev-tools/HostBootstrap.psm1` (+3), `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (+57), the issue, plan, research, and 31 evidence files.
- AC source: the `## Acceptance Criteria` section of `issue.md` only. `spec.md` and `user-story.md` are intentionally absent for minor-audit.
- Baseline test count 624; post-change 629 (624 plus 5), 0 failures.

## Acceptance Criteria Inventory

Eleven criteria, AC-1 through AC-11, in `issue.md`. Ten were checked by the executor; AC-11 is CI-dependent and unchecked.

## Acceptance Criteria Evaluation

| AC | Result | Evidence |
|----|--------|----------|
| AC-1 apply mode invokes `Install-PoetryWithPip` once with `ApplyMode` | PASS | Test AC930-APPLY-INVOKES-POETRY-INSTALL in the test diff uses `-Times 1 -Exactly -ParameterFilter { $ApplyMode }`; node PASS in `pester-run-final`. |
| AC-2 dry run invokes it once without `ApplyMode` | PASS | AC930-DRYRUN-INVOKES-POETRY-INSTALL uses `{ -not $ApplyMode }`; node PASS. |
| AC-3 call after Process-scope PATH refresh, before `Invoke-HostBootstrapPoetry`, and before Graphite | PASS | AC930-POETRY-INSTALL-ORDER asserts `PathRefresh,PoetryInstall,ProjectPoetry`; module lines 365, 369, 372 confirm placement before Graphite. |
| AC-4 throw propagates; project poetry not invoked | PASS | AC930-POETRY-INSTALL-FAILURE-PROPAGATES; node PASS. |
| AC-5 `-SkipProjectPoetryInstall` does not suppress the tool install | PASS | AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL; node PASS. |
| AC-6 manifest unchanged; winget fallback retained; AC06 tests pass | PASS | The manifest is absent from the branch diff; `manifest-unchanged.2026-10-16T03-22.md`; AC06-POETRY-PIP-FALLBACK and AC06-NONPOETRY-RETHROW PASS. |
| AC-7 BeforeEach mocks the seam; pre-existing Invoke tests pass unmodified | PASS | Diff shows one added mock line and no removed lines in the test file; AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS and AC07-DRYRUN-COMMITTED-MANIFEST PASS. |
| AC-8 expect-fail before fix, pass after; MCP test results recorded | PASS | `prefix-new-tests-expect-fail` shows FAILURES=5 with the five AC930 nodes FAIL; `postfix-new-tests-pass` and `pester-run-final` show FAILURES=0. MCP dispositions recorded in `mcp-test-baseline-disposition` and `mcp-test-disposition` (they assert no counts, as disclosed). |
| AC-9 module and test files at or under 500 lines | PASS | `wc -l`: module 465, test file 348. |
| AC-10 format, analyze, test report zero findings and failures | PASS | Format no rewrite; analyzer 0 on both files; 629 tests, 0 failures, 0 errors; module coverage independently confirmed at 155/155 lines in `artifacts/pester/powershell-coverage.xml`. Checks used the self-hosted inline routes plus MCP dispositions. |
| AC-11 `poshqc / PowerShell QC` CI job passes on PR head with line coverage at or above the threshold | PENDING-CI | CI-dependent by definition; `evidence/other/ac11-pending-ci.2026-10-16T03-22.md`. The on-disk coverage artifact is from a scoped run and is not a repo-wide measure. |

## Summary

Ten of eleven criteria are verified PASS from the diff and evidence. The eleventh, AC-11, cannot be evaluated until CI runs on the PR head. It stays unchecked and is the sole blocking finding (class awaiting_ci). No functional, scope, or evidence defect was found: the diff touches only the two permitted files plus feature documents, evidence files lack absolute host paths, evidence field requirements are met except for three documentary records, and the plan checklist matches the evidence.

## Acceptance Criteria Check-off

### Acceptance Criteria Status
- Source: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/issue.md
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC-11 (CI-dependent; owned by the item's orchestrator run at the S9 CI gate)

Newly checked off by this review: none. AC-1 through AC-10 were already checked and were confirmed PASS.
