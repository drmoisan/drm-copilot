# Batch B2 — invocation file and test suite line counts

Timestamp: 2026-09-07T12-39

Task: [P3-T6]

Command: `wc -l .claude/hooks/hook-command-invocation.ps1 tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1`

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `@(Get-Content -LiteralPath <path>).Count` requires a `pwsh` process, which
the runtime worktree-isolation guard refuses unconditionally in this session. `wc -l` counts the same
newline-terminated lines; all three files end with a trailing newline.

## Result

| File | Lines | 450 threshold crossed? | Over the 500 cap? |
| --- | --- | --- | --- |
| `.claude/hooks/hook-command-invocation.ps1` | 483 | **yes** | no |
| `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` | 330 | no | no |
| `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` | 267 | no | no |

All three are at or under the 500-line cap, which is the acceptance condition for this task.

## The 450 crossing on the production file, and why no third parser file follows from it

`.claude/hooks/hook-command-invocation.ps1` measures 483 lines and therefore crosses the 450-line
threshold. Unlike [P2-T5], this task defines no spillover action for a crossing; it requires only that
the crossing be stated. It is stated here, and the standing constraint that a third parser file is not
permitted is honoured: no third file was created. A third file would require a third full
fourteen-entry registration set across the five registry files, which [P4-T12] would then have to
account for.

The 17 lines of headroom below the cap are not consumed by any later phase. Phases 5 through 10
rewrite hook call sites to consume this file; none of them edits this file. The only later task that
touches a parser file at all is [P4-T2], which mirrors it byte-identically into the Claude bundle.

## Byte-identity of the Codex production copy ([P3-T2])

| File | SHA-256 |
| --- | --- |
| `.claude/hooks/hook-command-invocation.ps1` | `b82246c61bb9fcb44ad6471dfa15278069c599ac3a52da26e62ede0cf1e92609` |
| `.codex/hooks/hook-command-invocation.ps1` | `b82246c61bb9fcb44ad6471dfa15278069c599ac3a52da26e62ede0cf1e92609` |

Equal. The Codex production copy therefore also measures 483 lines.

## Line-count divergence between the two test suites, recorded so it is not read as drift

The two invocation test suites differ by 63 lines. That is the `D12 public parser contract` `Context`
added by [P3-T5], which the plan scopes to the two **Claude** suites by name and does not add to
either Codex suite. At the point [P3-T4] was accepted, the two invocation suites held the identical
39-case set; the divergence was introduced afterwards by [P3-T5], as the plan directs. The same
divergence exists for the scanner pair, where the Claude suite is now 347 lines against the Codex
suite's 321.

Output Summary: `.claude/hooks/hook-command-invocation.ps1` measures **483** lines — under the
500-line cap, above the 450-line threshold, which is recorded rather than acted on because this task
defines no spillover. `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` measures **330**
and `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` measures **267**; neither crosses
450. No third parser file was created.
