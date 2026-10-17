# Remediation Inputs — Cycle 2 (post-PR CI failure)

Timestamp: 2026-10-10T19-25
Source: required CI check on PR #881 (base `epic/enforcement-hook-precision-integration`, head `bug/hook-preexisting-imports-fail-open-exec-786` at `a9e8e88feee89fece6fd328bcbe9c05f946b7f18`)
Failing check: `poshqc / PowerShell hook suites (Linux)`
Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/38093728445/job/114335212763
Run result: `Tests Passed: 5682, Failed: 18` (Linux, ubuntu runner). The Windows `poshqc / PowerShell QC` check passed on the same head.

## Blocking finding CI-1: 18 Linux-only Pester failures in suites added by this branch

All 18 failures are in test files created by this branch under `tests/scripts/codex-hooks/`. The failure messages indicate Windows-only assumptions in test code (drive-letter roots, mock parameter sets, host-specific path handling). Production behaviour on Linux is not shown to be defective by these messages; that must be confirmed per row.

| # | Test (Describe . Context . It) | Location | Message |
|---|---|---|---|
| 1 | Codex enforce-codex-model-routing coverage (issue #786) . entry point . falls back to the agent-id attestation scan | `tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1:118` | Expected 0, but got 2. |
| 2 | Codex enforce-epic-root-invocation coverage (issue #786) . entry point . falls back to the agent-id attestation scan and denies missing provenance | `tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1:90` | Expected 0, but got 2. |
| 3 | Codex enforce-epic-wave-barrier coverage (issue #786) . entry point . exits 0 for a non-mutating tool with no local or launcher state | `tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1:151` | Expected 0, but got 2. |
| 4 | Codex enforce-epic-wave-barrier coverage (issue #786) . entry point . exits 0 without a deny for a ready execution child | `tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1:168` | Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2. |
| 5 | Codex enforce-epic-wave-barrier coverage (issue #786) . entry point . writes the deny for an unready execution child | `tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1:177` | same 'Raw' parameter message, got 2 |
| 6 | Codex hook dependency-failure behaviour (issue #786) . baseline mock interception probe | `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:131` (via `EpicStateIsolation.Baseline.Helpers.ps1:130`) | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times |
| 7–8 | Codex validate-codex-subagent-routing coverage (issue #786) . Find-CodexStopAttestationRaw . (two rows) | `tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1:85`, `:92` (raised at `.codex/hooks/validate-codex-subagent-routing.ps1:119`) | ParameterBindingException: A parameter cannot be found that matches parameter name 'File'. |
| 9–16 | Codex validate-feature-review-coverage coverage (issue #786) . readers and parsers . (eight rows) | `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:63`, `:69`, `:121`, and siblings (raised at `.codex/hooks/validate-feature-review-coverage.ps1:55`, `:67`, `:134`) | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist. |
| 17–18 | Codex validate-feature-review-coverage coverage (issue #786) . entry point . (two rows) | `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:178`, `:186` | Expected 0, but got 2. |

Required outcome: the Linux hook-suite job passes with 0 failures and the Windows `poshqc / PowerShell QC` job stays green, with no reduction of coverage on changed lines and no change to the AC-17 assertion set (these suites are new in this branch, so AC-17 does not constrain them). Any production change found necessary must be mirrored to the bundle copies. The local CI-parity reproduction route and its limits (Windows host) must be stated in the plan; the definitive verification is the Linux CI job on the pushed head.

blocking_count: 1
