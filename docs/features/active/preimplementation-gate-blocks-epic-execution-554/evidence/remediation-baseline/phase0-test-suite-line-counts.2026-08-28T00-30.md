# Phase 0 — Branch-Created Test Suite Line Counts and 500-Line Headroom

Timestamp: 2026-08-28T01-37
Task: [P0-T8]
Command: `pwsh -NoProfile -Command "(@(Get-Content -LiteralPath 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1')).Count; (@(Get-Content -LiteralPath 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1')).Count"`
EXIT_CODE: 0

## Measured counts

| Suite | Lines | Cap | Headroom |
| --- | --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **302** | 500 | **198** |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | **154** | 500 | **346** |

The 500-line cap is the file-size limit of `.claude/rules/general-code-change.md`, restated in
`.claude/rules/powershell.md`.

## Headroom decision

The Codex suite count is the integer **302**, leaving **198 lines of headroom** against the 500-line
cap. The two Phase 1 cases of [P1-T2] and [P1-T3] require approximately **24 lines** including their
`Context` wrapper and comment block. **The Codex suite therefore has room for the approximately 24
lines the two Phase 1 cases require**, with roughly 174 lines still spare afterwards.

The blocked branch of this task is not taken: the headroom of 198 is not fewer than 24, so no new
test file is created and no blocked report is required. Had the headroom been fewer than 24 lines,
this task would have stopped and reported blocked rather than creating a sibling file.

The Claude classifier suite count is the integer **154**, leaving **346 lines of headroom**. The
Phase 2 edit to that file is a comment-block replacement of seven lines by twelve, a net rise of
five lines, well inside that headroom.

Output Summary: Codex mode-resolution suite is **302** lines (198 of headroom); Claude classifier
suite is **154** lines (346 of headroom). The Codex suite has room for the approximately 24 lines the
two Phase 1 cases require, so no new test file is created. EXIT_CODE 0.
