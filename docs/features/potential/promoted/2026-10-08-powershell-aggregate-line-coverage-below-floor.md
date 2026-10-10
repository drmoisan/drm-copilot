# powershell-aggregate-line-coverage-below-floor (Issue #847)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/powershell-aggregate-line-coverage-below-floor/ (Issue #847)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #847
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/847
- Last Updated: 2026-10-08
## Summary

Repository-wide PowerShell line coverage is 84.67% (13325/15738 lines, 174 files), below the uniform 85% line-coverage floor. The drop from 96.38% (127 files) is caused by #527 (PR #821, merged as 9fb35e7f), which replaced the 127-file runsettings allow-list with a population derived from `config/poshqc-coverage.json`. The newly measured files include many with low or zero coverage, and the modified module `scripts/powershell/PoshQC/PoshQC.psm1` is at 66.67%.

## Environment

- OS/version: GitHub Actions CI runners (PoshQC job); also applies to local self-hosted PoshQC runs
- Python version: n/a (PowerShell / Pester)
- Command/flags used: `Invoke-PoshQCTest -Root "${{ github.workspace }}"` (`.github/workflows/_poshqc.yml:42`); CI runs 36983551836 (run A) and 36984586891 (run B)
- Data source or fixture: `config/poshqc-coverage.json` roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`; `artifacts/ci/run-36983551836/powershell-coverage.xml`

## Steps to Reproduce

1. On main at or after 9fb35e7f, run the PoshQC test suite with coverage (CI `poshqc` job or `mcp__drm-copilot__run_poshqc_test`).
2. Confirm the job log line `Code coverage population: source=config; files=174`.
3. Reduce `powershell-coverage.xml` to a repository aggregate and per-file line rates.

## Expected Behavior

Repository-wide PowerShell line coverage is at or above 85% per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`, with every production file in the denominator. Each modified file is at or above 85%.

## Actual Behavior

The #527 evidence `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md` records:

| Metric | Baseline (CI run 36978425380) | Run A (CI run 36983551836) |
| --- | --- | --- |
| LINE_PCT | 96.38 | 84.67 |
| LINE_TOTAL | 11887 | 15738 |
| FILES | 127 | 174 |
| LINE_MISSED / LINE_COVERED | 430 / 11457 | 2413 / 13325 |

Run B reports the same 84.67%. 42 files are below 85%. The largest contributors by missed lines:

- `.codex/scripts/epic-child-launch-runtime.ps1` 30/229 (13.10%)
- `.codex/scripts/launch-epic-child-wave.ps1` 97/291 (33.33%)
- `scripts/dev-tools/bootstrap-host.ps1` 0/177 (0.00%)
- `scripts/dev-tools/verify-host.ps1` 0/153 (0.00%)
- `.codex/scripts/resume-epic-child.ps1` 38/181 (20.99%)
- `scripts/dev-tools/publish-sideloaded-extension.ps1` 0/138 (0.00%)
- `.codex/hooks/validate-feature-review-coverage.ps1` 10/137 (7.30%)
- `.claude/hooks/validate-feature-review-coverage.ps1` 104/210 (49.52%)
- `scripts/powershell/PoshQC/PoshQC.psm1` 40/60 (66.67%), modified by #527 and newly measured

The full 42-row list is in the evidence file above.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `policy-audit.2026-10-02T05-34.md:123` in the #527 folder: "Repo-wide line threshold (85%), PowerShell | FAIL | 84.67% (13325/15738) in run A and run B, caused by population growth from 127 to 174 files." Lines 407-408 record PA-N1 (repo-wide 84.67%) and PA-N2 (`PoshQC.psm1` 66.67%) as non-blocking findings that require this follow-up issue.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The repository is below its uniform line-coverage policy floor for PowerShell. CI does not enforce a PowerShell threshold (#527 `spec.md:238`), so no gate currently fails, and later changes can lower coverage further without detection.

## Suspected Cause / Notes

- The 127-file allow-list excluded these files from measurement; #527 made the population workspace-derived, which exposed existing untested code rather than removing tests. The baseline 96.38% therefore overstated repository coverage.
- #527 `spec.md:80`, `:238` and `:303` place raising the aggregate out of scope and require a follow-up issue if it falls below 85%. The operator accepted the shortfall as non-blocking on 2026-09-30 (run notes item 527; `policy-audit.2026-10-02T05-34.md:47`).
- #527 remains open for its own operator-run acceptance criteria (AC-01, AC-11 to AC-13: denominator reproducibility). This issue covers only the coverage shortfall, which is a separate defect.
- Several low files are host-bound entry scripts (`bootstrap-host.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`, `post-codex-worktree-session.ps1`). Under the Coverage Exclusion Policy they stay in the denominator; the expected remedy is extracting logic into testable modules.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add Pester tests for the largest contributors above, starting with `.codex/scripts/epic-child-launch-runtime.ps1`, `launch-epic-child-wave.ps1`, `resume-epic-child.ps1`, both `validate-feature-review-coverage.ps1` hooks, and `PoshQC.psm1`; refactor host-bound scripts so their logic lives in testable modules.
- [ ] Integration scenario to retest: CI `poshqc` job reports aggregate line coverage >= 85% over the `source=config` population with no root narrowed and no production file excluded.
- [ ] Manual verification notes: consider adding an enforced PowerShell line threshold to the CI PoshQC job once the aggregate is above 85%.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
