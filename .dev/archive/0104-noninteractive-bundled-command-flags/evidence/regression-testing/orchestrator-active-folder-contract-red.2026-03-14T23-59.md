Timestamp: 2026-03-14T23-59
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py -k test_root_orchestrators_use_direct_new_active_feature_folder_commands
EXIT_CODE: 1
Output Summary:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot-wt-20260314-224838
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 3 items / 2 deselected / 1 selected

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py F  [100%]

================================== FAILURES ===================================
____ test_root_orchestrators_use_direct_new_active_feature_folder_commands ____

    def test_root_orchestrators_use_direct_new_active_feature_folder_commands() -> None:
        """Require root orchestrators to document direct active-folder command usage."""
        raw_active_folder_command = "python -m scripts.dev_tools.new_active_feature_folder"
    
        for relative_path in ROOT_ORCHESTRATOR_AGENT_PATHS:
            agent_text = read_repo_text(relative_path)
    
>           assert "drmCopilotExtension.newActiveFeatureFolder" in agent_text
E           AssertionError: assert 'drmCopilotExtension.newActiveFeatureFolder' in '---\nname: orchestrator\nmodel: GPT-5.4 (copilot)\ndescription: Orchestrate end-to-end feature/bug delivery by estima...forms.\n- Skipping feature review in large path.\n- Claiming completion without checkpoint update and final summary.\n'

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py:56: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_new_active_feature_folder_commands
======================= 1 failed, 2 deselected in 0.09s =======================
