# P5-T19 CI PoshQC Result for AC4

Timestamp: 2026-09-27T10-46
Command: orchestrator-observed (the executor tool allowlist has no `gh`; the orchestrator ran these commands at approximately 2026-09-27T14:55Z and supplied the results):
1. `gh run list --branch bug/gate-suites-read-unmocked-local-epic-state-709 --workflow ci.yml --limit 1 --json conclusion,headSha,databaseId` -> `[{"conclusion":"success","databaseId":36326672278,"headSha":"8d26d3f8686f628fa7d75471ad2aa75a77e5579b"}]`
2. `gh run view 36326672278 --json jobs` -> job "poshqc / PowerShell QC", job id 108640658489, conclusion success
3. `gh run download 36326672278 --name poshqc-test-results --dir <session scratchpad>/ci-709` -> exit 0; pester-junit.xml present
4. Read of the `<testsuite>` element of pester-junit.xml whose name attribute ends with enforce-gate-suites.EpicStateIsolation.Tests.ps1
Executor-run: `git rev-parse HEAD` -> 8d26d3f8686f628fa7d75471ad2aa75a77e5579b (equal to the run head SHA)
EXIT_CODE: 0
Output Summary:
Run ID: 36326672278 (workflow ci.yml), conclusion success
Head SHA: 8d26d3f8686f628fa7d75471ad2aa75a77e5579b (equals `git rev-parse HEAD`)
Job: poshqc / PowerShell QC (id 108640658489), conclusion: success
testsuite name: enforce-gate-suites.EpicStateIsolation.Tests.ps1
tests="24" failures="0" errors="0" skipped="0"
PR #728: all 16 checks passed on head 8d26d3f8.
