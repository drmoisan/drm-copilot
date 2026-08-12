# PowerShell Analyzer Baseline

Timestamp: `2026-08-10T23-05`

Precondition: [P0-T16] returned `ok: true` and changed zero files.

MCP invocation: `mcp__drm-copilot__run_poshqc_analyze(workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25")`

EXIT_CODE: `0` (the MCP result returned `ok: true` and `isError: false`)

Error count: `0`

Warning count: `0`

Complete MCP result:

```json
{
  "content": [
    {
      "type": "text",
      "text": "{\n  \"ok\": true,\n  \"tool\": \"run_poshqc_analyze\",\n  \"workspace_root\": \"C:\\\\Users\\\\DanMoisan\\\\repos\\\\drm-copilot-wt\\\\2026-08-10T19-25\",\n  \"summary\": \"Ran bundled PoshQC analyze against 'C:\\\\Users\\\\DanMoisan\\\\repos\\\\drm-copilot-wt\\\\2026-08-10T19-25'.\"\n}"
    }
  ],
  "structuredContent": {
    "ok": true,
    "tool": "run_poshqc_analyze",
    "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
    "summary": "Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25'."
  },
  "isError": false
}
```
