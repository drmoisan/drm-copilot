# Preflight Fixes (issue #1187)

Timestamp: 2026-11-14T18-41
Plan: docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187/plan.2026-11-14T13-12.md
Validators after the fixes: branch-current Python CLI `plan` subcommand exit 0; installed MCP `validate_orchestration_artifacts` ok.

## Fix 1 - Design Notes, script-tail tests (changed existing behavior)

- Defect class: task-text ambiguity against AC-15 ("existing suites pass unchanged in assertion").
- Before: the note named the new mock and the added call assertion but did not state whether the two existing script-tail rows keep their exit-code, emitted-count, and `HOOK_DISPATCH_BLOCKED:` assertions.
- Change: the note now states that both rows keep those assertions; only the arrange step changes and one call assertion is added.

## Fix 2 - P1-T4, module cleanup of the new test file

- Defect class: test-isolation clarification (validator-blind; meaning of the acceptance unchanged).
- Before: the new file dot-sources the Claude dispatcher, which imports `HookDispatchRunner` and `HookDispatch`, with no cleanup stated.
- Change: the task text adds an `AfterAll` that removes both modules, as `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1` already does.

## Fix 3 - P2-T1, task-check selection

- Defect class: task-ordering visibility under the test-cadence selection rule (validator-blind).
- Before: the acceptance named a fixed selection; the cadence rule also selects every test file that names the changed dispatcher, which includes `PreToolUseDispatch.Parity.Tests.ps1`, whose P1-T3 row cannot pass until P2-T2 adds the Codex reader.
- Change: the task text states that such files run as well and that the P1-T2 and P1-T3 rows remain expected-fail until P2-T2, listed by name in the task-check evidence.

## Fix 4 - P3-T4, AC-19 verification

- Defect class: acceptance criterion checked off without a stated observation (design check; correction keeps the meaning of AC-19).
- Before: P3-T4 checks off AC-1 to AC-19 "each with its evidence path" but its verification list had no observation for AC-19 (comment-based help of both dispatchers).
- Change: P3-T4 now records that the parsed comment-based help of each canonical dispatcher contains the tokens `UTF-8` and `ASCII`, and that the Claude dispatcher's help contains `per-process`.
