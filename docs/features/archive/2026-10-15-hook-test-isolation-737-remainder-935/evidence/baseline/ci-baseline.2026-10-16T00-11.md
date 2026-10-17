# CI Baseline (P7-T1, orchestrator)

Timestamp: 2026-10-16T00-11
Command: git merge-base origin/main HEAD; gh run list --workflow ci.yml --branch main --event push --commit adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 --status success --limit 1 --json databaseId,headSha; gh run download 38730332356 -n poshqc-test-results -D SCRATCH/935/issue-935/ci-38730332356; D-JUNIT counts over pester-junit.xml; D-COV over powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- B (merge-base origin/main HEAD): adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99
- R_base: run 38730332356 (https://github.com/drmoisan/drm-copilot/actions/runs/38730332356), headSha adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99, selected by the first D-BASE rule (successful push run of ci.yml on main at B).
- Windows Passed counts (D-JUNIT, artifact poshqc-test-results, file pester-junit.xml, job poshqc / PowerShell QC):
  - tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1: 51 (members 51)
  - tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1: 25 (members 25)
  - tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1: 120 (members 120)
  - tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1: 32 (members 32)
  - tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1: 54 (members 54)
- Baseline line coverage (D-COV, root report LINE counter): covered 16381, missed 1735, 90.42%.
- Note: Passed counts are testcase counts and include -ForEach/-TestCases expansions, so they can exceed the static `It` line counts.
