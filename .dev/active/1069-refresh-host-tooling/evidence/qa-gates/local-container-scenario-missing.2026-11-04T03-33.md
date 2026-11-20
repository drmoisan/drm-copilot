Timestamp: 2026-11-04T03-33
Command: pwsh -NoProfile -File SCRATCH/issue-1069-container-final.ps1 -Configuration local
EXIT_CODE: 0
Output Summary: Devcontainer verification: local
[OK] Debian GNU/Linux 12 (bookworm)
[FAIL] python is not installed
[FAIL] node is not installed
[FAIL] npm is not installed
[FAIL] pwsh is not installed
[FAIL] poetry is not installed
[FAIL] shfmt is not installed
[FAIL] shellcheck is not installed
[FAIL] actionlint is not installed
[FAIL] git is not installed
[FAIL] gh is not installed
[FAIL] kcov is not installed
[FAIL] bats is not installed
[FAIL] bashdb is not installed
[FAIL] claude is not installed
[FAIL] cswap is not installed
[OK] .devcontainer/local/devcontainer.json
[OK] Workspace virtual environment Python 3.13.17
Devcontainer verification failed. Rebuild using .devcontainer/local/devcontainer.json.
See .devcontainer/TROUBLESHOOTING.md for setup guidance.

Boundary version/setup fixtures isolate branches; native stage independently measures installed versions. Negative scenario exit is normalized only after observing the expected verifier failure.
