# Task check - [P2-T1] (remediation cycle 1)

Timestamp: 2026-11-18T02-26
Command: sh SCRATCH/issue-1201-ps-static.sh <16 changed test files>; sh SCRATCH/issue-1201-suite-retry.sh rc1-tc-p2t1 pester -TestPath <16 changed test files> tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1; git diff <cycle-0 PR head> --name-only
EXIT_CODE: 0
Output Summary: the fix from evidence/other/ci1-diagnosis.2026-11-18T02-06.md is applied. Static checks: 16 files, 0 format drift, 0 PSScriptAnalyzer findings. Selection: 1265 tests, 0 failed. The probe `It` is unchanged, and no hook or bundle file changed.

## Changed files

- Victim: tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1 - outer `BeforeAll` only: a `Reset-EpicStateProbeModuleBinding` call (with a two-line comment) after the helpers dot-source and before the first `Register-EpicStateBaselineMock`.
- Leakers (teardown only, `AfterAll` calling `Reset-EpicStateProbeModuleBinding`):
  - file-level `AfterAll` in validate-orchestrator-output.Tests.ps1, validate-orchestrator-output.artifact-type-dispatch.Tests.ps1, validate-orchestrator-output.FeatureFolder.Tests.ps1, validate-orchestrator-output.human-interaction.Tests.ps1, validate-orchestrator-output.model-routing.Tests.ps1, validate-orchestrator-output.MutationRejection.Tests.ps1, validate-orchestrator-output.OwnerDirectives.Tests.ps1, validate-orchestrator-output.Reentry.Tests.ps1, validate-orchestrator-output.WaveBarrier.Tests.ps1, validate-orchestrator-output.WorktreeResolution.Tests.ps1, validate-orchestrator-output-resolution.Tests.ps1, validate-orchestrator-output-target.Tests.ps1 (each already dot-sources EpicStateIsolation.Baseline.Helpers.ps1 in its file-level `BeforeAll`);
  - file-level `AfterAll` that first dot-sources EpicStateIsolation.Baseline.Helpers.ps1 in validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1 and owner-directive-pass-down-target.Tests.ps1;
  - Describe-level `AfterAll` in Describe `orchestrator output validator handler proof` of hook-import-failure-exemptions.FailClosed.Tests.ps1.
- All files are under tests/scripts/claude-hooks. Line endings stay LF; the diff adds lines only.

## Selection and rule

- Rule (atomic-plan-contract `## Test Cadence (Mandatory)` and P2-T1 text): the edited suites plus enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, which reads each hook suite's text.
- Run through the launcher `pester` suite with `-TestPath`, in parallel (8 workers).

## Commands and results

| Step | Command | EXIT_CODE | Result |
|---|---|---|---|
| Format (check-only) | sh SCRATCH/issue-1201-ps-static.sh <16 files> | 0 | format_drift=0 |
| PSScriptAnalyzer | same script, repository settings | 0 | pssa_findings=0 |
| Launcher selection, attempt 1 | sh SCRATCH/issue-1201-suite.sh rc1-tc-p2t1 pester -TestPath ... | 75 | TEST_EXECUTION_QUEUE_TIMEOUT: lock held by another worktree's pester suite; queue timeout, not a failure |
| Launcher selection, retry | sh SCRATCH/issue-1201-suite-retry.sh rc1-tc-p2t1 pester -TestPath ... | 0 | 6 attempts; run 2026-11-18T02-19 to 02-26 UTC; JUnit tests 1265, passed 1265, failed 0, errors 0, skipped 0 |
| Probe unchanged | git diff <cycle-0 PR head recorded in remediation-inputs.2026-11-18T01-37.md> -- tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1, count of lines naming `baseline mock interception probe` | 0 | 0 (the probe `It`, its `-Seam` values, and every other `It` are unchanged) |
| No hook or bundle change | git diff <cycle-0 PR head> --name-only -- .claude/hooks .codex/hooks extensions | 0 | 0 paths |
| Untracked companion | git status --porcelain | 0 | only the 16 test files (M) plus feature-folder docs and evidence |

- The coverage figure of this selection run is not gate evidence and is not recorded.
- Note: hook-import-failure-exemptions.FailClosed.Tests.ps1 was 536 lines before this change and is 539 after. It is above the 500-line guidance tier and below the 700-line advisory tier and the 800-line hard limit. The 500-line condition of P2-T3 cannot hold for this leaker; P2-T3 records it as a non-blocking deviation.
