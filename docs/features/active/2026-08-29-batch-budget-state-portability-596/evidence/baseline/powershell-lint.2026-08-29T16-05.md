# [P0-T10] PowerShell lint baseline (PoshQC analyzer)

Timestamp: 2026-08-29T20-39

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`
and no `scan_folders` restriction.

EXIT_CODE: 0

Output Summary: The analyzer ran successfully and reported no findings. The result carried
`ok: true`, from which `EXIT_CODE: 0` is derived. The baseline is therefore clean: the analyzer does
**not** already report findings, so the [P7-T3] assertion of zero findings is a real gate against
this run rather than a claim inherited from a dirty baseline.

## Exit-code derivation

Derived exactly as fixed in the plan's "How `EXIT_CODE:` is derived for a PoshQC MCP task"
paragraph. The PoshQC MCP tools return a structured result object rather than a process exit code.
`EXIT_CODE: 0` is recorded when the result carries `ok: true`; a non-zero code would be taken from
the `Command exited with code <N>.` message on an `ok: false` result. This result carries `ok: true`,
so `EXIT_CODE: 0`.

No `ExpectedExitCode:` field is set, because the observed exit code is 0 and the artifact schema
treats an absent expectation as an expectation of 0. The observed-state clause in the task text,
which applies when the derived exit code is non-zero, was **not** triggered.

## Result object, verbatim

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'."}
```

`summary` field, verbatim:

```
Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'.
```

No `stderr_excerpt` field is present. That field appears on failure only, and its absence is
consistent with `ok: true`.

## Zero-findings entailment

Per the plan's "Why an `ok: true` analyze result is a falsifiable zero-findings claim" paragraph:
`Invoke-PoshQCAnalyze` raises `PSScriptAnalyzer reported N issue(s).` whenever its result set is
non-empty (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:181-184`), and the bundled entry script
sets `$ErrorActionPreference = "Stop"`
(`extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1:14`), so any finding terminates
the process with a non-zero code and the MCP result would be `ok: false`. The observed `ok: true`
therefore entails zero analyzer findings at baseline.

The entailment is asserted of the installed extension's bundled analyzer copies that this MCP tool
actually executes; the two repository files cited above are the source of the mechanism, not the
files that ran.

## Statement required by the task text

The analyzer does **not** already report findings at baseline. The derived exit code is zero, so the
explicit statement the task requires in the non-zero case does not apply. [P7-T3] can assert zero
findings against a baseline that is itself zero.
