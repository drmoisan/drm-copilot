# Preflight Fixes (final preflight, after the planner revision of the four round-3 defects)

Timestamp: 2026-11-09T23-13
Plan: docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/plan.2026-11-09T16-31.md

Earlier records `preflight-fixes.2026-11-09T22-20.md`, `preflight-fixes.2026-11-09T22-35.md` and `preflight-fixes.2026-11-09T23-00.md` are unchanged.

## Round-3 defects verified resolved

1. [P2-T2]/[P2-T3] and spec Main flow step 4 / D2: the runners redirect `[Console]::SetOut` per hook, merge that text into captured stdout, restore it in `finally`, and both test files name the four `It` blocks (Console.Out capture, no-exit maps to 0, terminating error non-blocking, restore after a throw).
2. [P5-T2]: `It` `ships both registries with isolation set to in-process` asserts `in-process` in both registries.
3. [P7-T1]: derived sets (a) and (b) are recomputed on the merged tree, with content-changed members treated as unhandled and given the [P3-T2] and [P0-T11]/[P1-T2] procedures.
4. [P7-T1]: the integration record lists envelope keys or a reason per arrived registry hook, and the acceptance condition limits the skipped `has parity envelopes for <hook leaf>` names to those with a recorded reason.

## Fixes

1. [P4-T1] | stale anchor (intent unambiguous) | The task re-targeted "both registration `It` blocks" of `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1` "to the Claude registry", but one of the two blocks is `registers the Codex hook in the ^Bash$ group of .codex/config.toml`. The text now names both blocks: the Claude block reads the Claude registry and the Codex block reads the Codex registry. The assertion intent is unchanged.
2. [P4-T2] | missing asserting-test disposition | `S7: discovers hooks from .claude/settings.json and .codex/config.toml` in `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` asserts the exact output of `Get-HookRegistration` over a synthetic reader that returns `$null` for unlisted paths. The task now states that a registry read as `$null` adds no entry, so S7 is unchanged and unaffected. No assertion changes.
3. [P2-T4] and [P2-T5] | implicit input made explicit | [P5-T2] `It` `loads each stateless shared module once per call` counts module loads from the `-PerHookTrace` output, but the trace content did not name module loads. Both tasks now state that each per-hook trace record carries the modules loaded or re-loaded while that hook ran. The design (trace written to stderr, consumed by the parity suite) and every acceptance condition are unchanged.

## Validation

- `mcp__drm-copilot__validate_orchestration_artifacts` (plan): ok.
- `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>`: `plan validation passed`, EXIT_CODE 0.
