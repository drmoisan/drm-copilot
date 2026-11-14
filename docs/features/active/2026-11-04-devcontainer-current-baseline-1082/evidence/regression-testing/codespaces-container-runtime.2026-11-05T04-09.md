Timestamp: 2026-11-05T04-09
Started: 2026-11-05T04:08:58.5669800Z
Command: docker exec -u vscode 1a90d86c1591 bash SCRATCH/issue-1082-runtime.sh
EXIT_CODE: 0
Output Summary:

```text
[OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.
uid=1000(vscode) gid=1000(vscode) groups=1000(vscode),998(pipx),999(nvm)
 M .devcontainer/codespaces/Dockerfile
 M .devcontainer/codespaces/devcontainer.json
 M .devcontainer/local/Dockerfile
 M .devcontainer/local/devcontainer-lock.json
 M .devcontainer/local/devcontainer.json
 M .devcontainer/post-create.sh
 M .devcontainer/verify-container.sh
 M docs/features/active/2026-11-04-devcontainer-current-baseline-1082/plan.2026-11-04T21-35.md
 M scripts/bash/container_versions.sh
 M scripts/powershell/PoshQC/PoshQC.Testing.psm1
 M scripts/powershell/PoshQC/PoshQC.psm1
 M scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 M tests/scripts/dev_tools/test_host_environment_contracts.py
 M tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1
 M tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1
 M tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1
 M tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1
 M tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
 M tests/scripts/powershell/PoshQC/PoshQC.TestingOutputPath.Tests.ps1
 M tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1
 M tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1
 M tests/shell/test_container_versions.bats
Python 3.13.18
0.28.2
0.28.2
NATIVE_CODEX_LOCATION=/usr/local/bin/codex
codex-cli 0.166.0
10.0.403 [/usr/share/dotnet/sdk]
claude-swap v0.29.0
- claude-swap
- cswap
1000:1000 /home/vscode/.claude
1000:1000 /home/vscode/.codex
1000:1000 /home/vscode/.local/share/claude-swap
0:0 /etc/codex/config.toml
check_for_update_on_startup = false
cli_auth_credentials_store = "file"
AUTH_STATE_FILES
tmp/arg0-linux/codex-arg0dfBRwa/.lock
SOURCE_SHA256
429c1cd768e901c23c071048f8fa5267ffd2257f31a329ac4e8eef781df03165  .devcontainer/local/devcontainer.json
17c93d3b34a54659db11bbe0fd7fa289438cbdf0bd6721a3ca4a6924c0779cfe  .devcontainer/lib/workspace.sh
```

Raw output: SCRATCH/issue-1082-codespaces-container-runtime.log
