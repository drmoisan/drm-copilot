# r2 P8-T13 shell syntax, WORKFLOW static checks, and shell-QC route

Timestamp: 2026-10-03T16-39
Command: step script SCRATCH/steps/r2-p8-t13.ps1: SH-CHECK on both setup copies; YAML-CHECK(r2-yaml-final.log); ACTIONLINT-RUN(r2-actionlint-final.log); ACTIONLINT-NEW-MESSAGES against RECORDED P0-T24 messages (empty); VERDICT
EXIT_CODE: 0
Output Summary:
- .codex/codex-web-setup.sh SYNTAX-EXIT=0; bundle copy SYNTAX-EXIT=0; SYNTAX-EXIT=0
- YAML-EXIT=0; YAML-STEPS=11; YAML-STEP-COUNT=11
- YAML-NAMES=Check out repository|Install shell tooling (shellcheck, shfmt, bats)|Cache kcov build|Build kcov from source|Install kcov from cache|Run shell-qc check (shfmt diff + shellcheck)|Run shell-qc test with coverage|Upload shell coverage artifacts|Measure .codex/codex-web-setup.sh coverage with kcov (issue 824)|Upload .codex/codex-web-setup.sh coverage artifacts (issue 824)|Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)
- ACTIONLINT-EXIT=0 (actionlint on PATH; no finding; shellcheck and pyflakes integrations disabled); ACTIONLINT-NEW-MESSAGES=0
- Shell format (shfmt) and lint (shellcheck): N/A locally - .codex/ and .bats files are outside the shell-QC discovery roots (.claude/rules/shell.md Discovery Contract)
- Shell tests (bats): CI-dependent - shell-coverage / Shell Coverage (Bats + kcov) runs tests/shell on the PR head
- Shell coverage (kcov) for .codex/codex-web-setup.sh: CI - Measure and Gate steps of shell-coverage / Shell Coverage (Bats + kcov) on the PR head (D13)
