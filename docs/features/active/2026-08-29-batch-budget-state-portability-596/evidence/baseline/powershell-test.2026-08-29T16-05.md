# [P0-T11] PowerShell test baseline (PoshQC MCP runner, unscoped)

Timestamp: 2026-08-29T20-40

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`
and no `scan_folders` restriction.

EXIT_CODE: 2

ExpectedExitCode: 2

Output Summary: The MCP test run returned `ok: false` with `summary` reading
`Command exited with code 2.`, from which `EXIT_CODE: 2` is derived. This is a baseline capture of
the tree as found rather than a gate, so `ExpectedExitCode: 2` is recorded to match the observed
integer and the artifact normalizes to pass. The condition is pre-existing: it precedes every edit
this plan makes, and no repair was attempted during Phase 0. The `stderr_excerpt` shows the failure
originating in publish-verification message assertions, which are unrelated to the batch-budget
hooks this feature changes.

## Exit-code derivation

Derived exactly as fixed in the plan's "How `EXIT_CODE:` is derived for a PoshQC MCP task"
paragraph. The PoshQC MCP tools return a structured result object rather than a process exit code. A
non-zero exit of the spawned `pwsh` process is converted into a `CommandExecutionError` whose message
is `Command exited with code <N>.`, which the MCP layer projects onto `ok: false` with that message
in `summary`. This result carries `ok: false` and `summary` reading `Command exited with code 2.`,
so `EXIT_CODE: 2` with `N = 2`.

## Result object, verbatim

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5",
  "summary": "Command exited with code 2.",
  "stderr_excerpt": "Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with \"gh workflow run publish-mcp-npm.yml --ref\" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish."
}
```

`summary` field, verbatim:

```
Command exited with code 2.
```

`stderr_excerpt` field, verbatim:

```
Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.
Publish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.
Publish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.
```

## Pre-existing condition statement

The non-zero result is **pre-existing**. It was observed at Phase 0 baseline, before any file this
plan edits had been touched: the [P0-T5] git capture shows the only modified tracked file is this
feature's own plan file and the only untracked path is this feature's own `evidence/` directory. The
`stderr_excerpt` names publish-verification tag messages for `mcp-server-v0.0.2`, which belong to the
release/publish tooling and not to the three batch-budget hooks or their Pester suites. No repair was
attempted, consistent with the plan's instruction not to repair a pre-existing failure during
Phase 0.

## What this MCP result does not carry

This MCP result carries **no test counts and no test names**. On both the success and failure paths
the `run_poshqc_test` result object exposes only `ok`, `tool`, `workspace_root`, `summary`, and (on
failure) `stderr_excerpt`; no Pester passed/failed/skipped counts, no `It` names, and no process
stdout are returned. **No count is asserted in this artifact.**

The task that records the counts is **[P0-T12]**, which runs the self-hosted Form A Pester invocation
and reads the replayed `Tests Passed: ` line and the coverage report directly. [P0-T12] is also the
source of the four baseline coverage percentages that [P7-T12] needs.

## Runner-selection note

`mcp__drm-copilot__run_poshqc_test` resolves its Pester settings from the installed extension rather
than from either in-repo copy, so it is retained in this plan only where a pass/fail signal alone is
the evidence. Every count-bearing and coverage-bearing observation uses the self-hosted Form A
invocation instead.
