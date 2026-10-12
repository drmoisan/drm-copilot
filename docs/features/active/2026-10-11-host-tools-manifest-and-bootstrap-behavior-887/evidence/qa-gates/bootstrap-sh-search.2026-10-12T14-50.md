# Bash Bootstrap Reference Search (Issue 887)

Timestamp: 2026-10-12T14-50
Command: git grep -n -F --untracked 'bootstrap-host.sh' -- scripts tests
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- No output; git grep exited 1 (no match) under scripts/ and tests/, including untracked files (AC-9).
- Before the change the same search matched scripts/dev-tools/HostBootstrap.psm1:335, tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1, and tests/scripts/dev-tools/bootstrap-host.Tests.ps1.
