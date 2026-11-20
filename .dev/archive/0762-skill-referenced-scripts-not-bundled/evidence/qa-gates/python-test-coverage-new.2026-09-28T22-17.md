# Python Test with Coverage, New Modules (P9-T4)

Timestamp: 2026-09-28T22-17
Command: poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov=scripts.dev_tools.skill_bundle_contract_cli --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-762-new.json ; poetry run python SCRATCH/py-cov-files.py SCRATCH/cov-762-new.json scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py
EXIT_CODE: 0
Output Summary:
- `collected 42 items`; `42 passed in 0.57s`; no FAILED line. Collected node count: 42.
- Final accepted run, after the loop restarts recorded in `python-format.2026-09-28T22-17.md` and `line-counts-final.2026-09-28T22-17.md`.
- term-missing rows:
  - `scripts\dev_tools\skill_bundle_contract.py         141      5     60      3    96%   109, 225, 254-255, 263`
  - `scripts\dev_tools\skill_bundle_contract_cli.py      57      4     22      5    89%   59, 96, 127, 129, 138->140`
  - `TOTAL                                              198      9     82      8    94%`
- A7:
  - `COVERAGE file=scripts/dev_tools/skill_bundle_contract.py LinePercent=96.45 BranchPercent=95.00`
  - `COVERAGE file=scripts/dev_tools/skill_bundle_contract_cli.py LinePercent=92.98 BranchPercent=77.27`
- New-code coverage: both modules meet line >= 85 and branch >= 75.
