# Part 3.3 Verification — validate-orchestrator-output.ps1 (routing-contract seam + human_interaction gate)

- Timestamp: 2026-06-28T00-00
- Issue: #259
- File: `.claude/hooks/validate-orchestrator-output.ps1`
- Outcome: NO-OP (all required elements present; no code change required)

## Verified Elements

### Routing-contract subprocess seam — `Invoke-RoutingContractValidation` (lines 144–194)

- Injectable `Invoker` scriptblock parameter (lines 168–178).
- Default invoker (lines 169–177) runs:
  `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <Path> --require-complete` (lines 171–172),
  capturing `ExitCode` (`$LASTEXITCODE`) and `Output`.
- `HasErrors` is true on non-zero exit OR any non-empty error text (line 192).
- Caller emits `ROUTING_CONTRACT_BLOCKED: <ErrorText>` when `HasErrors` (line 284).

### human_interaction shape gate — `Test-HumanInteractionShape` (lines 60–142)

- Absent key passes (lines 96–98).
- `requirements` must be present (lines 100–103).
- Per-requirement enforcement:
  - missing/blank `response` -> block (lines 115–117)
  - `response` outside `{scope_change, exception, halt}` -> block (lines 119–121)
  - `response == 'halt'` -> block (lines 123–125)
  - `response == 'exception'` with empty `runbook_path` -> block (lines 131–133)
  - `response == 'exception'` with non-existent `runbook_path` (via injectable `FileExistsCheck`, default `Test-Path -PathType Leaf`, lines 92–93) -> block (lines 135–137)
- Wired in `Invoke-OrchestratorOutputValidation` (lines 266–273).

## SubagentStop Block Form (Unchanged)

Entrypoint (lines 291–300) retains `Write-Error` + `exit 1` to block, `exit 0` to allow. No top-level `decision` envelope introduced. Correct for SubagentStop; not changed.
