# Post-Change Gate Detection (Pass-After Record)

Timestamp: 2026-08-20T12-14
Task: [P6-T14]
Issue: #486
Working directory: worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a61259d5432e08b89`

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan "C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot/73acdafc-7722-4904-b9f6-50feaae9cb08/scratchpad/probe-plan-486.md"`

The `Command:` line above is byte-identical to the `Command:` line of the pre-change artifact `evidence/regression-testing/pre-change-no-gate-detection.2026-08-20T11-38.md`. The synthetic probe plan at that scratchpad path is unmodified.

EXIT_CODE: 1

Output Summary:

- stdout was empty; the pre-change success line is no longer emitted.
- stderr carried exactly one line, beginning with `[P1-T1]` and naming the dotted remedy:

```
[P1-T1] --cov argument `scripts/dev_tools/plan_gate_discrimination.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.plan_gate_discrimination.
```

## Fail-before / pass-after pair

| State | Command | EXIT_CODE | Detection |
| --- | --- | --- | --- |
| Pre-change ([P0-T10]) | identical | 0 | none; no `--cov` finding emitted |
| Post-change ([P6-T14]) | identical | 1 | one Blocking G1 finding naming `[P1-T1]` and the dotted remedy |

The pre-change artifact recorded exit 0 for the identical command and the identical plan, so the pair is the fail-before and pass-after record for spec AC2 (G1 Blocking with a dotted remedy) and AC4 (automatic invocation on the existing `plan` route with no new flag). The post-change invocation supplies no flag beyond the artifact type and the path.
