# R3 CI jobs on the final code state (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T12-49
Command: gh run watch 38900960142 --interval 60 --exit-status
EXIT_CODE: 0
Output Summary: CI run 38900960142 (workflow_dispatch) on head 8259a11df completed with conclusion success; 17 of 17 jobs success, including poshqc / PowerShell QC (windows-latest, every suite with coverage) and poshqc / PowerShell hook suites (Linux) (ubuntu-latest, claude-hooks and codex-hooks, no coverage). In poshqc / PowerShell QC, Format PowerShell, Analyze PowerShell, and Test PowerShell each read success. Every step row reads success or skipped.

R3_CI_RUN_ID: 38900960142
R3_CI_HEAD: 8259a11df659283c4c78c443be99a02ca7698098

Command 2: gh run view 38900960142 --json headSha,status,conclusion
EXIT_CODE_2: 0
RUN_VIEW: {"conclusion":"success","headSha":"8259a11df659283c4c78c443be99a02ca7698098","status":"completed"}
HEAD_SHA_EQUALS_R3_CI_HEAD: true

Command 3: gh run view 38900960142 --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'
EXIT_CODE_3: 0
JOB: shell-coverage / Shell Coverage (Bats + kcov)	success
JOB: security-scan / Security Scanning	success
JOB: root-typescript-tests / Root TypeScript Tests (windows-latest)	success
JOB: poshqc / PowerShell hook suites (Linux)	success
JOB: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	success
JOB: NPM Audit Gate / npm audit (packages/mcp-server)	success
JOB: docs-validation / Documentation Validation	success
JOB: NPM Audit Gate / npm audit (.)	success
JOB: quality-checks7 / Code Quality & Tests (3.12)	success
JOB: build-check / Build Package	success
JOB: quality-checks7 / Code Quality & Tests (3.10)	success
JOB: NPM Audit Gate / npm audit (extensions/drm-copilot)	success
JOB: quality-checks7 / Code Quality & Tests (3.13)	success
JOB: poshqc / PowerShell QC	success
JOB: quality-checks7 / Code Quality & Tests (3.11)	success
JOB: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
JOB: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success

