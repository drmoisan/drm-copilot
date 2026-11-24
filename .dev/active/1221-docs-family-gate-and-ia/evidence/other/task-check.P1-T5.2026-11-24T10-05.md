# Task Check - [P1-T5]

Plan: remediation-plan.2026-11-24T08-32.md
Timestamp: 2026-11-24T10-05
Command: git -C <worktree> diff HEAD --stat -- .dev/active/1221-docs-family-gate-and-ia/spec.md; git -C <worktree> diff HEAD -- <spec> | grep '^[-+]' | grep -c 'AC-'; line counts of HEAD and working copies; grep -n "compared ordinally" <spec>; grep -rln "1221-docs-family-gate-and-ia/spec.md" tests scripts
EXIT_CODE: 0
Output Summary:
- Changed file: .dev/active/1221-docs-family-gate-and-ia/spec.md, three lines edited in place (3 insertions, 3 deletions): D7 gains the ordinal-comparison sentence; the `### Family evidence` root-file bullet states the empty-path root listing and the ordinal exact match; the `## File Inventory` "Not edited" sentence drops `Invoke-DocsCommand.ps1` and records that remediation cycle 1 edits `Get-DocsContextFileList` in it.
- The D7 line (line 28) contains the token `compared ordinally`.
- Added or removed diff lines containing `AC-`: 0. Line count: 264 at HEAD and 264 after the edit.
- Selection and rule: contract tests that read the changed Markdown path. The search of `tests/` and `scripts/` for the spec path found no file, so no contract test reads it and no test runs for this task.
- Format, lint, and type check: not applicable (Markdown; no Markdown lint in this repository).
