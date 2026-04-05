Timestamp: 2026-03-14T23-58
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py -k test_root_orchestrators_use_direct_potential_entry_commands
EXIT_CODE: 1
Output Summary:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot-wt-20260314-224838
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 1 item

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py F  [100%]

================================== FAILURES ===================================
_________ test_root_orchestrators_use_direct_potential_entry_commands _________

    def test_root_orchestrators_use_direct_potential_entry_commands() -> None:
        """Require root orchestrators to document direct potential-entry command usage."""
        raw_feature_command = "${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1"
        raw_bug_command = "scripts/dev_tools/new_potential_bug_entry.py --short-name"
    
        for relative_path in ROOT_ORCHESTRATOR_AGENT_PATHS:
            agent_text = read_repo_text(relative_path)
    
>           assert "drmCopilotExtension.newPotentialEntry" in agent_text
E           AssertionError: assert 'drmCopilotExtension.newPotentialEntry' in '---\nname: orchestrator\nmodel: GPT-5.4 (copilot)\ndescription: Orchestrate end-to-end feature/bug delivery by estima...forms.\n- Skipping feature review in large path.\n- Claiming completion without checkpoint update and final summary.\n'

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py:29: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_potential_entry_commands
============================== 1 failed in 0.07s ==============================
