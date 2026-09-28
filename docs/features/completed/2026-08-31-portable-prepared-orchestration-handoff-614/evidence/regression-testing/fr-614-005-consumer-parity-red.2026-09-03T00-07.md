# FR-614-005 Consumer Parity Red Test

Timestamp: 2026-09-03T02-12
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: `2 failed, 21 passed in 0.25s`. Both failures are the missing publication contract: source and bundled orchestration guidance does not require callers to supply independent expected context to the context-bound handoff operations. No generated resource, pack manifest, skill file, or user file was mutated.

## Expected failure signature

The published guidance currently instructs the destination to prove a handoff from the envelope alone. `.claude/skills/orchestrate/SKILL.md` states, in its Prepared-State Portable Handoff Intake section, "Prove the plan using only the envelope's normalized repository-relative path and raw-byte SHA-256." That is the guidance form of FR-614-005: the envelope under validation is named as the source of the values it is validated against. The same section names only `transition_prepared_orchestration` and names none of the ten independent expected-context keys, and `.agents/skills/repo-automation-adapter/SKILL.md` names no context-bound operation at all.

## Observed failing cases (2)

- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_codex_guidance_requires_independent_expected_context`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_orchestrate_requires_independent_expected_context`

Representative diagnostic:

```text
AssertionError: source guidance .claude\skills\orchestrate\SKILL.md does not name the context-bound operation resolve_orchestration_topology
```

The new assertion is shared through the existing `tests/scripts/dev_tools/push_down_handoff_test_support.py` module that both suites already import, and it checks source and bundled copies of each guidance path for all three context-bound operations and all ten independent expected-context keys.

## Environmental failure observed and removed before the recorded run

The first execution of this command additionally reported `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` as failing:

```text
AssertionError: Repo file missing from bundle: .claude\state\current-session-id
```

That failure is not attributable to this change. `.claude/state/` is gitignored at `.gitignore:68`, the file was created by the running Claude session at 07:36 local time, and the P0-T7 baseline captured earlier in this remediation recorded `167 passed` with `EXIT_CODE: 0` for a command set that includes this same suite. The file is runtime-generated local state rather than repository content, so it was removed before the recorded run. Removing it changed no tracked path: `git status --porcelain=v1 --untracked-files=all -- .claude` reports no rows both before and after. This condition can recur whenever the runtime rewrites its session-state file, and it must be re-checked immediately before the P3-T15 integration and parity gate.

## Changed-path boundary

Command: git status --porcelain=v1 --untracked-files=all -- extensions/drm-copilot/resources .agents .claude .codex
EXIT_CODE: 0
Output Summary: No rows. No generated resource, bundled skill, pack manifest, or user file changed during the red run.

## File-size compliance

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is 500 lines and `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` is 416 lines, both within the 500-line limit. The claude suite reached the limit, so its module docstring was reflowed by one line; no assertion or case was removed. The shared assertion body lives in `push_down_handoff_test_support.py` (100 lines), which both suites already used.
