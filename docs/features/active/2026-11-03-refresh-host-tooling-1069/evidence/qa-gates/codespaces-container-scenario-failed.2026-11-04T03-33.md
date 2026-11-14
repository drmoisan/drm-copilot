Timestamp: 2026-11-04T03-33
Command: pwsh -NoProfile -File SCRATCH/issue-1069-container-final.ps1 -Configuration codespaces
EXIT_CODE: 0
Output Summary: Devcontainer verification: codespaces
[OK] Debian GNU/Linux 12 (bookworm)
[OK] python 3.13.17
[FAIL] node version command failed
[OK] npm 11.20.0
[OK] pwsh 7.6.9
[OK] poetry 2.3.2
[OK] shfmt v3.14.1
[OK] shellcheck 0.11.0
[OK] actionlint 1.7.12
[OK] git is installed
[OK] gh is installed
[OK] kcov is installed
[OK] bats is installed
[OK] bashdb is installed
[OK] claude is installed
[OK] cswap is installed
[OK] .devcontainer/codespaces/devcontainer.json
[OK] Workspace virtual environment Python 3.13.17
Devcontainer verification failed. Rebuild using .devcontainer/codespaces/devcontainer.json.
See .devcontainer/TROUBLESHOOTING.md for setup guidance.

Boundary version/setup fixtures isolate branches; native stage independently measures installed versions. Negative scenario exit is normalized only after observing the expected verifier failure.
