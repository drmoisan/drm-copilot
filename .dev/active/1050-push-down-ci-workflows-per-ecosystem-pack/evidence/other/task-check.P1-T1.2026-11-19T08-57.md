# Task Check P1-T1

Timestamp: 2026-11-19T08-57
Command: sh SCRATCH/issue-1050-p1t1.sh (cp into place; cmp per pair; actionlint over the four harness workflows); env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py tests/scripts/dev_tools/test_host_environment_contracts.py
EXIT_CODE: 0
Output Summary: Eight files created; each bundle copy is byte-identical to its source (cmp, 4 of 4); actionlint 1.7.12 exit 0 with no finding over the four harness workflows; selected pytest 106 passed, 0 failed.

Changed files:
- `.github/workflows/harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, `harness-dotnet.yml` (new)
- `extensions/drm-copilot/resources/ci-workflows/workflows/harness-{python,powershell,typescript,dotnet}.yml` (new, byte copies)

Selection rule: for changed configuration paths, the contract tests that read them; the plan names `test_workflow_npm_token_guard.py` (enumerates every `.github` YAML file) and `test_host_environment_contracts.py` (Node and Poetry workflow pins). Static check for YAML is actionlint (plan D5).

| Step | Command | Exit code | Result |
| --- | --- | --- | --- |
| Byte identity | `cmp` per pair | 0 | 4 identical |
| YAML lint | `actionlint <four harness files>` | 0 | 0 findings |
| Tests | launcher `pytest` with the two test files | 0 | 106 passed |
