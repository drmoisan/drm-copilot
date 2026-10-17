# Production edit shape (P1-T12)

Timestamp: 2026-10-16T02-52

Command: git diff --numstat <merge-base-sha> -- scripts/dev-tools/HostBootstrap.psm1; grep -n -F -e "Target 'Process'" -e 'Install-PoetryWithPip -ApplyMode:$Apply' -e 'Installing Graphite CLI via npm' scripts/dev-tools/HostBootstrap.psm1

EXIT_CODE: 0

Output Summary:
- The merge-base SHA adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 was resolved by a separate `git merge-base HEAD origin/main` call (the isolation guard refuses `$(...)` in git commands) and passed literally.
- numstat: `3	0	scripts/dev-tools/HostBootstrap.psm1` (3 added, 0 removed).
- grep printed lines 80, 149, 158, 365, 369, 374 in that order: 369 (new call) follows 365 (Process-scope refresh in Invoke-BootstrapHost) and precedes 374 (Graphite CLI step).
