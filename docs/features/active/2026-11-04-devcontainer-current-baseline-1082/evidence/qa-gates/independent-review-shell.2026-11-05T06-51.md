Timestamp: 2026-11-05T06-51
Command: docker exec -u vscode -w /workspaces/drm-copilot 4ce6ae052778 bash -c 'shfmt -d .devcontainer/lib/workspace.sh .devcontainer/post-create.sh .devcontainer/verify-container.sh scripts/bash/container_versions.sh && shellcheck .devcontainer/lib/workspace.sh .devcontainer/post-create.sh .devcontainer/verify-container.sh scripts/bash/container_versions.sh && bash -n .devcontainer/lib/workspace.sh .devcontainer/post-create.sh .devcontainer/verify-container.sh scripts/bash/container_versions.sh && bats tests/shell/test_devcontainer_workspace.bats tests/shell/test_devcontainer_verification.bats tests/shell/test_container_versions.bats && bash .devcontainer/verify-container.sh'
EXIT_CODE: 0
Production paths: .devcontainer/lib/workspace.sh .devcontainer/post-create.sh .devcontainer/verify-container.sh scripts/bash/container_versions.sh
1..38
ok 1 Git trust adds only the exact workspace when no value exists
ok 2 Git trust preserves an already registered workspace and other entries
ok 3 Git trust does not confuse a parent path with the exact workspace
ok 4 Git configuration read errors stop setup without writing configuration
ok 5 Git configuration write failures propagate
ok 6 ordinary dependency directories receive no ownership changes
ok 7 dependency mount preparation adjusts all four mount roots without recursion
ok 8 dependency preparation changes only actual mount roots
ok 9 an ownership failure stops before later dependency mounts
ok 10 missing virtual environments require no cleanup
ok 11 healthy virtual environments are retained
ok 12 broken mounted virtual environments retain the volume root
ok 13 broken non-mounted environments are removed within the workspace
ok 14 virtual environment cleanup failures propagate
ok 15 sourcing the verifier runs no environment checks
ok 16 native CLI and module formats normalize to independent expected versions
ok 17 Codex version parsing tolerates native setup warnings
ok 18 unrecognized Poetry ShellCheck and Codex output fails parsing
ok 19 failed native commands and missing modules fail their query
ok 20 missing native CLI produces a failed requirement
ok 21 PowerShell module checks require the PowerShell executable
ok 22 failed module queries do not report success
ok 23 selected native versions pass while stale versions fail
ok 24 empty successful version output is still a failed requirement
ok 25 Debian Bookworm OS information passes verification
ok 26 missing unreadable and unsupported OS information fails verification
ok 27 workspace configuration and supported Linux Python pass
ok 28 missing workspace config or Linux interpreter fails
ok 29 failed or unsupported workspace Python probes fail
ok 30 main verifier selects local and Codespaces configurations
ok 31 main verifier collects failures and never prints the success banner
ok 32 container versions accept every pinned tool and optional v prefixes
ok 33 container Python accepts its minimum and later patches within 3.13
ok 34 container Python rejects stale patches wrong minors and malformed versions
ok 35 container versions reject stale or different pinned tool releases
ok 36 container Git accepts its minimum and newer installed releases
ok 37 container Git rejects stale incomplete and malformed versions
ok 38 container versions reject unknown missing and malformed tool inputs
Devcontainer verification: local
[OK] Debian GNU/Linux 12 (bookworm)
[OK] python 3.13.18
[OK] git 2.56.0
[OK] node v26.13.0
[OK] npm 11.20.0
[OK] pwsh 7.6.9
[OK] poetry 2.5.1
[OK] gh 2.103.3
[OK] dotnet 10.0.403
[OK] uv 0.13.7
[OK] claude 2.1.318
[OK] cswap 0.29.0
[OK] codex 0.166.0
[OK] shfmt v3.14.1
[OK] shellcheck 0.11.0
[OK] actionlint 1.7.12
[OK] gt 1.7.14
[OK] copilot 0.0.377
[OK] kcov v43
[OK] pester 6.2.0
[OK] pssa 1.25.0
[OK] bats is installed
[OK] bashdb is installed
[OK] .devcontainer/local/devcontainer.json
[OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.
