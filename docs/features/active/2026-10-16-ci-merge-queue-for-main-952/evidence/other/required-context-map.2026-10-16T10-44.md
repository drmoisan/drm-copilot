# Required-Context Mapping (P1-T6, AC-3)

Timestamp: 2026-10-16T10-44
Command: git grep -n -e "uses:" -- .github/workflows/ci.yml
EXIT_CODE: 0
Command: git grep -n -e "name:" -- .github/workflows/_quality-checks.yml .github/workflows/_security-scan.yml .github/workflows/_docs-validation.yml .github/workflows/_build-check.yml .github/workflows/_poshqc.yml .github/workflows/_shell-coverage.yml .github/workflows/_drm-copilot-extension-tests.yml .github/workflows/_root-typescript-tests.yml .github/workflows/_npm-audit-gate.yml
EXIT_CODE: 0
Output Summary: UNMAPPED=0; CI_TRIGGERS_MERGE_GROUP=true (ci.yml:9 `merge_group:`, ci.yml:10 `types: [checks_requested]`, P1-T3)

Derivation: the eleven `context` values were read from docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json (:47, :51, :55, :59, :63, :67, :71, :75, :79, :83, :87), split at ` / ` into the caller job id and the job display name, and located in the two outputs. Line numbers for ci.yml are after the P1-T3 insertion (two lines added after :8). Caller job id lines were confirmed with a read of ci.yml; matrix values were read from the reusable workflow `matrix:` blocks.

| # | Snapshot context (line) | ci.yml caller job id (line) | ci.yml uses: line | Reusable workflow | Job `name:` line | Matrix value |
|---|---|---|---|---|---|---|
| 1 | drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) (:47) | drm-copilot-extension-tests (:31) | :32 | .github/workflows/_drm-copilot-extension-tests.yml | :9 `name: drm-copilot Extension Tests (${{ matrix.os }})` | os=ubuntu-latest (:13) |
| 2 | drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) (:51) | drm-copilot-extension-tests (:31) | :32 | .github/workflows/_drm-copilot-extension-tests.yml | :9 `name: drm-copilot Extension Tests (${{ matrix.os }})` | os=windows-latest (:13) |
| 3 | docs-validation / Documentation Validation (:55) | docs-validation (:19) | :20 | .github/workflows/_docs-validation.yml | :9 `name: Documentation Validation` | none |
| 4 | poshqc / PowerShell QC (:59) | poshqc (:25) | :26 | .github/workflows/_poshqc.yml | :9 `name: PowerShell QC` | none |
| 5 | shell-coverage / Shell Coverage (Bats + kcov) (:63) | shell-coverage (:28) | :29 | .github/workflows/_shell-coverage.yml | :9 `name: Shell Coverage (Bats + kcov)` | none |
| 6 | security-scan / Security Scanning (:67) | security-scan (:16) | :17 | .github/workflows/_security-scan.yml | :9 `name: Security Scanning` | none |
| 7 | quality-checks7 / Code Quality & Tests (3.10) (:71) | quality-checks7 (:13) | :14 | .github/workflows/_quality-checks.yml | :9 `name: Code Quality & Tests` | python-version=3.10 (:13) |
| 8 | quality-checks7 / Code Quality & Tests (3.11) (:75) | quality-checks7 (:13) | :14 | .github/workflows/_quality-checks.yml | :9 `name: Code Quality & Tests` | python-version=3.11 (:13) |
| 9 | quality-checks7 / Code Quality & Tests (3.12) (:79) | quality-checks7 (:13) | :14 | .github/workflows/_quality-checks.yml | :9 `name: Code Quality & Tests` | python-version=3.12 (:13) |
| 10 | quality-checks7 / Code Quality & Tests (3.13) (:83) | quality-checks7 (:13) | :14 | .github/workflows/_quality-checks.yml | :9 `name: Code Quality & Tests` | python-version=3.13 (:13) |
| 11 | build-check / Build Package (:87) | build-check (:22) | :23 | .github/workflows/_build-check.yml | :9 `name: Build Package` | none |

Note on rows 7 to 10: the `quality-checks` job name carries no `${{ matrix.python-version }}` suffix in its `name:` line; GitHub appends the matrix value in parentheses to the check-run name when the job name does not reference the matrix, which yields `Code Quality & Tests (3.10)` and the three sibling contexts.

UNMAPPED=0
CI_TRIGGERS_MERGE_GROUP=true

Because every required context is produced by a job of a reusable workflow called from ci.yml, and ci.yml now declares `merge_group` with no filter, every required context is produced by a `merge_group` run of ci.yml (AC-3).
