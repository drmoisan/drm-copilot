# Baseline — PSScriptAnalyzer (PoshQC analyze), issue #491

Timestamp: 2026-08-19T10-20

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root: C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-19T08-39`

EXIT_CODE: 0

Output Summary:

- Returned `ok: true`, which denotes zero PSScriptAnalyzer findings across the scanned set.
- `summary` verbatim: `Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-19T08-39'.`
- The tool returns only `{ok, tool, workspace_root, summary}` and writes no artifact file, so the
  `ok` flag is the entire finding signal. Baseline is clean.
