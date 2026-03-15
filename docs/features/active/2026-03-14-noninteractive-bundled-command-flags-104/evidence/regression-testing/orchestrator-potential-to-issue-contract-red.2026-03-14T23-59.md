Timestamp: 2026-03-14T23-59
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py -k test_root_orchestrators_use_direct_potential_to_issue_commands_with_explicit_work_mode
EXIT_CODE: 1
Output Summary:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot-wt-20260314-224838
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 2 items / 1 deselected / 1 selected

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py F  [100%]

================================== FAILURES ===================================
_ test_root_orchestrators_use_direct_potential_to_issue_commands_with_explicit_work_mode _

    def test_root_orchestrators_use_direct_potential_to_issue_commands_with_explicit_work_mode() -> None:
        """Require root orchestrators to document direct promotion commands with explicit work modes."""
        raw_promotion_command = "python -m scripts.dev_tools.potential_to_issue"
    
        for relative_path in ROOT_ORCHESTRATOR_AGENT_PATHS:
            agent_text = read_repo_text(relative_path)
    
>           assert "drmCopilotExtension.potentialToIssue" in agent_text
E           AssertionError: assert 'drmCopilotExtension.potentialToIssue' in '---\nname: orchestrator\nmodel: GPT-5.4 (copilot)\ndescription: Orchestrate end-to-end feature/bug delivery by estima...forms.\n- Skipping feature review in large path.\n- Claiming completion without checkpoint update and final summary.\n'

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py:42: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_potential_to_issue_commands_with_explicit_work_mode
======================= 1 failed, 1 deselected in 0.06s =======================
