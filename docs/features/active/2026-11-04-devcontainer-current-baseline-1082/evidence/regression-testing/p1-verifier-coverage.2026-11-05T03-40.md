Timestamp: 2026-11-05T03-40
Started: 2026-11-05T03:40:41.8538947Z
Command: docker exec --user vscode --workdir /workspaces/drm-copilot 40c5007b16b3 bash -c shfmt -d .devcontainer/verify-container.sh && shfmt -ln bats -d tests/shell/test_devcontainer_verification.bats && shellcheck .devcontainer/verify-container.sh && bash -n .devcontainer/verify-container.sh && kcov --include-pattern=/workspaces/drm-copilot/.devcontainer/verify-container.sh SCRATCH/issue-1082-kcov-p1-verifier bats tests/shell/test_devcontainer_verification.bats
EXIT_CODE: 0
Output Summary:

```text
See .devcontainer/TROUBLESHOOTING.md for setup guidance. == *\D\e\v\c\o\n\t\a\i\n\e\r\ \v\e\r\i\f\i\c\a\t\i\o\n\ \f\a\i\l\e\d\.* ]]
[OK] Debian test release
[FAIL] fake python
[FAIL] fake git
[FAIL] fake node
[FAIL] fake npm
[FAIL] fake pwsh
[FAIL] fake poetry
[FAIL] fake gh
[FAIL] fake dotnet
[FAIL] fake uv
[FAIL] fake claude
[FAIL] fake cswap
[FAIL] fake codex
[FAIL] fake shfmt
[FAIL] fake shellcheck
[FAIL] fake actionlint
[FAIL] fake gt
[FAIL] fake copilot
[FAIL] fake kcov
[FAIL] fake pester
[FAIL] fake pssa
[FAIL] bats is not installed
[OK] bashdb is installed
[OK] .devcontainer/local/devcontainer.json
[OK] Workspace virtual environment Python 3.13.18
Devcontainer verification failed. Rebuild using .devcontainer/local/devcontainer.json.
See .devcontainer/TROUBLESHOOTING.md for setup guidance. != *\A\l\l\ \d\e\v\c\o\n\t\a\i\n\e\r\ \c\h\e\c\k\s\ \p\a\s\s\e\d\.* ]]
1..16
ok 1 sourcing the verifier runs no environment checks
ok 2 native CLI and module formats normalize to independent expected versions
ok 3 unrecognized Poetry and ShellCheck output fails parsing
ok 4 failed native commands and missing modules fail their query
ok 5 missing native CLI produces a failed requirement
ok 6 PowerShell module checks require the PowerShell executable
ok 7 failed module queries do not report success
ok 8 selected native versions pass while stale versions fail
ok 9 empty successful version output is still a failed requirement
ok 10 Debian Bookworm OS information passes verification
ok 11 missing unreadable and unsupported OS information fails verification
ok 12 workspace configuration and supported Linux Python pass
ok 13 missing workspace config or Linux interpreter fails
ok 14 failed or unsupported workspace Python probes fail
ok 15 main verifier selects local and Codespaces configurations
ok 16 main verifier collects failures and never prints the success banner
```

Raw output: SCRATCH/issue-1082-p1-verifier-coverage.log
