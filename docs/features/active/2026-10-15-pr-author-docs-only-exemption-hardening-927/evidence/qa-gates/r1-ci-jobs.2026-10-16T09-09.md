# R1 CI Jobs on the Final Code Commit (Issue #927; AC-19 supporting, AC-18 and AC-M23 analyzer half supporting)

Timestamp: 2026-10-16T09-09
Command: gh run watch 38876469175 --interval 60 --exit-status
EXIT_CODE: 0
Output Summary: Run 38876469175 (head 7966e1564635b5e4f60c22eeac47932018ae264a) completed with conclusion success. All 17 jobs read success, including poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux). In poshqc / PowerShell QC the Format PowerShell, Analyze PowerShell, and Test PowerShell steps each read success.

WATCH_NOTE: the run sat in the repository-wide Actions queue for about 20 minutes (Actions component operational; other sessions' runs were ahead). The watch was executed with --interval 30 in bounded foreground calls; the final call exited 0. Run view: {"conclusion":"success","headSha":"7966e1564635b5e4f60c22eeac47932018ae264a","status":"completed"}

Command 2: gh run view 38876469175 --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'
EXIT_CODE_2: 0
JOB: build-check / Build Package	success
JOB: docs-validation / Documentation Validation	success
JOB: NPM Audit Gate / npm audit (.)	success
JOB: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
JOB: shell-coverage / Shell Coverage (Bats + kcov)	success
JOB: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success
JOB: NPM Audit Gate / npm audit (packages/mcp-server)	success
JOB: security-scan / Security Scanning	success
JOB: poshqc / PowerShell QC	success
JOB: quality-checks7 / Code Quality & Tests (3.11)	success
JOB: poshqc / PowerShell hook suites (Linux)	success
JOB: quality-checks7 / Code Quality & Tests (3.13)	success
JOB: quality-checks7 / Code Quality & Tests (3.12)	success
JOB: NPM Audit Gate / npm audit (extensions/drm-copilot)	success
JOB: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	success
JOB: quality-checks7 / Code Quality & Tests (3.10)	success
JOB: root-typescript-tests / Root TypeScript Tests (windows-latest)	success

Command 3: gh run view 38876469175 --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'
EXIT_CODE_3: 0
STEP: poshqc / PowerShell QC	Set up job	success
STEP: poshqc / PowerShell QC	Check out repository	success
STEP: poshqc / PowerShell QC	Install PoshQC tooling	success
STEP: poshqc / PowerShell QC	Format PowerShell	success
STEP: poshqc / PowerShell QC	Analyze PowerShell	success
STEP: poshqc / PowerShell QC	Test PowerShell	success
STEP: poshqc / PowerShell QC	Upload PowerShell test artifacts	success
STEP: poshqc / PowerShell QC	Post Check out repository	success
STEP: poshqc / PowerShell QC	Complete job	success
STEP: poshqc / PowerShell hook suites (Linux)	Set up job	success
STEP: poshqc / PowerShell hook suites (Linux)	Check out repository	success
STEP: poshqc / PowerShell hook suites (Linux)	Install PoshQC tooling	success
STEP: poshqc / PowerShell hook suites (Linux)	Test PowerShell hook suites	success
STEP: poshqc / PowerShell hook suites (Linux)	Upload PowerShell hook-suite test results	success
STEP: poshqc / PowerShell hook suites (Linux)	Post Check out repository	success
STEP: poshqc / PowerShell hook suites (Linux)	Complete job	success
OTHER_STEPS: every other step row of the remaining 15 jobs reads success or skipped (skipped: kcov source build, cached-venv dependency install, and three Codecov uploads)
