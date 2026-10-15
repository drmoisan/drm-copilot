# Baseline actionlint ([P0-T19])

Timestamp: 2026-10-07T21-58
Command: pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml
Route: direct-binary
Deviation: DEV-ACTIONLINT-DIRECT
ExecutedCommand: actionlint .github/workflows/ci.yml
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- Full output of `actionlint .github/workflows/ci.yml`: empty (no findings), exit 0.
- actionlint version on PATH: 1.7.11 (the binary scripts/dev-tools/run-actionlint.ps1 resolves from PATH and passes arguments to unchanged).
- `Running actionlint...` printed: no (wrapper not run; the literal is printed only by the wrapper).
- `actionlint exited with code` line printed: no (wrapper not run; the direct binary exited 0).
- OperatorRunItem: the wrapper literal `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml` was not run by this agent and remains an operator-run item.
