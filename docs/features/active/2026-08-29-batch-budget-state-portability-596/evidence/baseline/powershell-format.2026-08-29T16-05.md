# [P0-T9] PowerShell format baseline (PoshQC formatter)

Timestamp: 2026-08-29T20-38

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`
and no `scan_folders` restriction. Bracketed by `git status --porcelain` immediately before and
immediately after the invocation.

EXIT_CODE: 0

Output Summary: The formatter ran successfully and left the tree unchanged. The result carried
`ok: true`, from which `EXIT_CODE: 0` is derived. The `git status --porcelain` outputs captured
immediately before and immediately after the invocation are byte-identical, which establishes that
the formatter rewrote no file. No pre-existing PowerShell formatting drift was repaired at baseline,
so the later [P7-T2] gate remains a real observation.

## Exit-code derivation

Derived exactly as fixed in the plan's "How `EXIT_CODE:` is derived for a PoshQC MCP task"
paragraph: the PoshQC MCP tools return a structured result object rather than a process exit code;
`EXIT_CODE: 0` is recorded when the result carries `ok: true`. This result carries `ok: true`, so
`EXIT_CODE: 0`. No `stderr_excerpt` field is present, which is consistent with the success path
(that field appears on failure only).

## Result object, verbatim

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'."}
```

`summary` field, verbatim:

```
Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'.
```

That summary is the canned success template; it carries no per-file status and no count of rewritten
files, which is why the porcelain bracket below is the evidence of record for whether the tree
changed.

## `git status --porcelain` immediately BEFORE the invocation

```
 M docs/features/active/2026-08-29-batch-budget-state-portability-596/plan.2026-08-29T16-05.md
?? docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/
```

## `git status --porcelain` immediately AFTER the invocation

```
 M docs/features/active/2026-08-29-batch-budget-state-portability-596/plan.2026-08-29T16-05.md
?? docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/
```

## Tree-change statement

The two porcelain outputs are **identical**. The formatter left the tree **unchanged**: it rewrote
**no** files. There is therefore no list of rewritten paths to record, and no pre-existing drift was
repaired at baseline.

The two entries present in both captures are this feature folder's own churn — the plan file's Phase
0 check-offs and this feature's untracked `evidence/` directory — and were already present in the
[P0-T5] baseline capture. Neither is a PowerShell file and neither was produced by the formatter.
