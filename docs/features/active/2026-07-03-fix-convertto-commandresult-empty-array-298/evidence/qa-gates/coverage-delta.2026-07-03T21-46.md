# Coverage Delta — Baseline vs Final (Issue #298)

Timestamp: 2026-07-03T21-46

Baseline (P0-T4, `evidence/baseline/test-baseline.2026-07-03T21-35.md`):
- Test counts: 25 passed / 25 total, 0 failed.
- Aggregate line coverage: 0.0% (0 / 1073 lines covered, per `artifacts/pester/powershell-coverage.xml` LINE counter).
- Aggregate branch coverage: not reported by the Pester CoverageGutters/JaCoCo exporter for this run (all `mb`/`cb` line attributes are `0`).

Post-change (P2-T3, `evidence/qa-gates/test-final.2026-07-03T21-45.md`):
- Test counts: 26 passed / 26 total, 0 failed.
- Aggregate line coverage: 0.0% (0 / 1073 lines covered, per `artifacts/pester/powershell-coverage.xml` LINE counter) — unchanged from baseline.
- Aggregate branch coverage: not reported by the exporter, same as baseline.

Regression verdict: No line or branch coverage regression. The aggregate line-coverage percentage (0.0%) is identical before and after the change; the identical value is expected because this run is scoped to a single test file and the in-scope production file `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is not present in `pester.runsettings.psd1`'s `CodeCoverage.Path` allowlist (a documented pre-existing condition, out of scope for this fix). No allowlisted file's measured coverage decreased.

Test-count delta: Total passing test count increased by exactly one, from 25 (baseline) to 26 (final) — the added case `accepts an empty array as Output without throwing` in the "helpers" `Context` block of `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`.
