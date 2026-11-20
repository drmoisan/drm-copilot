# Remediation Cycle 1 — R-1c Test File Split

Timestamp: 2026-07-06T00-00

## Finding

`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` exceeded the
500-line hard limit in `.claude/rules/general-code-change.md` (was 513 at base;
this cycle's edits grew it to 552 lines). Same file-size class as R-1.

## Action

Extracted the `Context 'Test-HumanInteractionShape'` block (7 `It` tests, all
exercising `Test-HumanInteractionShape` directly with no dependency on the other
contexts' mocks) into a new sibling file:

- `tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1`

This mirrors the naming convention already established by the R-1 split
(`validate-orchestrator-output.model-routing.Tests.ps1`). The new file is
self-contained: it carries its own `BeforeAll { . $hookPath }` dot-source of
`.claude/hooks/validate-orchestrator-output.ps1` and its own
`SuppressMessageAttribute` for the injected `FileExistsCheck` stubs, matching
the original file's setup exactly. No test assertions or behavior were changed;
only the block was relocated together with its minimal required setup.

## Line Counts

| File | Before | After |
|---|---|---|
| `validate-orchestrator-output.Tests.ps1` | 552 | 449 |
| `validate-orchestrator-output.human-interaction.Tests.ps1` (new) | n/a | 126 |

Both files are below the 500-line cap.

## Toolchain Results (PowerShell, via MCP)

Command order: format -> analyze -> test, restarting from format on any file
change or failure.

### Format

- Timestamp: 2026-07-06T00-05
- Command: `mcp__drm-copilot__run_poshqc_format` (scan_folders: `tests/scripts/claude-hooks`)
- EXIT_CODE: 0
- Output Summary: First pass reported no diff to the two target files (the
  formatter incidentally touched two unrelated pre-existing uncommitted files
  in the same folder — `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`
  and `validate-orchestrator-output.model-routing.Tests.ps1` — verified via
  `git diff` to be pre-existing content from earlier work in this remediation
  cycle, not introduced by this task; left untouched per scope). Second pass
  (after adding UTF-8 BOM to the new file, see Analyze below) produced zero
  further changes to either target file (line counts unchanged: 449 / 126).

### Analyze

- Timestamp: 2026-07-06T00-06
- Command: `mcp__drm-copilot__run_poshqc_analyze` (scan_folders: `tests/scripts/claude-hooks`)
- EXIT_CODE: 1 (first pass) -> 0 (second pass)
- Output Summary: First pass failed with `PSUseBOMForUnicodeEncodedFile` on the
  new file (non-ASCII em-dash characters in comments copied verbatim from the
  original required a UTF-8 BOM, matching the original file's encoding).
  Rewrote the new file with a UTF-8 BOM (`[System.Text.UTF8Encoding]::new($true)`),
  content and line count (126) unchanged. Re-ran format (no-op) then analyze:
  0 issues.

### Test

- Timestamp: 2026-07-06T00-07
- Command: `mcp__drm-copilot__run_poshqc_test` (scan_folders: `tests/scripts/claude-hooks`)
- EXIT_CODE: 0
- Output Summary: Pass. Direct Pester run for evidence detail —
  `Invoke-Pester` against both split files: 32 tests discovered, 32 passed,
  0 failed, 0 skipped. (25 remaining in the main file + 7 moved to the new
  sibling file = 32, confirming no test was lost or duplicated.)

## Python Parity

- Timestamp: 2026-07-06T00-08
- Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed.

## Scope Note

No production code was changed. No files under `.claude/**` or
`extensions/drm-copilot/resources/**` were touched. Only the target test file
was edited and one new sibling test file was created, both under `tests/`.
