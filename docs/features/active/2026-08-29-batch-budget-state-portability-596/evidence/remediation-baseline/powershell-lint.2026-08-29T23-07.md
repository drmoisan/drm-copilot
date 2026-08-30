# PowerShell lint baseline (remediation cycle 1)

Timestamp: 2026-08-30T00-52

Task: [P0-T9]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command:

```
mcp__drm-copilot__run_poshqc_analyze
```

invoked with `workspace_root` set to the absolute worktree path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan states PowerShell lint runs through this MCP tool; the absolute `workspace_root` above is the value actually supplied, because the MCP server cannot infer the calling agent's checkout.

EXIT_CODE: 0

ExpectedExitCode: 0

## Exit-code derivation

Derived exactly as the plan's "How `EXIT_CODE:` is derived for a PoshQC MCP task" paragraph fixes it. The result object carries `ok: true`, so `EXIT_CODE: 0` is recorded. Had it carried `ok: false`, the integer would have been taken from the `Command exited with code <N>.` message that `CommandExecutionError` produces and that the MCP layer projects into `summary`, and `stderr_excerpt` would have been quoted verbatim alongside it.

## Result object fields

Result object, verbatim:

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'."}
```

- `tool`: `run_poshqc_analyze`
- `workspace_root`: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`
- `summary`, verbatim: `Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'.`
- `stderr_excerpt`: not present. The field is emitted on failure only, and its absence is consistent with `ok: true`.

## Why `ok: true` is a falsifiable zero-findings claim

Recorded because a bare `ok: true` would otherwise be indistinguishable from a tool that ran and reported nothing.

`Invoke-PoshQCAnalyze` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` raises `PSScriptAnalyzer reported N issue(s).` whenever its result set is non-empty, and the bundled entry script sets `$ErrorActionPreference = "Stop"`. A single analyzer finding therefore terminates the spawned `pwsh` process with a non-zero exit code, which the MCP layer projects onto `ok: false`. `ok: true` is reachable only when the analyzer result set is empty. The observed `ok: true` is consequently a positive claim that PSScriptAnalyzer reported zero findings across the scanned set, not merely a claim that the tool executed.

A PoshQC MCP result carries no test counts and no test names at all, so nothing beyond the four fields above is available from this call.

## Baseline disposition and the [P5-T4] prediction

The plan predicts `ok: true` for this task and records the basis for that prediction: an independent read-only invocation of `mcp__drm-copilot__run_poshqc_analyze` against this worktree on 2026-08-29 returned `ok: true`, establishing that the workspace is analyzer-clean after the integration merge.

**The observed result matches the prediction.** `ok: true` was returned, so:

- The analyzer does **not** already report findings at baseline. The plan's conditional requirement to state otherwise does not apply, because that requirement is conditioned on a non-zero derived exit code.
- The acceptance condition of [P5-T4], which asserts `ok: true`, is reachable rather than pre-broken. Any `ok: false` observed at [P5-T4] will be attributable to this remediation's own edits rather than to pre-existing analyzer debt.

Under this task's stated terms a non-zero derived exit code would have been recorded with `ExpectedExitCode:` set to that same integer, and this artifact would then have had to state explicitly that the analyzer already reports findings. The observed code is 0, so `ExpectedExitCode: 0` is recorded, which renders identically to omitting the field.

## Output Summary

`mcp__drm-copilot__run_poshqc_analyze` returned `ok: true`, giving a derived `EXIT_CODE: 0`. PSScriptAnalyzer reported zero findings: the analyzer raises a terminating error on any non-empty result set under `$ErrorActionPreference = "Stop"`, so `ok: true` is a falsifiable zero-findings claim rather than a bare execution receipt. No `stderr_excerpt` present. The result matches the plan's recorded prediction, and the workspace is analyzer-clean at baseline, so [P5-T4]'s `ok: true` acceptance is reachable.
