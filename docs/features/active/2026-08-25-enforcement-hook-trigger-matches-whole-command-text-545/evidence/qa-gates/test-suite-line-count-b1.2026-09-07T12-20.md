# Batch B1 — test suite line counts

Timestamp: 2026-09-07T12-20

Task: [P2-T6]

Command: `wc -l tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1`

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `@(Get-Content -LiteralPath <path>).Count` requires a `pwsh` process, which
the runtime worktree-isolation guard refuses unconditionally in this session. `wc -l` counts the same
newline-terminated lines; both files end with a trailing newline.

## Result

| File | Lines | Over 450? | Over 500? | Split performed? |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | 321 | no | no | no |
| `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | 321 | no | no | no |

Neither suite exceeds 450, so no sibling split is required and Phase 3 may begin without rerunning
[P2-T7].

The two files hold the same 41 named cases. The Codex suite is generated from the Claude suite by
three substitutions and nothing else: the dot-source root moves from `.claude/hooks` to
`.codex/hooks`, the `.DESCRIPTION` names the Codex path, and the `Describe` name gains
`, Codex copy`. The identical line count is a consequence of that generation, not a coincidence.

Output Summary: both batch B1 test suites measure **321** lines, at or under the 500-line cap and
below the 450-line split threshold. No split was performed for either file.
