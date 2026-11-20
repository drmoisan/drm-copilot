# PowerShell Format Baseline (P0-T3)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`

EXIT_CODE: 0

## Raw Result

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a3c3e2a8cfa4dbcd5","summary":"Ran bundled PoshQC format against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a3c3e2a8cfa4dbcd5'."}
```

The MCP entry point returns a structured result rather than a raw process exit code. `ok: true` is
the success signal and is recorded as `EXIT_CODE: 0`.

## Changed-File Count

Changed files: 0

Derivation: the MCP result carries no changed-file count, so the count was derived from the working
tree immediately after the run. `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` returned no
rows, giving a count of 0 PowerShell files modified by the formatter.

The full porcelain status at that moment showed only two entries, neither of them a formatter
effect:

```
 M docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/plan.2026-08-24T08-39.md
?? docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/
```

The modified plan file is this executor's own Phase 0 checklist check-offs. The untracked evidence
directory holds this phase's artifacts. Neither is a PowerShell file and neither was produced by the
formatter.

Output Summary: PoshQC format completed successfully against the repository root with `ok: true`,
recorded as exit code 0. Numeric changed-file count: 0. The PowerShell tree was already
format-clean at the baseline commit `afbf51dfe6508319a2d673603d31825077d8cddb`, so any non-zero
changed-file count in the Phase 7 final-format run (P7-T1) is attributable to this change. The
toolchain loop did not need to restart at this stage.
