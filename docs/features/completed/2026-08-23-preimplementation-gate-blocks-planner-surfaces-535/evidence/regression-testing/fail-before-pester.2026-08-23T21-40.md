# Fail-Before Evidence — issue #535

Timestamp: 2026-08-23T21-40

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-23T20-24` and
`scan_folders=["tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1"]`,
run against the UNMODIFIED canonical hook `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`.

EXIT_CODE: 4

ExpectedExitCode: 4

Output Summary:

- Result: expected failure. MCP response `{"ok":false, ..., "summary":"Command exited with code 4."}`.
- Counts from `artifacts/pester/pester-junit.xml`: tests=35, failures=4, errors=0,
  disabled=0, time=1.045s. The 24 pre-existing tests all pass, and the 7 new deny cases
  pass (the unfixed hook already denies those payloads).
- The four failing tests are exactly the new allow cases, which the unfixed hook denies:
  1. `issue #535 checkpoint write exemptions.allows a Write to every exempt checkpoint literal with no ready checkpoint`
  2. `issue #535 checkpoint write exemptions.allows the backslash spelling of every exempt checkpoint literal`
  3. `issue #535 preparation-mode delegation exemption.allows the verbatim parallel-plan preparation kickoff delegation with no ready checkpoint`
  4. `issue #535 preparation-mode delegation exemption.allows the verbatim epic-plan preparation kickoff delegation with no ready checkpoint`

## Discrimination Note (recorded for audit)

An initial run of the same suite reported `tests=35, failures=0`. The four allow cases had
been authored without a `-CheckpointRaw` argument, so `Invoke-OrchestrationPreimplementationGateDecision`
fell back to the on-disk `artifacts/orchestration/orchestrator-state.json`. That checkpoint is
ready during an orchestrated run, so the decision allowed whether or not the exemption existed
and the assertion could not fail.

The four allow cases were corrected within [P1-T1]'s stated file scope to supply an explicit
not-ready checkpoint built with the existing helper
`ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false`. This is the same determinism
requirement [P1-T1] already imposes on every deny case, and it matches the spec acceptance
wording "allowed with no ready checkpoint present". The corrected run is the one recorded
above; it fails before the fix and is expected to pass after it.

Baseline run (pre-extension) for comparison:
`docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/baseline/baseline-pester-claude-hooks.2026-08-23T21-28.md`
(tests=24, failures=0).
