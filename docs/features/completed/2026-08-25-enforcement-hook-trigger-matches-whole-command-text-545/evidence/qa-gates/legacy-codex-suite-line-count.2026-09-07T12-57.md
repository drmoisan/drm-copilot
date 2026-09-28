# Legacy Codex contract suite line count after the [P4-T9] append

Timestamp: 2026-09-07T12-57

Task: [P4-T14]

Command: `wc -l tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `@(Get-Content -LiteralPath <path>).Count` requires a `pwsh` process, which
the runtime worktree-isolation guard refuses unconditionally in this session. `wc -l` counts the same
newline-terminated lines; the file ends with a trailing newline.

## Result

| File | Lines | At or under 500? |
| --- | --- | --- |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | **494** | yes |

The count is unchanged from the 494 recorded before the [P4-T9] edit, and 6 lines of headroom remain
below the 500-line cap.

## Why the count did not move

[P4-T9] permits exactly one single-line edit and no new line. The edit replaced line 30 in place,
extending `$script:SharedModuleNames` from two members to four on the same physical line. That is
confirmed independently of the line count by
`git diff --stat origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`,
which reports `1 file changed, 1 insertion(+), 1 deletion(-)` — a one-for-one line replacement, not an
insertion. A diff showing 2 insertions and 1 deletion would have meant a line was added; it does not.

The two measurements are complementary and neither alone is sufficient. The line count alone would not
distinguish a one-line append from an added line paired with a deleted line elsewhere; the diff stat
alone would not detect a very long line pushing the file over the cap. Both hold.

This is why the plan routes every new Codex scenario into a NEW test file rather than into this suite:
at 494 of 500 lines it can absorb the `$script:SharedModuleNames` append and nothing more.
`tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` and
`tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` were created as separate files for that
reason.

Output Summary: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` measures **494**
lines, at or under the 500-line cap and unchanged by the [P4-T9] edit. The corresponding `git diff
--stat` against `origin/epic/cleanup-merged-worktrees-hardening-integration` reports exactly
1 insertion and 1 deletion, confirming a single-line replacement with no line added.
