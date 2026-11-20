Timestamp: 2026-11-05T04-21
Started: 2026-11-05T04:21:28.3109254Z
Command: docker exec -u vscode -w /workspaces/drm-copilot 1a90d86c1591 bats tests/shell/test_devcontainer_verification.bats tests/shell/test_devcontainer_workspace.bats tests/shell/test_container_versions.bats
EXIT_CODE: 0
Output Summary:

```text
1..38
ok 1 sourcing the verifier runs no environment checks
ok 2 native CLI and module formats normalize to independent expected versions
ok 3 Codex version parsing tolerates native setup warnings
ok 4 unrecognized Poetry ShellCheck and Codex output fails parsing
ok 5 failed native commands and missing modules fail their query
ok 6 missing native CLI produces a failed requirement
ok 7 PowerShell module checks require the PowerShell executable
ok 8 failed module queries do not report success
ok 9 selected native versions pass while stale versions fail
ok 10 empty successful version output is still a failed requirement
ok 11 Debian Bookworm OS information passes verification
ok 12 missing unreadable and unsupported OS information fails verification
ok 13 workspace configuration and supported Linux Python pass
ok 14 missing workspace config or Linux interpreter fails
ok 15 failed or unsupported workspace Python probes fail
ok 16 main verifier selects local and Codespaces configurations
ok 17 main verifier collects failures and never prints the success banner
ok 18 Git trust adds only the exact workspace when no value exists
ok 19 Git trust preserves an already registered workspace and other entries
ok 20 Git trust does not confuse a parent path with the exact workspace
ok 21 Git configuration read errors stop setup without writing configuration
ok 22 Git configuration write failures propagate
ok 23 ordinary dependency directories receive no ownership changes
ok 24 dependency mount preparation adjusts all four mount roots without recursion
ok 25 dependency preparation changes only actual mount roots
ok 26 an ownership failure stops before later dependency mounts
ok 27 missing virtual environments require no cleanup
ok 28 healthy virtual environments are retained
ok 29 broken mounted virtual environments retain the volume root
ok 30 broken non-mounted environments are removed within the workspace
ok 31 virtual environment cleanup failures propagate
ok 32 container versions accept every pinned tool and optional v prefixes
ok 33 container Python accepts its minimum and later patches within 3.13
ok 34 container Python rejects stale patches wrong minors and malformed versions
ok 35 container versions reject stale or different pinned tool releases
ok 36 container Git accepts its minimum and newer installed releases
ok 37 container Git rejects stale incomplete and malformed versions
ok 38 container versions reject unknown missing and malformed tool inputs
```

Raw output: SCRATCH/issue-1082-shell-verifier-focused-corrected.log
