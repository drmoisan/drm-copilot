Timestamp: 2026-02-24T10-20
Command: derive tool parity matrix from codespaces devcontainer + Dockerfile
EXIT_CODE: 0
Output Summary: PASS tool parity matrix captured

Sources:
- .devcontainer/codespaces/devcontainer.json
- .devcontainer/codespaces/Dockerfile

Required Tools:
- jq
- shfmt
- shellcheck
- bats
- kcov
- node
- npm
- pwsh
- poetry
- actionlint

Observed Mapping:
- shellcheck/shfmt/bats: installed via apt in Dockerfile.
- kcov: copied from kcov image stage in Dockerfile.
- node/npm: installed via apt in Dockerfile.
- pwsh: powershell package installed in Dockerfile.
- poetry: installed via pip in Dockerfile.
- actionlint: installed by official download script in Dockerfile.
- jq: required by toolchain parity for codex setup and expected in setup validation coverage.
