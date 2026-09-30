# PoshQC Analyzer Gate Final QA (P10-T2)

Timestamp: 2026-09-30T15-10
Command: mcp__drm-copilot__run_poshqc_analyze with scan_folders: [".claude/lib/orchestrator-state", "tests/scripts/claude-lib/orchestrator-state"]
ok: true
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Recorded run: MCP result `ok:true` (2 selected scan folders), matching the P0-T27 baseline (`EXIT_CODE: 0`). The MCP result carries no finding counts; the count gate is P10-T3 (`Findings=0 Errors=0`).

## Deviation: first attempt returned ok:false (tool runtime exception)

The first call of the identical command, immediately before the recorded run, returned `ok:false` with summary `Command exited with code 1.` and this `stderr_excerpt` (path shortened to repository-relative form):

```
Exception: Invoke-ScriptAnalyzer failed for
.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 (System.InvalidOperationException): You cannot have more than one dynamic module in each
dynamic assembly in this version of the runtime.
```

Diagnosis: the exception is raised by the analyzer host (.NET dynamic-assembly limit), not a rule finding. `OrchestratorStateCheckpointValue.psm1` is not changed on this branch (`git diff --stat origin/epic/orchestrator-state-contract-correctness-integration -- .claude/lib/orchestrator-state` lists only `OrchestratorState.psm1`). The identical call re-run once returned `ok:true`. The fault is recorded as nondeterministic tooling behavior and is returned to the orchestrator for triage per the P10-T2 rule on results that differ from the baseline.
