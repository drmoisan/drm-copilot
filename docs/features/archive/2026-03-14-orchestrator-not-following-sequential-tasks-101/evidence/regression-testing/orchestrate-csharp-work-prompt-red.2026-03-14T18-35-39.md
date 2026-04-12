Timestamp: 2026-03-14T18:35:39-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle
EXIT_CODE: 1
Output Summary: EXPECTED RED — the root C# orchestration prompt still omits the required `minor-audit` short-path lifecycle wording.

Failure Excerpt:
AssertionError: assert 'minor-audit' in prompt_text

Pytest Summary:
1 failed, 1 deselected in 0.07s
