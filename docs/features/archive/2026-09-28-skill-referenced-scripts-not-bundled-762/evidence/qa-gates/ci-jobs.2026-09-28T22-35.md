# CI Jobs (P10-T4)

Timestamp: 2026-09-28T22-35
Command: gh run view 36513322997 --json jobs
EXIT_CODE: 0
Output Summary: Run 36513322997 (workflow_dispatch, FINAL_SHA 670577f2e94f1d6d50bcf390bc010090bdf73996). The jobs required by P10-T4 all concluded `success`:
- `shell-coverage / Shell Coverage (Bats + kcov)` (from `_shell-coverage.yml`): success
- `poshqc / PowerShell QC` (from `_poshqc.yml`): success
- `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, `(3.13)` (from `_quality-checks.yml`, which runs `poetry run pytest --cov --cov-branch` over `tests/`): success on all four Python versions

The guard runs in the CI Python stage (AC6 observation). The 3.12 job log contains
`tests/scripts/dev_tools/test_skill_bundle_contract_repo.py .....` and the summary `5340 passed, 6 skipped in 98.92s`.
In CI the KL-510 local state file is absent, so no test failed.

Other jobs, for information: the three `NPM Audit Gate` jobs failed on the unrelated `ip-address` advisories recorded in `ci-dispatch.2026-09-28T22-17.md`. The remaining jobs (build-check, security-scan, docs-validation, root-typescript-tests x2, drm-copilot-extension-tests x2) concluded success.
