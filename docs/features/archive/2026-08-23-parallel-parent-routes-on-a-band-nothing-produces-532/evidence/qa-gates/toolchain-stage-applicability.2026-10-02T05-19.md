# Toolchain-Stage Applicability (P7-T11)

Timestamp: 2026-10-02T05-19
Command: grep -c -E "importlinter|import-linter" pyproject.toml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
0 (pyproject.toml configures no import-linter)
- grep -c -E "depcruise|dependency-cruiser|oasdiff" extensions/drm-copilot/package.json exited 1
0 (extensions/drm-copilot/package.json defines no dependency-cruiser or contract-diff script)
Determination: general-code-change stages 4 (architecture-boundary tests) and 6 (contract/schema compatibility checks) have no configured tool for these two packages. Stage 7 (integration tests) is covered by tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py, run in P7-T4 and P7-T5.
