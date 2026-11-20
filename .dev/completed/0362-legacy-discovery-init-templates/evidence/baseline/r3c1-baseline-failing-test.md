# Baseline Failing Test — r3c1-baseline-failing-test.md

Timestamp: 2026-07-18T18-20

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v

EXIT_CODE: 1

## Output Summary

Test FAILED with AssertionError: "Repo file missing from bundle: .claude\agents\legacy-parity-analyst.md"

The test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` requires all repo-root `.claude/` runtime files (excluding `.claude/agent-memory/` and `.claude/settings.local.json`) to be present in the bundled extension resources at `extensions/drm-copilot/resources/claude-customizations/.claude/`.

At minimum, the following files are missing from the bundle:
- `.claude/agents/legacy-parity-analyst.md`

## Full Output

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-17T10-10\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 1 item

tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts FAILED [100%]

================================== FAILURES ===================================
_______ test_bundled_claude_payload_contains_all_repo_runtime_contracts _______

    def test_bundled_claude_payload_contains_all_repo_runtime_contracts() -> None:
        """Require every non-memory repo `.claude` file to exist in the bundle.
    
        Excludes settings.local.json and the `.claude/agent-memory/**` subtree.
        Agent memories are distributed by scope (general memories live in the
        bundle but not at the gitignored root), so they are not subject to the
        byte-identical mirror assertion.
        """
    
        bundled_files = list_scoped_files(BUNDLED_ROOT)
        # Enumerate repo .claude files, excluding the local-only settings file and
        # the scope-filtered agent-memory subtree.
        repo_runtime_files = [
            f
            for f in list_scoped_files(REPO_ROOT)
            if f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)
        ]
    
        for relative_path in repo_runtime_files:
>           assert (
                relative_path in bundled_files
            ), f"Repo file missing from bundle: {relative_path}"
E           AssertionError: Repo file missing from bundle: .claude\agents\legacy-parity-analyst.md
E           assert WindowsPath('.claude/agents/legacy-parity-analyst.md') in [WindowsPath('.claude/agent-memory/orchestrator/feedback_branch_base_check_unmerged_pr_deps.md'), ...]

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:119: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
============================== 1 failed in 0.09s
```
