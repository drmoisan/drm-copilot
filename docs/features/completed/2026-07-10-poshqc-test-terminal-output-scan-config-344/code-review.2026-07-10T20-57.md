# Code Review: PoshQC Test Terminal Output and Scan Config (#344) — Remediation Cycle 1 Re-Audit

- **Timestamp:** 2026-07-10T20-57
- **Scope:** Full branch diff `cf036d3f..c01eab76` versus merge-base of `main`. This re-review focuses on the remediation-cycle-1 change surface (commit `c01eab76`: AST loader refactor in `PoshQC.psm1`, `pester.runsettings.psd1` coverage-path addition, bundled mirror resync, regenerated coverage artifacts, remediation evidence) and re-confirms the prior cycle's dispositions for the feature change surface (commit `2ed08b19`).
- **Reviewer:** feature-review agent
- Template note: the MCP tool `resolve_policy_audit_template_asset` could not be invoked in this session; this artifact was instantiated from the bundled asset source file at `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`.

## Executive Summary

The remediation change surface is small, well-scoped, and correct. The `PoshQC.psm1` sub-module loader now uses `[System.Management.Automation.Language.Parser]::ParseFile(...).GetScriptBlock()` dot-sourcing in a single commented loop, which (a) preserves the PS 7.6+ module-scope workaround the previous fileless-scriptblock approach existed for, (b) restores the on-disk file association Pester coverage breakpoints require, and (c) fails module import fast on parse errors with the offending sub-module named. The `pester.runsettings.psd1` change adds exactly one `CodeCoverage.Path` entry with a rationale comment in the file's established style; no entry was removed and no `CodeCoverage.ExcludedPath` was introduced. Bundled mirrors are byte-identical (verified by direct comparison and by the eight-pair parity gate re-run in this session).

The refactor introduced no behavioral regression: the authoritative Pester gate reports 1103 tests, 0 failures, 0 errors (JUnit artifact parsed in this session), the exported command surface is unchanged plus the previously added `Get-PoshQCScanConfigFolder`, and PSScriptAnalyzer reports zero findings on the final pass.

The three Blockers from the 2026-07-10T19-52 review (stale TS lcov; unmeasured `PoshQC.ScanConfig.psm1`; absent Python coverage artifact) are all resolved with machine-readable evidence verified in this session. No new Blocker or Major defect was found in the remediation diff.

**Blockers: 0. Majors: 0 new (1 carried, non-blocking). Minors: 2 carried observations.**

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Blocker R1) | `extensions/drm-copilot/coverage/lcov.info` | whole artifact | Previously stale at HEAD (omitted the three new TS modules). Regenerated artifact now contains all four changed modules with per-file line coverage 94.27%-100% and branch coverage 85.71%-100%; repo-wide 96.78% lines / 88.79% branches, above the 96.64% / 88.62% baseline. | None; resolved. | Coverage evidence must be machine-readable at the audited branch state. | lcov parsed in this session; `evidence/qa-gates/remediation-ts-lcov-verification.2026-07-10T20-46.md` |
| Resolved (was Blocker R2) | `scripts/powershell/PoshQC/PoshQC.psm1`, `settings/pester.runsettings.psd1` | loader lines 82-106; coverage path list | Previously the fileless scriptblock loader prevented Pester breakpoint binding, leaving the new production module unmeasured. The AST `Parser::ParseFile(...).GetScriptBlock()` refactor binds breakpoints; `PoshQC.ScanConfig.psm1` now measures 44/46 = 95.65% lines. 1103-test gate and eight-pair parity gate both green post-refactor. | None; resolved. Follow-up O1 (below) covers denominator expansion for the pre-existing modules. | Coverage Exclusion Policy prescribes refactoring over exclusion for untestable production code; the policy-preferred path was taken with no human exception. | `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` parsed in this session; parity pytest re-run PASS; byte comparison of all eight pairs PASS |
| Resolved (was Blocker R3) | `artifacts/python/lcov.info` | whole artifact | Previously absent despite a changed Python file on the branch. Artifact now exists; repo-wide 8073/9320 = 86.62% lines (>= 85%). | None; resolved. | Coverage verification is mandatory for every language with changed files. | lcov parsed in this session; `evidence/qa-gates/remediation-py-coverage.2026-07-10T20-46.md`; full pytest re-run 1309 passed |
| Major (carried, non-blocking) | `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` (bundled wrapper) | self-test execution inside this dev repo | Running the bundled wrapper inside this development repository reports 31 failures in PoshQC's own self-mocking tests (resident-module collision after the FR2.2 `RequiredModules` removal). Cannot occur in consumer repos; the authoritative task/MCP gate passes 0 failures and discovered-set parity holds. | Open a follow-up issue; do not restore `RequiredModules` (would violate AC2 byte parity). | Carried from CR-4 of the 19-52 review; determination unchanged. | `remediation-inputs.2026-07-10T19-52.md` (non-blocking carry section) |
| Minor (carried) | `scripts/powershell/PoshQC/PoshQC.psm1` | `Export-ModuleMember` block | `Get-PoshQCScanConfigFolder` is named in the export list but does not appear in `Get-Command -Module PoshQC` output; behavior is identical before and after the AST refactor (verified via pre-change comparison during remediation), so it is pre-existing and not introduced by this branch. The function is defined, callable, and exercised by 12 passing tests. | Open a follow-up issue to reconcile the export surface. | Out-of-cycle observation; no acceptance criterion depends on `Get-Command` visibility. | `evidence/qa-gates/remediation-findings-resolution.2026-07-10T20-46.md` (Out-of-Cycle Findings) |
| Minor (observation O3) | repo coverage configuration (`pyproject.toml` addopts) | Python coverage invocation | The Python coverage run does not apply `--cov-branch`, so the lcov emits no branch records; branch thresholds cannot be evidenced for Python repo-wide. Vacuous for this branch (no Python production code changed). | Enable branch measurement repo-wide in a follow-up change. | `.claude/rules/python.md` states the test command with `--cov-branch`; the repo configuration predates this branch. | `artifacts/python/lcov.info` (BRF/BRH absent, verified in this session) |

