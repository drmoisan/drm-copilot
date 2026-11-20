Timestamp: 2026-03-15T00-00
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py -k test_mirrored_orchestrator_agents_match_root_direct_command_contracts
EXIT_CODE: 1
Output Summary:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot-wt-20260314-224838
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 4 items / 3 deselected / 1 selected

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py F  [100%]

================================== FAILURES ===================================
____ test_mirrored_orchestrator_agents_match_root_direct_command_contracts ____

    def test_mirrored_orchestrator_agents_match_root_direct_command_contracts() -> None:
        """Require mirrored orchestrator docs to match root direct-command contracts exactly."""
        for root_relative_path, mirror_relative_path in zip(
            ROOT_ORCHESTRATOR_AGENT_PATHS,
            MIRRORED_ORCHESTRATOR_AGENT_PATHS,
            strict=True,
        ):
            root_text = read_repo_text(root_relative_path)
            mirror_text = read_repo_text(mirror_relative_path)
    
>           assert "drmCopilotExtension.newPotentialEntry" in root_text
E           AssertionError: assert 'drmCopilotExtension.newPotentialEntry' in '---\nname: orchestrator\nmodel: GPT-5.4 (copilot)\ndescription: Orchestrate end-to-end feature/bug delivery by estima...forms.\n- Skipping feature review in large path.\n- Claiming completion without checkpoint update and final summary.\n'

tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py:79: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_mirrored_orchestrator_agents_match_root_direct_command_contracts
======================= 1 failed, 3 deselected in 0.08s =======================
