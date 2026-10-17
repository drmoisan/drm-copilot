# Code Review: Host bootstrap installs poetry (Issue #930)

- Timestamp: 2026-10-16T03-25
- Branch: bug/host-bootstrap-does-not-install-poetry-930 (head 4470de936)
- Scope: full diff against the merge-base with origin/main; production and test changes are in `scripts/dev-tools/HostBootstrap.psm1` and `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`.

## Executive Summary

The production change is three lines in `Invoke-BootstrapHost`: a comment and an unconditional call to `Install-PoetryWithPip -ApplyMode:$Apply`, placed after the Process-scope PATH refresh (line 365) and before the Graphite CLI step (line 372). `Install-PoetryWithPip` is already idempotent: it returns with `[OK] poetry already installed` when poetry is on PATH, prints a dry-run message without side effects when `-ApplyMode` is absent, and throws when python is absent or pip fails. The call is therefore safe to run unconditionally and propagates failure by design.

The test change adds one seam mock to the `Describe` `BeforeEach` and a new `Context 'poetry tool install'` with five tests: apply-mode invocation, dry-run invocation, ordering (PATH refresh, poetry install, project poetry), failure propagation, and `-SkipProjectPoetryInstall` independence. Tests follow Arrange/Act/Assert, use only mocks, create no temporary files, and keep the file at 348 lines.

No blocking code-quality finding was identified. The only blocking item on the branch is the CI-dependent coverage and AC-11 verification recorded in the policy audit and feature audit (class awaiting_ci). Items below are non-blocking observations.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Info | scripts/dev-tools/HostBootstrap.psm1 | lines 368-369 | Call is placed after the PATH refresh and before the Graphite step, as the acceptance criteria require. | None. | Ordering lets a freshly installed python be found; verified by AC930-POETRY-INSTALL-ORDER. | Diff; module lines 363-372; `pester-run-final` node PASS. |
| Info | scripts/dev-tools/HostBootstrap.psm1 | line 369 | A throw from `Install-PoetryWithPip` aborts bootstrap before the project repository sync and project poetry install. | None; this matches AC-4 and fail-fast policy. | Silent continuation would hide the original defect (later steps failing on a missing poetry). | AC930-POETRY-INSTALL-FAILURE-PROPAGATES. |
| Low | tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | AC930-POETRY-INSTALL-ORDER mock | The mock body assigns `$null = $ApplyMode` solely to satisfy the PSReviewUnusedParameter analyzer rule. | Optional: none required; the construct is readable and the analyzer is clean. | Non-blocking style note; documented in the QC loop evidence. | `clean-pass-confirmation.2026-10-16T03-22.md`. |
| Info | tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | new Context | Tests verify the call through a mocked seam; the real pip install path is covered by the existing `Describe 'Install-PoetryWithPip'` tests, which are unchanged. | None. | Matches the adopted approach stated in issue.md. | Issue.md `## Acceptance Criteria` preface; AC06 tests PASS in `pester-run-final`. |
| Info | docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence | three documentary files | `phase0-instructions-read`, `phase1-handoff`, and `reduced-audit-handoff` omit Command and EXIT_CODE fields. | None; no command was run for these records. | The other 28 evidence files carry Timestamp, Command, EXIT_CODE, and Output Summary. | Evidence scan during this review. |

## Correctness and Safety Notes

- Dry-run mode remains free of side effects: `Install-PoetryWithPip` without `-ApplyMode` only writes an output line (module lines 133-136), and the existing `AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS` test passes.
- `scripts/host-tools.manifest.json` is not in the diff, and the winget-failure fallback in `Install-WithWinget` is untouched.
- Module line count is 465, below the 500-line limit.
- The new tests use the literal `C:\fixture\repo`, consistent with the surrounding tests; no host path is embedded.

## Verdict

No blocking code findings. Review-Verdict for the branch: AWAITING_CI (CI-dependent AC-11 only).
