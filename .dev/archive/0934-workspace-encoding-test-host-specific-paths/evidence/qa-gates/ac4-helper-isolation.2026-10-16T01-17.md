# AC-4 Helper Isolation (P2-T12, Issue #934)

Timestamp: 2026-10-16T01-17
Command: git grep -n -E -e 'function (encodedNameOf|workspacePathOf)|encodeWorkspacePath' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts   (working directory: worktree root); followed by a Read of the file lines S..E
EXIT_CODE: 0
Output Summary:
- Output lines (path prefix `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts:` omitted):
  - `4:  encodeWorkspacePath,`
  - `16:function workspacePathOf(separator: string, ...segments: string[]): string {`
  - `21:function encodedNameOf(drive: string, ...segments: string[]): string {`
  - `25:describe("encodeWorkspacePath", () => {`
  - `31:    const encoded = encodeWorkspacePath(workspacePath);`
  - `43:    const encodedBackslash = encodeWorkspacePath(backslashPath);`
  - `44:    const encodedForwardSlash = encodeWorkspacePath(forwardSlashPath);`
  - `55:    const encodedWorkspaceName = encodeWorkspacePath(`
  - `76:    const encodedWorkspaceName = encodeWorkspacePath(`
  - `106:    const encodedWorkspaceName = encodeWorkspacePath(`
  - `129:    const encodedWorkspaceName = encodeWorkspacePath(`
  - `150:    const encodedWorkspaceName = encodeWorkspacePath(`
  - `174:    const encodedWorkspaceName = encodeWorkspacePath(`
  - `198:    const encodedWorkspaceName = encodeWorkspacePath(`
- Exactly one output line contains `function encodedNameOf` (line 21).
- S = 21; E = 23 (first subsequent line consisting only of `}`).
- Lines S through E verbatim:

```text
function encodedNameOf(drive: string, ...segments: string[]): string {
  return `${drive}--${[...PARENT_SEGMENTS, ...segments].join("-")}`;
}
```

- `encodeWorkspacePath` match line numbers: 4, 25, 31, 43, 44, 55, 76, 106, 129, 150, 174, 198. None lies in 21..23.
- Lines 21..23 contain no `workspacePathOf(` call.
- Verdict: PASS.
