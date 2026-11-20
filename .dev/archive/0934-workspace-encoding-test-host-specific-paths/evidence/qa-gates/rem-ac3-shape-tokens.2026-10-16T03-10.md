# AC-3 Input-Shape Re-verification (P2-T17, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T03-10
Command: git grep -n -w -F -e BACKSLASH -e SLASH -e toLowerCase -e OTHER_REPO -e unrelated-suffix -e wt-2026-06-13-11-51 -e wt-2026-07-03-22-30 -e wt-2026-07-07T18-00 -e 'toEqual([])' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts
EXIT_CODE: 0
Output Summary:
- 25 output lines. Token-to-line mapping (each a whole-word match; use sites, not declarations, for `BACKSLASH`, `SLASH`, `OTHER_REPO`):

| Token | AC-3 shape | Mapped line(s) |
|---|---|---|
| `BACKSLASH` | backslash separator | 28 `workspacePathOf(BACKSLASH, REPO)` (also 39, 56, 74, 101, 121, 142) |
| `SLASH` | forward-slash separator (not part of `BACKSLASH`) | 40 `workspacePathOf(SLASH, REPO)` (also 163, 184) |
| `toLowerCase` | uppercase input vs lowercase on-disk directory | 58 `encodedNameOf(REPO).toLowerCase()` |
| `wt-2026-06-13-11-51` | `-wt-` worktree suffix | 77 |
| `wt-2026-07-03-22-30` | nested worktree suffix | 105 |
| `wt-2026-07-07T18-00` | nested worktree suffix | 167 |
| `unrelated-suffix` | unrelated-suffix rejection | 81 |
| `OTHER_REPO` | other-repository rejection | 59 `encodedNameOf(OTHER_REPO)` (also 82, 123, 187) |
| `toEqual([])` | empty result | 132 `expect(matches).toEqual([]);` |

- Declarations (lines 11, 12, 13) are not used as mapped lines.
- All nine tokens are mapped. Verdict: PASS.
