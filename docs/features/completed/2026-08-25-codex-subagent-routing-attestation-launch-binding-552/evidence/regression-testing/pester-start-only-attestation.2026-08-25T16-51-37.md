Timestamp: 2026-08-25T16:51:37-04:00
Command: `mcp__drm-copilot__run_poshqc_test` (`scan_folders: ["tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1"]`)
EXIT_CODE: 0
Output Summary: The scoped PoshQC Pester run passed: 9 tests, 0 failures, 0 errors, and 0 skipped. The passing cases cover exact pre-spawn receipt validity, absence and late-receipt invalidity before mutation, generic-alias rejection, and model, reasoning, profile-path, and SHA mismatch rejection. The Pester coverage report contains no measured target lines for `record-subagent-routing-attestation.ps1`, equivalent to 0.00% (0 covered of 0 reported target lines), matching the P0-T5 reporting shape.

MCP result:
```json
{
  "ok": true,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-25T14-48",
  "summary": "Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-25T14-48' with 1 selected scan folder(s)."
}
```

Pester JUnit result: `tests=9`, `failures=0`, `errors=0`, `skipped=0`.
