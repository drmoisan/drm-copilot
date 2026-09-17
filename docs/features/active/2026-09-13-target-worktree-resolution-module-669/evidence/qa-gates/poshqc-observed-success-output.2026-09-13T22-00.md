# PoshQC Baseline Stage Records (consolidated)

Timestamp: 2026-09-17T08:01:34-04:00 (file write time)
Command: consolidation of the records captured by [P0-T4], [P0-T5], [P0-T6], and [P0-T7] (no new command executed)
EXIT_CODE: 0
Output Summary: Four stage blocks copied verbatim from the Phase 0 baseline artifacts. Format and analyze MCP results are ok=true with the fixed template summary; the MCP test result is ok=false (exit 2, two pre-existing failures outside scope); the self-hosted test run printed "Tests Passed: 1384, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0".

## Stage: format ([P0-T4])

MCP result object (verbatim):

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c' with 5 selected scan folder(s)."}
```

Source-derived, not observed: `PoshQC.Analyzer.psm1:62` emits one `Formatted: ` line per rewritten file and
`:64` one `Already formatted: ` line per unchanged file, to child-process stdout that the MCP layer discards.

## Stage: analyze ([P0-T5])

MCP result object (verbatim):

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c' with 5 selected scan folder(s)."}
```

Self-hosted `Invoke-PoshQCAnalyze` stdout (verbatim):

```text
PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a183dccbc73c30c
```

Baseline finding set: none

## Stage: MCP test ([P0-T6])

MCP result object (verbatim):

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c",
  "summary": "Command exited with code 2.",
  "stderr_excerpt": "Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with \"gh workflow run publish-mcp-npm.yml --ref\" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish."
}
```

Counts read from `evidence/other/baseline-pester-junit.2026-09-13T22-00.xml` (`testsuites` root):
tests=4547, failures=2, errors=0, disabled (skipped)=9.

## Stage: self-hosted test ([P0-T7])

Summary lines as printed (verbatim, ANSI codes removed):

```text
Tests completed in 47.04s
Tests Passed: 1384, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Covered 32.77% / 0%. 12,928 analyzed Commands in 101 Files.
```

The `Pester summary (replayed for readability):` header was not printed in this run; see
`evidence/baseline/baseline-poshqc-selfhosted-test.2026-09-13T22-00.md` for the observation.

## Source-derived, not observed

- `PoshQC.Testing.psm1:422-428` composes `Tests completed in {0:N2}s` and
  `Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}` from the Pester result object.
- `PoshQC.Testing.psm1:454-456` logs `Pester summary (replayed for readability):` followed by those two lines,
  through `Write-Information -InformationAction Continue`.

Where the source-derived description and the observed blocks differ (here: the replay header was not
observed), the observed blocks are authoritative.
