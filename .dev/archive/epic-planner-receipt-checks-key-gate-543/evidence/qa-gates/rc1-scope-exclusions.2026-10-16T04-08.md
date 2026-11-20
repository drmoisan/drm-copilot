# Remediation Cycle 1 Scope Exclusions (P4-T5)

Timestamp: 2026-10-16T04-08
Command: git rev-parse main; git diff main -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py; git diff 7c5b6fd1619829554705dd113f5371771bf8b1a1 -- <the twenty neighbour, existing-test, spec.md, and plan.2026-10-15T07-42.md paths listed in P4-T5>; git status --porcelain
EXIT_CODE: 0
Output Summary:
- Anchor: main (git rev-parse main = adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99, equal to MAIN_BASE_SHA)
- CYCLE_BASE_SHA substituted as 7c5b6fd1619829554705dd113f5371771bf8b1a1
- First diff (spec AC13 paths against main): no output, exit 0
- Second diff (neighbours, existing tests, spec.md, prior plan against CYCLE_BASE_SHA): no output, exit 0
- Porcelain output (only feature-folder paths):
   M docs/features/active/epic-planner-receipt-checks-key-gate-543/remediation-plan.2026-10-16T01-36.md
  ?? docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/rc1-byte-identical-strings.2026-10-16T04-07.md
