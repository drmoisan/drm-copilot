# Final actionlint ([P2-T4])

Timestamp: 2026-10-07T22-45
Command: pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml
Route: direct-binary
Deviation: DEV-ACTIONLINT-DIRECT
ExecutedCommand: actionlint .github/workflows/ci.yml
EXIT_CODE: 0
Output Summary:
- Run on the fixed ci.yml (line 7 `    branches: [main, development, "epic/**"]`, fix head 00798863).
- Full output of `actionlint .github/workflows/ci.yml`: empty (no findings), exit 0.
- actionlint version on PATH: 1.7.11 (the binary scripts/dev-tools/run-actionlint.ps1 resolves from PATH and passes arguments to unchanged).
- `Running actionlint...` printed: no (wrapper not run; the literal is printed only by the wrapper).
- `actionlint exited with code` line printed: no.
- OperatorRunItem: the wrapper literal `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml` was not run by this agent and remains an operator-run item.
