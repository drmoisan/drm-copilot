# Preflight Fixes

Timestamp: 2026-11-07T03-45
Plan: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/remediation-plan.2026-11-07T03-22.md

All fixes are task text or plan preamble. No task was added, removed, or reordered, and no asserted value changed.

## Fixes

1. Plan metadata, `Remediation-Mode`. Stale value. The plan said `proportionate`; `remediation-inputs.2026-11-07T03-22.md`, which owns the mode, says `design`. The plan now says `design`.
2. `## Execution Rules`, new **Working directory** rule. Validator-blind environment fact. The Bash working directory resets to the main checkout, so an unqualified `npm ci` would replace that checkout's `node_modules`, and the generator, whose root is derived from its own file, would write that checkout's files. The rule requires a launcher to change into the item worktree first.
3. [P0-T3]. Same class. The task now states that both installs run from the item worktree root and that the step stops before the first `npm` command otherwise.
4. [P1-T1]. Command spelling. The generator is now named in module form, `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`, matching P2-T3 and the execution-environment brief. The script's absolute `scripts.dev_tools` imports need that form.
5. [P1-T6]. Assertion precision, same meaning. The second case now states that both variants start from the first case's text. A scratch probe of the validator pattern showed that a retained `Change: +2%` part is accepted by the `Baseline:` search, so the rejection would not appear.
6. [P2-T5]. Validator-blind platform fact. The `lcov.info` record lookup now normalizes path separators, because `SF` records use backslashes on Windows.

## Validation

- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan` on the plan: exit 0 before and after the fixes, no gate warning.
- `mcp__drm-copilot__validate_orchestration_artifacts`, artifact type `plan`: passed before the fixes.
