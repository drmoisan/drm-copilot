# R2 CI Jobs (Issue #927)

Timestamp: 2026-10-16T11-11
Command: gh run watch 38890377723 --interval 60 --exit-status
EXIT_CODE: 0
Output Summary: CI run 38890377723 (workflow_dispatch) on R2_CI_HEAD 7b43fddd540dcb5243f0b888891c35d315d6c454 completed with conclusion success. All 17 jobs read success, including poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux). In poshqc / PowerShell QC, the Format PowerShell, Analyze PowerShell, and Test PowerShell steps each read success.

R2_CI_RUN_ID: 38890377723
R2_CI_HEAD: 7b43fddd540dcb5243f0b888891c35d315d6c454

## Commands

- Command 1: `gh run watch 38890377723 --interval 60 --exit-status` (background option)
  - EXIT_CODE_1: 0 (completion notification)
- Command 2: `gh run view 38890377723 --json headSha,status,conclusion`
  - EXIT_CODE_2: 0
  - Output: `{"conclusion":"success","headSha":"7b43fddd540dcb5243f0b888891c35d315d6c454","status":"completed"}`
- Command 3: `gh run view 38890377723 --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'`
  - EXIT_CODE_3: 0
- Command 4: `gh run view 38890377723 --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'`
  - EXIT_CODE_4: 0

## Job rows (verbatim)

```text
quality-checks7 / Code Quality & Tests (3.10)	success
docs-validation / Documentation Validation	success
security-scan / Security Scanning	success
drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success
NPM Audit Gate / npm audit (extensions/drm-copilot)	success
quality-checks7 / Code Quality & Tests (3.11)	success
shell-coverage / Shell Coverage (Bats + kcov)	success
poshqc / PowerShell QC	success
quality-checks7 / Code Quality & Tests (3.12)	success
poshqc / PowerShell hook suites (Linux)	success
root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	success
NPM Audit Gate / npm audit (.)	success
quality-checks7 / Code Quality & Tests (3.13)	success
NPM Audit Gate / npm audit (packages/mcp-server)	success
drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
build-check / Build Package	success
root-typescript-tests / Root TypeScript Tests (windows-latest)	success
```

## Step rows of the PowerShell jobs (verbatim)

```text
poshqc / PowerShell QC	Set up job	success
poshqc / PowerShell QC	Check out repository	success
poshqc / PowerShell QC	Install PoshQC tooling	success
poshqc / PowerShell QC	Format PowerShell	success
poshqc / PowerShell QC	Analyze PowerShell	success
poshqc / PowerShell QC	Test PowerShell	success
poshqc / PowerShell QC	Upload PowerShell test artifacts	success
poshqc / PowerShell QC	Post Check out repository	success
poshqc / PowerShell QC	Complete job	success
poshqc / PowerShell hook suites (Linux)	Set up job	success
poshqc / PowerShell hook suites (Linux)	Check out repository	success
poshqc / PowerShell hook suites (Linux)	Install PoshQC tooling	success
poshqc / PowerShell hook suites (Linux)	Test PowerShell hook suites	success
poshqc / PowerShell hook suites (Linux)	Upload PowerShell hook-suite test results	success
poshqc / PowerShell hook suites (Linux)	Post Check out repository	success
poshqc / PowerShell hook suites (Linux)	Complete job	success
```

Every other step row of the run reads `success` or `skipped`. The skipped rows are `Install dependencies` (four quality-checks7 jobs, cache hit), `Upload coverage to Codecov` (quality-checks7 3.10, 3.11, 3.12), and `Build kcov from source` (shell-coverage, cache hit).

R2_CI: SUCCESS
