# P8-T18 No Python 3.11+ API Use (pass 2, expect-fail search)

Timestamp: 2026-10-02T03-41
Command: git grep -n -E "tomllib|typing import .*Self|ExceptionGroup|except\*|StrEnum|datetime\.UTC" -- scripts/dev_tools/quality_tiers_contract.py scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No match in any of the four new files.
