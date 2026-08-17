# QA Gate — OrchestratorState Preflight Collapse and Probe Deletion ([P11-T5])

Timestamp: 2026-08-15T18-00

Issue: #475
Plan: `docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/plan.2026-08-15T12-47.md` (revision 8)
Task: `[P11-T5]` — verify the preflight change immediately.

## Self-Gating Invariant (AC-29), quoted verbatim

> **The reconciliation branch corrects the checkpoint, never the check.**

If a newly enforced check fails against real checkpoint state, that is the gate working
correctly, not a defect in the check. The permitted response is to correct
`artifacts/orchestration/orchestrator-state.json` and record the failing check IDs in the
evidence artifact before the phase closes. Adjusting a check to accommodate the checkpoint,
weakening a row to make this run pass, or relaxing a threshold is PROHIBITED. If the failure
cannot be resolved by correcting the checkpoint, execution halts and reports it as a finding —
the executor must not continue past this phase.

**Compliance statement:** no check, no inventory row, no error string, and no threshold was
altered in this phase. Phase 11 required no checkpoint correction at all — see the
reconciliation section below.

## Commands

### 1. Pester — the six suites named by the task

Command:

```
Invoke-Pester -Path `
  tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1, `
  tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1, `
  tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1, `
  tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1, `
  tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1, `
  tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 -PassThru
```

EXIT_CODE: 0

Output Summary: 143 passed, 0 failed, 0 skipped. Scope was narrowed to the six named suites;
the guard suite was NOT run, per the plan's standing constraint. The four direct seam-injection
tests in `OrchestratorState.Tests.ps1` pass unmodified. The PR-author preflight returns the same
fail-closed verdicts for missing, unreadable, and structurally invalid checkpoints, with the
`ORCHESTRATOR_STATE_PREFLIGHT_FAILED` prefix unchanged.

### 2. PoshQC format

Command: `mcp__drm-copilot__run_poshqc_format` with `scan_folders = [".claude/lib/orchestrator-state", "tests/scripts/claude-lib/orchestrator-state", "tests/scripts/claude-hooks"]`

EXIT_CODE: 0

Output Summary: clean.

### 3. PoshQC analyze

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same three scan folders.

EXIT_CODE: 0

Output Summary: 0 findings. No rule suppressed, no analyzer setting changed.

### 4. Direct-invocation sanity check via the consumer hook

Two real, separate `pwsh` processes were used.

**4a — the literal `-File` form named by the task.**

Command: `pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1` with `CLAUDE_HOOK_INPUT` / `CLAUDE_TOOL_INPUT` set to a `gh pr create --body-file` payload.

EXIT_CODE: 0

Output Summary: the process started and terminated cleanly with no `CommandNotFoundException`
and emitted a well-formed PreToolUse decision. The verdict is
`PR_CONTEXT_MISSING: artifacts/pr_context.summary.txt is absent`, because the hook's earlier
PR-context gate (Case C) intercepts before the preflight is reached. That gate is unrelated to
this change and is behaving correctly.

**4b — reaching the preflight itself.**

The task requires a payload "that reaches the preflight path". The bare `-File` form cannot
reach it while `artifacts/pr_context.summary.txt` is absent, and fabricating that artifact to
force the path would be an accommodation of exactly the kind this phase prohibits. The
preflight was therefore reached using the established house pattern from
`tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`: a
real separate `pwsh` process dot-sources the hook, points the PR-context seam at a
permanently-existing repository file (the hook script itself), and replays the hook's own
decision path. No temporary file is created.

Command:

```
pwsh -NoProfile -Command ". '.claude/hooks/enforce-pr-author-skill.ps1'
$script:PrContextArtifactPath = '.claude/hooks/enforce-pr-author-skill.ps1'
Invoke-PrAuthorSkillDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT | ConvertTo-Json -Compress -Depth 5"
```

EXIT_CODE: 0

Output Summary: no `CommandNotFoundException`; the deleted probe is referenced nowhere on the
path. The verdict is

```
ORCHESTRATOR_STATE_PREFLIGHT_FAILED: Checkpoint PR-creation readiness validation failed: step6_status is pending.
Checkpoint PR-creation readiness validation failed: step7_status is pending.
Checkpoint PR-creation readiness validation failed: local_execution_overrides must be an empty list when present.
```

