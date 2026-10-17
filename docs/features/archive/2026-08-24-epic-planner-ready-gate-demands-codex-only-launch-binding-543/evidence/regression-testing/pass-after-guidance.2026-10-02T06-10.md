# Pass-after: guidance flags and Pester contracts (issue #543)

Timestamp: 2026-10-02T05-33
Timestamp-Correction: original value 2026-10-02T06-10 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.
Task: P6-T9
Command:
1. `poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_epic_planner_ready_gate_guidance_passes_both_codex_flags" -v`
2. `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = this worktree and `scan_folders: ["tests/scripts/codex-hooks"]`, then `poetry run python <scratchpad>/read_pester_junit.py` over `artifacts/pester/pester-junit.xml`
Route: native for command 1; poshqc-mcp (D3) for command 2 (replaces the plan's `Route: sh-pwsh`)
EXIT_CODE: 0

Output Summary:
- pytest: `1 passed in 0.08s` (exit 0). Paired fail-before run: `evidence/regression-testing/fail-before-guidance.2026-10-02T06-05.md`.
- Pester (JUnit file freshly written, mtime 9 s before the read): matching `testsuite` `codex-epic-runtime-contracts.Tests.ps1` `tests="10" failures="0" errors="0" skipped="0"`; PassedCount = 10 (equal to the P0-T17 baseline of 10); FailedCount = 0.
- Testcase `keeps root and tracked bundle runtime copies byte-identical`: `status="Passed"` (D3 equivalent of the `[+]` line).
- Supporting task observations (Route: native (D3)):
  - P6-T3: `.agents/skills/epic-plan/SKILL.md` counts `require_codex_model_routing: true` = 1, `require_codex_topology: true` = 1; `git diff --stat` 1 file, 2 insertions, 1 deletion.
  - P6-T4: `sha256sum` root and bundle `epic-plan/SKILL.md` both `6e1752a9ce28f5ecd6944a561bd6d60cda3f238eba8b526abec1434c95ea20b8` (copied with `cp`).
  - P6-T5: `.agents/skills/epic-run/SKILL.md` counts 1 and 1.
  - P6-T6: `sha256sum` root and bundle `epic-run/SKILL.md` both `12b8a82cd4a064bd40c6450df2454ceba61de98eff30dca7c5072a15e0c04085`.
  - P6-T7: `.codex/agents/epic-orchestrator.toml` counts `require_codex_topology: true` = 2 (lines 43, 82) and `require_codex_model_routing: true` = 2 (lines 44, 83); file 97 lines. The existing `epic-orchestrator-state` completion-gate lines (planning-time 81-82) moved to 82-83 because of the one inserted line and are textually unchanged.
  - P6-T8: `sha256sum` root and bundle `epic-orchestrator.toml` both `8d62f9a06f089acfb29db66a3bb07129420b86fe9c9ebe6dd4ad6c37671cf928`.
