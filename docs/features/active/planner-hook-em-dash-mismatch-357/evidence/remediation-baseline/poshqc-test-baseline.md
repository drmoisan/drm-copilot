# PoshQC Test — Pre-Remediation Baseline (Issue #357, Cycle 1)

Timestamp: 2026-07-17T14-48

Command: `mcp__drm-copilot__run_poshqc_test` (scan_folders: ["tests/scripts/claude-hooks/validate-planner-output.Tests.ps1"], using the pre-remediation `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, allowlist not yet modified)

EXIT_CODE: 0

Output Summary: `artifacts/pester/pester-junit.xml` reports `tests="7" errors="0" failures="0"` for `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (all 7 existing Pester tests pass). A direct grep of `artifacts/pester/powershell-coverage.xml` for `validate-planner-output` returns zero matches, confirming the canonical coverage artifact still does not measure `.claude/hooks/validate-planner-output.ps1` because the `CodeCoverage.Path` allowlist in `pester.runsettings.psd1` has not yet been modified. Restating the numeric pre-remediation baseline line coverage for this file from the prior cycle's `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/poshqc-test-baseline.md` (obtained via an ad hoc, non-repo-modifying `Invoke-Pester` run scoped to this single file): **69.87% line coverage (109 of 156 analyzed commands executed)**. Branch coverage is not measurable for any file under Pester 5.6.1's built-in code-coverage engine in this repository (no `BRANCH` JaCoCo counter emitted), a known toolchain limitation, not a regression introduced by this change.
