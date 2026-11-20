# Pass-After Run of PoshQcWorkflow.Tests.ps1 (P3-T2)

Timestamp: 2026-10-01T16-55
Deviations: D8 (CI JUnit plus MCP run in place of SP6) and D9 (Python JUnit helper).

Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <REPO_ROOT>, scan_folders = ["tests/scripts/workflows"])
EXIT_CODE: 0
Output Summary: `ok: true`; summary `Ran bundled PoshQC test against '<REPO_ROOT>' with 1 selected scan folder(s).` (Before the workflow edit the same call returned `ok: false`, exit code 6.)

CI evidence: run https://github.com/drmoisan/drm-copilot/actions/runs/36894194578 (P4-T2), job `PowerShell QC` databaseId 110476951925, headSha 90b6bd4a8646f0a510509c839e9daec77dff69d1 (CI_SHA_1), conclusion `success`.

Command: gh run view 36894194578 --log --job 110476951925 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6091, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`

Command: gh run download 36894194578 --name poshqc-test-results --dir <session-scratchpad>/windows-first-run-743
EXIT_CODE: 0
Output Summary: pester-junit.xml and coverage files downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/windows-first-run-743/pester-junit.xml --case ''
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=6101 failures=0 errors=0`; `SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | tests=7 | failures=0 | errors=0 | skipped=0`. FAILED-COUNT 0, PASSED-COUNT 7, SKIPPED-COUNT 0. All seven R1 cases PASSED:

```
CASE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | _poshqc.yml workflow invariants.declares exactly the poshqc and poshqc-linux-hooks jobs | PASSED
CASE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | _poshqc.yml workflow invariants.keeps the poshqc job on windows-latest running Invoke-PoshQCTest | PASSED
CASE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | _poshqc.yml workflow invariants.runs the poshqc-linux-hooks job on ubuntu-latest under its check name | PASSED
CASE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | _poshqc.yml workflow invariants.grants the poshqc-linux-hooks job read-only repository contents | PASSED
CASE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | _poshqc.yml workflow invariants.limits the poshqc-linux-hooks Run.Path to the two hook-suite folders | PASSED
CASE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | _poshqc.yml workflow invariants.fails the poshqc-linux-hooks job on a failed test and collects no coverage | PASSED
CASE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | _poshqc.yml workflow invariants.uploads the poshqc-linux-hooks JUnit result under a distinct artifact name | PASSED
```

These cover AC-1, AC-2, AC-3, and the AC-4 `poshqc` assertions.
