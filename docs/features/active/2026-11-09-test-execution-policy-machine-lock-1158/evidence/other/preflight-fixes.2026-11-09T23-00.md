# Preflight Fixes (round two)

Timestamp: 2026-11-09T23-00
Plan: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md

Each entry is a trivial defect fixed in task text. No task was added, removed, or reordered, and no pass or fail criterion changed. The round-one record `preflight-fixes.2026-11-09T22-35.md` is unchanged.

1. [P3-T1] | ambiguous anchor | "the repository root four levels above the script" could be read as four parents of the file or of its folder; it now reads "the fourth parent directory of `$PSScriptRoot`", which is the repository root for both the `.claude` and the `.agents` script copies.
2. [P2-T2] | missing unchanged-test disposition | `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` asserts both template paths in argv and was not named; it is added to the unchanged list, and the stated reason now covers file existence (`packaging/discovery-resources.test.ts` checks existence only).
3. [P4-T3] | missing updated-test disposition (validator-blind class: changed behavior with an asserting test outside the file set) | `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` pins 26 registered hooks, 21 PreToolUse hooks, and 48 invocations over the bundled `config.toml`; the bundled registration raises these to 27, 22, and 49. The `^Bash$` entry admits the `Bash` candidate, and the new MCP matcher admits none of the candidates (`mcp__drm_copilot__run_poshqc_format` is not one of the two tool names). The task's acceptance (the updated suites pass) is unchanged.
4. [P7-T5] | tool-route reference | the launcher starts `poetry run pytest` as a child process that inherits `VIRTUAL_ENV`; the task now references the brief's `## Worktree Python Environment` section rather than restating the route.

Each fix was checked against the rule it enforces: the fix text contains no line or commit citation, no host path, no restated tool route, and no promotional wording.
