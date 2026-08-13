# Modern-Profile Invariant Baseline (Issue #469)

Timestamp: 2026-08-13T17-28

Command:
```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_modern_csharp_profile_retains_modern_gate_commands
```

EXIT_CODE: 0

Output Summary: **1 passed** (0.04s). The modern/default Claude C# profile invariant holds before the Phase 2 fix, which establishes that the test is a baseline pin rather than a regression artifact. The test asserts that `.claude/rules/csharp.md` and `.claude/skills/csharp-qa-gate/SKILL.md` each contain `dotnet csharpier check .` and `dotnet build` and contain neither `msbuild` nor `/t:Rebuild`. Coverage was disabled for this targeted run (`--no-cov`).