## Remediation-Diff Review Detail

### `scripts/powershell/PoshQC/PoshQC.psm1` (loader refactor)

- The loop iterates the four sub-module names in dependency-safe order (`FileDiscovery`, `ScanConfig`, `Analyzer`, `Testing`); `ScanConfig` precedes `Testing`, which consumes `Get-PoshQCScanConfigFolder`. Correct.
- `ParseFile` errors throw immediately with the sub-module name interpolated — fail-fast per the general code-change policy; no silent continuation.
- The replacing comment explains why the mechanism exists (module scope + breakpoint binding + issue reference), satisfying the comment-why rule.
- File is 121 lines; well under the 500-line cap.

### `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (coverage path)

- Single additive entry with rationale comment; `CoveragePercentTarget` and all other keys untouched; no `ExcludedPath` introduced; file parses (the 1103-test run consumed it).

### Bundled mirrors

- `PoshQC.psm1` and `settings/pester.runsettings.psd1` mirrors byte-identical to workspace sources (direct `cmp` this session); the parity pytest locks all eight pairs.

### Regenerated artifacts and evidence tree

- All remediation evidence lives under the canonical `<FEATURE>/evidence/qa-gates/` and `<FEATURE>/evidence/remediation-baseline/` locations; `validate_evidence_locations.py --root .` exits 0. Machine-readable toolchain outputs remain at their repo-standard `artifacts/` and `coverage/` locations, which are not evidence paths.

### Feature diff (commit `2ed08b19`) re-confirmation

- The prior cycle's code review (`code-review.2026-07-10T19-52.md`) found no implementation-logic defects in the TypeScript or PowerShell feature surface; its three Blockers were coverage-evidence findings, now resolved. Check-only re-runs in this session (prettier, eslint, tsc, black, ruff, pyright, pytest) are all clean at HEAD, and no production file exceeds 500 lines (measured). The prior dispositions stand.

## Determinism Review

- Diff scan of all changed test files found no banned APIs (`setTimeout`, `Thread.Sleep`, `Task.Delay`, `Date.now`, `Start-Sleep`) and no temp-file creation.
- Jest tests use mocked seams and in-memory `FileSystem`; Pester tests use injectable scriptblocks; the pytest parity test reads only checked-in files.

## Conclusion

No blocking findings. The remediation is contained, policy-compliant, and evidenced. Recommend proceeding to PR readiness with the follow-up items (O1 denominator expansion, O2 wrapper self-test collision, O3 Python branch measurement, O4 export visibility) tracked as separate issues.
