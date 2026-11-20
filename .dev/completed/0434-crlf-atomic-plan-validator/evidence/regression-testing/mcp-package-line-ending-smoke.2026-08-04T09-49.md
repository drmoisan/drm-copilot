# MCP package line-ending smoke

Timestamp: 2026-08-04T10-22-00-04:00

Command: Start `packages/mcp-server/out/mcp-server.js` as a fresh Node stdio MCP process for each input; initialize the MCP session; call `validate_orchestration_artifacts` with `artifact_type: "plan"`; validate the original TaskMaster CRLF plan plus LF, CRLF, and CR variants created only in one verified GUID-named directory beneath `[System.IO.Path]::GetTempPath()`; re-verify the exact cleanup target; delete that directory; compare TaskMaster and drm-copilot worktree status before and after.

EXIT_CODE: 0

Output Summary: The generated local MCP package accepted all four invocations. The original TaskMaster plan contained 141 CRLF delimiters, zero lone LF delimiters, and zero lone CR delimiters. Every response reported `Tool=validate_orchestration_artifacts`, `Ok=true`, and `IsError=false`. The MCP process reported package version `1.0.20`, which is the unreleased local package manifest version containing the generated fixed bundle. The verified temporary directory was removed, and both worktree status snapshots were unchanged.

## Results

| Variant | Server version | Tool | Ok | IsError |
| --- | --- | --- | --- | --- |
| CRLF original | 1.0.20 | validate_orchestration_artifacts | true | false |
| LF | 1.0.20 | validate_orchestration_artifacts | true | false |
| CRLF temporary variant | 1.0.20 | validate_orchestration_artifacts | true | false |
| CR | 1.0.20 | validate_orchestration_artifacts | true | false |

## Safety and cleanup

- Temporary directory pattern: `drm-copilot-434-mcp-smoke-<32 lowercase hexadecimal GUID characters>` beneath the resolved system temporary directory.
- Pre-creation and pre-deletion checks required the resolved path to start with the resolved temporary-directory prefix and the basename to match the exact pattern.
- Cleanup confirmed: true.
- TaskMaster status unchanged: true.
- drm-copilot status unchanged: true.
