# Remediation Cycle 1 — Phase 0 Policy Instructions Read

Timestamp: 2026-07-06T15-10
Policy Order: CLAUDE.md, .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md, .claude/rules/powershell.md

Files read (in the order specified by task P0-T1):

1. `CLAUDE.md` — not present at repository root (confirmed via `Glob **/CLAUDE.md`, which returned only an unrelated test fixture at `tests/fixtures/codex_native_converter/claude/CLAUDE.md`). No repo-root standing-instructions file exists to read for this cycle; proceeding with the three rule files below, which were confirmed present and were read in full.
2. `.claude/rules/general-code-change.md` — read in full. Key constraints applied this cycle: File Size Limit (no production/test file may exceed 500 lines), Mandatory Toolchain Loop (format -> lint -> type-check -> architecture -> unit test -> contract -> integration, restart on any change/failure), I/O boundary and public-API/compatibility guidance.
3. `.claude/rules/general-unit-test.md` — read in full. Key constraints applied this cycle: line coverage >= 85%, branch coverage >= 75%, no regression on changed lines, test file location mirrors production structure under `tests/`, Arrange-Act-Assert structure, no temporary files in tests, mocking discipline for external dependencies.
4. `.claude/rules/powershell.md` — read in full. Key constraints applied this cycle: toolchain order (format -> analyze -> test) via `mcp__drm-copilot__run_poshqc_format` / `run_poshqc_analyze` / `run_poshqc_test`, wrapper/seam design guidance, mocking rules (never mock external executables directly, mock signature parity, mock registration order), 500-line cap, PowerShell 7+ compatibility, coverage thresholds identical to the general unit-test policy.
