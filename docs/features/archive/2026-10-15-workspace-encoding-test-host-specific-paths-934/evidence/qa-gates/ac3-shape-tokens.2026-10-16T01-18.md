# AC-3 Input-Shape Tokens (P2-T13, Issue #934)

Timestamp: 2026-10-16T01-18
Command: git grep -n -w -F -e BACKSLASH -e SLASH -e toLowerCase -e OTHER_REPO -e unrelated-suffix -e wt-2026-06-13-11-51 -e wt-2026-07-03-22-30 -e wt-2026-07-07T18-00 -e 'toEqual([])' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts   (working directory: worktree root)
EXIT_CODE: 0
Output Summary:
- 23 output lines (path prefix omitted): 11, 12, 13, 28, 39, 40, 56, 58, 61, 77, 82, 87, 88, 107, 113, 130, 132, 141, 151, 175, 181, 199, 207.
- All nine tokens map to at least one use-site line (declaration lines 11, 12, 13 are not used for mapping). Verdict: PASS.

| Token | AC-3 shape | Mapped line (verbatim, leading spaces trimmed) |
| --- | --- | --- |
| `BACKSLASH` | backslash separator | 28: `const workspacePath = workspacePathOf(BACKSLASH, REPO);` (also 39, 56, 77, 107, 130, 151) |
| `SLASH` | forward-slash separator (`SLASH` not part of `BACKSLASH`) | 40: `const forwardSlashPath = workspacePathOf(SLASH, REPO);` (also 175, 199) |
| `toLowerCase` | uppercase input against lowercase on-disk directory | 58: `const lowercaseDirectory = encodedNameOf(UPPER_DRIVE, REPO).toLowerCase();` |
| `wt-2026-06-13-11-51` | `-wt-` worktree suffix | 82: `` `${REPO}-wt-2026-06-13-11-51`, `` |
| `wt-2026-07-03-22-30` | nested worktree suffix | 113: `` `${REPO}-wt-2026-07-03-16-18-wt-2026-07-03-22-30`, `` |
| `wt-2026-07-07T18-00` | nested worktree suffix | 181: `` `${REPO}-wt-2026-07-07T12-00-wt-2026-07-07T18-00`, `` |
| `unrelated-suffix` | unrelated-suffix rejection | 87: `` encodedNameOf(UPPER_DRIVE, `${REPO}-unrelated-suffix`), `` |
| `OTHER_REPO` | other-repository rejection | 61: `encodedNameOf(UPPER_DRIVE, OTHER_REPO),` (also 88, 132, 207) |
| `toEqual([])` | empty result | 141: `expect(matches).toEqual([]);` |
