# Python Test With Coverage (P9-T5)

Timestamp: 2026-09-29T19-13
Command: poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov=scripts.dev_tools.skill_bundle_contract_cli --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-763-final.json ; poetry run python SCRATCH/py-cov-files.py SCRATCH/cov-763-final.json scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py ; poetry run python SCRATCH/changed-lines-cov.py SCRATCH/cov-763-final.json 12db46245ba7683b5d6ccb676312a4b22a39b0ce scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py
EXIT_CODE: 0
Output Summary:
- pytest: `43 passed in 0.98s`; no FAILED line;
  `test_skill_bundle_contract_cli.py::test_main_returns_one_for_stale_exception PASSED` (the
  stale-exception branch is executed through the injected registry).
- term-missing rows:
  - `scripts\dev_tools\skill_bundle_contract.py         141      5     60      3    96%   109, 216, 245-246, 254`
  - `scripts\dev_tools\skill_bundle_contract_cli.py      58      4     22      5    89%   62, 99, 130, 132, 141->143`
  - `TOTAL                                              199      9     82      8    94%`
- A7:
  - `COVERAGE file=scripts/dev_tools/skill_bundle_contract.py LinePercent=96.45 BranchPercent=95.00`
    (line >= 85, branch >= 75, line >= P0-T15 value 96.45)
  - `COVERAGE file=scripts/dev_tools/skill_bundle_contract_cli.py LinePercent=93.10 BranchPercent=77.27`
    (line >= 85, branch >= 75, line >= P0-T15 value 92.98)
- Loop pass 4 (after the SKILL wording fix `0e41ad84`, see qa-gates/python-regression): the same
  command produced `43 passed in 0.85s`, the same term-missing rows, the same A7 lines, and the same
  A19 lines as below; the recorded values are the pass-4 values.
- A19 (changed lines against BASE_SHA):
  - `CHANGED file=scripts/dev_tools/skill_bundle_contract.py ChangedLines=5 ChangedExecutableLines=1 UncoveredChangedLines=0 Uncovered=[]`
  - `CHANGED file=scripts/dev_tools/skill_bundle_contract_cli.py ChangedLines=13 ChangedExecutableLines=1 UncoveredChangedLines=0 Uncovered=[]`
