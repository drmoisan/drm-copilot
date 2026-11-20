# MCP Surface Literal Pre-State — Red — [P1-T6]

Timestamp: 2026-09-07T11-27
Task: [P1-T6]

Command: `Select-String -LiteralPath extensions/drm-copilot/test/mcp-server-test-service.ts,extensions/drm-copilot/test/mcp-server.test.ts,extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts -Pattern 'C:/workspace' -SimpleMatch -CaseSensitive`
EXIT_CODE: 0

This pre-state was captured before any of the three paths was edited. None of [P1-T7], [P1-T9], or [P1-T10] had run at capture time.

## Per-file matched line numbers

| File | Count | Matching line numbers |
| --- | --- | --- |
| `extensions/drm-copilot/test/mcp-server-test-service.ts` | 1 | 46 |
| `extensions/drm-copilot/test/mcp-server.test.ts` | 73 | 32, 115, 117, 118, 126, 132, 139, 141, 142, 151, 160, 187, 189, 198, 203, 209, 211, 219, 227, 234, 242, 249, 251, 257, 258, 263, 264, 270, 277, 279, 285, 286, 291, 292, 298, 305, 307, 313, 314, 319, 320, 326, 333, 335, 341, 342, 347, 348, 354, 362, 363, 369, 380, 382, 388, 389, 394, 395, 401, 408, 421, 428, 430, 436, 462, 464, 465, 471, 472, 477, 478, 486, 487 |
| `extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts` | 12 | 71, 91, 110, 203, 213, 229, 241, 254, 265, 288, 312, 389 |

Total match count: 86

## Mechanism this pre-state proves

Each cited line was read directly from the current tree and is reproduced verbatim.

`mcp-server-test-service.ts` line 46 supplies `workspaceRoot`:

```
    workspaceRoot: "C:/workspace",
```

which line 56 forwards as the MCP argument:

```
      workspace_root: request.workspaceRoot,
```

reaching `orchestration-handoff-handlers.ts` line 154:

```
  if (!path.isAbsolute(workspaceRoot)) {
```

`mcp-server.test.ts` line 32 supplies `expected_workspace_root`:

```
  expected_workspace_root: "C:/workspace",
```

reaching `orchestration-handoff-handlers.ts` line 107:

```
  if (!path.isAbsolute(expectedWorkspaceRoot)) {
```

`repo-automation-orchestration-validation.test.ts` lines 91 and 312 supply the same two values:

```
    expectedWorkspaceRoot: "C:/workspace",
      workspaceRoot: "C:/workspace",
```

reaching both handler predicates and, through `resolvePortableHandoffAuthority`, `orchestration-handoff-authority-service.ts` line 59:

```
    if (!path.isAbsolute(workspaceRoot)) return null;
```

`path.isAbsolute("C:/workspace")` returns `false` on POSIX, so each predicate rejects the literal on Linux while accepting it on Windows. That is the platform dependence this remediation removes.

Output Summary: The pre-state records 86 matching lines across the three paths added to scope by the 2026-09-07 amendment, distributed exactly as the plan states: 1 in `mcp-server-test-service.ts` at line 46, 73 in `mcp-server.test.ts`, and 12 in `repo-automation-orchestration-validation.test.ts` at lines 71, 91, 110, 203, 213, 229, 241, 254, 265, 288, 312, 389. Every literal reaches at least one of the four production absolute-path predicates, verified by reading the cited production lines. [P1-T13] drives this same count to 0.
