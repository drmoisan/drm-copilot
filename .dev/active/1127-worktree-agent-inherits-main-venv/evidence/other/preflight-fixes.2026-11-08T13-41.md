# Preflight Fixes (issue #1127)

Timestamp: 2026-11-08T13-41
Plan: docs/features/active/2026-11-08-worktree-agent-inherits-main-venv-1127/plan.2026-11-08T08-08.md
Validator: `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>` passed before and after the fixes; installed MCP validator passed.

## Fixes

1. [P1-T1] Unsatisfiable acceptance from test-file structure. The test file dot-sourced only the hook, so the P2-T1 helper `It` blocks could not pass before the hook exists (P2-T2). The task text now dot-sources the helper in the helper-function `Describe` and the hook in the decision `Describe`. The asserted values are unchanged.
2. [P1-T2] Wording. "three new test files" named the shared case file as a test file; the text now names the two new `*.Tests.ps1` files.
3. [P3-T1] Literal command. `env -u VIRTUAL_ENV poetry sync` replaced with `env -u VIRTUAL_ENV poetry install`, the command AC20 in `spec.md` names. The asserted outcome (`cmp` exit 0, environment path in the item worktree) is unchanged.
4. [P2-T5] Anchor wording. "in sorted position" applies to the Claude core manifest; the Codex core manifest is not sorted, so the Codex entries go directly after `.codex/hooks/enforce-promotion-mcp-only.ps1`.
5. [P2-T4] Dispositions. The B4 tests are unchanged, and only their tables gain a row. The discovery-based suites `PreToolUsePayload.Contract.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1` are now named with disposition "unchanged", together with the requirement each places on the new hook.
