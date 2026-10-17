# PowerShell Coverage Baseline (P0-T18)

Timestamp: 2026-10-07T22-02
Task: [P0-T18]
Command: read artifacts/pester/powershell-coverage.xml (produced by the P0-T17 run; last-write 2026-10-07 22:00:01 -0400)
EXIT_CODE: 0
Output Summary:
- Report-level `<counter type="LINE">`: missed=430, covered=11455; line percent = 11455 / 11885 = 96.38.
- `<sourcefile name="enforce-epic-planning-only.ps1">` in the `<package>` whose name ends with `/.codex/hooks` (package name `<worktree root>/.codex/hooks`):
  - Complete missed-line set (every `<line>` with `ci="0"`): {58, 72, 77, 307, 336, 343, 344, 345, 350, 359}
  - Lines 58, 72, and 77 are members of that set (each `ci="0"`).
