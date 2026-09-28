# PowerShell format baseline (remediation cycle 1)

Timestamp: 2026-08-30T00-51

Task: [P0-T8]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command:

```
mcp__drm-copilot__run_poshqc_format
```

invoked with `workspace_root` set to the absolute worktree path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan states PowerShell format runs through this MCP tool; the absolute `workspace_root` above is the value actually supplied, because the MCP server cannot infer the calling agent's checkout.

The two porcelain captures were run as `git status --porcelain` with the working directory set to that same absolute worktree path.

EXIT_CODE: 0

ExpectedExitCode: 0

## Exit-code derivation

Derived exactly as the plan's "How `EXIT_CODE:` is derived for a PoshQC MCP task" paragraph fixes it. The result object carries `ok: true`, so `EXIT_CODE: 0` is recorded. Had it carried `ok: false`, the integer would have been taken from the `Command exited with code <N>.` message that `CommandExecutionError` produces and that the MCP layer projects into `summary`.

Result object, verbatim:

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'."}
```

`summary` field, verbatim:

```
Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5'.
```

No `stderr_excerpt` field is present, which is consistent with `ok: true`.

## Why the exit code is not the evidence here

This is a write-mode command. The PoshQC formatter rewrites tracked source in place and exits with the same code whether or not it rewrote anything, so its exit code is identical on a clean run and on a repairing run. The `summary` field is likewise identical in both cases: it reports only that the tool ran, and carries no count of rewritten files. **The tree observation below is the load-bearing evidence for this task, not the exit code and not the summary.**

## Porcelain capture, immediately BEFORE the invocation

```
 M docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md
?? docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/
```

## Porcelain capture, immediately AFTER the invocation

```
 M docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md
?? docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/
```

## Are the two captures identical?

**Yes. The two captures are identical, line for line and in the same order.** Neither a new entry nor a changed status letter appears between them.

This is the statement that makes the rewritten-path list below legitimately empty rather than merely unreported.

## Rewritten paths

**None. The formatter rewrote no file.**

The list is empty and the preceding section is what establishes it. Because the two porcelain captures are identical, no tracked file acquired a modified status across the invocation and no new untracked file appeared. Had the formatter rewritten a tracked `.ps1`, `.psm1`, or `.psd1` file, a new ` M` entry naming that file would have appeared in the after capture.

A later task keys its disposition to this exact list, so the list is stated explicitly as empty rather than omitted.

## Note on the two entries common to both captures

Both entries predate this task and are unchanged by it. They are recorded here so a reviewer does not read them as formatter output:

- The ` M` entry on `remediation-plan.md` is the `[ ]` to `[x]` check-off of the Phase 0 tasks that ran before this one. It is a Markdown file and is outside the PoshQC formatter's `.ps1`/`.psm1`/`.psd1` scope.
- The `??` entry on `evidence/remediation-baseline/` is the untracked evidence directory holding this cycle's Phase 0 artifacts, all of them Markdown.

Because both entries appear identically in the before capture and the after capture, neither is attributable to the formatter.

## Baseline disposition

This task is a baseline capture of the tree as found. Under its stated terms a non-zero derived exit code would have been recorded with `ExpectedExitCode:` set to that same integer rather than treated as a failure of this task. The observed code is 0, so `ExpectedExitCode: 0` is recorded, which renders identically to omitting the field.

No pre-existing PowerShell formatting drift was found, so no drift was repaired at baseline, and any formatting difference observed after Phase 1 or Phase 2 is attributable to this remediation's own edits rather than to pre-existing state.

## Output Summary

`mcp__drm-copilot__run_poshqc_format` returned `ok: true`, giving a derived `EXIT_CODE: 0`. The porcelain captures taken immediately before and immediately after the invocation are identical, so the formatter rewrote no file. The rewritten-path list is empty, and the identical captures are what make it legitimately empty. The worktree carries no pre-existing PowerShell formatting drift at baseline.
