# Fail-Before Run of PoshQcWorkflow.Tests.ps1 (P1-T2) [expect-fail]

Timestamp: 2026-10-01T16-45
Deviations: D7 (CI evidence plus MCP run in place of SP6) and D11 (the CI JUnit is unavailable for this run; the job log is the source).

Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <REPO_ROOT>, scan_folders = ["tests/scripts/workflows"])
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `ok: false`; summary `Command exited with code 6.` The non-zero code is consistent with six failed tests; the tool returns no test names. (The observed MCP result carries no numeric process exit code of its own; `EXIT_CODE: 1` records the failed outcome.)

CI evidence: run https://github.com/drmoisan/drm-copilot/actions/runs/36892883441 (workflow_dispatch of `_poshqc.yml`), job `PowerShell QC` databaseId 110472594155, headSha `10d71c993751b700bf673e198f1a1428ee080114` (Phase 1 boundary push; `.github/workflows/_poshqc.yml` still unmodified). Job conclusion `failure`; failing step `Test PowerShell`; step `Upload PowerShell test artifacts` was `skipped`.

D11: the `poshqc` job's upload step has no `if: always()`, so no `poshqc-test-results` artifact (and no JUnit) exists for a run whose Pester step fails. The plan forbids modifying the `poshqc` job (AC-4), so the per-test evidence is read from the job log.

Command: gh run view 36892883441 --log --job 110472594155 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6085, Failed: 6, Skipped: 10, Inconclusive: 0, NotRun: 0`

Command: gh run view 36892883441 --log --job 110472594155 | grep -E '\[-\]'
EXIT_CODE: 0
Output Summary: exactly six `[-]` lines, all in `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`:

```
[-] _poshqc.yml workflow invariants.declares exactly the poshqc and poshqc-linux-hooks jobs
[-] _poshqc.yml workflow invariants.runs the poshqc-linux-hooks job on ubuntu-latest under its check name
[-] _poshqc.yml workflow invariants.grants the poshqc-linux-hooks job read-only repository contents
[-] _poshqc.yml workflow invariants.limits the poshqc-linux-hooks Run.Path to the two hook-suite folders
[-] _poshqc.yml workflow invariants.fails the poshqc-linux-hooks job on a failed test and collects no coverage
[-] _poshqc.yml workflow invariants.uploads the poshqc-linux-hooks JUnit result under a distinct artifact name
```

Derived suite result: FAILED-COUNT 6, PASSED-COUNT 1, SKIPPED-COUNT 0 (tests=7, failures=6). The baseline run 36890793420 reported 6084 passed, 0 failed, 10 skipped; this run reports 6085 passed, 6 failed, 10 skipped. The seven new cases therefore account for one additional pass and six failures, and no other test failed. The only passing case is `keeps the poshqc job on windows-latest running Invoke-PoshQCTest` (the one R1 `It` block absent from the `[-]` list). No discovery or parse error was reported (the file was also listed `Already formatted:` in the `Format PowerShell` step).