The `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` prefix is intact and the collapsed default `$Invoker`
ran the portable in-process validation with no subprocess of its own.

### 5. Guard finding count over the guarded tree (read-only measurement)

The guard suite itself was not run, per the plan. Its detection helper was dot-sourced in a
one-off `pwsh -NoProfile` process and run over the two scan roots (`.claude/hooks`,
`.claude/lib`, `*.ps1` and `*.psm1`, excluding `.claude/lib/bash/**`) to measure the current
count for reporting only. Formal verification remains Phase 14's task.

EXIT_CODE: 0

Output Summary: `FILES_SCANNED: 55`, `TOTAL_FINDINGS: 0`. The guarded tree now contains zero
Python-invocation findings, down from the five sites recorded in
`evidence/regression-testing/guard-scan-fail-before.2026-08-15T19-53.md`. All five are removed:
the two discovery hooks (Phase 3), `validate-orchestrator-output.ps1` (Phase 10), and both
`OrchestratorState.psm1` sites (this phase). The allowlist remains empty.

## Self-Gating Reconciliation — Phase 11

The preflight's collapsed default `$Invoker` now runs `Get-OrchestratorStateUnconditionalError`
(the whole U family) before the readiness gate, so the live checkpoint was subjected to the
U-family checks a second time on this phase's path.

**No new shape failure surfaced, and no checkpoint correction was required in Phase 11.** The
U-family leg contributed ZERO errors. This is a direct consequence of the Phase 10
reconciliation: the U2 required-key and U5 delegation-receipt shape defects corrected under
`[P10-T6]` were the checkpoint's only shape defects, and the preflight runs the same
unconditional block, so it now passes that block cleanly. The Phase 10 corrections are
independently confirmed by this second, differently-routed execution of the same checks.

The three failures that remain are all PR-creation-readiness state, not shape:

| Failing check (verbatim) | Classification | Why this is the correct state |
| --- | --- | --- |
| `Checkpoint PR-creation readiness validation failed: step6_status is pending.` | Mid-run completion state | S6 executor validation has not run; execution is mid-plan. Expected, per the governing directive, and not an accommodation trigger. |
| `Checkpoint PR-creation readiness validation failed: step7_status is pending.` | Mid-run completion state | S7 feature-review has not run. |
| `Checkpoint PR-creation readiness validation failed: local_execution_overrides must be an empty list when present.` | Declared, approved override | LEO-1 is a real, coordinator-approved override (the sanctioned batch-budget reset). Deleting it to make the check pass would falsify the checkpoint and is exactly the accommodation the invariant prohibits. |

All three are the gate correctly refusing to certify a mid-run checkpoint as ready for the first
`gh pr create` of the branch. The run's binding stop condition forbids creating a pull request
at all, so a blocking preflight verdict is the intended outcome.

### Verdict

**The gate behaved correctly and Phase 11 closes green.** No shape failure arose, so no
checkpoint correction was needed. No case arose in which a failure could not be resolved by
correcting the checkpoint or correctly classified as expected mid-run state, so no halt
condition was met. No check, row, or threshold was altered.

## Files changed in this phase

- `.claude/lib/orchestrator-state/OrchestratorState.psm1` — 488 lines (cap 500). `Test-PythonOrchestratorValidatorAvailable` deleted (definition and export); the `Invoke-OrchestratorStatePreflight` default `$Invoker` collapsed to the portable path; the module doc-comment, the export comment, and the invoker doc-comment rewritten so no prose reference to the deleted symbol survives. The `[scriptblock] $Invoker` parameter, the `{ExitCode, Output}` -> `{HasErrors, ErrorText}` translation, and the strict-mode property guard are all retained.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` — capability-detection context rewritten with all three probe mocks removed, plus a new default-path test proving a U-family violation now fails the preflight, and a negative-invocation AST assertion over the collapsed invoker.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` — stale comment updated; every verdict assertion unchanged.

`Test-PythonOrchestratorValidatorAvailable` now has zero references in production and test
sources. The only remaining occurrences in the repository are the bundled mirror under
`extensions/drm-copilot/resources/claude-customizations/.claude/**`, which Phase 12 updates, and
historical documentation.
