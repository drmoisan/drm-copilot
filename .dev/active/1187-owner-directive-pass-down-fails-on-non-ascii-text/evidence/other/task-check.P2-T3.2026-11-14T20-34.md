# Task Check P2-T3

Timestamp: 2026-11-14T20-32
Changed files: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/invoke-pretooluse-dispatch.ps1, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/invoke-pretooluse-dispatch.ps1 (byte copies of the two canonical dispatchers).
Selection rule: the contract tests that read the bundle copies (the three push-down contract files the task names) and the Codex bundle hook probe suite.

Command: cp of each canonical dispatcher to its bundle path; sha256sum of the four files
EXIT_CODE: 0
Output Summary:
- .claude/hooks/invoke-pretooluse-dispatch.ps1 and its claude-customizations copy: 1e51663518d5550e4fdf0cdfc70eaf31bd5d9c433791d3e2879dfd7e6f8451c0 (equal).
- .codex/hooks/invoke-pretooluse-dispatch.ps1 and its codex-and-agents-customizations copy: 2bb17ae770dd3604ae2f2f60e8d51479ae36bf8d06d7bee0fd95e7bb343f56e6 (equal).
- git ls-files lists exactly these four dispatcher copies.

Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py
EXIT_CODE: 0
Output Summary: 41 passed in 3.23s, 0 failed.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
EXIT_CODE: 0
Output Summary: merged JUnit of this run: tests=3, failures=0, errors=0.
