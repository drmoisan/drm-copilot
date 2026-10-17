# Test edit shape (P1-T8)

Timestamp: 2026-10-16T02-47

Command: git diff --numstat <merge-base-sha> -- tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1; sh SCRATCH/issue-930/P1-T8.sh; grep -n -F -e 'Mock -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -MockWith { }' tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1

EXIT_CODE: 0

Output Summary:
- Note: the worktree isolation guard refuses `$(...)` substitution in a git command, so the merge-base was resolved by a separate `git merge-base HEAD origin/main` call (adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99) and its SHA passed literally; the anchor is the same.
- numstat: `56	0	tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (0 lines removed).
- line count: 347 (greater than 291, at most 500).
- grep -n -F seam literal printed exactly one line: `70:        Mock -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -MockWith { }`.
- Each of the five AC930 node names occurs exactly once in the file.
