# P8-T2 PR-head CI jobs (issue #927; AC-19, AC-18 and AC-M23 analyzer half)

Timestamp: 2026-10-16T13-29
Command: gh run watch 38905372728 --interval 60
EXIT_CODE: 0
Output Summary: Run 38905372728 (pull_request, head f82da3681f059f437573bf3b773f9a72a77b592b) completed with success. Jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` both report success; within `poshqc / PowerShell QC` the steps `Format PowerShell` and `Analyze PowerShell` both read success. All 17 jobs report success.

Note: each `gh` command was run with `--repo drmoisan/drm-copilot` added.

Command 1 output: `Run CI (38905372728) has already completed with 'success'`

## Command 2

Command 2: gh run view 38905372728 --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'
EXIT_CODE_2: 0

Required rows (verbatim, tab shown as ` | `):

- `poshqc / PowerShell QC | success`
- `poshqc / PowerShell hook suites (Linux) | success`

All job rows: build-check / Build Package success; poshqc / PowerShell QC success; drm-copilot-extension-tests (ubuntu-latest) success; quality-checks7 (3.10, 3.11, 3.12, 3.13) success; shell-coverage / Shell Coverage (Bats + kcov) success; poshqc / PowerShell hook suites (Linux) success; security-scan / Security Scanning success; docs-validation / Documentation Validation success; root-typescript-tests (windows-latest, ubuntu-latest) success; NPM Audit Gate (., extensions/drm-copilot, packages/mcp-server) success; drm-copilot-extension-tests (windows-latest) success.

## Command 3

Command 3: gh run view 38905372728 --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'
EXIT_CODE_3: 0

Rows whose first field is `poshqc / PowerShell QC` (verbatim, tab shown as ` | `):

- `poshqc / PowerShell QC | Set up job | success`
- `poshqc / PowerShell QC | Check out repository | success`
- `poshqc / PowerShell QC | Install PoshQC tooling | success`
- `poshqc / PowerShell QC | Format PowerShell | success`
- `poshqc / PowerShell QC | Analyze PowerShell | success`
- `poshqc / PowerShell QC | Test PowerShell | success`
- `poshqc / PowerShell QC | Upload PowerShell test artifacts | success`
- `poshqc / PowerShell QC | Post Check out repository | success`
- `poshqc / PowerShell QC | Complete job | success`

Rows whose first field is `poshqc / PowerShell hook suites (Linux)`:

- `poshqc / PowerShell hook suites (Linux) | Test PowerShell hook suites | success`
- `poshqc / PowerShell hook suites (Linux) | Upload PowerShell hook-suite test results | success`

JOB_POSHQC_QC: success
JOB_POSHQC_LINUX_HOOKS: success
STEP_FORMAT_POWERSHELL: success
STEP_ANALYZE_POWERSHELL: success
P8_CI_JOBS: SATISFIED
