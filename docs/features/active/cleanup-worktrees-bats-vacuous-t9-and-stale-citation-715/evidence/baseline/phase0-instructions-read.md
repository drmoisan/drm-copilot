# Phase 0 — Policy Reads Evidence

Timestamp: 2026-09-27T11-20

Policy Order: CLAUDE.md, .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md, .claude/rules/shell.md

Files read in P0-T1 through P0-T4:

- `CLAUDE.md` — confirmed the "Policy Compliance Reading Order" section lists
  `.github/copilot-instructions.md` first, followed by
  `.github/instructions/general-code-change.instructions.md` and
  `.github/instructions/general-unit-test.instructions.md` as the second and third entries.
- `.claude/rules/general-code-change.md` — read in full; "Mandatory Toolchain Loop" and
  "File Size Limit" sections confirmed present.
- `.claude/rules/general-unit-test.md` — read in full; "Core Principles" and
  "Test File Location" sections confirmed present.
- `.claude/rules/shell.md` — read in full; "Toolchain" and "Discovery Contract" sections
  confirmed present, including the statement that bats test directories are `tests/shell`
  and `tests/bash`.
