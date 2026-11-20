# R1 CR-N3 Fixture Names (P3-T1)

Timestamp: 2026-10-16T05-47
Command: Glob (worktree root) `.claude/hooks/gate.ps1`; `.codex/hooks/gate.ps1`; `.claude/hooks/Fixture.psm1`; `.codex/hooks/Fixture.psm1`; non-vacuity control `.codex/hooks/*.ps1`
EXIT_CODE: 0
Output Summary:
- `.claude/hooks/gate.ps1`: no files found
- `.codex/hooks/gate.ps1`: no files found
- `.claude/hooks/Fixture.psm1`: no files found
- `.codex/hooks/Fixture.psm1`: no files found
- Control `.codex/hooks/*.ps1`: 41 files returned (the Glob reads the hook directories, so the four empty results are not vacuous).
- Result: no fixture name used by the CR-N3 rows exists in either hook tree.

Post-write token checks on `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`:
- `grep -c -F -e "Describe 'issue #935 CR-N3 load-position parameters'"`: 1
- `grep -c -F -e "It 'CR-N3 does not report the separate-token value of"`: 1
- `grep -c -F -e "It 'CR-N3 binds Join-Path positionals after the separate-token value of -Credential'"`: 1
- `grep -c -F -e "It 'CR-N3 still reports a positional load after the switch"`: 1
- ERE `grep -c -E -e 'Start-Process'`: 0
- `awk 'END { print NR }'`: 429 (at most 500)
