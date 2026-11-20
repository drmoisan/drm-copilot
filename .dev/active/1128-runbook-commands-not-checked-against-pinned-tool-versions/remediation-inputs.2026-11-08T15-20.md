# Remediation Inputs — Issue #1128 (cycle 1)

- Timestamp: 2026-11-08T15-22
- Opened by: orchestrator, after review set `*.2026-11-08T15-20.md` (verdict PASS)
- Remediation-Mode: proportionate
- Basis: the two Minor findings of `code-review.2026-11-08T15-20.md` are related to this item. Standing owner direction is to fix related findings inside the item before merge rather than file follow-ups, and to make the legitimate path pass without weakening the gate. Finding 1 makes a legitimate multi-line command fail the gate; finding 2 lets a chained or environment-prefixed command evade it.

## Findings

### RI-1 — Continuation lines are read as separate commands

- Remediability: autonomous
- Finding-Scope: contained
- Location: `.claude/lib/runbook/RunbookCommandVersion.psm1`, `Get-RunbookCountedBlock` and `Get-RunbookCommandVersionFinding` (each non-blank line of a counted block is treated as one command).
- Observed: a block holding `python -m nuitka \`, `  --standalone \`, `  main.py` followed by `Version check: verified against nuitka 4.3.4` yields findings for tools `-standalone` and `main-py`.
- Required behavior: before tool extraction, join a line that ends with a continuation character to the following line: a trailing ` \` (POSIX shells), a trailing `` ` `` (PowerShell), or a trailing `^` (cmd). The joined logical command is evaluated once. The example above produces no finding.

### RI-2 — Chained and environment-prefixed commands resolve to the wrong tool

- Remediability: autonomous
- Finding-Scope: contained
- Location: `.claude/lib/runbook/RunbookCommandVersion.psm1`, `Get-RunbookCommandToolName` (first token names the tool).
- Observed: `cd x && python -m nuitka ...` resolves to `cd`; `FOO=1 python -m nuitka ...` resolves to `foo=1`. The real tool is not checked.
- Required behavior:
  - Split each logical command into segments on `&&`, `||`, `;`, and `|`; every segment's tool is a tool of the block and needs a marker.
  - Skip leading POSIX assignments (`NAME=value`) in a segment before reading the tool.
  - A segment whose first token is a shell builtin or a PowerShell environment assignment names no tool: `cd`, `pushd`, `popd`, `export`, `set`, `source`, `.`, `echo`, and a token beginning with `$env:`.
  - `cd x && python -m nuitka --clean-cache=all` with a marker for nuitka 4.3.4 produces no finding; the same block without the marker produces the nuitka finding.

## Required text and mirror updates

- `.claude/skills/human-exception-runbook/SKILL.md` `## Tool Command Version Rule`: state continuation joining, segment splitting, assignment skipping, and the builtin list in the `Counted fences` bullet; the same text in the `.agents` copy and both bundle copies.
- Bundle copy of the module under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/runbook/` stays byte-identical.

## Tests

- New Pester cases in `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` for each required behavior above, including the two observed reproductions (they fail before the fix).
- Gates: one `Invoke-PoshQCParallelTest` run (no new failures against the Phase 0 baseline, new module stays >= 85% line coverage) and one `pytest -n auto` run for the mirror and pack-manifest contract tests.
