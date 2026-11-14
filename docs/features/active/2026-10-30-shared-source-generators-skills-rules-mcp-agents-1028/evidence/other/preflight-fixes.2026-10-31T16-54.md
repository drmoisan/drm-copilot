# Preflight Fixes — Issue 1028 (H3 revision)

Timestamp: 2026-10-31T16-54
Plan: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md

Trivial defects fixed in place, in task text only. No task was added, removed or reordered.

1. [P1-T21] | stale citation | The task said to remove the `AGENTS.md` exemption "and its docstring mention" from `_validate_duplicate_targets` in `scripts/dev_tools/codex_native_converter/validation.py`. That docstring does not mention the exemption. Text now states that no docstring change is needed. The code change and the test dispositions are unchanged.
2. [P1-T15] | literal formatting | The report renders a null target as an empty code span (`renderConversionReport` in `reporting-render.ts`, `_render_conversion_report` in `reporting.py`). "an empty target cell" now reads "an empty code-span target cell". The assertion is unchanged.
3. `## Converter Test Disposition` (Unchanged, Jest) | incomplete citation | Added `cli.test.ts` `builds review options and prints the summary lines`, `writes the destination and returns exit code 0 for a clean plan` and `returns a non-zero exit code when a blocking finding suppresses the write`. Each runs the converter end to end on a seeded skill and none asserts `AGENTS.md`, so each stays unchanged. Also added `codex-native-converter-service-call.test.ts` `honors an explicit artifact root`, and corrected the parenthetical: the seeded skill keeps the apply destination non-empty, and the review-mode tests assert only the result record and the artifact root.

Validation after fixes: `mcp__drm-copilot__validate_orchestration_artifacts` (plan) ok; branch CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` exit 0.
