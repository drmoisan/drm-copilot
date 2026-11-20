# Preflight Fixes

Timestamp: 2026-11-07T01-56
Plan: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/plan.2026-11-06T20-01.md

Trivial defects fixed in place, in task text and plan preamble only. No task was added, removed, or reordered.

## Fixes

1. `## Execution Rules`, Evidence rule. Defect class: evidence selection left to the executor. Added the statement that evidence prose never uses the tokens that P6-T8 scans for, so that a statement that a run was not performed cannot trip the scan.
2. P0-T2 and P6-T1. Defect class: evidence selection left to the executor. Named the file set of the direct analyzer run as the `Get-PoshQCFileList -Root` result, the population `Invoke-PoshQCAnalyze` analyzes.
3. P4-T2. Defect class: stale anchor. The Run All Checks Pytest entry is spelled `QC: Pytest: run tests with coverage`, without the digit, so the task and the `VT-` case now name that spelling. The text also states that `TS: 4 Jest: unit tests with coverage` stays in `QC: Coverage: All Providers`.
4. P4-T3. Defect class: asserting test not fully named. `test_powershell_test_failure_returns_fail_result` builds its own `powershell` dictionary, and the fake runner raises on an unconfigured step, so the task and its acceptance now name that dictionary.
5. P5-T7. Defect class: ambiguous anchor. `.agents/skills/repo-automation-adapter/SKILL.md` has three `Required tools:` lists, so the task now names the list under `### PowerShell quality gates`.
6. P6-T8. Defect class: evidence selection left to the executor. Replaced the unnamed citation search with a fixed, case-insensitive token list in the task text.

This record names no scanned token, because P6-T8 reads this folder.
