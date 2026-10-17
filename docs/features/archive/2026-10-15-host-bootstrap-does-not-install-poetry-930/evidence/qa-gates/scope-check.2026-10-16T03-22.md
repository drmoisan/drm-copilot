# Scope and no-removed-line check (P2-T12, AC-7)

Timestamp: 2026-10-16T03-22

Command: git diff --numstat <merge-base-sha> -- scripts/dev-tools/HostBootstrap.psm1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1; git diff --name-only <merge-base-sha>; git status --porcelain; git ls-files --others --exclude-standard -- SCRATCH | grep -c -E -e '[.](ps1|psm1|psd1)$'

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- numstat: module `3	0`, Invoke test file `57	0` (0 lines removed in both). The test file shows 57 added because the analyzer fix added one line after P1-T8.
- name-only (anchored at merge-base adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99, so paths changed on origin/main afterwards are excluded): scripts/dev-tools/HostBootstrap.psm1, tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1, and paths under docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/ only.
- porcelain: ` M tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (the analyzer fix, in scope), `?? SCRATCH/`, and untracked evidence under the feature folder; no other path.
- `grep -c` printed 0 and exited 1 (grep exits 1 for a zero count; expected): no PowerShell file under SCRATCH.