Command 4: gh run view 38900960142 --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'
EXIT_CODE_4: 0
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Set up job	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Check out repository	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Install shell tooling (shellcheck, shfmt, bats)	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Cache kcov build	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Build kcov from source	skipped
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Install kcov from cache	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Run shell-qc check (shfmt diff + shellcheck)	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Run shell-qc test with coverage	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Upload shell coverage artifacts	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Post Cache kcov build	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Post Check out repository	success
STEP: shell-coverage / Shell Coverage (Bats + kcov)	Complete job	success
STEP: security-scan / Security Scanning	Set up job	success
STEP: security-scan / Security Scanning	Check out repository	success
STEP: security-scan / Security Scanning	Set up Python	success
STEP: security-scan / Security Scanning	Install Poetry	success
STEP: security-scan / Security Scanning	Check for security vulnerabilities	success
STEP: security-scan / Security Scanning	Post Set up Python	success
STEP: security-scan / Security Scanning	Post Check out repository	success
STEP: security-scan / Security Scanning	Complete job	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Set up job	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Check out repository	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Set up Node.js	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Install root dependencies	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Run root TypeScript toolchain and jest suite	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Post Set up Node.js	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Post Check out repository	success
STEP: root-typescript-tests / Root TypeScript Tests (windows-latest)	Complete job	success
STEP: poshqc / PowerShell hook suites (Linux)	Set up job	success
STEP: poshqc / PowerShell hook suites (Linux)	Check out repository	success
STEP: poshqc / PowerShell hook suites (Linux)	Install PoshQC tooling	success
STEP: poshqc / PowerShell hook suites (Linux)	Test PowerShell hook suites	success
STEP: poshqc / PowerShell hook suites (Linux)	Upload PowerShell hook-suite test results	success
STEP: poshqc / PowerShell hook suites (Linux)	Post Check out repository	success
STEP: poshqc / PowerShell hook suites (Linux)	Complete job	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Set up job	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Check out repository	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Set up Node.js	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Install root dependencies	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Run root TypeScript toolchain and jest suite	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Post Set up Node.js	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Post Check out repository	success
STEP: root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	Complete job	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Set up job	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Check out repository	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Set up Node.js	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Install from lockfile (verifies lockfile/manifest sync)	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Audit dependencies	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Post Set up Node.js	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Post Check out repository	success
STEP: NPM Audit Gate / npm audit (packages/mcp-server)	Complete job	success
STEP: docs-validation / Documentation Validation	Set up job	success
STEP: docs-validation / Documentation Validation	Check out repository	success
STEP: docs-validation / Documentation Validation	Validate README exists and is not empty	success
STEP: docs-validation / Documentation Validation	Check for LICENSE file	success
STEP: docs-validation / Documentation Validation	Validate instruction documents exist	success
STEP: docs-validation / Documentation Validation	Post Check out repository	success
STEP: docs-validation / Documentation Validation	Complete job	success
STEP: NPM Audit Gate / npm audit (.)	Set up job	success
STEP: NPM Audit Gate / npm audit (.)	Check out repository	success
STEP: NPM Audit Gate / npm audit (.)	Set up Node.js	success
STEP: NPM Audit Gate / npm audit (.)	Install from lockfile (verifies lockfile/manifest sync)	success
STEP: NPM Audit Gate / npm audit (.)	Audit dependencies	success
STEP: NPM Audit Gate / npm audit (.)	Post Set up Node.js	success
STEP: NPM Audit Gate / npm audit (.)	Post Check out repository	success
STEP: NPM Audit Gate / npm audit (.)	Complete job	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Set up job	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Set up Python 3.12	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Install Poetry	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Install dependencies	skipped
STEP: quality-checks7 / Code Quality & Tests (3.12)	Install project	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Verify poetry.lock is in sync	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Check formatting with Black	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Lint with Ruff	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Type check with Pyright	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Verify Codex agent deployment profiles	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	tier-classification	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Run tests with Pytest	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Enforce Python coverage thresholds	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Upload coverage to Codecov	skipped
STEP: quality-checks7 / Code Quality & Tests (3.12)	Post Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Post Set up Python 3.12	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Post Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.12)	Complete job	success
STEP: build-check / Build Package	Set up job	success
STEP: build-check / Build Package	Check out repository	success
STEP: build-check / Build Package	Set up Python	success
STEP: build-check / Build Package	Install Poetry	success
STEP: build-check / Build Package	Build package	success
STEP: build-check / Build Package	Verify package can be installed	success
STEP: build-check / Build Package	Shell QC smoke (native)	success
STEP: build-check / Build Package	Post Set up Python	success
STEP: build-check / Build Package	Post Check out repository	success
STEP: build-check / Build Package	Complete job	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Set up job	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Set up Python 3.10	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Install Poetry	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Install dependencies	skipped
STEP: quality-checks7 / Code Quality & Tests (3.10)	Install project	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Verify poetry.lock is in sync	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Check formatting with Black	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Lint with Ruff	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Type check with Pyright	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Verify Codex agent deployment profiles	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	tier-classification	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Run tests with Pytest	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Enforce Python coverage thresholds	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Upload coverage to Codecov	skipped
STEP: quality-checks7 / Code Quality & Tests (3.10)	Post Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Post Set up Python 3.10	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Post Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.10)	Complete job	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Set up job	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Check out repository	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Set up Node.js	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Install from lockfile (verifies lockfile/manifest sync)	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Audit dependencies	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Post Set up Node.js	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Post Check out repository	success
STEP: NPM Audit Gate / npm audit (extensions/drm-copilot)	Complete job	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Set up job	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Set up Python 3.13	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Install Poetry	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Install dependencies	skipped
STEP: quality-checks7 / Code Quality & Tests (3.13)	Install project	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Verify poetry.lock is in sync	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Check formatting with Black	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Lint with Ruff	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Type check with Pyright	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Verify Codex agent deployment profiles	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	tier-classification	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Run tests with Pytest	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Enforce Python coverage thresholds	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Upload coverage to Codecov	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Post Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Post Set up Python 3.13	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Post Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.13)	Complete job	success
STEP: poshqc / PowerShell QC	Set up job	success
STEP: poshqc / PowerShell QC	Check out repository	success
STEP: poshqc / PowerShell QC	Install PoshQC tooling	success
STEP: poshqc / PowerShell QC	Format PowerShell	success
STEP: poshqc / PowerShell QC	Analyze PowerShell	success
STEP: poshqc / PowerShell QC	Test PowerShell	success
STEP: poshqc / PowerShell QC	Upload PowerShell test artifacts	success
STEP: poshqc / PowerShell QC	Post Check out repository	success
STEP: poshqc / PowerShell QC	Complete job	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Set up job	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Set up Python 3.11	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Install Poetry	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Install dependencies	skipped
STEP: quality-checks7 / Code Quality & Tests (3.11)	Install project	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Verify poetry.lock is in sync	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Check formatting with Black	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Lint with Ruff	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Type check with Pyright	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Verify Codex agent deployment profiles	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	tier-classification	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Run tests with Pytest	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Enforce Python coverage thresholds	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Upload coverage to Codecov	skipped
STEP: quality-checks7 / Code Quality & Tests (3.11)	Post Load cached venv	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Post Set up Python 3.11	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Post Check out repository	success
STEP: quality-checks7 / Code Quality & Tests (3.11)	Complete job	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Set up job	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Check out repository	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Set up Node.js	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Install extension dependencies	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Type-check extension source and test tree	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Run extension unit/integration tests	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Post Set up Node.js	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Post Check out repository	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	Complete job	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Set up job	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Check out repository	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Set up Node.js	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Install extension dependencies	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Type-check extension source and test tree	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Run extension unit/integration tests	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Post Set up Node.js	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Post Check out repository	success
STEP: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	Complete job	success

R3_CI: SUCCESS
