# Code Review: Host bootstrap installs poetry (Issue #930), remediation cycle 2 re-audit

- Timestamp: 2026-10-16T06-51
- Branch: bug/host-bootstrap-does-not-install-poetry-930 (head bafae6260)
- Scope: full diff against the merge-base with origin/main; production and test changes are in `scripts/dev-tools/HostBootstrap.psm1` and `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`.

## Executive Summary

The production change is unchanged since the prior review: a comment and an unconditional call to `Install-PoetryWithPip -ApplyMode:$Apply` in `Invoke-BootstrapHost`, placed after the Process-scope PATH refresh and before the Graphite CLI step. `Install-PoetryWithPip` is idempotent, prints a side-effect-free message in dry-run mode, and throws when python is absent or pip fails, so the unconditional call is safe and fail-fast.

The test change adds one seam mock to `BeforeEach` and five tests in `Context 'poetry tool install'` (apply, dry-run, ordering, failure propagation, skip-project-install independence). Tests use Arrange/Act/Assert, mocks only, no temporary files; the test file is 348 lines and the module 465 lines.

Commit bafae6260 (cycle 2) changed only markdown under the feature folder. No code-quality defect was identified, CI on the PR head is green (17 of 17 checks), and the evidence-schema defect from the prior review is resolved. There are zero blocking findings.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Info | scripts/dev-tools/HostBootstrap.psm1 | lines 368-369 | Call is placed after the PATH refresh and before the Graphite step. | None. | A freshly installed python is visible when the call runs; verified by AC930-POETRY-INSTALL-ORDER. | Diff; CI poshqc job success. |
| Info | scripts/dev-tools/HostBootstrap.psm1 | line 369 | A throw from `Install-PoetryWithPip` aborts bootstrap before the project install. | None. | Matches AC-4 and fail-fast policy. | AC930-POETRY-INSTALL-FAILURE-PROPAGATES. |
| Low | tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | AC930-POETRY-INSTALL-ORDER mock | `$null = $ApplyMode` exists only to satisfy PSReviewUnusedParameter. | None required. | Non-blocking style note; analyzer clean. | `clean-pass-confirmation.2026-10-16T03-22.md`. |
| Info | tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | new Context | Tests verify the call through a mocked seam; the real pip path is covered by unchanged `Install-PoetryWithPip` tests. | None. | Matches the adopted approach in issue.md. | AC06 tests pass in CI. |
| Info | docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md | whole file | Now carries Timestamp, Command, EXIT_CODE, Output Summary, and a note that the command is the verifying command run when the fields were added. | None. | Prior blocking finding resolved; disclosure of retroactive verification is accurate. | Direct read; four line-anchored `grep -rL` scans over 44 evidence files each returned no file. |

## Correctness and Safety Notes

- Dry-run mode remains free of side effects; `AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS` passes.
- `scripts/host-tools.manifest.json` is not in the diff; the winget-failure fallback is untouched.
- Module line count is 465 and test file 348, both below 500.
- No `SCRATCH/`, `.claude/`, or `artifacts/` path is in the branch diff (`git diff --name-status origin/main...HEAD`).
- The new tests use the literal `C:\fixture\repo`, consistent with surrounding tests.

## Verdict

Zero blocking findings. Review-Verdict for the branch: PASS.
